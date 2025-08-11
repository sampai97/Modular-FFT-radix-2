library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.fft_types_pkg.all;     --packages must be in the same folder
use work.twiddle_type_pkg.all;  --types for twiddle factor and array of arrays

entity FFT2_main is
    generic(
        N : integer := 128;     --Point number, need to change here and in the package fft_types
        N_bit : integer := 15   --sample depth
    );
    port(
        clk,rst : in STD_LOGIC;
        x : in signed(N_bit-1 downto 0);    --serial in
        y : out signed(N_bit-1 downto 0)    --serial out
        );
end FFT2_main;

architecture Structural of FFT2_main is

signal out_parallel,in_parallel : array_data;   --signals for structural connection

    component serial_parallel is
    generic(
        N : integer := 64;
        N_bit : integer := 15
    );
    port(
        clk,rst : in STD_LOGIC;
        serial_in : in signed(N_bit-1 downto 0);
        parallel_out : out array_data
        );
end component;

component parallel_serial is
    generic(
        N : integer := 64;
        N_bit : integer := 15
    );
    port(
        clk,rst : in STD_LOGIC;
        parallel_in : in array_data;
        serial_out : out signed(N_bit-1 downto 0)  
        );
end component;

component modular_FFT2 is
    generic(
        N : integer := 64;
        N_bit : integer := 15

    );
    port (
        clk,rst   : in std_logic;
        x : in array_data;
        y : out array_data
        
    );
end component;
begin

    S_P : serial_parallel
        generic map (
            N => N,
            N_bit => N_bit
        )
        port map(
            clk => clk,
            rst => rst,
            serial_in => x,
            parallel_out => out_parallel
        );
    FFT : modular_FFT2
     generic map(
        N => N,
        N_bit => N_bit
    )
     port map(
        clk => clk,
        rst => rst,
        x => out_parallel,
        y => in_parallel
    );
    P_S : parallel_serial
        generic map (
            N => N,
            N_bit => N_bit
        )
        port map(
            clk => clk,
            rst => rst,
            serial_out => y,
            parallel_in => in_parallel
        );
end Structural;