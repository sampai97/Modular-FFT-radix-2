library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.fft_types_pkg.all;
use work.twiddle_type_pkg.all;

entity modular_FFT2 is
    generic(
        N       : integer := 128;
        N_bit   : integer := 15

    );
    port (
        clk,rst : in std_logic;
        x       : in array_data;
        y       : out array_data
        
    );
end modular_FFT2;

architecture Structural of modular_FFT2 is

constant stages : integer := log2ceil(N/2);                 --number of stages
type through_array is array (0 to stages) of array_data;    --for trasporting data from one stage to the next one
signal stage_signal : through_array;

begin

gen_stage : for i in 0 to stages-1 generate                 --generate stage by stage
constant dist : integer := N/(2**(i+1));                    --upgrading distance every stage
begin

stage: entity work.modular_FFT_stage
    generic map(
        N => N,
        dist => dist,
        N_bit => N_bit 
    )
    port map(
        clk => clk,
        rst => rst,
        x => stage_signal(i),
        y => stage_signal(i+1)
    );
end generate;

out_ffd : process(clk,rst)  --output FFD
begin
    if rst = '0' then
        for k in 0 to N-1 loop
            y(k) <= (others => '0');
        end loop;
    elsif clk' event and clk = '1' then
        y <= stage_signal(stages);
    end if;
end process;

stage_signal(0) <= x;
end Structural;
