#!/bin/bash

usage () {
    echo "Usage: ${0##*/} [-h] [-d] [-p]"
    echo "  -h      Show this help"
    echo "  -d      Show parameter dictionaries"
    echo "  -p      Print files content"
}

while getopts ":hdp" opt
do
    case ${opt} in
        h)  usage; exit 0;;
        d)  show_dicts=true;;
        p)  show_contents=true;;
        \?) usage; exit 1;;
    esac
done

PATHS=(%{PATHS})
PARAMS=(%{PARAMS})
for i in "${!PATHS[@]}"; do
    echo -e "$(basename ${PATHS[$i]})${show_dicts+\t ${PARAMS[$i]}}"
    if ${show_contents:-false}; then
        cat "${PATHS[$i]}"
        echo '---'
    fi
done
