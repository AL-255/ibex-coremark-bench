# ibex-coremark-bench
A simple testbench to test the performance of verilator on your CPU

----
## How to Run

### Using Pre-built Binary
1. Clone the repository
2. Go to the `pre-built` directory and find a binary that matches your system
3. Run the binary with: `<EXE> --meminit=ram,coremark.elf +ibex_tracer_enable=0`
4. Report the score in `ladder.csv`

### Building the Binary

1. Clone the repository
2. Make sure you have verilator v4.210 installed
3. Make sure you have a fresh python 3.10 Conda environment
    - Install Miniconda from [here](https://docs.anaconda.com/miniconda/miniconda-install/)
    - Run `conda create -n ibex-env python=3.10`
    - Run `conda activate ibex-env`
4. Run: `source ./util/quickstart.sh`
5. Report the score in `ladder.csv`