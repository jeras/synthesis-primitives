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
        type DAT_TYP;
        DAT_RST : DAT_TYP
        -- 'X' synthesizes into a datapath without reset
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

begin

    -- transfer signals
    rx_trn <= rx_vld and rx_rdy;
    tx_trn <= tx_vld and tx_rdy;

    -- handshake (asynchronous reset)
    handshake: process(clk)
    begin
        if (rst = '1') then
            tx_vld <= '0';
        elsif rising_edge(clk) then
            if (rx_rdy = '1') then
                tx_vld <= rx_vld;
            end if;
        end if;
    end process handshake;

    -- data path register (without reset)
    data: process(clk)
    begin
        if (rst = '1') then
            tx_dat <= DAT_RST;
        elsif rising_edge(clk) then
            if (rx_trn = '1') then
                tx_dat <= rx_dat;
            end if;
        end if;
    end process data;

    -- combinational backpressure
    rx_rdy <= not tx_vld or tx_rdy;

end rtl;