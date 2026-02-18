#!/bin/bash

PASS=0
FAIL=0

run_test() {
    local container="$1"
    local target_ip="$2"
    local description="$3"

    printf "  %-55s " "$description"
    if docker exec "$container" ping -c 1 -W 2 "$target_ip" > /dev/null 2>&1; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Ping Connectivity Tests ==="
echo ""

run_test "clab-network-demo-srvA1" "192.168.1.1"  "srvA1 -> rtA (192.168.1.1) [同一セグメント]"
run_test "clab-network-demo-srvA1" "192.168.2.10" "srvA1 -> srvB1 (192.168.2.10) [E2E 往路]"
run_test "clab-network-demo-srvB1" "192.168.2.1"  "srvB1 -> rtB (192.168.2.1) [同一セグメント]"
run_test "clab-network-demo-srvB1" "192.168.1.10" "srvB1 -> srvA1 (192.168.1.10) [E2E 復路]"
run_test "clab-network-demo-rtA"   "10.0.0.2"     "rtA -> rtB (10.0.0.2) [ルータ間リンク]"

TOTAL=$((PASS + FAIL))
echo ""
echo "=== Results: ${PASS}/${TOTAL} passed ==="

if [ "$FAIL" -gt 0 ]; then
    echo "FAILED: $FAIL test(s) failed."
    exit 1
fi

echo "All tests passed."
