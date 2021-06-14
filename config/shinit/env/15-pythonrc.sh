#!/bin/sh

if [ -z "${PYTHONSTARTUP-}" ]; then
    if [ -n "${HOME-}" ] && [ -r "${HOME}/.config/pythonrc" ]; then
        export PYTHONSTARTUP="${HOME}/.config/pythonrc"

    elif shinit_locate_config_file 'pythonrc'; then
        export PYTHONSTARTUP="${v0}"

    elif [ -r /etc/pythonrc ]; then
        export PYTHONSTARTUP=/etc/pythonrc
    fi
fi
