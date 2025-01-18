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
        -- data type and reset value
        -- by default 'X' synthesizes into a datapath without reset
        type DAT_TYP;
        DAT_RST : DAT_TYP;
        -- low power mode reduces propagation of non valid data from RX to TX
        LOW_PWR : boolean := TRUE
    );
    port (
        -- system signals
        clk    : in  std_logic;  -- clock
        rst    : in  std_logic;  -- reset
        -- receiver interface
        rx_vld : in  std_logic;  -- valid
        rx_dat : in  DAT_TYP;    -- data
        rx_rdy : out std_logic;  -- ready
        -- transmitter interface
        tx_vld : out std_logic;  -- valid
        tx_dat : out DAT_TYP;    -- data
        tx_rdy : in  std_logic   -- ready
    );
end register_slice_backpressure;

architecture rtl of register_slice_backpressure is

    -- transfer signals
    signal rx_trn : std_logic;
    signal tx_trn : std_logic;
    -- local storage register and enable
    signal ls_dat : DAT_TYP;
    signal ls_ena : std_logic;

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

    -- local storage enable
    ls_ena <= (rx_trn and (not tx_rdy)) when LOW_PWR else (not tx_rdy);

    -- local storage register (optional asynchronous reset)
    data: process(clk, rst)
    begin
        if (rst = '1') then
            ls_dat <= DAT_RST;
        elsif rising_edge(clk) then
            if (ls_ena = '1') then
                ls_dat <= rx_dat;
            end if;
        end if;
    end process data;

    -- combinational logic
    tx_vld <= rx_vld when rx_rdy = '1' else '1';
    tx_dat <= rx_dat when rx_rdy = '1' else ls_dat;

end rtl;
