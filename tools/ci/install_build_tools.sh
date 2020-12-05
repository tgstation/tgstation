#!/bin/bash
set -euo pipefail
base_dir="$(dirname "${0}")"

source dependencies.sh
source "${base_dir}/install_node.sh"
pip3 install --user PyYaml
pip3 install --user beautifulsoup4
