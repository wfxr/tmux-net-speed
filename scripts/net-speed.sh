#!/usr/bin/env bash
# https://github.com/koalaman/shellcheck/issues/3070
# shellcheck disable=SC2218
set -euo pipefail
IFS=$'\n\t'

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SDIR"
source ./lib.sh

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
    # shellcheck disable=SC2059
    printf "${2:-%8s}" "$(get_tmux_option "@netspeed_${field}_display" "   0B/s")"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
