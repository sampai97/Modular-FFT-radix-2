library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.fft_types_pkg.all;

entity parallel_serial is
    generic(
        N : integer := 64;
        N_bit : integer := 15
    );
    port(
        clk,rst : in STD_LOGIC;
        serial_out : out signed(N_bit-1 downto 0);
        parallel_in : in array_data
        );
end parallel_serial;

architecture Behavioral of parallel_serial  is

signal cnt_N : unsigned(log2ceil(N)-1 downto 0);    --counter signal
begin

counter_N: process(clk,rst)                         --counter, select mux output
begin
    if rst = '0' then
        cnt_N <= (others => '0');
        
    elsif(clk' event and clk = '1') then
        if (cnt_N = N-1) then
            cnt_N <= (others => '0');
        else
            cnt_N <= cnt_N + 1;
        end if;
    end if;
end process;

mux_FFD: process(clk,rst)                           --mux with out FFD
begin    
    if (rst = '0') then
        for i in 0 to N-1 loop
            serial_out <= (others => '0');
        end loop;
    elsif (clk' event and clk = '1') then
        serial_out <= parallel_in(to_integer(cnt_N));   --counter as mux selecting signal
    end if;
end process;
end Behavioral;