#!/bin/bash -u

MYDIR=$(dirname "$0")
WORK_DIR=$(readlink -m "$MYDIR/../.work")
WORK_DIR=${WORK_DIR#$(pwd)/}

. "$MYDIR/deploy.conf"

# Color constants
RED='\e[0;31m'
GREEN='\e[0;32m'
NC='\e[0m'

log() {
    declare msg=$1
    echo -e "${GREEN}${msg}${NC}"
}

error() {
    declare msg=$1
    echo -e "${RED}${msg}${NC}"
}

create_work_dir() {
    if [ -d "$WORK_DIR" ]; then
        log "BEGIN: Removing working directory: $WORK_DIR"
        rm -rf "$WORK_DIR"
        if [ $? -eq 0 ]; then
            log "END: Removing working directory: $WORK_DIR"
        else
            error "FAILED: Removing working directory: $WORK_DIR"
            exit 1
        fi
    fi

    log "BEGIN: Creating working directory: $WORK_DIR"
    mkdir "$WORK_DIR"
    if [ $? -eq 0 ]; then
        log "END: Creating working directory: $WORK_DIR"
    else
        error "FAILED: Creating working directory: $WORK_DIR"
        exit 1
    fi
}

prepare_deployment() {
    log "BEGIN: Preparing deployment"

    declare sub_dirs=$(find "$MYDIR/.." -maxdepth 1 -type d ! -name ".*")
    declare old_ifs=$IFS
    IFS=$'\n'
    for sdir in $sub_dirs; do
        find "$sdir" -type f -name '*.ex4' -exec cp -p {} "$WORK_DIR" \;
        if [ $? -ne 0 ]; then
            error "FAILED: Preparing deployment"
            exit 1
        fi
    done
    IFS=$old_ifs

    log "END: Preparing deployment"
}

deploy() {
    log "BEGIN: Deploying Indicators"

    rsync -av --include=*.ex4 "$WORK_DIR/" "$DEPLOY_ROOT/experts/indicators/"
    retval=$?

    if [ $retval -eq 0 ]; then
        log "END: Deploying Indicators"
    else
        error "FAILED: Deploying Indicators"
        exit 1
    fi
}

pause_on_exit() {
    if [ $PAUSE_ON_EXIT -eq 1 ]; then
        read -p 'Press enter to close this window'
    fi
}

PAUSE_ON_EXIT=0
while getopts 'p' opt; do
    case $opt in
        'p')
            PAUSE_ON_EXIT=1
            ;;
        *)
            ;;
    esac
done

create_work_dir
prepare_deployment
deploy
pause_on_exit
