import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
from cocotb.clock import Clock

from src.drivers.bus_driver import BusMaster
from src.drivers.uart_driver import UartTransceiver
from src.drivers.access_bus_driver import AccessBusDriver

def init_inputs(dut):
    dut.clock_50.value  = 1

    dut.key.value       = 0xF
    dut.sw.value        = 0

    dut.sim_rx.value    = 0

    dut.hab_clk.value   = 0
    dut.hab_mosi.value  = 0

    dut.hab_reset.value = 1

async def start_clock(dut):
    #await cocotb.start(Clock(dut.clock_50, 20, units="ns").start())
    await cocotb.start(Clock(dut.clk,      10, units="ns").start())
    await cocotb.start(Clock(dut.vga_clk,  40, units="ns").start())

async def reset(dut):
    dut.hab_reset.value = 1
    await FallingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.hab_reset.value = 0
    await RisingEdge(dut.hab_power)

async def clock_and_power(dut):
    init_inputs(dut)
    await start_clock(dut)
    await reset(dut)

@cocotb.test()
async def my_first_test(dut):
    xcvr = UartTransceiver(dut.clk, dut.sim_rx, dut.sim_tx, 144_000_000, 1_000_000)
    dp = AccessBusDriver(xcvr, 30, 32)
    await clock_and_power(dut)

    dp.read(1024*512)

    await dp.wait_complete()

    await ClockCycles(dut.clk, 100)
