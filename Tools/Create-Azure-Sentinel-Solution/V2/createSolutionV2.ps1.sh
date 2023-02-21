#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

pwsh ./createSolutionV2.ps1
../../../Solutions/CohesitySecurity/Package/mainTemplate.json.sh
