# az: A smarter cd command (Shell Integration)
# Integration script for Bash and Zsh

# Assumes 'alt-z' command is available in PATH.
# You can override the command by setting _ALT_Z_CMD
: "${_ALT_Z_CMD:=alt-z}"

_call_alt_z() {
    command "$_ALT_Z_CMD" "$@"
}

az() {
    if [ "$#" -eq 0 ]; then
        _call_alt_z --help
        return
    fi

    local subcmd="$1"
    
    # Direct pass-through for non-query commands
    if [[ "$subcmd" == "add" || "$subcmd" == "clean" ]]; then
        _call_alt_z "$@"
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
        target=$(_call_alt_z "${args[@]}")
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
        _call_alt_z "${args[@]}"
    fi
}

# Hook configuration
if [ -n "$BASH_VERSION" ]; then
    # Bash hook
    _az_hook() {
        _call_alt_z add "$PWD"
    }
    
    # Append to PROMPT_COMMAND
    if [[ "$PROMPT_COMMAND" != *"_az_hook"* ]]; then
        PROMPT_COMMAND="_az_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
    
elif [ -n "$ZSH_VERSION" ]; then
    # Zsh hook
    _az_hook() {
        _call_alt_z add "$PWD"
    }
    
    typeset -ga precmd_functions
    if [[ ${precmd_functions[(I)_az_hook]} -eq 0 ]]; then
        precmd_functions+=_az_hook
    fi
fi
