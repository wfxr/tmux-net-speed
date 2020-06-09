#!/usr/bin/env bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SDIR/helpers.sh"

# $1: rx_bytes/tx_bytes
get_bytes() {
    for file in /sys/class/net/*; do
        [[ $file =~ .*/(lo|docker.*) ]] || cat "$file/statistics/$1"
    done | sum_column 2>/dev/null
}

# $1: rx_bytes/tx_bytes
get_speed() {
    local pre cur diff speed pre_var
    pre_var="@netspeed_$1"
    cur=$(get_bytes "$1")
    pre=$(get_tmux_option "$pre_var" "$cur")
    diff=$(("$cur" - "$pre"))
    speed=$(numfmt --to=iec --padding=7 $diff)
    [[ $diff -lt 1024 ]] && speed+="B"
    echo "${speed}/s"
    set_tmux_option "$pre_var" "$cur"
}

# $1: tx_bytes/tx_bytes
# $2: format
main() {
    printf "${2:-%7s}" "$(get_speed $1)"
}

main "$@"
