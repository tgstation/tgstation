#!/bin/bash
set -euo pipefail

source dependencies.sh

wget -O ~/dreamchecker "https://github.com/SpaceManiac/SpacemanDMM/releases/download/$SPACEMAN_DMM_VERSION/dreamchecker"
chmod +x ~/dreamchecker
~/dreamchecker --version
