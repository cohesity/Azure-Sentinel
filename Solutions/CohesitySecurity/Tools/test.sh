#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

../Tests/az.test.py
error_handler "Failed to run az.test.py."

../Tests/alert.test.py
error_handler "Failed to run alert.test.py."

../Tests/helios.test.py
error_handler "Failed to run helios.test.py."

cd -
