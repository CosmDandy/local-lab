# Local Lab

Personal infrastructure-as-code repository: два Kubernetes-кластера на Talos поверх Proxmox, управляемые через Terraform (bootstrap) и ArgoCD (deploy).

> Состояние: **скелет**. Смотри [SERVICES.md](./SERVICES.md) для списка сервисов и текущей фазы.

---

## Архитектура

```
                    ┌─────────────────────────────────────┐
                    │           Tailscale mesh            │
                    │     (overlay для всех нод/сайтов)   │
                    └──────────┬──────────────┬───────────┘
                               │              │
        ┌──────────────────────┴──┐      ┌────┴───────────────────┐
        │   ОФИС (office-prod)    │      │   ДОМ (home-prod)      │
        │   3 × Proxmox host      │      │   1 × Proxmox host     │
        │                         │      │                        │
        │   ┌─ Talos VM (kaluga)  │      │   ┌─ Talos VM (beast)  │
        │   ├─ Talos VM (s-tropez)│      │   │  single-node       │
        │   └─ Talos VM (courch.) │      │   │  CP + worker       │
        │                         │      │   └────────────────────│
        │   3 mixed CP+worker     │      │                        │
        │   etcd quorum: 3/3      │      │   Хранение: local-path │
        │   Хранение: Longhorn    │      │   Назначение: lab + HA │
        │                         │      │     для умного дома    │
        │   ┌─────────────────┐   │      │                        │
        │   │     ArgoCD      │───┼──────┼──→ управляет home-prod │
        │   │   (hub-and-     │   │      │     через kubeconfig   │
        │   │    spoke)       │   │      │                        │
        │   └─────────────────┘   │      │                        │
        └─────────────────────────┘      └────────────────────────┘
                  ▲                                 ▲
                  │                                 │
              git push ───────→  ArgoCD reconcile loop
                                 (всё деплоится из этого репо)
```

### Принципы

- **GitOps** — состояние кластеров описано в этом репо, ArgoCD непрерывно синхронизирует
- **Talos Linux** в Proxmox VM — иммутабельная ОС только для Kubernetes, минимум attack surface
- **Hub-and-spoke ArgoCD** — один инстанс на office-prod управляет обоими кластерами через зарегистрированные kubeconfig'и
- **Расширяемость** — поднять lab-кластер (k3s/k0s/RKE2 на Ubuntu/OpenSUSE) для экспериментов = добавить папку `terraform/clusters/lab-X/` и опционально `kubernetes/lab-X/`, основная архитектура не меняется

---

## Кластеры

| Кластер | Сайт | Ноды | OS / k8s | Назначение |
|---|---|---|---|---|
| **office-prod** | Офис, 3 Proxmox-хоста (kaluga, saint-tropez, courchevel) | 3 × Talos VM, mixed CP+worker | Talos | Production: prod-сервисы, GitOps хаб |
| **home-prod** | Дом, 1 Proxmox-хост (beast) | 1 × Talos VM, single-node CP+worker | Talos | HA, личные эксперименты, ad-hoc |
| **lab-*** | По мере надобности | — | k3s / k0s / RKE2 / etc | Эксперименты, обучение |

Хардварная инвентаризация — [hardware/](./hardware/).

---

## Стек

### Bootstrap (вне кластера)
- **Terraform** — провижининг VM на Proxmox + bootstrap Talos через `talosctl`
- **Tailscale** — mesh между всеми нодами и клиентами (личный tailnet)
- **Headscale** — координационный сервер Tailscale (живёт **отдельно** на Hetzner-VM, не в этом репо)

### Кластерная база (день 1, ставится на каждый prod-кластер)
- **Cilium** — CNI (сеть подов, NetworkPolicy, eBPF)
- **Longhorn** — CSI распределённое хранилище (только office-prod)
- **cert-manager** — авто-обновление TLS (Let's Encrypt)
- **Traefik** — Ingress controller
- **ArgoCD** — GitOps деплой (hub на office-prod)

### Расширения (добавляются по мере необходимости)
External Secrets / Sealed Secrets, Velero (backup в S3/MinIO), ExternalDNS, Renovate Bot, CloudNativePG (Postgres operator), kube-prometheus-stack + Loki + Grafana Alloy.

Полный список с обоснованиями — [SERVICES.md](./SERVICES.md).

---

## Структура репозитория

```
local-lab/
├── terraform/                   # Bootstrap слой (вне k8s)
│   ├── modules/
│   │   ├── proxmox-vm/         # Универсальный модуль VM на Proxmox
│   │   │                        # (любая ОС: Talos / Ubuntu / OpenSUSE)
│   │   └── talos-cluster/      # Bootstrap Talos: talosctl genconfig/apply/bootstrap
│   └── clusters/
│       ├── office-prod/        # tf-stack для office-prod
│       └── home-prod/          # tf-stack для home-prod
│
├── kubernetes/                         # Что внутри кластеров (через ArgoCD)
│   ├── office-prod/
│   │   ├── bootstrap/          # ArgoCD App-of-Apps: точка входа
│   │   ├── infrastructure/     # Cilium, Longhorn, cert-manager, Traefik, ArgoCD
│   │   └── apps/               # Homepage, Nextcloud, Jellyfin, Paperless, и т.д.
│   └── home-prod/
│       ├── bootstrap/
│       ├── infrastructure/     # минимум: Cilium, cert-manager, Traefik
│       └── apps/               # пусто (Home Assistant — отдельная HAOS VM)
│
├── docker/                      # Legacy compose-файлы (справочник на время миграции)
├── configs/                     # Конфиги сервисов (исходники для k8s ConfigMaps)
├── hardware/                    # Инвентаризация железа
├── SERVICES.md                  # Карта сервисов и фаз миграции
└── README.md
```

### Конвенция содержимого папки сервиса

В `kubernetes/<cluster>/{infrastructure,apps}/<service>/` плоско лежит:

- `application.yaml` — ArgoCD `Application` (обязательный), ссылается на upstream Helm-чарт + values
- `values.yaml` — Helm values, если большие (опционально)
- `secret.yaml` — `ExternalSecret` или `SealedSecret` манифесты (опционально)
- любые дополнительные манифесты (IngressRoute, NetworkPolicy, и т.п.)

**Без `base/` и `overlays/`** — каждый сервис деплоится в один кластер, Kustomize-оверрайды не нужны.

---

## Сеть

- **Офис:** `192.168.20.0/24`
- **Дом:** `10.0.1.0/24`
- **Tailscale tailnet:** `100.64.0.0/10` (overlay)
- **Headscale:** на отдельной Hetzner-VM (вне этого репо)
- Доступ к сервисам — через Tailscale + Traefik Ingress, без публичных IP

---

## Workflow

### Поднять кластер с нуля (office-prod)
1. `cd terraform/clusters/office-prod && terraform apply` — создаёт 3 Talos VM на Proxmox-хостах + bootstrap кластер
2. Получить `kubeconfig` из output
3. Установить ArgoCD одной командой (`helm install`)
4. Применить `kubernetes/office-prod/bootstrap/root.yaml` — ArgoCD дальше сам подтянет всю инфру и приложения из репо

### Добавить сервис
1. Создать папку `kubernetes/<cluster>/apps/<service>/`
2. Положить `application.yaml` (ArgoCD Application с Helm chart reference)
3. `git commit && git push`
4. ArgoCD заметит и применит автоматически

### Поднять lab-кластер (эксперимент)
1. Создать модуль `terraform/modules/<distro>-cluster/` (если ещё нет)
2. Создать `terraform/clusters/lab-<name>/` с tf-стеком
3. (Опц.) Зарегистрировать новый кластер в ArgoCD на office-prod через `Cluster` ресурс

---

## Установка кластера с нуля (pve-local-l)

Пошаговый runbook для реального кластера `pve-local-l` (3 CP + 3 worker, Talos + Cilium Gateway API + Longhorn). Три шага неизбежно ручные — это bootstrap-«семя» (инфраструктуры ещё нет / ArgoCD не ставит сам себя / нужно посадить первый Application). Всё остальное ArgoCD доводит сам.

### Слой 0 — предпосылки на Proxmox
- образ Talos **с extensions** (`iscsi-tools`, `util-linux-tools`) залит в `local:import/`
- registry-зеркала `10.0.1.50:5000-5002` подняты и прогреты (в Talos `skipFallback: true` — без них кластер не соберётся)
- ZFS-пул `tank` для data-дисков Longhorn

### Слой 1 — Terraform (VM + диски + Talos + Cilium)
```bash
cd terraform/live/pve-local-l/talos-k8s-3c-3w
terraform init
terraform apply
```
Закладывай ~10 мин: etcd проходит через learner-гонку и самособирается (поды control-plane могут повисеть в `ContainerCreating` — это ожидаемо, не ошибка).

Достать доступы:
```bash
mkdir -p ~/.kube
terraform output -raw kubeconfig  > ~/.kube/local-lab.yaml
terraform output -raw talosconfig > ~/.talosconfig
export KUBECONFIG=~/.kube/local-lab.yaml
```

### Слой 2 — ArgoCD (единственная ручная установка чарта)
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace \
  --version <pin> \
  -f gitops/pve-local-l/bootstrap/argocd-values.yaml
```
`argocd-values.yaml` уводит redis с `ecr-public.aws.com` (нет в registry-зеркалах) на `docker.io`. Версию чарта запинь через `--version` (`helm search repo argo/argo-cd --versions`).

### Слой 3 — посадить App-of-Apps
```bash
kubectl apply -f gitops/pve-local-l/bootstrap/root-app.yaml
```

### Слой 4 — дальше ArgoCD сам
Подтягивает из репозитория: metallb → metrics-server → longhorn → cilium-gateway → homepage. Между приложениями нет жёсткого порядка — ArgoCD реконсилит до сходимости (~несколько минут после первого `git push` reconcile-задержки).
```bash
kubectl get applications -n argocd -w
```

### Проверки после сходимости
```bash
kubectl get nodes                    # 6 Ready (3 CP + 3 worker)
kubectl get gatewayclass             # cilium
kubectl get gateway -n gateway       # homelab: PROGRAMMED=True, есть ADDRESS из MetalLB-пула
kubectl get storageclass             # longhorn
```

---

## DevContainer

Репозиторий настроен под **DevPod / VS Code DevContainers**. Открой в VS Code → Reopen in Container, либо:

```bash
devpod up . --id . --provider . --dotfiles https://github.com/CosmDandy/dotfiles-devpod.git
```

В девконтейнер будут установлены: Terraform, talosctl, kubectl, helm, k9s, gitleaks (для pre-commit hook).

---

## Безопасность

- Pre-commit hook `gitleaks` — блокирует случайные секреты в коммитах
- `.gitignore` исключает: `*.env`, `*.tfvars` (кроме `*.example`), `*.key`, `*.pem`, `kubeconfig`, `talosconfig`, `secrets/`, `.claude/`
- Все секреты в кластерах — через **External Secrets Operator** или **SealedSecrets** (без plaintext в репо)
- Сертификаты — через cert-manager + Let's Encrypt (DNS challenge, без публичного 443)
