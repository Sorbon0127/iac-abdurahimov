#!/usr/bin/env bash
set -euo pipefail

PREFIX="abdurahimov-04"

# Удаление ресурсов с точным именем
delete_named() {
  local name="$1"
  shift

  local data ids id
  data=$(yc "$@" list --format json)
  ids=$(printf '%s' "$data" | jq -r --arg name "$name" \
    '.[] | select(.name == $name) | .id')

  if [ -z "$ids" ]; then
    echo "$name: уже отсутствует"
    return
  fi

  while IFS= read -r id; do
    [ -n "$id" ] || continue
    echo "Удаление $name ($id)"
    yc "$@" delete "$id"
  done <<< "$ids"
}

# Балансировщик и целевая группа
delete_named "$PREFIX-lb" load-balancer network-load-balancer
delete_named "$PREFIX-tg" load-balancer target-group

# Все ВМ стенда с именами вида abdurahimov-04-app-N
instances=$(yc compute instance list --format json)
instance_ids=$(printf '%s' "$instances" | jq -r \
  --arg prefix "$PREFIX-app-" \
  '.[] | select(.name | startswith($prefix))
       | select(.name | ltrimstr($prefix) | test("^[0-9]+$"))
       | .id')

if [ -z "$instance_ids" ]; then
  echo "Виртуальные машины стенда уже отсутствуют"
else
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    echo "Удаление ВМ $id"
    yc compute instance delete "$id"
  done <<< "$instance_ids"
fi

# Дополнительный диск, подсети и сеть
delete_named "$PREFIX-data" compute disk
delete_named "$PREFIX-subnet-a" vpc subnet
delete_named "$PREFIX-subnet-b" vpc subnet
delete_named "$PREFIX-net" vpc network

echo "Проверка удаления завершена"
