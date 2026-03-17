#!/usr/bin/env bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SDIR/helpers.sh"

IGNORED_IFACES='^(lo|docker|veth|br-|virbr|tun|vnet)'

# $1: rx_bytes/tx_bytes
get_bytes() {
    local field=$1
    local os=$(get_os)
    case $os in
        linux)
            awk -v field="$field" -v ignore="$IGNORED_IFACES" '
            NR > 2 {
                gsub(/:/, "", $1)
                if ($1 ~ ignore) next
                if (field == "rx_bytes") sum += $2
                else if (field == "tx_bytes") sum += $10
            }
            END { printf "%.0f", sum }
            ' /proc/net/dev
            ;;
        osx|freebsd|netbsd|openbsd)
            local netstat_flags rx_col tx_col
            case $os in
                osx)            netstat_flags="-ibn";  rx_col=7;  tx_col=10 ;;
                freebsd)        netstat_flags="-ibnW"; rx_col=8;  tx_col=11 ;;
                netbsd|openbsd) netstat_flags="-ibn";  rx_col=5;  tx_col=6  ;;
            esac
            netstat $netstat_flags |
                awk -v field="$field" -v ignore="$IGNORED_IFACES" \
                    -v rx_col="$rx_col" -v tx_col="$tx_col" '
                /:/ && !seen[$1]++ {
                    if ($1 ~ ignore) next
                    rx += $rx_col; tx += $tx_col
                }
                END { printf "%.0f", (field == "rx_bytes") ? rx : tx }
                '
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
