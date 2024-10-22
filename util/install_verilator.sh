# If VERILATOR_ROOT is not set, ask the user for prefix
if [ -z "$VERILATOR_ROOT" ]; then
    echo "Please set the VERILATOR_ROOT environment variable to the Verilator installation directory"
    # Prompt
    read -p "Enter the Verilator installation directory: " VERILATOR_PREFIX
    # Set the environment variable
    export VERILATOR_PREFIX=$VERILATOR_PREFIX
    # Update the PATH
fi

# Install Verilator
export VERILATOR_VERSION=4.210
git clone https://github.com/verilator/verilator verilator-$VERILATOR_VERSION
unset VERILATOR_ROOT
cd verilator-$VERILATOR_VERSION
git pull
git checkout v$VERILATOR_VERSION
autoconf
./configure --prefix=$VERILATOR_PREFIX
make -j$(nproc)
sudo make install
cd ..
export PATH=$VERILATOR_PREFIX/bin:$PATH
export VERILATOR_ROOT=$VERILATOR_PREFIX

# Check if verilator executable of the correct version is in the path
if [ "$(verilator --version | grep -oP 'Verilator \K[0-9.]+')" != "$VERILATOR_VERSION" ]; then
    echo "Verilator version mismatch. Expected $VERILATOR_VERSION, found $(verilator --version | grep -oP 'Verilator \K[0-9.]+')"
    return 1
else
    echo "Verilator version match: v$VERILATOR_VERSION"
    return 0
fi
