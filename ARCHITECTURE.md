# Архитектура инфраструктуры

Живой документ. Описывает инфру слой за слоем — от bootstrap до приложений, плюс storage, observability, бэкапы и порядок развёртывания с нуля. Дополняется по мере роста.

## Принципы

- **Два мира деплоя**: **Ansible → VM/LXC** (всё в `ansible/roles/` ставится на виртуалки/контейнеры Proxmox), **GitOps/ArgoCD → Kubernetes** (всё в `gitops/` живёт в кластере).
- **Слоистая модель**: каждый слой зависит только от нижних, разворачивается снизу вверх. Отдельный Terraform-стейт на слой.
- **Terraform = инфра** (создать VM/LXC), **Ansible = конфиг** (что внутри; конфиги в `templates/`).
- **Размещение**: stateless/эфемерное → k8s; тяжёлое stateful → VM/LXC (data gravity). **Тяжёлые/критичные → отдельные VM** (ресурсы, изоляция IO); **лёгкие → отдельные LXC** (дёшево + изоляция, не пихать несколько в одну VM); **агенты (node-exporter, vector) → co-located** на каждой VM/LXC.
- **Критерий выбора** — «оптимальное, а не максимальное» (Longhorn не Ceph, PowerDNS не anycast-BIND, VictoriaMetrics не Thanos-обвязка).
- **Один кластер** (multi-cluster — абстракция на 2+ года вперёд, пока не строим). Но виртуалок много.
- **Дно стека самодостаточно**: bootstrap не зависит от себя (DNS по статическому IP, Nexus с прямым upstream).
- **Меньше движущихся частей**: один компонент закрывает несколько потребностей → лишние убираем (Longhorn заменил горячий S3 + NFS + Restic).

## Слои (снизу вверх)

### Layer 0 — Bootstrap (VM/LXC)
Фундамент, от которого зависят все. Прямой upstream / golden image (в обход Nexus).
- **DNS — PowerDNS** (LXC): split-horizon (внутренний = всё; Cloudflare = публичное). Authoritative + recursor. HA из 2 узлов. Домен `cosmdandy.dev` → валидный TLS внутренним (DNS-01).
- **Nexus** (VM, Java): registry + pull-through cache (apt/pip/helm/docker).

### Layer 1 — Base (VM/LXC)
**Сервисы:**
- **SeaweedFS** (VM, диски): S3 (вместо MinIO — archived). Один инстанс под бэкапы. ZFS RAIDZ + Object Lock + offsite.
- **GitLab** (VM, тяжёлый): git + CI/CD (Omnibus).
- **Authentik** (SSO): compute в k8s, Postgres на VM, Redis в k8s. Break-glass в обход SSO для Proxmox/критичного.
- **Traefik** (LXC): reverse-proxy для VM-сервисов (TLS/ACME, file-provider).
- **Databasus** (VM): бэкап Postgres (PITR) — см. Backup.

**Observability (хранилища + агенты на VM):**
- **OpenSearch** (VM, тяжёлый): хранилище логов.
- **VictoriaMetrics** (VM): хранилище метрик (эффективнее Prometheus, встроенный long-term).
- **Vector** (на каждой VM + DaemonSet в k8s): сбор логов → OpenSearch.
- **node-exporter** (на каждой VM): метрики хоста.
- **postgres-exporter** (рядом с Postgres): метрики БД.
- **Gatus** (VM/LXC): uptime/доступность сервисов извне.

### Layer 2 — Database (VM)
- **PostgreSQL** (VM). Odoo 13 / PG12 сейчас (за EOL — апгрейд в roadmap), переход на Odoo 19 / новый PG.
- **Redis — НЕ нужен** (single-instance Odoo: сессии на Longhorn PVC, как filestore). Понадобится только при репликах Odoo — для shared-сессий (либо RWX, либо Redis).

### Layer 3 — Kubernetes (Talos на VM)
Кластер `talos-k8s-3c-3w` (3 CP + 3 worker, рабочий). k8s-ноды — только VM.
- **CNI: Cilium + Gateway API** (HTTPRoute, не Ingress). GatewayClass `cilium` подаётся декларативно.
- **Storage: Longhorn** — data-диски worker (`/dev/sdb` → `/var/lib/longhorn`), replicaCount=2. Закрывает filestore + репликацию + бэкап.
- **LB: MetalLB** (пул `10.0.1.200-220`).
- **GitOps: ArgoCD** (App-of-Apps; ставится вручную helm'ом с `argocd-values.yaml`).
- **Платформенный слой**: Sealed Secrets, cert-manager, external-dns, metrics-server (только HPA!), gitlab-runner, Vector (DaemonSet, логи).
- **GitLab Runners** — эфемерные поды (k8s executor).

### Apps
- Workload через ArgoCD: Odoo, homepage… — папками в `gitops/`, не отдельными репо.
- **Odoo** (Nomad → k8s): stateless Deployment + образ (всё запечено). Состояние снаружи: filestore + сессии → один Longhorn PVC на весь `/var/lib/odoo` (RWO, `strategy: Recreate` — иначе новый под не примонтирует RWO-том, пока старый держит). Миграции (`-u`) — отдельным Job.

## Observability

Принцип: **хранилища наблюдаемости — ВНЕ кластера (на VM)**, чтобы видеть падение самого кластера и собирать со всех VM. Три столпа:

| Столп | Сбор | Хранилище | UI |
|-------|------|-----------|-----|
| **Логи** | Vector (VM + k8s DaemonSet), push | **OpenSearch** (VM) | OpenSearch Dashboards / Grafana |
| **Метрики** | node-exporter + exporters (VM) + vmagent (k8s), pull/scrape | **VictoriaMetrics** (VM) | **Grafana** |
| **Uptime** | Gatus (пробы извне) | — | Gatus UI |

- **Экспортеры**: встроенный `/metrics` (Traefik, Cilium, ArgoCD, SeaweedFS — ставить не надо) vs отдельные (postgres-exporter, node-exporter). blackbox/Gatus — проверка доступности снаружи.
- **Логи vs метрики** — разные столпы: OpenSearch (что случилось) ≠ VictoriaMetrics (тренды/здоровье/алерты). Нужны оба.

### Алертинг
Стек (в k8s, через ArgoCD): **vmalert** (вычисляет alerting-rules на метриках VictoriaMetrics) → **Alertmanager** (группировка/маршрутизация/отправка → Telegram/Slack). Telegram bot-token → **Sealed Secret**.

Принципы (чтобы не утонуть в шуме):
- Алерты на **симптомы** (боль пользователя), не на каждую метрику. «Не требует немедленного действия → не алерт».
- **Alerts as code** — правила (VMRule) в git, не в UI; готовые библиотеки (awesome-prometheus-alerts).
- **Grouping / inhibition / silencing** (Alertmanager) — лавину в один осмысленный алерт.
- **Severity-маршрутизация**: critical → пейджер/звонок, warning → чат, info → только дашборд.
- На будущее: **SLO-based** (burn rate бюджета ошибок).

### ⚠️ Пробелы observability (план в k8s)
- **Grafana** — визуализация метрик (дашборды as-code в git, настройки в Postgres).
- **vmagent** — scrape метрик k8s-workload → VictoriaMetrics (на VM). `metrics-server` это НЕ закрывает (только HPA).
- **vmalert + Alertmanager** — алертинг (см. выше).

## Storage

`Longhorn заменил три вещи: горячий S3, NFS и Restic для filestore.`
- **filestore (Odoo)** → **Longhorn PVC** (RWO без реплик; RWX при репликах). `reclaimPolicy: Retain`. Том независим от пода → деплой не теряет данные. Убирает NFS-SPOF.
- **S3 (SeaweedFS)** → только бэкапы (один инстанс). Горячий S3 не нужен.
- Горячее (Longhorn, SSD/worker) ≠ холодное (SeaweedFS, HDD, immutable, offsite).

## Backup & Restore

Принцип: **реплики ≠ бэкап**. Инструмент следует за тем, где данные.

| Что | Где | Инструмент |
|-----|-----|------------|
| **БД** | VM | **Databasus** — PITR, tiered/GFS retention |
| **filestore** | Longhorn PVC | **Longhorn native backup** (snapshot+incremental) → SeaweedFS |
| **k8s-ресурсы** | k8s | Velero (отложен) |
| **VM целиком** | Proxmox | Proxmox Backup Server (отдельное железо) |

- Databasus tiered/GFS: свежее окно physical base + WAL (PITR); старое — daily logical с прореживанием. PG12 — без incremental (нужен PG17). Экономия vs pg_dump 4-6×/день: ~75% + RPO в секунды.
- **Restic убран** (filestore на Longhorn).
- **⚠️ Консистентность filestore↔БД** не решена полностью (разные системы бэкапа; append-only смягчает; restore = БД на T + ближайший снапшот).

## Секреты

- **Sealed Secrets** — статические секреты, зашифрованы в git. Замена GitLab CI variables, безопаснее.
- **Vault/ESO — отложены** (нужны при dynamic secrets / PKI).
- **VM-секреты** — ansible-vault / GitLab CI variables.
- ⚠️ **Бэкапить приватный ключ sealed-secrets**.

## Порядок развёртывания с нуля

1. **Proxmox-предпосылки**: образ Talos с extensions, registry-зеркала, ZFS-пул `tank`.
2. **Layer 0 bootstrap**: terraform (VM) → Ansible (PowerDNS + self-record, Nexus).
3. **Layer 1 base**: SeaweedFS, GitLab, Traefik, Databasus, OpenSearch, VictoriaMetrics, Vector/exporters, Gatus.
4. **Layer 2 database**: Postgres + Databasus.
5. **Layer 3 clusters**: terraform (Talos) → kubeconfig (~10 мин на etcd).
6. **ArgoCD**: `helm install -f argocd-values.yaml` → `kubectl apply root-app.yaml` → платформенный слой + apps.

## Restore

- **БД**: Databasus PITR → нужная секунда.
- **filestore**: Longhorn backup → новый PVC.
- **k8s**: пересоздать кластер (terraform) → ArgoCD пересинкает из git. Sealed Secrets — **только при бэкапе приватного ключа**.
- **VM целиком**: PBS image restore.
