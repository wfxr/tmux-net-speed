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

update_speeds() {
    local last_update now elapsed
    last_update=$(get_tmux_option "@netspeed_last_update" "0")
    now=$(date +%s)
    elapsed=$((now - last_update))
    # Already updated within this second (dedup concurrent rx/tx calls)
    (( elapsed < 1 )) && return

    local rx_cur tx_cur rx_pre tx_pre rx_diff tx_diff
    rx_cur=$(get_bytes rx_bytes)
    tx_cur=$(get_bytes tx_bytes)
    rx_pre=$(get_tmux_option "@netspeed_rx_bytes" "$rx_cur")
    tx_pre=$(get_tmux_option "@netspeed_tx_bytes" "$tx_cur")

    rx_diff=$(( (rx_cur - rx_pre) / elapsed ))
    tx_diff=$(( (tx_cur - tx_pre) / elapsed ))
    (( rx_diff < 0 )) && rx_diff=0
    (( tx_diff < 0 )) && tx_diff=0

    set_tmux_option "@netspeed_rx_bytes_display" "$(bytestohuman $rx_diff)/s"
    set_tmux_option "@netspeed_tx_bytes_display" "$(bytestohuman $tx_diff)/s"
    set_tmux_option "@netspeed_rx_bytes" "$rx_cur"
    set_tmux_option "@netspeed_tx_bytes" "$tx_cur"
    set_tmux_option "@netspeed_last_update" "$now"
}

# $1: rx_bytes/tx_bytes
# $2: format
main() {
    local field=$1
    update_speeds
    printf "${2:-%8s}" "$(get_tmux_option "@netspeed_${field}_display" "   0B/s")"
}

main "$@"
