import cocotb
from cocotb.queue import Queue
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep

from ..util.event_queue import EventQueue

class ParallelTx:
    def __init__(self, clk, entity, name):
        self.clk = clk
        self.data  = entity._id(name + "_data")
        self.valid = entity._id(name + "_valid")
        self.ready = entity._id(name + "_ready")

        self.driver_queue = EventQueue(Queue())

        cocotb.start_soon(self.driver())

    async def driver(self):
        while True:
            self.data.value = 0
            self.valid.value = 0
            data = await self.driver_queue.get()
            if self.ready.value:
                await NextTimeStep()
            else:
                while not self.ready.value:
                    await RisingEdge(self.clk)
            self.data.value = data
            self.valid.value = 1
            await self.driver_queue.get()
            await RisingEdge(self.clk)

    def transmit(self, data):
        self.driver_queue.put_nowait(data)
        self.driver_queue.put_nowait(0)

    def complete(self):
        return self.driver_queue.empty()

    async def wait_complete(self):
        await self.driver_queue.wait_empty()

class ParallelRx:
    def __init__(self, clk, entity, name, readys = 0):
        self.clk = clk
        self.data  = entity._id(name + "_data")
        self.valid = entity._id(name + "_valid")
        self.ready = entity._id(name + "_ready")
        self.readys = readys

        self.rx_queue    = EventQueue(Queue())
        self.ready_queue = EventQueue(Queue())

        cocotb.start_soon(self.monitor())
        cocotb.start_soon(self.driver())

    async def monitor(self):
        read = False
        while True:
            await ReadOnly()
            if self.valid.value and self.ready.value:
                self.rx_queue.put_nowait(self.data.value)
                read = True
            await RisingEdge(self.clk)
            if read:
                if self.readys > 0:
                    self.readys -= 1
                if self.readys == 0:
                    self.ready.value = 0
                read = False

    async def driver(self):
        if self.readys != 0:
            self.ready.value = 1
        while True:
            await self.ready_queue.get()
            self.ready.value = 1
            while self.ready.value:
                await NextTimeStep()
                await ReadOnly()

    def set_ready(self, readys):
        self.ready = readys
        if readys != 0:
            self.ready_queue.put_nowait(0)

    def is_ready(self):
        return self.ready != 0

    def receive_nowait(self):
        return self.rx_queue.get_nowait()

    def available(self):
        return not self.rx_queue.empty()

    async def receive(self):
        return await self.rx_queue.get()

    async def wait_available(self):
        await self.rx_queue.wait_not_empty()

class ParallelTransceiver:
    def __init__(self, clk, entity, name, inverted = True, readys = 0):
        if inverted:
            self.tx = ParallelTx(clk, entity, name + "_rx")
            self.rx = ParallelRx(clk, entity, name + "_tx", readys)
        else:
            self.tx = ParallelTx(clk, entity, name + "_tx")
            self.rx = ParallelRx(clk, entity, name + "_rx", readys)

    def transmit(self, data):
        self.tx.transmit(data)

    def complete(self):
        return self.tx.complete()

    async def wait_complete(self):
        await self.tx.wait_complete()

    def set_ready(self, readys):
        self.rx.set_ready(readys)

    def is_ready(self):
        return self.rx.is_ready()

    def receive_nowait(self):
        return self.rx.receive_nowait()

    def available(self):
        return self.rx.available()

    async def receive(self):
        return await self.rx.receive()

    async def wait_available(self):
        await self.rx.wait_available()

    async def transmit_receive(self, data):
        self.transmit(data)
        return await self.receive()
