#!/bin/sh

if [ -n "${USER-}" ]; then
    if [ -d "/ram/users/${USER}/." ]; then
        export SHINIT_USER_RAMDISK="/ram/users/${USER}"

        # TMPDIR
        if [ -d "${SHINIT_USER_RAMDISK}/tmp" ]; then
            export TMPDIR="${SHINIT_USER_RAMDISK}/tmp"
        fi

        # TMUX_TMPDIR
        if [ -d "${SHINIT_USER_RAMDISK}/tmux" ]; then
            export TMUX_TMPDIR="${SHINIT_USER_RAMDISK}/tmux"
        fi

        # SSH_AUTH_SOCK
        #  For an ad-hoc ssh-agent setup,
        #  see snippets/config/shinit/ssh-agent.sh
        if [ -S "${SHINIT_USER_RAMDISK}/ssh-agent.socket" ]; then
            export SSH_AUTH_SOCK="${SHINIT_USER_RAMDISK}/ssh-agent.socket"
        fi

    else
        unset -v SHINIT_USER_RAMDISK
    fi
fi
