#!/bin/bash

function export_anchor_ip_to_env {
  if grep -q DO_ANCHOR_IPV4 /etc/environment; then
    echo "[initializer] anchor IP already set"
  else
    anchor_ip=`/usr/bin/curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/address` 
    echo "DO_ANCHOR_IPV4=$anchor_ip" | sudo tee -a /etc/environment
  fi
}

function initialize_docker_networks {
  local networks=`docker network ls`

  set -e

  if [[ "$networks" == *"fulcrum-private"* ]]; then
    echo "[initializer] fulcrum-private already exists"
  else
    echo "[initializer] creating fulcrum-private"
    sudo docker network create -o "com.docker.network.bridge.name=fulcrum0" fulcrum-private
  fi

  if [[ "$networks" == *"fulcrum-nginx"* ]]; then
    echo "[initializer] fulcrum-nginx already exists"
  else
    echo "creating fulcrum-nginx"
    sudo docker network create -o "com.docker.network.bridge.name=fulcrum1" fulcrum-nginx
  fi
}

function create_swap {
  if [[ ! -f $SWAPFILE ]]; then
    sudo /usr/bin/touch $SWAPFILE
    sudo /usr/bin/chattr +C $SWAPFILE
    sudo /usr/bin/fallocate -l 2048m $SWAPFILE
    sudo /usr/bin/chmod 600 $SWAPFILE
    sudo /usr/sbin/mkswap $SWAPFILE
  fi
}

function create_docker_volumes() {
  local volumes=`docker volume ls`

  if [[ "$volumes" == *letsencrypt* ]]; then
    echo "[initializer] letsencrypt volume exists."
  else
    echo "[initializer] creating volume letsencrypt"
    docker volume create --name letsencrypt
  fi

  if [[ "$volumes" == *nginx_conf* ]]; then
    echo "[initializer] nginx_conf volume exists."
  else
    echo "[initializer] creating volume nginx_conf"
    docker volume create --name nginx_conf
  fi

  if [[ "$volumes" == *fulcrumpgdata* ]]; then
    echo "[initializer] fulcrumpgdata volume exists."
  else
    echo "[initializer] creating volume fulcrumpgdata"
    docker volume create --name fulcrumpgdata
  fi
}

function enable_swap {
  sudo /usr/sbin/losetup -f ${SWAPFILE}
  sudo /usr/bin/sh -c "/sbin/swapon $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"
}

function disable_swap {
  sudo /usr/bin/sh -c "/sbin/swapoff $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"
  sudo /usr/bin/sh -c "/usr/sbin/losetup -d $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"
}

SWAPFILE="/2GiB.swap"

case $1 in
  "up")
    export_anchor_ip_to_env

    create_swap
    enable_swap
    ;;
  "nginx-preflight")
    create_docker_volumes
    export_anchor_ip_to_env
    initialize_docker_networks
    ;;
  "create-docker-volumes")
    create_docker_volumes
    ;;
  "down")
    ;;
  * )
    echo "$0 <up|down>"
  ;;
esac
