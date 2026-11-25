#!/usr/bin/env bash
# Встановлення Microsoft SQL Server на Ubuntu з доступом по мережі (порт 1433).
#   Ubuntu 22.04 -> SQL Server 2022
#   Ubuntu 24.04 -> SQL Server 2025
#
# Запуск:
#   chmod +x install_mssql_ubuntu.sh
#   sudo ./install_mssql_ubuntu.sh
#
# Пароль для sa можна передати заздалегідь:
#   sudo SA_PASSWORD='MyStr0ng!Pass' ./install_mssql_ubuntu.sh
# Вимоги до пароля: мінімум 8 символів, великі й малі літери, цифри, спецсимволи.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Запустіть скрипт через sudo." >&2
    exit 1
fi

. /etc/os-release
UBUNTU_VER="$VERSION_ID"

case "$UBUNTU_VER" in
    22.04) MSSQL_VER=2022 ;;
    24.04) MSSQL_VER=2025 ;;
    *)
        echo "Ubuntu $UBUNTU_VER офіційно не підтримується (потрібна 22.04 або 24.04)." >&2
        exit 1 ;;
esac

# SQL Server потребує щонайменше 2 ГБ RAM
MEM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
if (( MEM_MB < 2000 )); then
    echo "Увага: лише ${MEM_MB} МБ RAM, а SQL Server потребує мінімум 2 ГБ. Сервер може не запуститися." >&2
fi

if [[ -z "${SA_PASSWORD:-}" ]]; then
    read -rsp "Придумайте пароль для користувача sa: " SA_PASSWORD; echo
    read -rsp "Повторіть пароль: " SA_PASSWORD2; echo
    [[ "$SA_PASSWORD" == "$SA_PASSWORD2" ]] || { echo "Паролі не співпадають." >&2; exit 1; }
fi

echo ">>> Ubuntu $UBUNTU_VER -> встановлюємо SQL Server $MSSQL_VER"

# 0. Прибираємо залишки попередніх спроб ДО першого apt-get update,
#    інакше зламані списки репозиторіїв Microsoft зупиняють скрипт
dpkg --purge packages-microsoft-prod > /dev/null 2>&1 || true
rm -f /etc/apt/sources.list.d/mssql-release.list \
      /etc/apt/sources.list.d/mssql-server-*.list \
      /etc/apt/trusted.gpg.d/microsoft.asc \
      /usr/share/keyrings/microsoft-prod.gpg

apt-get update
apt-get install -y curl gnupg ca-certificates

# 1. Ключ і репозиторії Microsoft (сервер + інструменти командного рядка)
#    Офіційний пакет Microsoft: ставить ключ (/usr/share/keyrings/microsoft-prod.gpg)
#    і репозиторій prod (там лежать mssql-tools18)
curl -fsSL -o /tmp/packages-microsoft-prod.deb \
    "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VER}/packages-microsoft-prod.deb"
dpkg -i /tmp/packages-microsoft-prod.deb
rm -f /tmp/packages-microsoft-prod.deb

#    Репозиторій самого SQL Server
curl -fsSL "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VER}/mssql-server-${MSSQL_VER}.list" \
    | tee /etc/apt/sources.list.d/mssql-server-${MSSQL_VER}.list > /dev/null

echo ">>> Підключені репозиторії Microsoft:"
grep -h microsoft /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources 2>/dev/null || true

apt-get update

# 2. Сам сервер
apt-get install -y mssql-server

# 3. Налаштування без діалогу: безкоштовна Developer-редакція, пароль sa
MSSQL_PID=Developer MSSQL_SA_PASSWORD="$SA_PASSWORD" ACCEPT_EULA=Y \
    /opt/mssql/bin/mssql-conf -n setup accept-eula

systemctl enable --now mssql-server

# 4. Утиліти sqlcmd / bcp
ACCEPT_EULA=Y apt-get install -y mssql-tools18 unixodbc-dev
if ! grep -q mssql-tools18 /etc/profile.d/mssql.sh 2>/dev/null; then
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' > /etc/profile.d/mssql.sh
fi

# 5. Відкриваємо порт 1433, щоб до сервера можна було підключитися з віртуалки
if command -v ufw > /dev/null && ufw status | grep -q "Status: active"; then
    ufw allow 1433/tcp
    echo ">>> У ufw відкрито порт 1433/tcp"
fi

# 6. Перевірка
sleep 5
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C \
    -Q "SELECT @@VERSION AS Version;"

echo
echo "=========================================================="
echo " SQL Server працює. Адреси цього комп'ютера:"
ip -4 -o addr show scope global | awk '{print "   " $2 ": " $4}'
echo " Підключення з Windows (SSMS / Azure Data Studio):"
echo "   Server:   <IP з переліку вище>,1433"
echo "   Login:    sa  (SQL Server Authentication)"
echo "   Обов'язково увімкніть 'Trust server certificate'."
echo "=========================================================="
