#!/usr/bin/env bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SDIR/../lib.sh"

failures=0

assert_eq() {
    local input=$1 expected=$2
    local actual=$(bytestohuman "$input")
    if [[ "$actual" != "$expected" ]]; then
        echo "FAIL: bytestohuman($input) = [$actual], expected [$expected]"
        (( failures++ ))
    fi
}

# Bytes
assert_eq 0          "   0B"
assert_eq 1          "   1B"
assert_eq 500        " 500B"
assert_eq 1023       "1023B"

# Kilobytes
assert_eq 1024       " 1.0K"
assert_eq 1536       " 1.5K"
assert_eq 10240      "10.0K"
assert_eq 102400     " 100K"
assert_eq 1047552    "1023K"

# Megabytes
assert_eq 1048576    " 1.0M"
assert_eq 1572864    " 1.5M"
assert_eq 104857600  " 100M"
assert_eq 123456789  " 117M"

# Gigabytes
assert_eq 1073741824   " 1.0G"
assert_eq 10737418240  "10.0G"
assert_eq 107374182400 " 100G"

# Terabytes
assert_eq 1099511627776 " 1.0T"

if (( failures > 0 )); then
    echo "$failures test(s) failed"
    exit 1
else
    echo "All tests passed"
fi
