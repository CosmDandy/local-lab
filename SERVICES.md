# Сервисы Local Lab

## Кластеры

| Кластер | Где | Назначение | k8s | Ноды |
|---|---|---|---|---|
| office-prod | Офис (3 Proxmox) | Production | Talos | 3 mixed CP+worker |
| home-prod | Дом (beast) | Production | Talos | 1 single-node CP+worker |
| lab-* | по мере надобности | Эксперименты | k3s/k0s/RKE2/etc | — |

## Infrastructure: минимум на день 1 (5 компонентов)

| Сервис | Назначение | office-prod | home-prod |
|---|---|---|---|
| Cilium | CNI (сеть подов) | ✅ | ✅ |
| Longhorn | CSI распределённое хранилище | ✅ | — |
| cert-manager | Авто-обновление TLS | ✅ | ✅ |
| Traefik | Ingress controller | ✅ | ✅ |
| ArgoCD | GitOps (хаб для всех кластеров) | ✅ | — |

> На home-prod вместо Longhorn используется встроенный в Talos `local-path-provisioner` — хранилище привязано к ноде, для single-node это не проблема.

## Infrastructure: добавляем по мере необходимости

| Сервис | Назначение | Когда добавлять |
|---|---|---|
| External Secrets | Подтяжка секретов из Vault/1Password/etc | Когда появятся секреты, которые нельзя в Sealed Secrets |
| Sealed Secrets | Зашифрованные секреты прямо в гите | Если External Secrets избыточен |
| Velero | Backup PV в S3 (MinIO) | Когда в кластере появятся данные, которые жалко потерять |
| ExternalDNS | Авто-синк Ingress в DNS | Когда надоест прописывать DNS руками |
| Renovate | PR с обновлениями версий чартов | После 5+ Helm-релизов в репо |
| CloudNativePG | Operator для Postgres (общий для нескольких apps) | Когда надоест что каждый Helm-чарт тянет свой Postgres |

## Observability (отдельная итерация)

| Сервис | Назначение | office-prod | home-prod |
|---|---|---|---|
| kube-prometheus-stack | Prometheus+Grafana+Alertmanager+exporters | ✅ | ✅ (минимум) |
| Loki | Хранилище логов | ✅ | — |
| Grafana Alloy | Агент сбора логов/метрик | ✅ | ✅ |

> Observability — **не на день 1**. Сначала работающий кластер с парой apps, потом мониторинг.

## Apps

| Сервис | Назначение | Где |
|---|---|---|
| Homepage | Стартовая страница со ссылками | office-prod |
| Nextcloud | Файлы / календарь / контакты | office-prod |
| Paperless-ngx | OCR / индекс документов | office-prod |
| Photoprism | Индекс фото с AI-распознаванием | office-prod |
| Jellyfin | Медиа-сервер | office-prod |
| MinIO | S3 (бэкапы, артефакты) | office-prod |
| Atuin | Синк shell history | office-prod |
| Home Assistant | Умный дом | beast (HAOS VM, вне k8s) |

## Удалено / не используется

- **Authentik** — отказались (если понадобится SSO позже — пересмотрим, рассмотреть Pocket-ID/Keycloak)
- **Pi-hole / AdGuard Home** — отказались
- **n8n** — отказались
- **Tempo** — отложено, добавим когда появятся свои инструментированные приложения
- **Headscale / Headplane** — живёт отдельно на Hetzner-VM, в репо не нужен
- **Sonarr / Radarr / Prowlarr / Overseerr / qBittorrent** — медиа-автоматизация убрана
- **Restic** — заменяется Velero
- **Consul / Vault / Nomad** — заменяется k8s primitives + ArgoCD + External Secrets

## Опционально на будущее

- **Immich** — современная альтернатива Photoprism (лучше мобильное приложение)
- **Headlamp** — web UI для k8s
- **Vaultwarden** — менеджер паролей
- **ntfy** — уведомления для Alertmanager / Velero
