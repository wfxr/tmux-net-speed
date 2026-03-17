#!/usr/bin/env bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SDIR/helpers.sh"

# $1: rx_bytes/tx_bytes
get_bytes() {
    case $(get_os) in
        osx)
            netstat -ibn | sort -u -k1,1 | grep ':' | grep -Ev '^(lo|docker).*' |
                awk '{rx += $7;tx += $10;}END{print "rx_bytes "rx,"\ntx_bytes "tx}' |
                grep "$1" | awk '{print $2}'
            ;;
        linux)
            for file in /sys/class/net/*; do
                [[ $file =~ .*/(lo|docker.*) ]] || cat "$file/statistics/$1"
            done | sum_column 2>/dev/null
            ;;
        freebsd)
            netstat -ibnW | sort -u -k1,1 | grep ':' | grep -Ev '^lo.*' |
                awk '{rx += $8;tx += $11;}END{print "rx_bytes "rx,"\ntx_bytes "tx}' |
                grep "$1" | awk '{print $2}'
            ;;
        netbsd|openbsd)
            netstat -ibn | sort -u -k1,1 | grep ':' | grep -Ev '^lo.*' |
                awk '{rx += $5;tx += $6;}END{print "rx_bytes "rx,"\ntx_bytes "tx}' |
                grep "$1" | awk '{print $2}'
            ;;
        *)
            echo 0
            ;;
    esac
}

# $1: rx_bytes/tx_bytes
get_speed() {
    local field=$1
    local pre cur diff speed pre_var time_var pre_time cur_time elapsed
    pre_var="@netspeed_$field"
    time_var="@netspeed_${field}_time"
    cur=$(get_bytes "$field")
    cur_time=$(date +%s)
    pre=$(get_tmux_option "$pre_var" "$cur")
    pre_time=$(get_tmux_option "$time_var" "$cur_time")
    elapsed=$((cur_time - pre_time))
    (( elapsed < 1 )) && elapsed=1
    diff=$(( (cur - pre) / elapsed ))
    (( diff < 0 )) && diff=0
    speed=$(bytestohuman $diff)
    echo "${speed}/s"
    set_tmux_option "$pre_var" "$cur"
    set_tmux_option "$time_var" "$cur_time"
}

# $1: tx_bytes/tx_bytes
# $2: format
main() {
    printf "${2:-%8s}" "$(get_speed "$1")"
}

main "$@"
