import subprocess

def run_analyze():
    try:
        result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True, check=False)
        lines = result.stdout.split('\n')
        for line in lines:
            if ' • ' in line:
                print(line)
        if result.stderr:
            print("STDERR:")
            print(result.stderr)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    run_analyze()
