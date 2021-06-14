#!/bin/sh

if [ "${SHINIT_PLATFORM:-_}" = 'wsl' ]; then
    # enable fancy PS1 in WSL environment
    shinit_want_fancy_ps1=true

    # Set a sane umask
    if t0="$(umask 2>/dev/null)" && [ "${t0}" = '0000' ]; then
        umask 0022 1>/dev/null 2>&1 || :
    fi
    unset -v t0

    # There's a WSL bug where gpg hangs forever
    # instead of asking for a passphrase.
    # Well, thanks for that.
    # Explicitly setting the TTY helps.
    if [ -z "${GPG_TTY-}" ]; then
        if t0="$( tty 2>/dev/null )" && [ -n "${t0}" ]; then
            export GPG_TTY="${t0}"
        fi
        unset -v t0
    fi

    # Reset working directory when currently below /mnt/
    #  (chdir to home rather than Windows' USERPROFILE;
    #  skip when running inside tmux)
    if [ -z "${TMUX-}" ]; then
        case "${PWD-}" in
            ('/mnt/'?*) cd 1>/dev/null 2>&1 ;;
        esac
    fi

    # WSL <> windows exec helper
    start_in_windows() { windows_powershell -Command start "${@}"; }
    alias start='start_in_windows'
fi
