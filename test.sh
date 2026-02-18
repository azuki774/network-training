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

echo "--- 同一セグメント ---"
run_test "clab-network-demo-srvA1" "192.168.1.1"    "srvA1    -> rtA      (192.168.1.1)   [Network A]"
run_test "clab-network-demo-srvB1" "192.168.2.1"    "srvB1    -> rtB      (192.168.2.1)   [Network B]"
run_test "clab-network-demo-srvExt" "203.0.113.1"   "srvExt   -> rt-ext   (203.0.113.1)   [External Network]"

echo ""
echo "--- 内部ルータ間リンク (OSPF) ---"
run_test "clab-network-demo-rtA"   "10.0.0.2"       "rtA      -> rt-asbr  (10.0.0.2)      [Link rtA--rt-asbr]"
run_test "clab-network-demo-rt-asbr" "10.0.0.1"     "rt-asbr  -> rtA      (10.0.0.1)      [Link rtA--rt-asbr]"
run_test "clab-network-demo-rt-asbr" "10.0.0.6"     "rt-asbr  -> rtB      (10.0.0.6)      [Link rt-asbr--rtB]"
run_test "clab-network-demo-rtB"   "10.0.0.5"       "rtB      -> rt-asbr  (10.0.0.5)      [Link rt-asbr--rtB]"

echo ""
echo "--- BGP リンク (eBGP AS65001<->AS65002) ---"
run_test "clab-network-demo-rt-asbr" "10.0.1.2"     "rt-asbr  -> rt-ext   (10.0.1.2)      [BGP Link]"
run_test "clab-network-demo-rt-external" "10.0.1.1" "rt-ext   -> rt-asbr  (10.0.1.1)      [BGP Link]"

echo ""
echo "--- E2E (OSPF + BGP 経由) ---"
run_test "clab-network-demo-srvA1" "192.168.2.10"   "srvA1    -> srvB1    (192.168.2.10)   [E2E 内部往路]"
run_test "clab-network-demo-srvB1" "192.168.1.10"   "srvB1    -> srvA1    (192.168.1.10)   [E2E 内部復路]"

TOTAL=$((PASS + FAIL))
echo ""
echo "=== Results: ${PASS}/${TOTAL} passed ==="

if [ "$FAIL" -gt 0 ]; then
    echo "FAILED: $FAIL test(s) failed."
    exit 1
fi

echo "All tests passed."
