#!/usr/bin/env bash
set -euo pipefail

PREFIX="abdurahimov-04"
ZONE="ru-central1-a"
CIDR="10.14.1.0/24"
DISK_SIZE="15"
SSH_KEY="$HOME/.ssh/id_ed25519.pub"

# Создание сети и подсети
yc vpc network create --name "$PREFIX-net"

yc vpc subnet create \
  --name "$PREFIX-subnet" \
  --network-name "$PREFIX-net" \
  --zone "$ZONE" \
  --range "$CIDR"

# Создание двух виртуальных машин
for NUMBER in 1 2; do
  yc compute instance create \
    --name "$PREFIX-app-$NUMBER" \
    --hostname "$PREFIX-app-$NUMBER" \
    --zone "$ZONE" \
    --platform standard-v3 \
    --cores=2 \
    --core-fraction=20 \
    --memory=2 \
    --preemptible \
    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,type=network-hdd,size="$DISK_SIZE" \
    --network-interface subnet-name="$PREFIX-subnet",nat-ip-version=ipv4 \
    --ssh-key "$SSH_KEY" \
    --labels created-by=cli
done

yc compute instance list
