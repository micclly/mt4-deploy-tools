#!/bin/bash -u

MYDIR=$(dirname "$0")

"$MYDIR/sudo" bash --login $(readlink -m "$MYDIR/deploy-indicators.sh") -p
