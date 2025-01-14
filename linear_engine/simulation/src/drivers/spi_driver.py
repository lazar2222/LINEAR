import cocotb
from cocotb.queue import Queue
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

from ..util.event_queue import EventQueue

class SpiTx:
    def __init__(self, clk, dout, data_width = 8):
        self.clk = clk
        self.dout = dout
        self.data_width = data_width

        self.driver_queue = EventQueue(Queue())

        cocotb.start_soon(self.driver())

    async def driver(self):
        self.dout.value = 0
        while True:
            value = await self.driver_queue.get()
            for _ in range(self.data_width):
                await RisingEdge(self.clk)
                self.dout.value = value & 1
                value >>= 1
            await self.driver_queue.get()

    def transmit(self, value):
        self.driver_queue.put_nowait(value)
        self.driver_queue.put_nowait(0)

    def complete(self):
        return self.driver_queue.empty()

    async def wait_complete(self):
        await self.driver_queue.wait_empty()

class NSpiTx:
    def __init__(self, clk, dout, data_width = 8, instance_count = 1):
        self.tx = []

        for i in range(instance_count):
            self.tx.append(SpiTx(clk, dout[i], data_width // instance_count))
    
    def transmit(self, value):
        for tx in self.tx:
            tx.transmit(value & (2 ** tx.data_width - 1))
            value >>= tx.data_width

    def complete(self):
        return self.tx[0].complete()

    async def wait_complete(self):
        await self.tx[0].wait_complete()

class SpiRx:
    def __init__(self, clk, din, data_width = 8):
        self.clk = clk
        self.din = din
        self.data_width = data_width

        self.rx_queue = EventQueue(Queue())

        cocotb.start_soon(self.monitor())

    async def monitor(self):
        await RisingEdge(self.clk)
        while True:
            value = 0
            for i in range(self.data_width):
                await FallingEdge(self.clk)
                value |= self.din.value.integer << i
            self.rx_queue.put_nowait(value)

    def receive_nowait(self):
        return self.rx_queue.get_nowait()

    def available(self):
        return not self.rx_queue.empty()

    async def receive(self):
        return await self.rx_queue.get()

    async def wait_available(self):
        await self.rx_queue.wait_not_empty()

class NSpiRx:
    def __init__(self, clk, din, data_width = 8, instance_count = 1):
        self.rx = []

        for i in range(instance_count):
            self.rx.append(SpiRx(clk, din[i], data_width // instance_count))

    def receive_nowait(self):
        value = 0
        for i in range(len(self.rx)):
            value |= self.rx[i].receive_nowait() << self.rx[i].data_width * i
        return value

    def available(self):
        return self.rx[0].available()

    async def receive(self):
        value = 0
        for i in range(len(self.rx)):
            value |= await self.rx[i].receive() << self.rx[i].data_width * i
        return value

    async def wait_available(self):
        await self.rx[0].wait_available() 

class NSpiSlave:
    def __init__(self, clk, mosi, miso, data_width = 8, instance_count = 1):
        
        self.rx = NSpiRx(clk, mosi, data_width, instance_count)
        self.tx = NSpiTx(clk, miso, data_width, instance_count)

    def transmit(self, value):
        self.tx.transmit(value)

    def complete(self):
        return self.tx.complete()

    async def wait_complete(self):
        await self.tx.wait_complete()

    def receive_nowait(self):
        return self.rx.receive_nowait()

    def available(self):
        return self.rx.available()

    async def receive(self):
        return await self.rx.receive()

    async def wait_available(self):
        await self.rx.wait_available()

    async def transmit_receive(self, value):
        self.transmit(value)
        return await self.receive()

class NSpiMaster:
    def __init__(self, base_clk, division_factor, clk, mosi, miso, data_width = 8, instance_count = 1):
        self.base_clk = base_clk
        self.division_factor = division_factor
        self.clk = clk
        self.data_width = data_width // instance_count

        self.slave = NSpiSlave(clk, miso, mosi, data_width, instance_count)

        self.clock_gen_queue = EventQueue(Queue())

        cocotb.start_soon(self.clock_gen())

    async def clock_gen(self):
        self.clk.value = 0
        await ClockCycles(self.base_clk, self.division_factor // 2)
        while True:
            await self.clock_gen_queue.get()
            for _ in range(self.data_width):
                self.clk.value = 1
                await ClockCycles(self.base_clk, self.division_factor // 2)
                self.clk.value = 0
                await ClockCycles(self.base_clk, self.division_factor // 2)
            await self.clock_gen_queue.get()

    def transmit(self, value):
        self.slave.transmit(value)
        self.clock_gen_queue.put_nowait(0)
        self.clock_gen_queue.put_nowait(0)

    def complete(self):
        return self.slave.complete()

    async def wait_complete(self):
        await self.slave.wait_complete()

    def receive_nowait(self):
        return self.slave.receive_nowait()

    def available(self):
        return self.slave.available()

    async def receive(self):
        if self.clock_gen_queue.empty():
            self.clock_gen_queue.put_nowait(0)
            self.clock_gen_queue.put_nowait(0)
        return await self.slave.receive()

    async def wait_available(self):
        await self.slave.wait_available()

    async def transmit_receive(self, value):
        self.transmit(value)
        return await self.receive()
