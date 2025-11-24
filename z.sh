# alt-z: A smarter cd command
# Integration script for Bash and Zsh

# Resolve the directory where this script resides (when sourced)
if [ -n "$BASH_SOURCE" ]; then
    _ALT_Z_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
elif [ -n "$ZSH_VERSION" ]; then
    _ALT_Z_DIR=$(cd "$(dirname "${(%):-%x}")" && pwd)
else
    _ALT_Z_DIR=$(cd "$(dirname "$0")" && pwd)
fi

_alt_z_python_script() {
    # Absolute path to main.py
    python3 "$_ALT_Z_DIR/python/src/main.py" "$@"
}

alt-z() {
    if [ "$#" -eq 0 ]; then
        _alt_z_python_script --help
        return
    fi

    local subcmd="$1"
    
    # Direct pass-through for non-query commands
    if [[ "$subcmd" == "add" || "$subcmd" == "clean" ]]; then
        _alt_z_python_script "$@"
        return
    fi
    
    # Prepare arguments for query
    local args=("$@")
    if [[ "$subcmd" != "query" ]]; then
        # Implicit query: prepend 'query'
        args=("query" "${args[@]}")
    fi
    
    # Check for flags that prevent cd
    local cd_mode=true
    for arg in "${args[@]}"; do
        if [[ "$arg" == "-e" || "$arg" == "-l" || "$arg" == "--help" || "$arg" == "-h" ]]; then
            cd_mode=false
            break
        fi
    done
    
    if $cd_mode; then
        local target
        target=$(_alt_z_python_script "${args[@]}")
        local ret=$?
        if [ $ret -eq 0 ] && [ -n "$target" ]; then
            if [ -d "$target" ]; then
                cd "$target"
            else
                echo "$target"
            fi
        else
            return $ret
        fi
    else
        _alt_z_python_script "${args[@]}"
    fi
}

# Hook configuration
if [ -n "$BASH_VERSION" ]; then
    # Bash hook
    _alt_z_hook() {
        _alt_z_python_script add "$PWD"
    }
    
    # Append to PROMPT_COMMAND
    if [[ "$PROMPT_COMMAND" != *"_alt_z_hook"* ]]; then
        PROMPT_COMMAND="_alt_z_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
    
elif [ -n "$ZSH_VERSION" ]; then
    # Zsh hook
    _alt_z_hook() {
        _alt_z_python_script add "$PWD"
    }
    
    typeset -ga precmd_functions
    if [[ ${precmd_functions[(I)_alt_z_hook]} -eq 0 ]]; then
        precmd_functions+=_alt_z_hook
    fi
fi
