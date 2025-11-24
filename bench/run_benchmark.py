import subprocess
import os
import tempfile
import shutil

def run_benchmark():
    # Setup temp file
    tmp_dir = tempfile.mkdtemp()
    data_file = os.path.join(tmp_dir, ".z")
    
    # Generate data
    print("Generating 1000 entries...")
    subprocess.run(["python3", "benchmark_gen_data.py", data_file, "1000"])
    
    count = 100
    
    print(f"Benchmarking (Loop count: {count})...")
    print(f"{'Implementation':<10} {'Action':<10} {'Total Time (ms)':<15} {'Avg Time (ms)':<15}")
    print("-" * 55)
    
    for impl in ["orig", "new"]:
        for action in ["add", "query"]:
            cmd = ["bash", "benchmark_runner.sh", impl, action, str(count), data_file]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"Error running {impl} {action}: {result.stderr}")
                continue
                
            total_ms = int(result.stdout.strip())
            avg_ms = total_ms / count
            
            print(f"{impl:<10} {action:<10} {total_ms:<15} {avg_ms:<15.2f}")
            
    # Cleanup
    shutil.rmtree(tmp_dir)

if __name__ == "__main__":
    run_benchmark()
