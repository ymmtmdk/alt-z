import sys
import time
import os
from common import read_data, write_data, Entry, MAX_SCORE, EXCLUDE_DIRS

def register(subparsers):
    parser = subparsers.add_parser('add', help='add a directory to the database')
    parser.add_argument('path', nargs='*', help='path to add')
    parser.set_defaults(func=run)

def run(args):
    path_parts = args.path
    path = ""
    
    # Handle --add flag if passed (compatibility with original z.sh call)
    # Since we are using argparse now, --add might be treated as a path if not careful, 
    # but since this is a subcommand 'add', the user would call `alt-z add path`.
    # If the user calls `alt-z add --add path`, argparse might complain if --add isn't defined.
    # However, we can assume the caller (shell script) will be updated to call `alt-z add path`.
    
    if path_parts:
        path = " ".join(path_parts)
    
    # If no argument, try reading from stdin
    if not path and not sys.stdin.isatty():
        path = sys.stdin.read().strip()
        
    if not path:
        return

    # Normalize path
    path = os.path.abspath(path)
    
    # Exclusions
    if path == os.environ.get("HOME") or path == "/":
        return
        
    for exclude in EXCLUDE_DIRS:
        if exclude and path.startswith(exclude):
            return

    entries = read_data()
    now = int(time.time())
    
    found = False
    total_rank = 0
    
    for entry in entries:
        if entry.path == path:
            entry.rank += 1
            entry.timestamp = now
            found = True
        total_rank += entry.rank
        
    if not found:
        entries.append(Entry(path, 1, now))
        total_rank += 1

    # Aging
    if total_rank > MAX_SCORE:
        new_entries = []
        for entry in entries:
            entry.rank *= 0.99
            if entry.rank >= 1:
                new_entries.append(entry)
        entries = new_entries

    write_data(entries)

