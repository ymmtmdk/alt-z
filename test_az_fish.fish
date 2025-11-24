#!/usr/bin/env fish
# Test az.fish integration

# Setup temp env
set -x _Z_DATA (mktemp)
echo "Using temp data file: $_Z_DATA"

# Add bin to PATH so alt-z command is found
set -x PATH $PWD/bin $PATH

# Source az.fish
source ./az.fish

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
set RESULT (az -e dir1)
echo "Result: $RESULT"

if test "$RESULT" = "/tmp/test/dir1"
    echo "PASS: az -e returned correct path"
else
    echo "FAIL: az -e returned '$RESULT'"
end

# 4. Test query (cd mode)
echo "Querying 'dir2' (cd mode)..."
mkdir -p /tmp/test/dir2
az dir2
if test "$PWD" = "/tmp/test/dir2"
    echo "PASS: cd successful"
else
    echo "FAIL: PWD is $PWD, expected /tmp/test/dir2"
end

# 5. Test explicit query
echo "Querying 'dir1' (explicit query)..."
cd /tmp
az query dir1
if test "$PWD" = "/tmp/test/dir1"
    echo "PASS: explicit query cd successful"
else
    echo "FAIL: explicit query cd failed. PWD: $PWD"
end

# Cleanup
rm $_Z_DATA
rm -rf /tmp/test
