#!/bin/bash

# Fail on failure.
set -euo pipefail

OLD_KEY_FILENAME="$HOME/.ssh/id_rsa_old.pub"

echo "Going to remove $OLD_KEY_FILENAME, aka"
cat "$OLD_KEY_FILENAME"

echo ""
echo "Going to remove it on:"
for server in "$@"; do
    echo -n '* '
    echo "$server"
done
echo ""

if [ ! -z "$DRY_RUN" ] ; then
    echo ''
    echo "Operating in dry run mode."
fi

echo ''
echo "Sound good? ^D to continue, ^C to exit."
cat >/dev/null

echo "Continuing!"
echo ""
echo ""

PUBLIC_KEY_MATERIAL="$(cat "$OLD_KEY_FILENAME" | awk '{print $2}')"

for host in "$@"; do
    echo "Processing $host..."
    if ! ssh "$host" grep -q "$PUBLIC_KEY_MATERIAL" '$HOME/.ssh/authorized_keys'
    then
        echo "$host does not have this key."
        continue  # next host
    fi

    # else, process the host.
    if [ ! -z "$DRY_RUN" ] ; then
        SSH_CMD='echo ssh'
    else
        SSH_CMD='ssh'
        set -x
    fi
    $SSH_CMD "$host" grep -v "$PUBLIC_KEY_MATERIAL" '$HOME/.ssh/authorized_keys' '>' '$HOME/.ssh/authorized_keys.cleaned' '&&' 'mv' '$HOME/.ssh/authorized_keys.cleaned' '$HOME/.ssh/authorized_keys'

    if [ ! -z "$DRY_RUN" ] ; then
        set +x
    fi
done
