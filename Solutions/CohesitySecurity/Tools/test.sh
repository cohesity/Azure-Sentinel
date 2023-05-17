#!/bin/zsh

# Description: This script runs a series of tests: az.test.py, alert.test.py, and helios.test.py.
# Each test is followed by an error handler to handle test failures.

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
