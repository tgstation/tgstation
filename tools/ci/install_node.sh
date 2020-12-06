#!/bin/bash
set -euo pipefail

source dependencies.sh

## Install NVM if it's not in our environment
if [[ ! -d ~/.nvm ]]; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
fi

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION
