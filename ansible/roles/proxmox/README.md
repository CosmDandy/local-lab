# Proxmox Role

Роль для автоматизации post-install конфигурации Proxmox VE серверов.

## Возможности

- ✅ Поддержка Proxmox VE 9.x (Debian Trixie)
- ✅ Настройка правильных репозиториев пакетов (deb822 формат)
- ✅ Отключение enterprise репозитория
- ✅ Включение no-subscription репозитория
- ✅ Удаление назойливых уведомлений о подписке
- ✅ Отключение HA сервисов (для single-node setup)
- ✅ Обновление пакетов
- ✅ Опциональная автоматическая перезагрузка

## Использование

### Базовое использование
```yaml
- hosts: proxmox_servers
  become: true
  roles:
    - proxmox
```

### С настройками
```yaml
- hosts: proxmox_servers
  become: true
  vars:
    proxmox_auto_reboot: true
    proxmox_update_packages: false
  roles:
    - proxmox
```

### Через playbook
```bash
# Стандартная конфигурация
ansible-playbook playbooks/proxmox-configure-role.yml

# Только post-install (без проверки перезагрузки)
ansible-playbook playbooks/proxmox-configure-role.yml --tags post-install

# Только проверка перезагрузки
ansible-playbook playbooks/proxmox-configure-role.yml --tags reboot

# С автоматической перезагрузкой
ansible-playbook playbooks/proxmox-configure-role.yml -e proxmox_auto_reboot=true

# Для конкретных серверов
ansible-playbook playbooks/proxmox-configure-role.yml -e target_hosts=proxmox_tailscale
```

## Переменные

### Управление выполнением
| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `proxmox_run_post_install` | `true` | Выполнять post-install конфигурацию |
| `proxmox_run_reboot_check` | `true` | Проверять необходимость перезагрузки |

### Post-install конфигурация
| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `proxmox_configure_sources` | `true` | Настраивать источники пакетов |
| `proxmox_disable_enterprise` | `true` | Отключать enterprise репозиторий |
| `proxmox_enable_no_subscription` | `true` | Включать no-subscription репозиторий |
| `proxmox_disable_subscription_nag` | `true` | Убирать уведомления о подписке |
| `proxmox_disable_ha_services` | `true` | Отключать HA сервисы |
| `proxmox_update_packages` | `true` | Обновлять пакеты |

### Конфигурация перезагрузки
| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `proxmox_auto_reboot` | `false` | Автоматически перезагружать при необходимости |
| `proxmox_reboot_timeout` | `300` | Таймаут перезагрузки (секунды) |
| `proxmox_post_reboot_delay` | `30` | Задержка после перезагрузки (секунды) |

## Теги

- `proxmox` - все задачи роли
- `proxmox-post-install` / `post-install` - только post-install конфигурация
- `proxmox-reboot` / `reboot` - только проверка перезагрузки

## Примеры использования

### Конфигурация без обновления пакетов
```yaml
- hosts: proxmox_servers
  become: true
  vars:
    proxmox_update_packages: false
  roles:
    - proxmox
```

### Только настройка репозиториев
```yaml
- hosts: proxmox_servers
  become: true
  vars:
    proxmox_disable_subscription_nag: false
    proxmox_disable_ha_services: false
    proxmox_update_packages: false
  roles:
    - proxmox
```

### С автоматической перезагрузкой
```yaml
- hosts: proxmox_servers
  become: true
  vars:
    proxmox_auto_reboot: true
    proxmox_reboot_timeout: 600
  roles:
    - proxmox
```

## Совместимость

- Proxmox VE 9.0+ (Debian Trixie)
- Использует современный deb822 формат репозиториев

## Зависимости

Роль не имеет внешних зависимостей, но требует:
- Ansible 2.9+
- sudo/root доступ на целевых серверах
- Доступ к интернету для обновления пакетов
