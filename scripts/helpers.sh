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

bytestohuman() {
    local bytes=${1:-0}
    local units="BKMGTEPYZ"
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
