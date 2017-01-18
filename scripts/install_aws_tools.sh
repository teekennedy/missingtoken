#!/usr/bin/env bash

# This script sets up AWS related Python tools for this project using a virtual
# environment. This script should be ran from the project root directory. This
# script is safe to run when the virtual environment already exists. The tools
# installed are as follows:
PYTHON_PIP_PACKAGES="awscli certbot-s3front"

# The virtual environment directory relative to the project root.
# When editing this value, edit the corresponding value in .gitignore
PYTHON_VENV_DIR="_env27"
PYTHON_VENV_COMMAND="virtualenv-2.7"

if [ -d "$PYTHON_VENV_DIR" ]; then
    echo "=> Python virtual environment already created."
else
    echo "=> Creating python virtual environment.."
    $PYTHON_VENV_COMMAND $PYTHON_VENV_DIR
fi

echo "=> Installing tools in virtual environment.."

$PYTHON_VENV_DIR/bin/pip install $PYTHON_PIP_PACKAGES

echo "=> Done!"
echo
echo "MacOS users: install 'dialog' as a dependency for certbot-s3front."
echo "    brew install dialog"
