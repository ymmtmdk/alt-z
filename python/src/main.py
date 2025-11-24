import argparse
import sys
import z_add
import z_query
import z_clean

def main():
    parser = argparse.ArgumentParser(description='alt-z: A smarter cd command')
    subparsers = parser.add_subparsers(dest='command', help='sub-command help')
    
    # Register subcommands
    z_add.register(subparsers)
    z_query.register(subparsers)
    z_clean.register(subparsers)
    
    # If no arguments provided, print help
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)
        
    args = parser.parse_args()
    
    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help(sys.stderr)

if __name__ == "__main__":
    main()
