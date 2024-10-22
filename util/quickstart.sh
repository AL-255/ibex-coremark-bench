## Check if ../ibex submodule is initialized
if [ ! -d "./ibex" ]; then
    echo "\e[1;32m[INFO]\e[0m Ibex submodule not found. Initializing..."
    git submodule update --init --recursive
else
    echo "\e[1;31m[ERROR]\e[0m Ibex submodule found"
fi

## Check verilator 

# Check if the executable is of the correct version is in the path
export VERILATOR_VERSION=4.210
verilator_exists=false

if ! command -v verilator &> /dev/null; then
    echo "\e[1;32m[INFO]\e[0m Verilator not found in PATH"
    verilator_exists=false
    # Also check if the verilator executable is in the verilator root directory
    if [ -f "$VERILATOR_ROOT/bin/verilator" ]; then
        echo "\e[1;32m[INFO]\e[0m Verilator found in VERILATOR_ROOT"
        export PATH=$VERILATOR_ROOT/bin:$PATH
        verilator_exists=true
    else
        verilator_exists=false
    fi
else
    echo "\e[1;32m[INFO]\e[0m Verilator found in PATH"
    verilator_exists=true
fi

# Check if verilator version is correct
if [ "$verilator_exists" = true ]; then
    if [ "$(verilator --version | grep -oP 'Verilator \K[0-9.]+')" != "$VERILATOR_VERSION" ]; then
        echo "\e[1;31m[ERROR]\e[0m Verilator version mismatch. Expected $VERILATOR_VERSION, found $(verilator --version | grep -oP 'Verilator \K[0-9.]+')"
        verilator_exists=false
    else
        echo "\e[1;32m[INFO]\e[0m Verilator version match: v$VERILATOR_VERSION"
        verilator_exists=true
    fi
fi

if [ "$verilator_exists" = false ]; then
    echo "\e[1;32m[INFO]\e[0m Please install Verilator $VERILATOR_VERSION using the script provided"
    return 1
fi


## Check python 
# Check if is in conda environment
if [ -z "$CONDA_DEFAULT_ENV" ] || [ "$(python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')" != "3.10" ]; then
    echo "\e[1;31m[ERROR]\e[0m Please activate a conda environment with python==3.10"
    return 1
else 
    # Check if the conda environment is "base"
    if [ "$CONDA_DEFAULT_ENV" = "base" ]; then
        echo "\e[1;31m[ERROR]\e[0m Do not use the base conda environment. Please activate a different environment."
        return 1
    fi
    echo "\e[1;32m[INFO]\e[0m Conda environment activated"
    PY_RUN="python3.10"
fi

# Check if python dependencies are installed
requirements_file="./ibex/python-requirements.txt"

# Function to check if a Python package is installed
is_installed() {
    $PY_RUN -m pip show "$1" &> /dev/null
}

# Read the dependencies from requirements.txt and process each line
while IFS= read -r package || [ -n "$package" ]; do
    # Remove leading/trailing whitespace
    package=$(echo "$package" | xargs)
    # Skip empty lines and comments
    if [[ -z "$package" || "$package" == \#* ]]; then
        continue
    fi
    # Extract the package name without extras and version specifiers for checking
    package_name=$(echo "$package" | sed 's/\[.*\]//;s/[<>=].*//')
    echo "\e[1;32m[INFO]\e[0m Checking if $package is installed..."
    if is_installed "$package_name"; then
        echo "\e[1;32m[INFO]\e[0m $package is already installed."
    else
        echo "\e[1;32m[INFO]\e[0m $package is not installed. Installing..."
        $PY_RUN -m pip install "$package"
        # Check if the installation was successful
        if is_installed "$package_name"; then
            echo "\e[1;32m[INFO]\e[0m $package installed successfully."
        else
            echo "\e[1;31m[ERROR]\e[0m Failed to install $package."
        fi
    fi
    echo
done < "$requirements_file"
echo "\e[1;32m[INFO]\e[0m Dependency check and package installations complete."

source ./util/run.sh