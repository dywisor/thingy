#!/bin/sh

# SHINIT_THINGS_BASEDIR must be set
if [ -n "${SHINIT_THINGS_BASEDIR-}" ]; then
    export SHINIT_THINGS_BASEDIR
else
    # can only return in sourced context
    return 2 2>/dev/null || exit 2
fi

# SHINIT_THINGS_LOCALDIR should be set, not enforced
if [ -n "${SHINIT_THINGS_LOCALDIR-}" ]; then
    export SHINIT_THINGS_LOCALDIR
fi

[ -n "${SHINIT_PATH_BAK-}" ] || SHINIT_PATH_BAK="${PATH-}"

shinit_unload_functions() {
    unset -v SHINIT_PATH_BAK

    unset -v SHINIT_PLATFORM_NAME

    unset -f shinit_setvar

    unset -f shinit_first_file
    unset -f shinit_locate_config_file

    unset -f shinit_load_env_from_file
    unset -f shinit_load_env_from_dir
    unset -f shinit_load_env

    unset -f shinit_PATH_has
    unset -f shinit_PATH_add
    unset -f shinit_PATH_addif

    unset -f shinit_unload_functions
}

# shinit_setvar ( varname, *cmdv, **<varname>! )
#
#  Runs a command and exports its non-empty output as variable.
#
shinit_setvar() {
   local varname
   local val

   varname="${1}"
   shift || return 2
   [ $# -gt 0 ] || return 3

   val="$( "${@}" 2>/dev/null )" && [ -n "${val}" ] || return

   export "${varname}=${val}"
}

# shinit_first_file ( filepath..., **v0! )
#
#   Picks the first readable file out of the given
#   list of candidates and stores it in %v0.
#
shinit_first_file() {
    v0=

    while [ $# -gt 0 ]; do
        if [ -n "${1}" ] && [ -f "${1}" ] && [ -r "${1}" ]; then
            v0="${1}"
            return 0
        fi

        shift
    done

    return 1
}

# shinit_locate_config_file ( relpath, **v0! )
#
shinit_locate_config_file() {
    local path
    local relpath

    [ -n "${1-}" ] || return 64
    relpath="${1}"

    set --

    if [ -n "${SHINIT_THINGS_LOCALDIR-}" ]; then
        set -- "${@}" "${SHINIT_THINGS_LOCALDIR}/config/${1}"
    fi

    set -- "${@}" "${SHINIT_THINGS_BASEDIR}/config/${1}"

    shinit_first_file "${@}"
}

# shinit_load_env_from_file ( filepath )
shinit_load_env_from_file() {
    [ -n "${1-}" ] || return 64
    [ -r "${1}" ] || return 2
    . "${1}"
}

# shinit_load_env_from_dir ( dirpath )
shinit_load_env_from_dir() {
    local env_file

    [ -n "${1-}" ] || return 64
    [ -d "${1}"  ] || return 1

    case "$-" in
        (*f*)
            set +f
            for env_file in "${1}/"*.sh; do
                [ -r "${env_file}" ] && . "${env_file}" || :
            done
            set -f
        ;;

        (*)
            for env_file in "${1}/"*.sh; do
                [ -r "${env_file}" ] && . "${env_file}" || :
            done
        ;;
    esac
}

# shinit_load_env ( name )
shinit_load_env() {
    [ -n "${1-}" ] || return 64

    shinit_load_env_from_file "${SHINIT_THINGS_BASEDIR}/config/shinit/${1}.sh" || :
    shinit_load_env_from_dir  "${SHINIT_THINGS_BASEDIR}/config/shinit/${1}" || :

    if \
        [ -n "${SHINIT_THINGS_LOCALDIR-}" ] && \
        [ -d "${SHINIT_THINGS_LOCALDIR}/config/shinit" ]
    then
        shinit_load_env_from_file "${SHINIT_THINGS_LOCALDIR}/config/shinit/${1}.sh" || :
        shinit_load_env_from_dir  "${SHINIT_THINGS_LOCALDIR}/config/shinit/${1}" || :
    fi
}


# int shinit_PATH_has ( dir )
shinit_PATH_has() {
   [ -n "${1-}" ] || return 0
   case ":${PATH-}:" in
      *":${1}:"*)
         return 0
      ;;
      *)
         return 1
      ;;
   esac
}

# void shinit_PATH_add ( *dirs )
shinit_PATH_add() {
   while [ ${#} -gt 0 ]; do
      shinit_PATH_has "${1}" || PATH="${1}${PATH:+:}${PATH-}"
      shift
   done
}

# void shinit_PATH_addif ( *dirs )
shinit_PATH_addif() {
   while [ ${#} -gt 0 ]; do
      if ! shinit_PATH_has "${1}" && [ -d "${1}" ]; then
         PATH="${1}${PATH:+:}${PATH-}"
      fi
      shift
   done
}


# bash compat
#  init some basic user-related vars
#
[ -n "${EUID-}" ] || shinit_setvar EUID id -u
[ -n "${UID-}"  ] || shinit_setvar UID  id -ru
[ -n "${USER-}" ] || shinit_setvar USER id -rnu

if [ -z "${HOME-}" ] && [ -n "${USER-}" ]; then
    HOME="$( 2>/dev/null getent passwd "${USER}" | cut -d : -f 6 )"

    if [ -n "${HOME}" ]; then
        export HOME
    else
        unset -v HOME
    fi
fi

# load non-interactive shell environment
shinit_load_env 'env' || :


case "${-}" in
    # interactive shell: set PS1, load additional shell environment
    *i*)
        PS1='\u@\h \w \$ '
        [ ! -e /CHROOT ] || PS1="(chroot) ${PS1}"

        if [ -d "${SHINIT_THINGS_BASEDIR}/config/shinit" ]; then
            shinit_want_fancy_ps1=

            shinit_load_env 'aliases' || :
            shinit_load_env 'ienv' || :

            if [ -z "${shinit_want_fancy_ps1-}" ]; then
                case "$(tty 2>/dev/null)" in

                    (/dev/tty[A-Za-z]*)
                        true
                    ;;

                    (/dev/pts/?*|/dev/tty[0-9]*)
                        shinit_want_fancy_ps1=true
                    ;;

                    (/dev/console)
                        case "${container:-_}" in
                            (systemd-nspawn)
                                shinit_want_fancy_ps1=true
                            ;;

                            (*)
                                if { systemd-detect-virt -q -c; } 1>/dev/null 2>&1; then
                                    want_fancy_ps1=true
                                fi
                            ;;
                        esac
                    ;;
                esac
            fi

            if [ "${shinit_want_fancy_ps1}" = 'true' ]; then
                if ! shinit_load_env_from_file "${SHINIT_THINGS_BASEDIR}/config/shinit/fancy-ps1.sh"; then
                    PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
                    [ ! -e /CHROOT ] || PS1="(chroot) ${PS1}"
                fi
            fi

            SHINIT_PS1="${PS1}"

            unset -v shinit_want_fancy_ps1
        fi
    ;;

    # non-interactive shell: unload functions
    *)
        shinit_unload_functions || :
    ;;
esac

# discard result var result
unset -v v0

:
