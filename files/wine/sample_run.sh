#!/bin/bash

cd "$(dirname "$0")"
command -V games_chroot >&/dev/null && exec games_chroot "./$(basename "$0")"

export PROTONPATH=/games/steam/compatibilitytools.d/UMU-Proton-10.0-4
export WINEPREFIX=/games/epic-games/MyTimeAtPortia/pfx/
export WINEDLLOVERRIDES="winhttp=n,b"

cd "/games/epic-games/MyTimeAtPortia"
# legendary launch --wine umu-run  MyTimeAtPortia  --skip-version-check
umu-run '/games/epic-games/MyTimeAtPortia/bin/Portia.exe' -AUTH_LOGIN=unused -AUTH_PASSWORD= -AUTH_TYPE=exchangecode -epicapp=Cobra -epicenv=Prod -EpicPortal -epiclocale=pl -epicsandboxid=cobra
