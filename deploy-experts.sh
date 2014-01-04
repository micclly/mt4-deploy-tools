#!/bin/bash -u

MYDIR=$(dirname "$0")
WORK_DIR=$(readlink -m "$MYDIR/../.work")
WORK_DIR=${WORK_DIR#$(pwd)/}

. "$MYDIR/deploy.conf"
. "$MYDIR/common.sh.inc"

create_work_dir
prepare_deployment
deploy 'experts/'
pause_on_exit
