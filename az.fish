# az: A smarter cd command (Fish Shell Integration)
# Integration script for Fish shell

# Assumes 'alt-z' command is available in PATH.
# You can override the command by setting _ALT_Z_CMD
if not set -q _ALT_Z_CMD
    set -g _ALT_Z_CMD alt-z
end

function _call_alt_z
    command $argv
end

function az
    if test (count $argv) -eq 0
        $_ALT_Z_CMD --help
        return
    end

    set -l subcmd $argv[1]
    
    # Direct pass-through for non-query commands
    if test "$subcmd" = "add"; or test "$subcmd" = "clean"
        $_ALT_Z_CMD $argv
        return
    end
    
    # Prepare arguments for query
    set -l args $argv
    if test "$subcmd" != "query"
        # Implicit query: prepend 'query'
        set args query $argv
    end
    
    # Check for flags that prevent cd
    set -l cd_mode true
    for arg in $args
        if test "$arg" = "-e"; or test "$arg" = "-l"; or test "$arg" = "--help"; or test "$arg" = "-h"
            set cd_mode false
            break
        end
    end
    
    if test "$cd_mode" = "true"
        set -l target ($_ALT_Z_CMD $args)
        set -l ret $status
        if test $ret -eq 0; and test -n "$target"
            if test -d "$target"
                cd "$target"
            else
                echo "$target"
            end
        else
            return $ret
        end
    else
        $_ALT_Z_CMD $args
    end
end

# Fish hook for automatic directory tracking
function _az_hook --on-variable PWD
    $_ALT_Z_CMD add $PWD
end

# Command-not-found handler: fallback to az
function fish_command_not_found
    set -l cmd $argv[1]
    
    # Try to query az with the command name
    set -l target ($_ALT_Z_CMD query -e $cmd 2>/dev/null)
    set -l ret $status
    
    if test $ret -eq 0; and test -n "$target"; and test -d "$target"
        # Found a matching directory, cd to it
        echo "jumping to $target" >&2
        cd "$target"
    else
        # No match found, show standard error
        echo "fish: Unknown command: $cmd" >&2
        return 127
    end
end
