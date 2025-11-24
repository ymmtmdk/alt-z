import sys
import time
import os
import re
import argparse
from common import read_data, frecency

def main():
    parser = argparse.ArgumentParser(description='z query tool')
    parser.add_argument('-c', action='store_true', help='restrict matches to subdirectories of the current directory')
    parser.add_argument('-e', action='store_true', help='echo the best match, don\'t cd') # In this architecture, we always echo, but this flag might affect behavior if we were a full shell wrapper. For now, z-query just outputs.
    parser.add_argument('-l', action='store_true', help='list only')
    parser.add_argument('-r', action='store_true', help='match by rank only')
    parser.add_argument('-t', action='store_true', help='match by recent access only')
    parser.add_argument('regex', nargs='*', help='regex patterns to match')
    
    # z.sh passes arguments directly. We need to handle flags manually or use argparse carefully.
    # z.sh: z [-chlrtx] [regex1 regex2 ... regexn]
    # argparse handles this well.
    
    args = parser.parse_args()
    
    query_regexes = args.regex
    
    entries = read_data()
    now = int(time.time())
    cwd = os.getcwd()
    
    matches = []
    
    for entry in entries:
        # Filter by -c
        if args.c and not entry.path.startswith(cwd):
            continue
            
        # Filter by regex (AND match)
        match_all = True
        for q in query_regexes:
            # Case insensitive match, spaces treated as wildcards if needed, but original z treats space as separate args usually.
            # Original z: z foo bar -> matches foo AND bar.
            # Here argparse gives us a list ['foo', 'bar'].
            # We treat them as separate regexes.
            try:
                if not re.search(q, entry.path, re.IGNORECASE):
                    match_all = False
                    break
            except re.error:
                # Invalid regex, treat as literal string? or fail?
                # z.sh uses awk's ~ operator.
                if q.lower() not in entry.path.lower():
                    match_all = False
                    break
        
        if match_all:
            matches.append(entry)
            
    if not matches:
        sys.exit(1)
        
    # Scoring
    scored_matches = []
    for entry in matches:
        score = 0
        if args.r:
            score = entry.rank
        elif args.t:
            score = entry.timestamp
        else:
            score = frecency(entry.rank, entry.timestamp, now)
        scored_matches.append((entry, score))
        
    # Sort: descending score
    scored_matches.sort(key=lambda x: x[1], reverse=True)
    
    if args.l:
        # List all matches
        for entry, score in scored_matches:
            print(f"{int(score):<10} {entry.path}")
    else:
        # Best match
        # Handle common prefix logic?
        # Original z has a "common" logic:
        # "When multiple directories match all queries, and they all have a common prefix, 
        # z will cd to the shortest matching directory, without regard to priority."
        # This is complex to replicate exactly but let's try if we have time.
        # For now, just return the best match.
        
        best_match = scored_matches[0][0]
        print(best_match.path)

if __name__ == "__main__":
    main()
