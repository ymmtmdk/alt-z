import sys
import time
import os
from common import read_data, write_data, Entry, MAX_SCORE, EXCLUDE_DIRS

def main():
    args = sys.argv[1:]
    path = ""
    
    # Handle --add flag if passed (compatibility with original z.sh call)
    if len(args) > 0 and args[0] == "--add":
        args.pop(0)
        
    if len(args) > 0:
        path = " ".join(args)
    
    # If no argument, try reading from stdin? 
    # Original z.sh calls `_z --add "${PWD:a}"`. 
    # Our architecture doc says "Argument or Stdin".
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

if __name__ == "__main__":
    main()
