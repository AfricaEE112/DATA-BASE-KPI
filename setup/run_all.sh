#!/usr/bin/env bash
# Виконує всі SQL-скрипти лаб по порядку через sqlcmd (запускати на Ubuntu).
#   SA_PASSWORD='...' ./setup/run_all.sh            -- всі скрипти
#   SA_PASSWORD='...' ./setup/run_all.sh 11 18      -- лише з 11 по 18
# -f 65001 потрібен, щоб кирилиця з файлів читалася як UTF-8.

set -euo pipefail
cd "$(dirname "$0")/.."

FROM=${1:-1}
TO=${2:-99}
SQLCMD=/opt/mssql-tools18/bin/sqlcmd
: "${SA_PASSWORD:?Задайте змінну SA_PASSWORD}"

for f in [0-9][0-9]_*.sql; do
    n=$((10#${f%%_*}))
    (( n < FROM || n > TO )) && continue
    echo "================= $f ================="
    "$SQLCMD" -S localhost -U sa -P "$SA_PASSWORD" -C -f 65001 -b -i "$f"
done
