#!/bin/sh
# shellcheck disable=SC1090,SC2039

# @virtual @stdout int start_ssh_agent ( *common_argv )
#

# int attach_to_ssh_agent ( **SSH_AUTH_SOCK!, **SSH_AGENT_PID! )
#
attach_to_ssh_agent() {
    local env_file
    local create_new
    local auth_sock

    create_new=false
    auth_sock=

    # existing SSH_AUTH_SOCK gets ignored,
    # this may result in talking to the "wrong" ssh-agent

    # agree on a temporary environment file to use
    if [ -n "${USER_RAMDISK-}" ]; then
        env_file="${USER_RAMDISK}/ssh-agent.env"
        auth_sock="${USER_RAMDISK}/ssh-agent.socket"

    elif [ -n "${USER-}" ]; then
        env_file="/tmp/ssh-agent_${USER}.env"

    else
        # whoops, how to create per-user files
        # with a known path in public spaces then?
        return 2
    fi

    if [ -n "${auth_sock}" ] && [ -S "${auth_sock}" ]; then
        # up and running, leave now
        export SSH_AUTH_SOCK="${auth_sock}"
        unset -v SSH_AGENT_PID
        return 0
    fi

    # load environment file, check whether a new ssh-agent needs to be spawned
    if [ ! -r "${env_file}" ]; then
        create_new=true

    elif ! { . "${env_file}"; } 1>/dev/null; then
        create_new=true

    elif \
        [ -z "${SSH_AUTH_SOCK-}" ] || \
        [ -z "${SSH_AGENT_PID-}" ] || \
        ! kill -0 "${SSH_AGENT_PID}" 1>/dev/null 2>&1
    then
        create_new=true
    fi

    # start new ssh-agent process
    if "${create_new}"; then
        unset -v SSH_AUTH_SOCK
        unset -v SSH_AGENT_PID

        (
            umask 0077 || exit

            # charge @ARGV: ssh-agent options
            set -- -s
            [ -z "${auth_sock}" ] || set -- "${@}" -a "${auth_sock}"

            if command -V start_ssh_agent 1>/dev/null 2>&1; then
                start_ssh_agent "${@}" > "${env_file}" || exit
            else
                # builtin variant: 1 hour timeout for identities
                ssh-agent "${@}" -t 1h > "${env_file}" || exit
            fi
        ) || return 5

        { . "${env_file}"; } 1>/dev/null || return 4
    fi

    [ -n "${SSH_AUTH_SOCK-}" ] || return 2
    [ -n "${SSH_AGENT_PID-}" ] || return 2

    export SSH_AUTH_SOCK
    export SSH_AGENT_PID

    return 0
}


attach_to_ssh_agent || :
