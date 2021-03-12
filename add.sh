#!/bin/sh

# Скрипт для создания правил в iptables, чтобы перенаправлять запросы
# с порта из внешней сети на порт устройства во внутренней сети

# Основано на http://www.it-simple.ru/?p=2250

# Пример использования

# FROM_IP=111.222.111.222 FROM_PORT=8080 FROM_IF=eth0 \
# TO_OWN=192.168.123.10 TO_IP=192.168.123.20 TO_PORT=8888 \
# ./port-forwarding/add.sh # для добавлениия правил

if [ -z "$FROM_IP" ] && [ -z "$FROM_PORT" ] && [ -z "$FROM_IF" ] &&
  [ -z "$TO_OWN" ] && [ -z "$TO_IP" ] && [ -z "$TO_PORT" ]; then
  echo 'Error. Usage example:'
  echo 'FROM_IP=111.222.111.222 FROM_PORT=8080 FROM_IF=eth0 \'
  echo 'TO_OWN=192.168.123.10 TO_IP=192.168.123.20 TO_PORT=8888 \'
  echo './port-forwarding/add.sh'
  echo ''
  echo 'More: https://github.com/sotnikov-link/port-forwarding'
  exit 1
fi

# Внешний IP-адрес, который будет принимать запросы
EXTERNAL_IP=$FROM_IP

# Внешний номер порта, который будет принимать запросы
EXTERNAL_PORT=$FROM_PORT

# Внешний интерфейс через который будут проходить запросы
EXTERNAL_IF=$FROM_IF

# Собственный адрес во внутренней сети
INTERNAL_OWN_IP=$TO_OWN

# IP-адрес устройства, которое будет обрабатывать запрос во внутренней сети
INTERNAL_TARGET_IP=$TO_IP

# Номер порта устройства, которое будет обрабатывать запрос во внутренней сети
INTERNAL_TARGET_PORT=$TO_PORT

set -ex

# Правила
iptables -t nat -A PREROUTING -d $EXTERNAL_IP -p tcp -m tcp --dport $EXTERNAL_PORT -j DNAT --to-destination $INTERNAL_TARGET_IP:$INTERNAL_TARGET_PORT
iptables -t nat -A POSTROUTING -d $INTERNAL_TARGET_IP -p tcp -m tcp --dport $INTERNAL_TARGET_PORT -j SNAT --to-source $INTERNAL_OWN_IP
iptables -t nat -A OUTPUT -d $EXTERNAL_IP -p tcp -m tcp --dport $INTERNAL_TARGET_PORT -j DNAT --to-destination $INTERNAL_TARGET_IP
iptables -I FORWARD 1 -i $EXTERNAL_IF -d $INTERNAL_TARGET_IP -p tcp -m tcp --dport $INTERNAL_TARGET_PORT -j ACCEPT
