#!/bin/bash

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

# Created with Gemini AI, 2026

# Nazwa skryptu definiuje obsługiwany protokół: cryptossh://
# Zapisz ten skrypt jako: git-remote-cryptossh

# Inicjalizacja remote cryptossh: `git-remote-cryptossh init origin user@host:port/path/to/repo`


set -euo pipefail

# Sprawdzenie czy jesteśmy w repozytorium gita
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null || { echo "Błąd: To nie jest repozytorium Gita!" >&2; exit 1; })

# 1. PARSOWANIE ARGUMENTÓW GITA
INIT_MODE=false
if [ "$1" = "init" ]; then
	INIT_MODE=true
	shift
fi
REMOTE_NAME="$1"
REMOTE_URL="$2"

# Parsowanie URL formatu: cryptossh://user@host:port/path/to/cipherdir
# Wycinamy protokół
URL_WITHOUT_PROTO="${REMOTE_URL#cryptossh://}"
# Wyciągamy ścieżkę (wszystko od pierwszego ukośnika)
SSH_CIPHERDIR="/${URL_WITHOUT_PROTO#*/}"
# Wyciągamy host i port (wszystko przed pierwszym ukośnikiem)
SSH_AUTH="${URL_WITHOUT_PROTO%%/*}"

if [[ "$SSH_AUTH" == *":"* ]]; then
	SSH_USER_HOST="${SSH_AUTH%%:*}"
	SSH_PORT="${SSH_AUTH##*:}"
else
	SSH_USER_HOST="$SSH_AUTH"
	SSH_PORT="22"
fi

# Lokalne ścieżki struktur montowania bazowane na nazwie REMOTE
MOUNT_ROOT="$GIT_DIR/remote_fs/$REMOTE_NAME"
SSHFS_RAW_DIR="$MOUNT_ROOT/.sshfs_raw"
GIT_REMOTE_REPO="$MOUNT_ROOT/decrypted"
PASS_FILE="$MOUNT_ROOT/.pass"

# 2. FUNKCJA SPRZĄTAJĄCA
cleanup() {
	fusermount -u "$GIT_REMOTE_REPO" 2>/dev/null || true
	fusermount -u "$SSHFS_RAW_DIR" 2>/dev/null || true
}

# 3. MONTOWANIE ZASOBU ZDALNEGO

mkdir -p "$SSHFS_RAW_DIR" "$GIT_REMOTE_REPO"

if [ ! -f "$PASS_FILE" ]; then
	if $INIT_MODE; then
		read -p "Wprowadź hasło dla gocryptfs: " pass
		(umask 0377 && echo "$pass" > "$PASS_FILE")
	else
		echo "Błąd: Brak pliku z hasłem $PASS_FILE. Przerwano." >&2
		exit 1
	fi
fi

if $INIT_MODE; then
	ssh -p "$SSH_PORT" "$SSH_USER_HOST" "mkdir -p $SSH_CIPHERDIR"
fi

trap cleanup EXIT

if ! mountpoint -q "$SSHFS_RAW_DIR"; then
	sshfs -p "$SSH_PORT" "$SSH_USER_HOST:$SSH_CIPHERDIR" "$SSHFS_RAW_DIR" -o reconnect,ServerAliveInterval=15,workaround=rename
fi

if [ ! -f "$SSHFS_RAW_DIR/gocryptfs.conf" ]; then
	if $INIT_MODE; then
		echo "Inicjalizacja gocryptfs w zdalnym katalogu..." >&2
		gocryptfs -init -passfile "$PASS_FILE" "$SSHFS_RAW_DIR"
	else
		echo "Błąd: gocryptfs nie jest zainicjalizowany (brak 'gocryptfs.conf')." >&2
		exit 1
	fi
fi

if ! mountpoint -q "$GIT_REMOTE_REPO"; then
	gocryptfs -passfile "$PASS_FILE" "$SSHFS_RAW_DIR" "$GIT_REMOTE_REPO"
fi

if [ ! -f "$GIT_REMOTE_REPO/HEAD" ]; then
	if $INIT_MODE; then
		git init --bare "$GIT_REMOTE_REPO"
	else
		echo "Błąd: repozytorium git nie jest zainicjalizowane (brak 'HEAD')." >&2
		exit 1
	fi
fi

# 4(A). FINALIZACJA INICJALIZACJI
if $INIT_MODE; then (
	cd "$GIT_DIR"
	git remote add $REMOTE_NAME cryptossh://$URL_WITHOUT_PROTO
	git config "remote.$REMOTE_NAME.lfsurl" "${GIT_REMOTE_REPO}"
); fi

# 4(B). KOMUNIKACJA Z WEWNĘTRZNYM MECHANIZMEM GITA
# za pomocą standardowego wejścia/wyjścia (Capabilities stdio)
# Git rozmawia ze skryptem tekstowo. Informujemy gita, że potrafimy obsłużyć 'connect'
while read -r line; do
	if [ "$line" = "capabilities" ]; then
		echo "connect"
		echo ""
	elif [[ "$line" == connect* ]]; then
		# Git wysyła komendę np. "connect git-receive-pack" (dla push) lub "connect git-upload-pack" (dla fetch)
		echo "" # Pusta linia oznacza akceptację połączenia
		
		# Pobieramy nazwę usługi (odbiornik/nadajnik packów gita)
		SERVICE="${line#connect }"
		
		# Przekierowujemy binarne strumienie Gita bezpośrednio do odszyfrowanego katalogu lokalnego
		$SERVICE "$GIT_REMOTE_REPO"
	elif [ -z "$line" ]; then
		exit 0
	fi
done
