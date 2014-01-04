#!/bin/bash -u

MYDIR=$(dirname "$0")

"$MYDIR/sudo" bash --login $(readlink -m "$MYDIR/deploy-experts.sh") -p
