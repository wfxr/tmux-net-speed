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
        bsd*)     echo "bsd" ;;
        msys*)    echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

sum_column() {
    awk '{sum += $1;}END{print sum;}'
}
