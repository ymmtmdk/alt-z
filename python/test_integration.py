import os
import sys
import subprocess
import tempfile
import shutil

def run_command(cmd, env):
    result = subprocess.run(cmd, shell=True, env=env, capture_output=True, text=True)
    return result.stdout.strip(), result.stderr.strip(), result.returncode

def test_integration():
    # Setup temp env
    tmp_dir = tempfile.mkdtemp()
    data_file = os.path.join(tmp_dir, ".z")
    
    env = os.environ.copy()
    env["_Z_DATA"] = data_file
    
    src_dir = os.path.abspath("python/src")
    z_add = f"python3 {src_dir}/z_add.py"
    z_query = f"python3 {src_dir}/z_query.py"
    
    print(f"Testing with data file: {data_file}")
    
    # 1. Add paths
    paths = [
        "/tmp/foo/bar",
        "/tmp/foo/baz",
        "/tmp/other/place"
    ]
    
    print("Adding paths...")
    for p in paths:
        # Simulate adding multiple times to boost rank
        run_command(f"{z_add} {p}", env)
        run_command(f"{z_add} {p}", env)
        
    # Boost /tmp/foo/bar more
    run_command(f"{z_add} /tmp/foo/bar", env)
    
    # 2. Verify file content
    with open(data_file, "r") as f:
        content = f.read()
        print("Data file content:")
        print(content)
        
    # 3. Query
    print("Querying 'foo'...")
    out, err, rc = run_command(f"{z_query} foo", env)
    print(f"Result: {out}")
    
    if out == "/tmp/foo/bar":
        print("PASS: Best match for 'foo' is correct.")
    else:
        print(f"FAIL: Expected /tmp/foo/bar, got {out}")
        
    # 4. Query list
    print("Querying list 'foo'...")
    out, err, rc = run_command(f"{z_query} -l foo", env)
    print(f"Result:\n{out}")
    if "/tmp/foo/bar" in out and "/tmp/foo/baz" in out:
        print("PASS: List contains both matches.")
    else:
        print("FAIL: List missing matches.")

    # Cleanup
    shutil.rmtree(tmp_dir)

if __name__ == "__main__":
    test_integration()
