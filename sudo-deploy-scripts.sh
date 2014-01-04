#!/bin/bash -u

MYDIR=$(dirname "$0")

"$MYDIR/sudo" bash --login $(readlink -m "$MYDIR/deploy-scripts.sh") -p
