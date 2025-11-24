#!/bin/bash
# Test az integration

# Setup temp env
export _Z_DATA=$(mktemp)
echo "Using temp data file: $_Z_DATA"

# Add bin to PATH so alt-z command is found
export PATH=$PWD/bin:$PATH

# Source az.sh
source ./az.sh

# 1. Add some paths
echo "Adding paths..."
mkdir -p /tmp/test/dir1
mkdir -p /tmp/test/dir2
az add /tmp/test/dir1
az add /tmp/test/dir2
az add /tmp/test/dir1

# 2. Verify data file content
echo "Data file content:"
cat $_Z_DATA

# 3. Test query (echo mode)
echo "Querying 'dir1' (echo mode)..."
RESULT=$(az -e dir1)
echo "Result: $RESULT"

if [ "$RESULT" == "/tmp/test/dir1" ]; then
    echo "PASS: az -e returned correct path"
else
    echo "FAIL: az -e returned '$RESULT'"
fi

# 4. Test query (cd mode - simulated)
echo "Querying 'dir2' (cd mode)..."
mkdir -p /tmp/test/dir2
az dir2
if [ "$PWD" == "/tmp/test/dir2" ]; then
    echo "PASS: cd successful"
else
    echo "FAIL: PWD is $PWD, expected /tmp/test/dir2"
fi

# 5. Test explicit query
echo "Querying 'dir1' (explicit query)..."
az query dir1
# Should print path (since we are not capturing, but az function logic for explicit query 'query' 
# in my implementation calls _call_alt_z directly if subcmd is query?
# Wait, my implementation:
# if subcmd != query -> args=("query" args)
# then check flags.
# if cd_mode -> capture and cd.
# So `az query dir1` -> subcmd="query".
# It goes to `check for flags`. `dir1` is not a flag. `cd_mode`=true.
# It captures output and cds.
# So `az query dir1` should also cd.
# Let's verify that.
cd /tmp
az query dir1
if [ "$PWD" == "/tmp/test/dir1" ]; then
    echo "PASS: explicit query cd successful"
else
    echo "FAIL: explicit query cd failed. PWD: $PWD"
fi

# Cleanup
rm $_Z_DATA
rm -rf /tmp/test


