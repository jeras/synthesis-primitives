-------------------------------------------------------------------------------
-- register slice with generics to enable data path and/or backpressure registers
--
-- Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
--
-- Licensed under CERN-OHL-P v2 or later
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity register_slice is
    generic (
        -- configuration
        ENABLE_BACKPRESSURE : boolean := true;  -- enable backpressure register
        ENABLE_DATAPATH     : boolean := true;  -- enable data path register
        -- data type and reset value
        type DAT_TYP;
        DAT_RST : DAT_TYP
        -- 'X' synthesizes into a datapath without reset
    );
    port (
        -- system signals
        clk    : in  std_logic;  -- clock
        rst    : in  std_logic;  -- reset
        -- receiver interface
        rx_vld : in  std_logic;  -- valid
        rx_dat : in  DAT_TYP;      -- data
        rx_rdy : out std_logic;  -- ready
        -- transmitter interface
        tx_vld : out std_logic;  -- valid
        tx_dat : out DAT_TYP;      -- data
        tx_rdy : in  std_logic   -- ready
    );
end register_slice;

architecture rtl of register_slice is

    -- middle stream signals
    signal md_vld : std_logic;  -- valid
    signal md_dat : DAT_TYP;      -- data
    signal md_rdy : std_logic;  -- ready

begin

---------------------------------------------------------------------------------------------------
-- backward path (backpressure) register
---------------------------------------------------------------------------------------------------

backpressure: if ENABLE_BACKPRESSURE generate

    backpressure : entity work.register_slice_backpressure
    generic map (
        DAT_TYP => DAT_TYP,
        DAT_RST => DAT_RST
    )
    port map (
        -- system signals
        clk    => clk,
        rst    => rst,
        -- receiver interface
        rx_vld => rx_vld,
        rx_dat => rx_dat,
        rx_rdy => rx_rdy,
        -- transmitter interface
        tx_vld => md_vld,
        tx_dat => md_dat,
        tx_rdy => md_rdy
    );

else generate

    -- combinational passthrough mode
    md_vld <= rx_vld;
    md_dat <= rx_dat;
    rx_rdy <= md_rdy;

end generate backpressure;

---------------------------------------------------------------------------------------------------
-- forward (datapath) path register
---------------------------------------------------------------------------------------------------

datapath: if ENABLE_DATAPATH generate

    datapath : entity work.register_slice_datapath
    generic map (
        DAT_TYP => DAT_TYP,
        DAT_RST => DAT_RST
    )
    port map (
        -- system signals
        clk    => clk,
        rst    => rst,
        -- RX interface
        rx_vld => md_vld,
        rx_dat => md_dat,
        rx_rdy => md_rdy,
        -- TX interface
        tx_vld => tx_vld,
        tx_dat => tx_dat,
        tx_rdy => tx_rdy
    );

else generate

    -- combinational passthrough mode
    tx_vld <= md_vld;
    tx_dat <= md_dat;
    md_rdy <= tx_rdy;

end generate datapath;

end rtl;
