#!/usr/bin/env bash
# shellcheck disable=SC2218

set_tmux_option() {
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}

get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value
    option_value="$(tmux show-option -gqv "$option")"

    [[ -z "$option_value" ]] && echo "$default_value" || echo "$option_value"
}

get_os() {
    case "$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "osx" ;;
        solaris*) echo "solaris" ;;
        freebsd*) echo "freebsd" ;;
        netbsd*)  echo "netbsd" ;;
        openbsd*) echo "openbsd" ;;
        bsd*)     echo "bsd" ;;
        msys*)    echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

IGNORED_IFACES='^(lo|docker|veth|br-|virbr|tun|vnet)'

# Shared awk snippet: precompute whitelist in BEGIN, skip_iface() returns 1 if
# the interface should be excluded.
AWK_IFACE_FILTER='
BEGIN {
    if (ifaces != "") {
        n = split(ifaces, _arr)
        for (i = 1; i <= n; i++) wanted[_arr[i]] = 1
    }
}
function skip_iface(name) {
    if (ifaces != "") return !(name in wanted)
    return (name ~ ignore)
}
'

# $1: rx_bytes/tx_bytes
get_bytes() {
    local field=$1
    local os
    os=$(get_os)
    local interfaces
    interfaces=$(get_tmux_option "@net_speed_interfaces" "")
    case $os in
        linux)
            awk -v field="$field" -v ignore="$IGNORED_IFACES" -v ifaces="$interfaces" \
                "$AWK_IFACE_FILTER"'
            NR > 2 {
                gsub(/:/, "", $1)
                if (skip_iface($1)) next
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
                    -v rx_col="$rx_col" -v tx_col="$tx_col" -v ifaces="$interfaces" \
                    "$AWK_IFACE_FILTER"'
                /:/ && !seen[$1]++ {
                    if (skip_iface($1)) next
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

bytestohuman() {
    local bytes=${1:-0}
    local units="BKMGTPEZY"
    local i=0 divisor=1

    while (( bytes / divisor >= 1024 && i < ${#units} - 1 )); do
        divisor=$((divisor * 1024))
        (( i++ ))
    done

    local unit=${units:$i:1}
    local value=$((bytes / divisor))

    if (( i == 0 || value > 99 )); then
        printf "%4d%s" "$value" "$unit"
    else
        local frac=$(( (bytes % divisor) * 10 / divisor ))
        printf "%4s%s" "${value}.${frac}" "$unit"
    fi
}
