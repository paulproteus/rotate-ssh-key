#!/bin/bash

# Fail on failure.
set -euo pipefail

# Capture if we are in DRY_RUN mode from the environment variable.
DRY_RUN="${DRY_RUN:-}"

OLD_KEY_FILENAME="$HOME/.ssh/id_rsa_old.pub"
NEW_KEY_FILENAME="$HOME/.ssh/id_rsa.pub"

OLD_PUBLIC_KEY_MATERIAL="$(cat "$OLD_KEY_FILENAME" | awk '{print $2}')"
NEW_PUBLIC_KEY_MATERIAL="$(cat "$NEW_KEY_FILENAME" | awk '{print $2}')"

echo "Going to remove $OLD_KEY_FILENAME, aka"
echo "$OLD_PUBLIC_KEY_MATERIAL"
echo "and replace it with"
echo "$NEW_PUBLIC_KEY_MATERIAL"

echo ""
echo "Going to remove old key on:"
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

for host in "$@"; do
    echo "Processing $host..."
    if ! ssh "$host" grep -q "$OLD_PUBLIC_KEY_MATERIAL" '$HOME/.ssh/authorized_keys'
    then
        echo "$host does not have the old key. That is OK."
        continue  # next host
    fi

    # Make sure it has the new public key material, or else add it.
    ssh-copy-id -i "$NEW_KEY_FILENAME" "$host"

    if [ ! -z "$DRY_RUN" ] ; then
        SSH_CMD='echo ssh'
    else
        SSH_CMD='ssh'
        set -x
    fi
    $SSH_CMD "$host" grep -v "$OLD_PUBLIC_KEY_MATERIAL" '$HOME/.ssh/authorized_keys' '>' '$HOME/.ssh/authorized_keys.cleaned' '&&' 'mv' '$HOME/.ssh/authorized_keys.cleaned' '$HOME/.ssh/authorized_keys' '&&' 'chmod 0600 $HOME/.ssh/authorized_keys'


    if [ ! -z "$DRY_RUN" ] ; then
        set +x
    fi
done
