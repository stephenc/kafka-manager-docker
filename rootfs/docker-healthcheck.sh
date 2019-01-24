#!/usr/bin/env bash
set -eo pipefail

host="$( (hostname -i || echo '127.0.0.1') | while IFS=$' ' read -a _line ; do echo $_line; break; done )"

# just test that the port is open
if nc -w 1 -z "$host" 9000 ; then
    exit 0
fi

exit 1
