#!/bin/bash
set -euo pipefail

source dependencies.sh

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION

pip3 install --user PyYaml
pip3 install --user beautifulsoup4

phpenv global $PHP_VERSION
