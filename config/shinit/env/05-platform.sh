#!/bin/sh

case "$(uname -s 2>/dev/null)" in
    (Linux)
        case "$(uname -r 2>/dev/null)" in
            (*[Mm]'icrosoft'*)
                # may misdetect custom kernels with misguiding names
                SHINIT_PLATFORM_NAME='wsl'
            ;;

            (*)
                SHINIT_PLATFORM_NAME='linux'
            ;;
        esac
    ;;

    (OpenBSD)
        SHINIT_PLATFORM_NAME='openbsd'
    ;;

    (*)
        SHINIT_PLATFORM_NAME=''
    ;;
esac
