#!/bin/sh


with_proxy_env() {
    [ $# -gt 1 ] || return 64
    (
        set_proxy_env "${1}" || exit
        shift || exit
        "${@}"
    )
}

without_proxy_env() {
    [ $# -gt 0 ] || return 64
    (
        unset_proxy_env || exit
        "${@}"
    )
}
