# Архитектура инфраструктуры

Живой документ. Описывает инфру слой за слоем — от bootstrap до приложений, плюс storage, бэкапы и порядок развёртывания с нуля. Дополняется по мере роста.

## Принципы

- **Слоистая модель**: каждый слой зависит только от нижних, разворачивается снизу вверх.
- **Отдельный Terraform-стейт на слой** (`terraform/live/<site>/{bootstrap,base,database,clusters}/`), верхние читают выходы нижних через `terraform_remote_state`.
- **Terraform = инфра** (создать VM/LXC), **Ansible = конфиг** (что внутри; конфиги в `templates/`, не `files/`).
- **GitOps (ArgoCD)** — для k8s-приложений (pull из git).
- **Размещение**: stateless/эфемерное → k8s; тяжёлое stateful → VM/LXC (data gravity).
- **Критерий выбора** — «оптимальное, а не максимальное» (Longhorn не Ceph, PowerDNS не anycast-BIND).
- **Дно стека самодостаточно**: bootstrap-сервисы не зависят от себя (DNS по статическому IP, Nexus с прямым upstream).
- **Меньше движущихся частей**: если один компонент закрывает несколько потребностей — лишние убираем (см. Longhorn ниже).

## Слои (снизу вверх)

### Layer 0 — Bootstrap (VM/LXC)
Фундамент, от которого зависят все. Прямой upstream-доступ / golden image (в обход Nexus).
- **DNS — PowerDNS**: split-horizon (внутренний = всё; публичный Cloudflare = только публичное). Authoritative + recursor. HA из 2 узлов (AXFR). Домен `cosmdandy.dev`. Реальный домен → валидный TLS внутренним сервисам (DNS-01).
- **Nexus**: registry + pull-through cache (apt/pip/helm/docker). Заменяет mirror `10.0.1.50`.

### Layer 1 — Base (VM/LXC)
- **SeaweedFS** — S3-совместимое хранилище (вместо MinIO — он archived фев 2026). **Один инстанс, только под бэкапы** (Longhorn backup target + Databasus). Горячий S3 не нужен (filestore на Longhorn). ZFS RAIDZ + Object Lock (immutable бэкапы) + offsite.
- **GitLab** — Omnibus на VM (git + CI/CD). Перенос: `gitlab-backup` + `gitlab-secrets.json` + `gitlab.rb`, restore на той же версии.
- **Authentik** — SSO (compute в k8s, Postgres на VM, Redis в k8s). Break-glass-аккаунты в обход SSO для Proxmox/критичных сервисов.
- **Traefik** — reverse-proxy для VM-сервисов (TLS/ACME, file-provider: роль сервиса несёт свой маршрут).
- **Databasus** — бэкап Postgres (PITR), см. раздел Backup.

### Layer 2 — Database (VM)
- **PostgreSQL** на VM. Сейчас Odoo 13 / PG12 (за EOL — в roadmap апгрейд), переход на Odoo 19 / новый PG.
- **Redis** (эфемерный) — в k8s. Для сессий Odoo (на будущее, при репликах) и кэша.

### Layer 3 — Kubernetes (Talos на VM)
Кластеры: `talos-k8s-3c-3w` (3 CP + 3 worker, рабочий), `talos-k8s-5c-6w`. k8s-ноды — только VM.
- **CNI: Cilium + Gateway API** (HTTPRoute, не Ingress). KubePrism, kube-proxy отключён. GatewayClass `cilium` подаётся декларативно.
- **Storage: Longhorn** — data-диски на worker (`/dev/sdb` → `/var/lib/longhorn`), replicaCount=2. Закрывает filestore + репликацию + бэкап (см. Storage).
- **LB: MetalLB** (пул `10.0.1.200-220`).
- **GitOps: ArgoCD** (App-of-Apps; ставится вручную helm'ом с `argocd-values.yaml` — единственный bootstrap-шаг в k8s; redis уведён на docker.io).
- **Платформенный слой** (через ArgoCD): Sealed Secrets, cert-manager, external-dns, metrics-server, gitlab-runner. Пробелы: Velero (backup), Kyverno (policy), observability (отложена).
- **GitLab Runners** — эфемерные поды (k8s executor), не VM.

### Apps
- Workload через ArgoCD: Odoo, Superset, homepage… — папками в `gitops/`, не отдельными репо (готовые продукты ≠ разрабатываемый код).
- **Odoo** (переход Nomad → k8s): stateless Deployment + образ (всё запечено, без git-clone-скриптов). Состояние снаружи: filestore → Longhorn PVC, сессии → Longhorn PVC (весь `/var/lib/odoo`) или Redis. Деплой = пересоздание пода, PVC не трогается. Миграции БД (`-u`) — отдельным Job, не в runtime-репликах.

## Storage

`★ Longhorn заменил три вещи: горячий S3, NFS и Restic для filestore.`

- **filestore (Odoo)** → **Longhorn PVC** (RWO пока без реплик; RWX при репликах). `reclaimPolicy: Retain`. Том живёт независимо от пода — деплой не теряет данные. Убирает прежний NFS-SPOF (Longhorn реплицирует на 2 ноды).
- **S3 (SeaweedFS)** → только под бэкапы (один инстанс). Второй (горячий filestore S3) не нужен.
- **k8s-PV приложений** → Longhorn.
- Горячее vs холодное: Longhorn (горячее, SSD/data-диски worker) ≠ SeaweedFS (холодные бэкапы, HDD, immutable, offsite).

## Backup & Restore

Принцип: **реплики ≠ бэкап**. Инструмент следует за тем, где данные.

| Что | Где | Инструмент |
|-----|-----|------------|
| **БД (Postgres)** | VM | **Databasus** — PITR (physical base + WAL), tiered/GFS retention |
| **filestore** | Longhorn PVC (k8s) | **Longhorn native backup** (snapshot + incremental) → SeaweedFS, RecurringJob в git |
| **k8s-ресурсы** | k8s | Velero (отложен) → SeaweedFS |
| **VM целиком** | Proxmox | Proxmox Backup Server (image-level, отдельное железо) |

- **Databasus**: tiered/GFS — свежее окно (prod 2 нед / stage,dev 1 нед) physical base + WAL (PITR на любую секунду); старое — daily logical (сжатый) с прореживанием daily→weekly→monthly. На PG12 — без incremental (требует PG17); включится на Odoo 19/PG17. Экономия vs текущий pg_dump 4-6×/день (~5.5 ТБ): ~75% места + RPO из часов в секунды.
- **Restic — убран** (filestore переехал на Longhorn). Держать только если останутся файлы на VM вне k8s/БД.
- Всё в SeaweedFS (бэкап-S3) + offsite (3-2-1). Object Lock = immutable (anti-ransomware).

### ⚠️ Известная проблема: консистентность filestore ↔ БД
БД (Databasus PITR) и filestore (Longhorn snapshot) бэкапятся **разными системами**, разными расписаниями — точная синхронность не гарантируется (как и раньше с NFS). Смягчается тем, что Odoo filestore append-only. Restore: БД на момент T + ближайший Longhorn-снапшот filestore ≥ T. Не решено полностью — допустим небольшой рассинхрон вложений.

## Секреты

- **Sealed Secrets** — статические секреты, зашифрованы в git (kubeseal шифрует публичным ключом, контроллер расшифровывает приватным). Замена «секретов в GitLab CI variables», безопаснее.
- **Vault/ESO — отложены** (нужны при dynamic secrets / PKI; у нас секреты статические).
- **VM-секреты** — `ansible-vault` / GitLab CI variables.
- ⚠️ **Бэкапить приватный ключ sealed-secrets** — иначе потеря кластера = мёртвые секреты в git.

## Порядок развёртывания с нуля

1. **Proxmox-предпосылки**: образ Talos с extensions (iscsi-tools, util-linux-tools), registry-зеркала прогреты, ZFS-пул `tank`.
2. **Layer 0 bootstrap**: `terraform apply` (VM) → Ansible (PowerDNS + self-record, Nexus).
3. **Layer 1 base**: SeaweedFS, GitLab, Traefik, Authentik-БД, Databasus.
4. **Layer 2 database**: Postgres + Databasus.
5. **Layer 3 clusters**: `terraform apply` (Talos) → выгрузить kubeconfig (~10 мин на самосборку etcd).
6. **ArgoCD**: `helm install -f argocd-values.yaml` → `kubectl apply root-app.yaml` → ArgoCD доводит платформенный слой + apps.

## Restore (восстановление)

- **БД**: Databasus PITR → на нужную секунду.
- **filestore**: Longhorn backup → новый PVC (ближайший к точке БД).
- **k8s**: пересоздать кластер (terraform) → ArgoCD пересинкает из git. Sealed Secrets восстановятся **только при наличии бэкапа приватного ключа контроллера**.
- **VM целиком**: PBS image restore.
