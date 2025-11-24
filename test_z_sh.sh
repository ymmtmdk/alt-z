#!/bin/bash
# Test alt-z integration

# Setup temp env
export _Z_DATA=$(mktemp)
echo "Using temp data file: $_Z_DATA"

# Source z.sh
# We need to make sure we are in the right dir for z.sh to find python script
# The script uses dirname BASH_SOURCE, so it should work if we source it from here.
source ./z.sh

# 1. Add some paths
echo "Adding paths..."
mkdir -p /tmp/test/dir1
mkdir -p /tmp/test/dir2
alt-z add /tmp/test/dir1
alt-z add /tmp/test/dir2
alt-z add /tmp/test/dir1

# 2. Verify data file content
echo "Data file content:"
cat $_Z_DATA

# 3. Test query (echo mode)
echo "Querying 'dir1' (echo mode)..."
RESULT=$(alt-z -e dir1)
echo "Result: $RESULT"

if [ "$RESULT" == "/tmp/test/dir1" ]; then
    echo "PASS: alt-z -e returned correct path"
else
    echo "FAIL: alt-z -e returned '$RESULT'"
fi

# 4. Test query (cd mode - simulated)
echo "Querying 'dir2' (cd mode)..."
mkdir -p /tmp/test/dir2
alt-z dir2
if [ "$PWD" == "/tmp/test/dir2" ]; then
    echo "PASS: cd successful"
else
    echo "FAIL: PWD is $PWD, expected /tmp/test/dir2"
fi

# 5. Test explicit query
echo "Querying 'dir1' (explicit query)..."
alt-z query dir1
# Should print path (since we are not capturing, but alt-z function logic for explicit query 'query' 
# in my implementation calls _alt_z_python_script directly if subcmd is query?
# Wait, my implementation:
# if subcmd != query -> args=("query" args)
# then check flags.
# if cd_mode -> capture and cd.
# So `alt-z query dir1` -> subcmd="query".
# It goes to `check for flags`. `dir1` is not a flag. `cd_mode`=true.
# It captures output and cds.
# So `alt-z query dir1` should also cd.
# Let's verify that.
cd /tmp
alt-z query dir1
if [ "$PWD" == "/tmp/test/dir1" ]; then
    echo "PASS: explicit query cd successful"
else
    echo "FAIL: explicit query cd failed. PWD: $PWD"
fi

# Cleanup
rm $_Z_DATA
rm -rf /tmp/test

