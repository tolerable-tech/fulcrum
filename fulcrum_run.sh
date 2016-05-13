#!/bin/bash
# NOTE: changes to this file for now need to be copied to cloud-config.yml

function has_previously_ran_container {
  local exists=`$DOCKER ps -qaf "name=$CONTAINER_NAME"`
  if [[ -n "$exists" ]]; then
    echo "yup"
  else
    echo "nah"
  fi
}

function pull_image() {
  $DOCKER pull $IMAGE_NAME
}

function sanitize_arg() {
  local arg=$1
  local flag=$2

  if [[ ! -z "$arg" && "$arg" != '""'  && "$arg" != 'none' ]]; then
    echo " $flag `sed "s/,/ $flag /g" <<< $arg`"
  fi
}

function run_docker_container {
  local detached=$1
  local optional_flags="$(sanitize_arg "$ENV_SETTINGS" "-e")"
  optional_flags+="$(sanitize_arg "$PORT_SETTINGS" "--publish")"
  optional_flags+="$(sanitize_arg "$LINK_SETTINGS" "--link")"
  optional_flags+="$(sanitize_arg "$NETWORK_SETTINGS" "--net")"

  if [[ "$VOLUME_SETTINGS" =~ .*--volumes-from.* ]]; then
    optional_flags+=" $VOLUME_SETTINGS "
  else
    optional_flags+="$(sanitize_arg "$VOLUME_SETTINGS" "--volume")"
  fi

  if [[ -z "$START_CMD" || "$START_CMD" == '""' || "$START_CMD" == "none" ]]; then
    START_CMD=''
  fi

  if [[ "$LINK_SETTINGS" != "none" ]]; then
    echo "giving other things a chance to boot..."
    wait_for_containers "$LINK_SETTINGS"
  fi

  echo "
  container name   = $CONTAINER_NAME image name = $IMAGE_NAME
  envs             = $ENV_SETTINGS
  link settings    = $LINK_SETTINGS
  port settins     = $PORT_SETTINGS
  volume settings  = $VOLUME_SETTINGS
  network settings = $NETWORK_SETTINGS
  optional_flags   = $optional_flags"

  $DOCKER run $detached --name $CONTAINER_NAME $optional_flags $IMAGE_NAME $START_CMD
}

function do_run_component() {
  pull_image
  run_docker_container
}

function run_volume_persistable_container {
  local vpc=`$DOCKER run -d --volumes-from $CONTAINER_NAME busybox:latest /bin/sleep 300`
  echo $vpc
}

function rm_container {
  local container=$1
  container=${container:="$CONTAINER_NAME"}
  $DOCKER rm $container
}

function cleanup_volume_persistable_container {
  $DOCKER kill $1
  rm_container $1
}

function attach_to_component_container {
  $DOCKER attach --sig-proxy $CONTAINER_NAME
}

function reattach_to_existing_volumes {
  pull_image

  local vpc=$(run_volume_persistable_container)
  VOLUME_SETTINGS="--volumes-from $vpc"

  rm_container

  run_docker_container '-d'

  cleanup_volume_persistable_container $vpc

  attach_to_component_container
}

function wait_for_containers {
  local CONTAINER_NAME_LIST=$1
  local CONTAINER_NAME_ARRAY=""
  local is_missing="false"
  local out=`docker ps`

  IFS=', ' read -r -a CONTAINER_NAME_ARRAY <<< "$CONTAINER_NAME_LIST"

  for container_name in "${CONTAINER_NAME_ARRAY[@]}"; do
    container_name=$(echo $container_name | cut -d ":" -f 1)
    if [[ -z "$(echo $out | grep "$container_name")" ]]; then
      is_missing=true
    fi
  done

  until [[ "$is_missing" == "false" ]]; do
    sleep 1

    out=`docker ps`

    is_missing="false"
    for container_name in "${CONTAINER_NAME_ARRAY[@]}"; do
      container_name=$(echo $container_name | cut -d ":" -f 1)
      if [[ -z "$(echo $out | grep "$container_name")" ]]; then
        is_missing=true
      fi
    done
  done
}

function wait_then {
  local CONTAINER_NAME=$1
  shift
  local COMMAND_WHEN_AVAILABLE="$@"

  wait_for_containers "$CONTAINER_NAME"

  $COMMAND_WHEN_AVAILABLE
}

DOCKER=`which docker`
CMD=$1
shift

case $CMD in
  "run")
    CONTAINER_NAME=$1;   shift
    IMAGE_NAME=$1;       shift # $2
    ENV_SETTINGS=$1;     shift # $3
    LINK_SETTINGS=$1;    shift # $4
    PORT_SETTINGS=$1;    shift # $5
    VOLUME_SETTINGS=$1;  shift # $6
    NETWORK_SETTINGS=$1; shift # $7
    START_CMD=$@

    if [[ "$(has_previously_ran_container)" == "yup" ]]; then
      reattach_to_existing_volumes
    else
      do_run_component 
    fi
    ;;
  "wait-then")
    wait_then $@
    ;;
  * )
    echo "usage: $0 run <container_name> <image_name> <env_settings> <volume_settings> <network_settings> <start_cmd>"
    exit 1
    ;;
esac
