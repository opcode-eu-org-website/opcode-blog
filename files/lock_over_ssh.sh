#!/bin/bash
set -e

REMOTE_HOST="$1"
REMOTE_LOCK_FILE="$2"
TIMEOUT_SEC=30


FIFOs=$(mktemp -d)
mkfifo "$FIFOs/ssh_in"
mkfifo "$FIFOs/ssh_out"

lock_cleanup() {
	echo "END" >> "$FIFOs/ssh_in" || true
	[ -n "${SSH_PID}" ] && kill "$SSH_PID" 2>/dev/null || true
	rm -rf "$FIFOs"
}
trap lock_cleanup EXIT

cat "$FIFOs/ssh_in" | ssh "$REMOTE_HOST" "flock -w $TIMEOUT_SEC -x $REMOTE_LOCK_FILE sh -c 'echo LOCKED; read _'; echo 'FLOCK TIMEOUT';" > "$FIFOs/ssh_out" & SSH_PID=$!

echo "Waiting for lock ..." >&2
read -t $((TIMEOUT_SEC + 2)) -r REMOTE_RESPONSE < "$FIFOs/ssh_out";
if [ "$REMOTE_RESPONSE" != "LOCKED" ]; then
	echo "Can't get lock: ${REMOTE_RESPONSE:-No response}" >&2
	exit 1
fi
echo "Lock received!" >&2


echo "Uruchamiam zadanie w blokadzie"
sleep 5 # Tutaj wstaw swoje właściwe polecenie działające na SSHFS
