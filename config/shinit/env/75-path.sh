#!/bin/sh

# extend PATH

for __shinit_dir in \
    "${SHINIT_THINGS_BASEDIR}" \
    "${SHINIT_THINGS_LOCALDIR-}" \
    "${HOME-}" \
; do
    if [ -n "${__shinit_dir}" ]; then
        shinit_PATH_addif "${__shinit_dir}/scripts/all"

        # add extra progs in GUI mode (as detected by non-empty DISPLAY var)
        if [ -n "${DISPLAY-}" ]; then
            shinit_PATH_addif "${__shinit_dir}/scripts/x"
        fi

        # platform-specific scripts
        if [ -n "${SHINIT_PLATFORM_NAME-}" ]; then
            shinit_PATH_addif "${__shinit_dir}/scripts/${SHINIT_PLATFORM_NAME}"
        fi
    fi
done

unset -v __shinit_dir

export PATH
