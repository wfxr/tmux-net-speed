#!/usr/bin/env bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SDIR/../lib.sh"

failures=0

assert_valid_bytes() {
    local field=$1
    local value=$(get_bytes "$field")
    # Must be a non-negative integer
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "FAIL: get_bytes($field) = [$value], expected non-negative integer"
        (( failures++ ))
        return
    fi
    # Must be > 0 (any real system has some traffic)
    if (( value == 0 )); then
        echo "WARN: get_bytes($field) = 0 (expected > 0 on a system with network activity)"
    fi
}

assert_valid_bytes rx_bytes
assert_valid_bytes tx_bytes

# rx and tx should be independent values
rx=$(get_bytes rx_bytes)
tx=$(get_bytes tx_bytes)
if [[ "$rx" == "$tx" ]]; then
    echo "WARN: rx_bytes ($rx) == tx_bytes ($tx), may indicate a problem"
fi

if (( failures > 0 )); then
    echo "$failures test(s) failed"
    exit 1
else
    echo "All tests passed"
fi
