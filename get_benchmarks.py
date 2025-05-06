import yaml
import sys

def extract_benchmarks(input):
    data = yaml.safe_load(input)
    for _, details in data.get("benchmark_suites", {}).items():
        location = details.get("location", "")
        for benchmark in details.get("benchmarks", []):
            for name, props in benchmark.items():
                command = props.get("command", name)
                extra_args = props.get("extra_args", "")
                print(location, command, extra_args)

if __name__ == "__main__":
    if (len(sys.argv) < 2):
        sys.exit(1)

    with open(sys.argv[1]) as file:
        extract_benchmarks(file)

