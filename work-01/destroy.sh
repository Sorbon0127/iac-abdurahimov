#!/usr/bin/env bash
set -euo pipefail

PREFIX="abdurahimov-04"

# Удаление виртуальных машин самостоятельного стенда
yc compute instance delete --name "$PREFIX-app-1"
yc compute instance delete --name "$PREFIX-app-2"

# Удаление подсети и сети самостоятельного стенда
yc vpc subnet delete --name "$PREFIX-subnet"
yc vpc network delete --name "$PREFIX-net"

# Проверка оставшихся ресурсов
yc compute instance list
yc compute disk list
yc vpc network list
yc vpc subnet list
