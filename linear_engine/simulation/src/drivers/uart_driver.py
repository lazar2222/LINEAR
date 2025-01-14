import cocotb
from cocotb.queue import Queue
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

from ..util.event_queue import EventQueue

class UartTx:
    def __init__(self, clk, tx, clock_rate, baud_rate, data_width=8):
        self.clk = clk
        self.tx = tx
        self.division_factor = clock_rate // baud_rate
        self.data_width = data_width + 2
        
        self.driver_queue = EventQueue(Queue())

        cocotb.start_soon(self.driver())

    async def driver(self):
        self.tx.value = 1
        while True:
            value = await self.driver_queue.get()
            for _ in range(self.data_width):
                await ClockCycles(self.clk, self.division_factor)
                self.tx.value = value & 1
                value >>= 1
            await self.driver_queue.get()

    def transmit(self, data):
        data = (1 << (self.data_width - 1)) | data << 1
        self.driver_queue.put_nowait(data)
        self.driver_queue.put_nowait(0)

    def complete(self):
        return self.driver_queue.empty()

    async def wait_complete(self):
        await self.driver_queue.wait_empty()

class UartRx:
    def __init__(self, clk, rx, clock_rate, baud_rate, data_width=8):
        self.clk = clk
        self.rx = rx
        self.division_factor = clock_rate // baud_rate
        self.data_width = data_width + 2

        self.rx_queue = EventQueue(Queue())

        cocotb.start_soon(self.monitor())

    async def monitor(self):
        while True:
            value = 0
            await FallingEdge(self.rx)
            await ClockCycles(self.clk, self.division_factor // 2)
            value |= self.rx.value.integer
            for i in range(self.data_width - 1):
                await ClockCycles(self.clk, self.division_factor)
                value |= self.rx.value.integer << (i + 1)
            self.rx_queue.put_nowait(value)

    def receive_nowait(self):
        data = self.rx_queue.get_nowait()
        assert data & 1 == 0
        assert data & (1 << (self.data_width - 1)) != 0
        return data >> 1 & ((1 << self.data_width - 2) - 1)

    def available(self):
        return not self.rx_queue.empty()

    async def receive(self):
        data = await self.rx_queue.get()
        assert data & 1 == 0
        assert data & (1 << (self.data_width - 1)) != 0
        return data >> 1 & ((1 << self.data_width - 2) - 1)

    async def wait_available(self):
        await self.rx_queue.wait_not_empty()

class UartTransceiver:
    def __init__(self, clk, tx, rx, clock_rate, baud_rate, data_width=8):
        self.tx = UartTx(clk, tx, clock_rate, baud_rate, data_width)
        self.rx = UartRx(clk, rx, clock_rate, baud_rate, data_width)

    def transmit(self, data):
        self.tx.transmit(data)

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
        return await self.rx.wait_available()

    async def transmit_receive(self, data):
        self.transmit(data)
        return await self.receive()
