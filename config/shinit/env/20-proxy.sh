#!/bin/sh

# @virtual void set_default_proxy_env ( **<proxy_vars>! )
#
#  Local override env files may set this function
#  to provide a default proxy.
#
#  (proxy_knock_knock() and _set_proxy_env() may be of use
#  for their implementation.)
#
#  As an alternative, the default proxy environment may also
#  be read from ${SHINIT_THINGS_LOCALDIR}/config/proxy.sh
#  (which should export the appropriate variables on its own).
#
#set_default_proxy_env() { _set_proxy_env ...; }


# @shbool proxy_knock_knock ( host, port, [timeout:=2] )
#
#   Returns true if host:port is reachable, else false.
#
#   Needs nc and works on select distributions only (tested w/ Debian/Ubuntu).
#
#   NOTE: this actually a TCP port checker
#
#   @COMPAT: -z option may be problematic
#
proxy_knock_knock() {
    nc -z -w "${3:-2}" "${1:?}" "${2:?}" < /dev/null 1>/dev/null 2>&1
}


# @shbool proxy_knock_knock_select ( timeout:=2, proxy..., **v0! )
#
#
#   Accepts a series of proxy candidates (host:port pairs)
#   and returns the first reachable one via %v0.
#   The status code indicates whether at least one proxy was found.
#
#   All candidates will be checked in parallel,
#   passing 1000s of hosts to this function at once is highly discouraged.
#
#   The %timeout parameter is mandatory, but may be empty.
#
#   Note: IPv6 addresses are not properly supported, but should work as long
#         as the last colon-separated component is the destination port.
#
proxy_knock_knock_select() {
    v0=

    local timeout
    local px
    local wait_list
    local job_id
    local idx

    [ $# -gt 0 ] || return 64
    timeout="${1-}"

    wait_list=
    for px; do
        proxy_knock_knock "${px%:*}" "${px##*:}" "${timeout}" &
        wait_list="${wait_list:+${wait_list} }${!}"
    done

    px=
    idx=0
    for job_id in ${wait_list}; do
        idx=$(( idx + 1 ))
        if wait "${job_id}"; then
            # EVAL (quoted)
            [ -n "${px}" ] || eval "px=\"\${${idx}}\""
        fi
    done

    v0="${px}"
    [ -n "${v0}" ]
}


# void unset_proxy_env ( **<proxy_vars>! )
#
#  Unsets (and unexports) all proxy-related variables.
#
unset_proxy_env() {
    unset -v http_proxy
    unset -v https_proxy
    unset -v ftp_proxy
    unset -v no_proxy

    unset -v HTTP_PROXY
    unset -v HTTPS_PROXY
    unset -v FTP_PROXY
    unset -v NO_PROXY
}


# void _set_proxy_env ( proxy, **<proxy_vars>! )
#
#  Sets and exports all proxy-related variables
#  so that the given proxy url will be used.
#
#  The no_proxy bypass gets set to localhost.
#
_set_proxy_env() {
    export http_proxy="${1}"
    export https_proxy="${1}"
    export ftp_proxy="${1}"
    export no_proxy="127.0.0.1,localhost"

    export HTTP_PROXY="${http_proxy}"
    export HTTPS_PROXY="${https_proxy}"
    export FTP_PROXY="${ftp_proxy}"
    export NO_PROXY="${no_proxy}"
}


# int set_proxy_env ( [proxy_url|proxy_host|'none'|'default'], **<proxy_vars>! )
#
set_proxy_env() {
    case "${1:-default}" in
        # default is dispatch or static file
        ('default')
            if command -V set_default_proxy_env 1>/dev/null 2>&1; then
                set_default_proxy_env

            elif \
                [ -n "${SHINIT_THINGS_LOCALDIR-}" ] && \
                [ -r "${SHINIT_THINGS_LOCALDIR}/config/proxy.sh" ]
            then
                . "${SHINIT_THINGS_LOCALDIR}/config/proxy.sh" || return 3

            else
                return 2
            fi
        ;;

        # none means no proxy
        ('none')
            unset_proxy_env
        ;;

        # proto://proxy
        (?*'://'?*)
            _set_proxy_env "${1}"
        ;;

        # (invalid)
        (*'://'*) return 64 ;;

        # guess protocol (http://) when omitted
        (?*:?*)
            _set_proxy_env "http://${1}"
        ;;

        # (invalid)
        (*:*) return 64 ;;

        # guess protocol and port when omitted (http + port 3128 then)
        (?*)
            _set_proxy_env "http://${1}:3128"
        ;;

        # (invalid)
        (*) return 64 ;;
    esac
}
