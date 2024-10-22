# All done, time to run the tests
echo "\e[1;32m[INFO]\e[0m Running tests..."

fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system `./util/ibex_config.py small fusesoc_opts`
if [ $? -eq 0 ]; then
    echo "\e[1;32m[INFO]\e[0m Simulator Build successful"
else
    echo "e[1;31m[ERROR]\e[0m Simulator Build failed"
    return 1
fi

output=$(./build/lowrisc_ibex_ibex_simple_system_0/sim-verilator/Vibex_simple_system --meminit=ram,./pre-built/coremark.elf +ibex_tracer_enable=0)

# Grep the line with "Simulation speed" and extract the number
cps=$(echo "$output" | grep "Simulation speed" | grep -oP '\d+(\.\d+)?([eE][+-]?\d+)?' | sed -n '1p')

if [ $? -eq 0 ]; then
    echo "\e[1;32m[INFO]\e[0m Execution successful"
    echo "\e[1;32m[INFO]\e[0m Simulation speed: \e[4;32m\e[1m$cps\e[0m CPS"
else
    echo "e[1;31m[ERROR]\e[0m Execution failed"
    return 1
fi
