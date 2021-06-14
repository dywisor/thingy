#!/bin/sh
#  do not include this file if your console does not support colors.
#
# shellcheck disable=SC1090,SC2039,SC2120

SHINIT_FANCY_PS1_FALLBACK='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
PS1="${SHINIT_FANCY_PS1_FALLBACK}"

if [ "${__SHINIT_HAVE_PS1_COLORS:-X}" != "y" ]; then
    shinit_load_env_from_file "${SHINIT_THINGS_BASEDIR}/config/shinit/ps1-colors.sh" || :
fi

if [ "${__SHINIT_HAVE_SYSEXITS:-X}" != "y" ]; then
    shinit_load_env_from_file "${SHINIT_THINGS_BASEDIR}/config/shinit/sysexits.sh" || :
fi


if [ "${__SHINIT_HAVE_PS1_COLORS:-X}" = "y" ]; then

SHINIT_FANCY_PS1_FALLBACK="\
${PS1_COLOR_PURPLE_LIGHT}\\u${PS1_COLOR_WHITE_LIGHT}@\h${COLOR_DEFAULT_PS1} \
${PS1_COLOR_WHITE_LIGHT}\\w${COLOR_DEFAULT_PS1} \
${PS1_COLOR_PURPLE}\\$ \
${COLOR_DEFAULT_PS1}"


shinit_mkps1_get_color_by_name() {
    case "${1-}" in
        ('green')
            v0="${PS1_COLOR_GREEN_DARK}"
            v1="${PS1_COLOR_GREEN_LIGHT}"
        ;;

        ('red')
            v0="${PS1_COLOR_RED_DARK}"
            v1="${PS1_COLOR_RED_LIGHT}"
        ;;

        ('yellow')
            v0="${PS1_COLOR_YELLOW_DARK}"
            v1="${PS1_COLOR_YELLOW_LIGHT}"
        ;;

        ('purple')
            v0="${PS1_COLOR_PURPLE_LIGHT}"
            v1="${PS1_COLOR_PURPLE}"
        ;;

        (*)
            return 64
        ;;
    esac
}

shinit_mkps1_get_color_default() {
    case "${1}" in
        (0)
            shinit_mkps1_get_color_by_name yellow
        ;;

        (*)
            shinit_mkps1_get_color_by_name purple
        ;;
    esac
}

if ! command -V shinit_mkps1_get_color 1>/dev/null 2>&1; then
    # local files may override the shinit_mkps1_get_color() function
    # prior to includes this file
    shinit_mkps1_get_color() { shinit_mkps1_get_color_default "${@}"; }
fi

# __shinit_mkps1__ ( [color_name] )
__shinit_mkps1__() {
    local _who
    local _workdir
    local _cmdsep
    local _retps
    local _uid
    local c
    local v0
    local v1

    c="${COLOR_DEFAULT_PS1}"
    _workdir="${PS1_COLOR_BLUE_LIGHT}"

    _uid="${UID:-$(id -ru 2>/dev/null)}"

    { [ -n "${1-}" ] && shinit_mkps1_get_color_by_name "${1}"; } \
        || shinit_mkps1_get_color "${_uid:-X}" \
        || return

    if [ "${_uid:-X}" = "0" ]; then
        _who="${v0}"'\h'
        _cmdsep="${v1}"

    else
        _who="${v0}"'\u'"${PS1_COLOR_WHITE_LIGHT}"'@\h'
        _cmdsep="${v1}"
        _workdir="${PS1_COLOR_WHITE_LIGHT}"
    fi

    _who="${_who}${c}"
    _cmdsep="${_cmdsep}\\\$${c}"
    _workdir="${_workdir}\\w${c}"

    ## "hardcoded" colors in $_retps -- could change $COLORVAR to \$COLORVAR
    _retps="\$( \
        _rc=\${?:-0}

        __printrc() {
            printf '%s%s%s ' \
            \"\${1}\" \"[\${2:-\${_rc}}]\" \"${COLOR_DEFAULT_PS1}\"
        }

        __printfail() {
            __printrc \"\${2:-${PS1_COLOR_RED_LIGHT}}\" \"\${1-}\"
        }

        __retps() {
            local v0

            case \"\${_rc}\" in
                (0)   : ;;
                (127) __printrc \"${PS1_COLOR_YELLOW_LIGHT}\" \"CNF\" ;;
                (130) __printrc \"${PS1_COLOR_YELLOW_LIGHT}\" \"^C\" ;;
                (255) __printfail \"DIED\" ;;
                (*)
                    if \
                        [ \"\${__SHINIT_HAVE_SYSEXITS:-X}\" = 'y' ] && \
                        shinit_get_sysexit_name \${_rc}
                    then
                        __printfail \"\${v0}\"
                    else
                        __printfail
                    fi
                ;;
            esac
        }

        __retps
    )"

    PS1="${_retps}${_who} ${_workdir} ${_cmdsep} "
    return 0
}

__shinit_mkps1__ || PS1="${SHINIT_FANCY_PS1_FALLBACK}"
fi
