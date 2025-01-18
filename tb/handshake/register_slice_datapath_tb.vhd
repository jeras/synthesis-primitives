-------------------------------------------------------------------------------
-- register slice for forward data path,
-- testbench
--
-- Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
--
-- Licensed under CERN-OHL-P v2 or later
-------------------------------------------------------------------------------

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_slice_datapath_tb is
    generic (
        -- datapath width
        WIDTH : positive := 8;
        -- low power mode reduces propagation of non valid data from RX to TX
        LOW_PWR : boolean := TRUE
    );
end register_slice_datapath_tb;

architecture testbench of register_slice_datapath_tb is

    -- clock period
    constant T : time := 10.0 ns;

    -- system signals
    signal clk : std_logic := '0';  -- clock
    signal rst : std_logic := '1';  -- reset
    signal cnt : integer := 0;  -- clock cycle counter

    -- data type and reset value
    -- by default 'X' synthesizes into a datapath without reset
    subtype  DAT_TYP is std_logic_vector(WIDTH-1 downto 0);
    constant DAT_RST : DAT_TYP := (others => 'X');
    constant DAT_C00 : DAT_TYP := 8X"00";
    constant DAT_C01 : DAT_TYP := 8X"01";

    -- RX interface
    signal rx_vld : std_logic := '0';
    signal rx_dat : DAT_TYP;
    signal rx_rdy : std_logic;

    -- TX interface
    signal tx_vld : std_logic;
    signal tx_dat : DAT_TYP;
    signal tx_rdy : std_logic := '0';

begin

-------------------------------------------------------------------------------
-- test
-------------------------------------------------------------------------------

    -- clock source
    clock : process
    begin
        loop
            clk <= '1'; wait for T/2;
            clk <= '0'; wait for T/2;
        end loop;
    end process clock;

    -- clock cycle counter
    counter: process(clk)
    begin
        if (rst = '1') then
            cnt <= 1;
        elsif rising_edge(clk) then
            cnt <= cnt + 1;
        end if;
    end process counter;
    
    -- test sequence
    test : process
    begin
        -- skip clock edge at time zero
        wait for 0 ns;
        -- TX/RX init
        rx_vld <= '0';
        rx_dat <= DAT_RST;
        tx_rdy <= '1';
        -- T0 (reset)
        rst <= '1';
        wait until rising_edge(clk);
        -- T1
        rst <= '0';
        wait until rising_edge(clk);
        assert (tx_dat = DAT_RST) report "Step 3: TX data mismatch" severity ERROR;
        -- T2
        rx_vld <= '1';
        rx_dat <= DAT_C00;
        wait until rising_edge(clk);
        -- T3
        rx_vld <= '1';
        rx_dat <= DAT_C01;
        wait until rising_edge(clk);
        assert (tx_dat = DAT_C00) report "Step 3: TX data mismatch" severity ERROR;
        -- T4
        rx_vld <= '0';
        rx_dat <= DAT_RST;
        tx_rdy <= '0';
        wait until rising_edge(clk);
        -- T5
        tx_rdy <= '1';
        wait until rising_edge(clk);
        assert (tx_dat = DAT_C01) report "Step 5: TX data mismatch" severity ERROR;
        -- T6
        tx_rdy <= '0';
        wait until rising_edge(clk);
        -- T...
        wait until rising_edge(clk);

        -- end simulation
        report "SUCCESS running " & test'path_name severity NOTE;
        finish;
    end process test;

-------------------------------------------------------------------------------
-- DUT instance
-------------------------------------------------------------------------------

    dut : entity work.register_slice_datapath
    generic map (
        DAT_TYP => DAT_TYP,
        DAT_RST => DAT_RST,
        LOW_PWR => LOW_PWR
    )
    port map (
        -- system signals
        clk    => clk,
        rst    => rst,
        -- RX interface
        rx_vld => rx_vld,
        rx_dat => rx_dat,
        rx_rdy => rx_rdy,
        -- TX interface
        tx_vld => tx_vld,
        tx_dat => tx_dat,
        tx_rdy => tx_rdy
    );

end testbench;

