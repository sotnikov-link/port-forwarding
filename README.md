# Перенаправление портов в iptables

Скрипты добавления и удаления правил в iptables для проброса портов между
устройствами во внешней сети и внутренней.

## Установка

```sh
git clone https://github.com/sotnikov-link/port-forwarding.git
```

## Пример использования

Есть устройство, которое подключено к двум сетям

- к интернету через сетевой интерфейс eth0 и имеет глобальный IP-адрес
  111.222.111.222;
- к локальной сети 192.168.123.0/24 и имеет локальный IP-адрес 192.168.123.10.

Необходимо установить соединение между любым внешним устройством из интернета
с устройством в локальной сети, которое имеет IP-адрес 192.168.123.20,
но для соединения в интернете нужно использовать порт 8080, а устройство
в локальной сети должно использовать порт 8888.

### Схема

```
Любое внешнее           Сетевой интерфейс                Адрес устройства
устройство              для интернета                    во внутренней сети
 |                              |                                |
---                            ----                      -------------------
ЛВУ → [ 111.222.111.222:8080 → eth0 → 192.168.123.10 ] → 192.168.123.20:8888
      | --------------------          -------------- |
      |         |                          |         |
      |   Адрес доступный            Собственный IP  |
      |   в интернете                во внутренней   |
      |                              сети            |
      |                                              |
      \----------------------------------------------/
                             |
              Границы устройства, на котором
              необходимо выполнить скрипты
              для проброса портов
```

### Описание переменных

| Переменная | Описание                           | Значение        |
| ---------- | ---------------------------------- | --------------- |
| FROM_IP    | Статичный внешний IP               | 111.222.111.222 |
| FROM_PORT  | Внешний порт                       | 8080            |
| FROM_IF    | Интерфейс внешней сети             | eth0            |
| TO_OWN     | Собственный IP во внутренней сети  | 192.168.123.10  |
| TO_IP      | IP устройства во внутренней сети   | 192.168.123.20  |
| TO_PORT    | Порт устройства во внутренней сети | 8888            |

### Для включения перенаправления

```sh
FROM_IP=111.222.111.222 FROM_PORT=8080 FROM_IF=eth0 \
TO_OWN=192.168.123.10 TO_IP=192.168.123.20 TO_PORT=8888 \
./port-forwarding/add.sh
```

### Для выключения перенаправления

```sh
FROM_IP=111.222.111.222 FROM_PORT=8080 FROM_IF=eth0 \
TO_OWN=192.168.123.10 TO_IP=192.168.123.20 TO_PORT=8888 \
./port-forwarding/remove.sh
```
