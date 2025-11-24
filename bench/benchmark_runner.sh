#!/bin/bash

IMPL=$1
ACTION=$2
COUNT=$3
DATA_FILE=$4

# Setup environment
export _Z_DATA="$DATA_FILE"
export PATH=$PWD/bin:$PATH

# Source implementation
if [ "$IMPL" == "orig" ]; then
    source ./orig/z.sh
    CMD="_z"
elif [ "$IMPL" == "new" ]; then
    source ./az.sh
    CMD="az"
else
    echo "Unknown implementation: $IMPL"
    exit 1
fi

# Prepare command arguments
if [ "$ACTION" == "add" ]; then
    ARGS="--add /tmp/bench/path"
    if [ "$IMPL" == "new" ]; then
        ARGS="add /tmp/bench/path"
    fi
elif [ "$ACTION" == "query" ]; then
    ARGS="project"
    # For query, we want to avoid actual cd, so use -e (echo)
    # orig: _z -e project
    # new: az -e project
    ARGS="-e project"
else
    echo "Unknown action: $ACTION"
    exit 1
fi

# Run benchmark
start_time=$(date +%s%N)
for ((i=1; i<=COUNT; i++)); do
    $CMD $ARGS > /dev/null 2>&1
done
end_time=$(date +%s%N)

# Calculate duration in milliseconds
duration=$(( (end_time - start_time) / 1000000 ))
echo "$duration"
