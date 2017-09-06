#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set_tmux_option() {
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}
get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value="$(tmux show-option -gqv "$option")"

    [[ -z "$option_value" ]] && echo $default_value || echo $option_value
}

download_interpolation="\#{download_speed}"
download_speed_format=$(get_tmux_option @upload_speed_format "%7s")

download_speed="#($CURRENT_DIR/scripts/net-speed rx_bytes)"
do_interpolation() {
    local input=$1
    local result=""

    result=${input/$download_interpolation/$download_speed}
    result=${result/$net_interpolation/$net_speed}
    result=${result/$upload_interpolation/$upload_speed}

    echo $result
}

update_tmux_option() {
    local option=$1
    local option_value=$(get_tmux_option "$option")
    set_tmux_option "$option" "$(do_interpolation "$option_value")"
}

main() {
    update_tmux_option "status-right"
    update_tmux_option "status-left"
}
main
