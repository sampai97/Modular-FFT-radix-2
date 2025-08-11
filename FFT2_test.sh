#!/bin/bash

PROJ_DIR="your_path/vhdl"
cd "$PROJ_DIR"

echo "running simulation"
ghdl --clean
ghdl -a fft_types_pkg.vhd
ghdl -a twiddle_type_pkg.vhd
ghdl -a serial_parallel.vhd
ghdl -a parallel_serial.vhd
ghdl -a FFT2_stage.vhd
ghdl -a FFT2_modular.vhd
ghdl -a FFT2_main.vhd
ghdl -a FFT2_main_tb.vhd
ghdl -e FFT2_main_tb
ghdl -r FFT2_main_tb --wave=FFT2_wave.ghw --stop-time=10250ns
