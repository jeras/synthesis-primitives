-------------------------------------------------------------------------------
-- register slice for backpressure
--
-- Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
--
-- Licensed under CERN-OHL-P v2 or later
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity register_slice_backpressure is
    generic (
        -- data type
        type DAT_T
    );
    port (
        -- system signals
        clk    : in  std_logic;  -- clock
        rst    : in  std_logic;  -- reset
        -- receiver interface
        rx_vld : in  std_logic;
        rx_dat : in  DAT_T;
        rx_rdy : out std_logic;
        -- transmitter interface
        tx_vld : out std_logic;
        tx_dat : out DAT_T;
        tx_rdy : in  std_logic
    );
end register_slice_backpressure;

architecture rtl of register_slice_backpressure is

    -- transfer signals
    signal rx_trn : std_logic;
    signal tx_trn : std_logic;
    -- local signals/registers
    signal ls_dat : DAT_T;

begin

    -- transfer signals
    rx_trn <= rx_vld and rx_rdy;
    tx_trn <= tx_vld and tx_rdy;

    -- handshake (asynchronous reset)
    handshake: process(clk, rst)
    begin
        if (rst = '1') then
            rx_rdy <= '1';
        elsif (rising_edge(clk)) then
            if (tx_vld = '1') then
                rx_rdy <= tx_rdy;
            end if;
        end if;
    end process handshake;

    -- data path register (without reset)
    data: process(clk)
    begin
        if rising_edge(clk) then
            if ((rx_trn and (not tx_rdy)) = '1') then
                ls_dat <= rx_dat;
            end if;
        end if;
    end process data;

    -- combinational logic
    tx_vld <= rx_vld when rx_rdy = '1' else '1';
    tx_dat <= rx_dat when rx_rdy = '1' else ls_dat;

end rtl;
