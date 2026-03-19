# MTProto Proxy For Personal Use

Набор файлов для поднятия личного `MTProxy` сервера под Telegram на VPS.

Подходит для:

- личного использования;
- маленькой группы до `30` человек;
- запуска через `Docker Compose`;
- обычного `VPS` c `1 vCPU`, `1-2 GB RAM`, `10+ GB SSD`.

## Что внутри

- сборка официального `MTProxy` из исходников `TelegramMessenger/MTProxy`;
- автоматическая загрузка `proxy-secret` и `proxy-multi.conf` при старте;
- хранение секрета в `data/secret`;
- HTTP-статистика на `127.0.0.1:8888`;
- поддержка обычного режима и режима `Fake TLS`.

## Быстрый старт

1. Поднимите VPS c `Ubuntu 24.04` или `Debian 12`.
2. Откройте входящий `TCP 443`.
3. Установите `Docker` и `Docker Compose`.
4. Скопируйте проект на сервер.
5. Создайте `.env` из шаблона:

```bash
cp .env.example .env
```

6. Отредактируйте `.env`.
7. Запустите:

```bash
docker compose up -d --build
```

8. Проверьте логи:

```bash
docker compose logs -f
```

## Настройка `.env`

Обязательные поля:

- `PUBLIC_IP` - публичный IP вашего VPS;
- `PORT` - внешний порт, обычно `443`.

Опциональные поля:

- `TLS_DOMAIN` - домен для `Fake TLS`, например `www.cloudflare.com`;
- `WORKERS` - число воркеров, обычно `1`;
- `CLIENT_LIMIT` - мягкий ориентир по числу клиентов, для себя и 30 человек хватит с запасом.

Пример:

```dotenv
PUBLIC_IP=203.0.113.10
PORT=443
TLS_DOMAIN=www.cloudflare.com
WORKERS=1
CLIENT_LIMIT=30
```

## Как получить ссылку для Telegram

После первого старта сервер сам создаст секрет в `data/secret`.

Посмотреть его:

```bash
cat data/secret
```

### Вариант 1. Обычный MTProxy

Ссылка:

```text
tg://proxy?server=PUBLIC_IP&port=443&secret=SECRET
```

### Вариант 2. Fake TLS

Если задан `TLS_DOMAIN`, для клиента нужен секрет в формате:

```text
ee + SECRET + hex(TLS_DOMAIN)
```

Пример генерации:

```bash
DOMAIN="www.cloudflare.com"
SECRET="$(cat data/secret)"
printf 'ee%s%s\n' "$SECRET" "$(printf '%s' "$DOMAIN" | xxd -p -c 256)"
```

Ссылка:

```text
tg://proxy?server=PUBLIC_IP&port=443&secret=EE_SECRET
```

## Рекомендации по VPS

Для вашей задачи обычно достаточно:

- `1 vCPU`;
- `1 GB RAM`;
- `20 GB SSD`;
- датацентр вне РФ, если цель в обходе блокировок;
- хороший аплинк и стабильный IP.

Практичный старт:

- `Hetzner CX22 / CPX11`;
- `Netcup VPS`;
- `DigitalOcean basic droplet`;
- `Vultr regular cloud`.

## Безопасность

- Не публикуйте секрет в открытом виде.
- Не открывайте наружу порт `8888` со статистикой.
- Ограничьте доступ к серверу по `SSH key`, отключите парольный вход.
- Включите `ufw` и оставьте только `22/tcp` и `443/tcp`.
- Делайте обновление контейнера после обновлений Telegram или ОС.

## Полезные команды

Перезапуск:

```bash
docker compose restart
```

Остановка:

```bash
docker compose down
```

Обновление после изменений:

```bash
docker compose up -d --build
```

## Ограничения

- `MTProxy` не заменяет полноценный `VPN`.
- Если IP попадает в блок-листы, может потребоваться смена VPS/IP.
- Для высокой скрытности лучше использовать `Fake TLS`.
