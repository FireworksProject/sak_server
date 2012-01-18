#!/bin/bash
THISDIR="$(cd `dirname "$0"` && pwd)"
ROOTDIR="$( dirname "$THISDIR" )"
LIBDIR="$ROOTDIR/lib"
source "$LIBDIR/utils.sh"

if [ -z $1 ]; then
    echo "Mirror files from a src to a destination without deleting"
    echo
    echo "  <src> <dest> <logfile>"
    echo
    echo "! <src> and <dest> directory names to *not* need to have a trailing /"
    exit 0
fi

main () {
    local src="$1"
    local dest="$2"
    local logfile="$3"

    if [ -z "$logfile" ]; then
        fail "$0: logfile is a required argument"
    fi

    rsync \
        --recursive \
        --links \
        --perms \
        --times \
        --owner \
        --progress \
        --human-readable \
        --log-file="$logfile" \
        -e 'ssh -p 2575' \
        "$src/" "$dest/" || fail "$0: rsync failed"
}

main "$@"
