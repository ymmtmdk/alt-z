# z.sh - Python version wrapper

# Find the directory where this script is located
if [ -n "$BASH_VERSION" ]; then
    _Z_PY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
    _Z_PY_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"
else
    # Fallback
    _Z_PY_DIR="$HOME/github/z/python"
fi

_z_add() {
    python3 "$_Z_PY_DIR/src/z_add.py" "$@"
}

_z_query() {
    python3 "$_Z_PY_DIR/src/z_query.py" "$@"
}

_z_clean() {
    python3 "$_Z_PY_DIR/src/z_clean.py" "$@"
}

z() {
    local cmd="$1"
    if [ "$cmd" = "-x" ]; then
        _z_clean -x
        return
    fi
    
    # Handle other flags passed to z-query
    # If -l (list), just print
    # If -e (echo), just print
    # Otherwise, cd to the result
    
    # Check for flags that imply NO cd
    local list_mode=0
    local echo_mode=0
    
    # Simple parsing to check for -l or -e
    # Note: This is a bit naive, but sufficient for z's simple args
    for arg in "$@"; do
        if [ "$arg" = "-l" ]; then list_mode=1; fi
        if [ "$arg" = "-e" ]; then echo_mode=1; fi
        if [ "$arg" = "-h" ]; then
             echo "z [-cehlrtx] args"
             return
        fi
    done
    
    if [ "$list_mode" -eq 1 ] || [ "$echo_mode" -eq 1 ]; then
        _z_query "$@"
    else
        local target
        target="$(_z_query "$@")"
        if [ -n "$target" ] && [ -d "$target" ]; then
            cd "$target"
        else
            return 1
        fi
    fi
}

# Precmd / Prompt Command Hook
if [ -n "$ZSH_VERSION" ]; then
    _z_precmd() {
        (_z_add --add "${PWD:a}" &)
    }
    typeset -ga precmd_functions
    if [[ -z "${precmd_functions[(r)_z_precmd]}" ]]; then
        precmd_functions+=_z_precmd
    fi
elif [ -n "$BASH_VERSION" ]; then
    # Bash hook
    if [[ ! "$PROMPT_COMMAND" =~ _z_add ]]; then
        PROMPT_COMMAND="_z_add --add \"\$(pwd)\";$PROMPT_COMMAND"
    fi
fi
