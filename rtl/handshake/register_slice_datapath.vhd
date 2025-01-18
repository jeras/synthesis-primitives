-------------------------------------------------------------------------------
-- register slice for forward data path
--
-- Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
--
-- Licensed under CERN-OHL-P v2 or later
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity register_slice_datapath is
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
        -- RX interface
        rx_vld : in  std_logic;  -- valid
        rx_dat : in  DAT_TYP;    -- data
        rx_rdy : out std_logic;  -- ready
        -- TX interface
        tx_vld : out std_logic;  -- valid
        tx_dat : out DAT_TYP;    -- data
        tx_rdy : in  std_logic   -- ready
    );
end register_slice_datapath;

architecture rtl of register_slice_datapath is

    -- transfer signals
    signal rx_trn : std_logic;
    signal tx_trn : std_logic;
    -- datapath clock enable
    signal tx_ena : std_logic;

begin

    -- transfer signals
    rx_trn <= rx_vld and rx_rdy;
    tx_trn <= tx_vld and tx_rdy;

    -- handshake (asynchronous reset)
    handshake: process(clk, rst)
    begin
        if (rst = '1') then
            tx_vld <= '0';
        elsif rising_edge(clk) then
            if (rx_rdy = '1') then
                tx_vld <= rx_vld;
            end if;
        end if;
    end process handshake;

    -- datapath clock enable
    tx_ena <= rx_trn when LOW_PWR else rx_rdy;

    -- data path register (optional asynchronous reset)
    data: process(clk, rst)
    begin
        if (rst = '1') then
            tx_dat <= DAT_RST;
        elsif rising_edge(clk) then
            if (tx_ena = '1') then
                tx_dat <= rx_dat;
            end if;
        end if;
    end process data;

    -- combinational backpressure
    rx_rdy <= not tx_vld or tx_rdy;

end rtl;
