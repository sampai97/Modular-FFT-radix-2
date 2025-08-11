library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package fft_types_pkg is
    constant N : integer := 128;                                            --number of points, need to change here and main
    constant N_bit : integer := 15;                                         --sample depth
    type array_data is array (0 to N-1) of signed(N_bit-1 downto 0);        --array of arrays of N_bit
    type temp_result is array (0 to N-1) of signed(N_bit downto 0);         --types needed to temporary store data in a way that the synthetizer does not make ugly stuff
    type temp_array is array (0 to N-1) of signed(2*N_bit-1 downto 0);
    type temp_result_dist is array (0 to N-1) of signed(2*N_bit downto 0);
    function log2ceil(a : integer) return integer;                          --function to compute log2 of a number taking the ceil
end package fft_types_pkg;

package body fft_types_pkg is
    function log2ceil(a : integer) return integer is
    variable result : integer := 0;
    variable value : integer := a - 1;
    begin
    while value > 0 loop
        value := value / 2;     --divide the value by 2
        result := result + 1;   --for every iteration means that you can still divide by 2
    end loop;
    return result;
    end function;
end package body fft_types_pkg;
