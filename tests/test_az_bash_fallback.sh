#!/bin/bash
# Test az.sh command-not-found fallback feature for Bash

# Setup temp env
export _Z_DATA=$(mktemp)
echo "Using temp data file: $_Z_DATA"

# Add bin to PATH so alt-z command is found
export PATH=$PWD/bin:$PATH

# Source az.sh
source ./az.sh

# 1. Add some paths to the database
echo "Setting up test directories..."
mkdir -p /tmp/test/myproject
mkdir -p /tmp/test/documents
mkdir -p /tmp/test/downloads

az add /tmp/test/myproject
az add /tmp/test/myproject  # Add twice to increase rank
az add /tmp/test/documents
az add /tmp/test/downloads

# 2. Verify data file content
echo ""
echo "Data file content:"
cat $_Z_DATA

# 3. Test command-not-found fallback
echo ""
echo "Test 1: Typing 'myproject' (non-existent command) should jump to /tmp/test/myproject"
cd /tmp
myproject
if [ "$PWD" = "/tmp/test/myproject" ]; then
    echo "✓ PASS: Command-not-found fallback worked! Jumped to $PWD"
else
    echo "✗ FAIL: Expected to be in /tmp/test/myproject, but PWD is $PWD"
fi

# 4. Test with partial match
echo ""
echo "Test 2: Typing 'doc' should jump to /tmp/test/documents"
cd /tmp
doc
if [ "$PWD" = "/tmp/test/documents" ]; then
    echo "✓ PASS: Partial match worked! Jumped to $PWD"
else
    echo "✗ FAIL: Expected to be in /tmp/test/documents, but PWD is $PWD"
fi

# 5. Test with truly non-existent command
echo ""
echo "Test 3: Typing a truly non-existent command should show error"
nonexistentcommandxyz123 2>&1 | grep -q "command not found"
ret=$?
if [ $ret -eq 0 ]; then
    echo "✓ PASS: Non-existent command showed correct error message"
else
    echo "✗ FAIL: Expected 'command not found' error message"
fi

# Cleanup
echo ""
echo "Cleaning up..."
rm $_Z_DATA
rm -rf /tmp/test

echo ""
echo "All tests completed!"
