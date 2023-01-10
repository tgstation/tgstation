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
# 1) Copy the default config/ files from the read-only volume to /tgstation/config/
# 2) Override files under /tgstation/config/ with files present in /gamecfg/
# 3) Process environment variables passed to the container into /tgstation/config/
# 4) Finally start the DreamDaemon

# Override game config files
echo -e "${PURPLE}[${YELLOW}---${PURPLE}]${RS} Copying default configuration files..."
cp -frv /gamecfg_ro/* /tgstation/config
echo -e "${PURPLE}[${GREEN}---${PURPLE}]${RS} ${GREEN}Copy complete!${RS}"

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

sed -i -r 's/(#|^)ADDRESS .*/ADDRESS '"$DB_HOST"'/' /tgstation/config/dbconfig.txt
sed -i -r 's/(#|^)FEEDBACK_LOGIN .*/FEEDBACK_LOGIN '"$DB_USER"'/' /tgstation/config/dbconfig.txt
sed -i -r 's/(#|^)FEEDBACK_PASSWORD .*/FEEDBACK_PASSWORD '"$DB_PASS"'/' /tgstation/config/dbconfig.txt

function envvar_override () {
  ### FUNCTION for overriding options in a file using the exported environment variables
  # Syntax:
  # envvar_override "<envvar prefix>"" "<filename in container>"

  # Overriding options
  PREFIX=$1
  FILENAME=$2

  env | grep "$PREFIX"| while read p
  do
    OPTION=`echo $p | cut -d "=" -f 1 | sed s/"$PREFIX"//`
    VALUE=`echo $p | cut -d "=" -f 2`
    # Comment out logic, comments line out if value is #
    if [[ "${VALUE}" == "#" ]]; then 
      echo "Commenting out option \"$OPTION\" in $FILENAME"
      sed -i -r 's/^'"$OPTION"'.*/#&/' "$FILENAME"
    else
      echo "Injecting option \"$OPTION\" with value \"$VALUE\" in $FILENAME"
      sed -i -r 's/(#|^)'"$OPTION"'.*/'"$OPTION"' '"$VALUE"'/' "$FILENAME"
    fi
  done
}
# Overriding game options
envvar_override "TG_GAME_" "/tgstation/config/game_options.txt"


# Setting ranks
export IFS=","
if [[ ! -z "${CKEYRANKS}" ]]; then
  echo -e "${PURPLE}[${YELLOW}---${PURPLE}]${RS} Inserting ranks..."
  echo "" > /tgstation/config/admins.txt
  echo -e "${RED}admins.txt has been reset!${RS}"
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