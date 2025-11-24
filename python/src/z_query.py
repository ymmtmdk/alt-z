import sys
import time
import os
import re
import argparse
from common import read_data, frecency

def register(subparsers):
    parser = subparsers.add_parser('query', help='search for a directory')
    parser.add_argument('-c', action='store_true', help='restrict matches to subdirectories of the current directory')
    parser.add_argument('-e', action='store_true', help='echo the best match, don\'t cd') 
    parser.add_argument('-l', action='store_true', help='list only')
    parser.add_argument('-r', action='store_true', help='match by rank only')
    parser.add_argument('-t', action='store_true', help='match by recent access only')
    parser.add_argument('regex', nargs='*', help='regex patterns to match')
    parser.set_defaults(func=run)

def run(args):
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
            try:
                if not re.search(q, entry.path, re.IGNORECASE):
                    match_all = False
                    break
            except re.error:
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
        best_match = scored_matches[0][0]
        print(best_match.path)

