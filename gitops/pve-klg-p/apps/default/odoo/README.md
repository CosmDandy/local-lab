# Odoo

## Секреты

В манифестах этой директории секреты намеренно не хранятся в открытом виде.
Перед первым sync ArgoCD в namespace `odoo` нужны два Secret:

- `gitlab-registry` — docker-registry secret для `imagePullSecrets` (образ тянется из `gitlab.electrointech.ru:5050`).
- `odoo-db` — generic secret с ключом `password` (тот же пароль, что `vault_postgres_odoo_password` в Ansible Vault).

### MVP: создать вручную

```bash
kubectl create namespace odoo

kubectl create secret docker-registry gitlab-registry \
  --namespace odoo \
  --docker-server=gitlab.electrointech.ru:5050 \
  --docker-username=<username> \
  --docker-password=<token>

kubectl create secret generic odoo-db \
  --namespace odoo \
  --from-literal=password='<vault_postgres_odoo_password>'
```

### Прод: Sealed Secrets

В кластере есть sealed-secrets controller (`gitops/pve-klg-p/infrastructure/sealed-secrets`).
Секреты выше нужно зашифровать через `kubeseal` и закоммитить как `SealedSecret` в эту директорию,
чтобы ArgoCD применял их вместе с остальными манифестами:

```bash
kubectl create secret generic odoo-db \
  --namespace odoo \
  --from-literal=password='<vault_postgres_odoo_password>' \
  --dry-run=client -o yaml \
  | kubeseal --format yaml > sealed-odoo-db.yaml

kubectl create secret docker-registry gitlab-registry \
  --namespace odoo \
  --docker-server=gitlab.electrointech.ru:5050 \
  --docker-username=<username> \
  --docker-password=<token> \
  --dry-run=client -o yaml \
  | kubeseal --format yaml > sealed-gitlab-registry.yaml
```

Заготовка (пример структуры, не для применения as-is):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: odoo-db
type: Opaque
stringData:
  password: "REPLACE_WITH_ODOO_DB_PASSWORD"
```

## Namespace

Namespace `odoo` создаётся автоматически ArgoCD (`syncOptions: CreateNamespace=true`
в `gitops/pve-klg-p/argocd/odoo.yaml`), отдельного `namespace.yaml` в манифестах нет —
по аналогии с `apps/default/homepage` и `infrastructure/sealed-secrets`.
