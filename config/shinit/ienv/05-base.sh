#!/bin/sh
#

__nostdout__() { "${@}" 1>/dev/null; }
__nostderr__() { "${@}" 2>/dev/null; }
__quietly__()  { "${@}" 1>/dev/null 2>&1; }
__have_cmd__() { __quietly__ command -V "${1}";  }


newdir() {
    [ -n "${1-}" ] && mkdir -p -- "${1}" && cd -- "${1}"
}

__shinit_cd_command_output() {
    v0="$( "${@}" )" && [ -n "${v0}" ] || return

    cd -- "${v0}"
}

tmpdir() {
    __shinit_cd_command_output mktemp -d
}

git_topdir() {
    __shinit_cd_command_output git rev-parse --show-toplevel
}
