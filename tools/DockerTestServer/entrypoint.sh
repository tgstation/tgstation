#!/bin/bash
RS='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
# Docker entrypoint
# =================
# What this will do:
# 1) Override files under /tgstation/config/ with files present in /gamecfg/
# 2) Process environment variables passed to the container into /tgstation/config/
# 3) Finally start the DreamDaemon

# Override game config files
echo -e "${PURPLE}[${YELLOW}---${PURPLE}]${RS} Overriding config files"
cp -frv /gamecfg/* /tgstation/config
echo -e "${PURPLE}[${GREEN}---${PURPLE}]${RS} ${GREEN}Override complete!${RS}"

# Override common game options using variables
# <TODO>
echo -e "${PURPLE}[${YELLOW}---${PURPLE}]${RS} Overriding environment options..."
# Set DB settings
DB_HOST="${DB_HOST:-db}"
DB_USER="${DB_USER:-gamelord}"
DB_PASS="${DB_PASS:-gamelord}"

sed -i -r 's/ADDRESS .*/ADDRESS '"$DB_HOST"'/' /tgstation/config/dbconfig.txt
sed -i -r 's/FEEDBACK_LOGIN .*/FEEDBACK_LOGIN '"$DB_USER"'/' /tgstation/config/dbconfig.txt
sed -i -r 's/FEEDBACK_PASSWORD .*/FEEDBACK_PASSWORD '"$DB_PASS"'/' /tgstation/config/dbconfig.txt

# Setting ranks
export IFS=","
if [[ -z "${CKEYRANKS}" ]]; then
  echo -e "${PURPLE}[${YELLOW}---${PURPLE}]${RS} Inserting ranks..."
  echo "" > /tgstation/config/admins.txt
  echo "${RED}admins.txt has been reset!${RS}"
  for RANK in $CKEYRANKS; do
    echo "$( echo $RANK | cut -d '=' -f 1 )is now$( echo $RANK | cut -d '=' -f 2 )"
    printf "${RANK}\n" >> /tgstation/config/admins.txt
  done
  echo -e "${PURPLE}[${GREEN}---${PURPLE}]${RS} ${GREEN}CKEY Ranks set.${RS}"
fi

echo -e "${PURPLE}[${GREEN}---${PURPLE}]${RS} ${GREEN}Override complete!${RS}"


# Start DreamDaemon
echo -e "${PURPLE}[${GREEN}---${PURPLE}]${RS} ${GREEN}Starting DreamDaemon ...${RS}"
echo -e "${PURPLE}[${GREEN}---${PURPLE}]${RS} ${YELLOW}Enjoy! <3${RS}"
cd /tgstation
DreamDaemon tgstation.dmb -port 1337 -trusted -close -verbose