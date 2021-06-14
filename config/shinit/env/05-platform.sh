#!/bin/sh

case "$(uname -s 2>/dev/null)" in
    (Linux)
        case "$(uname -r 2>/dev/null)" in
            (*[Mm]'icrosoft'*)
                # may misdetect custom kernels with misguiding names
                SHINIT_PLATFORM='wsl'
            ;;

            (*)
                SHINIT_PLATFORM='linux'
            ;;
        esac
    ;;

    (OpenBSD)
        SHINIT_PLATFORM='openbsd'
    ;;

    (*)
        SHINIT_PLATFORM=''
    ;;
esac
