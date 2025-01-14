import cocotb
from cocotb.triggers import Event
from cocotb.queue import Queue

class EventQueue:
    def __init__(self, queue):
        self.queue = queue
        self.maxsize = queue.maxsize
        self.put_event = Event()
        self.get_event = Event()

    def qsize(self):
        return self.queue.qsize()

    def empty(self):
        return self.queue.empty()

    def full(self):
        return self.queue.full()

    def put_nowait(self, item):
        self.queue.put_nowait(item)
        self.put_event.set()

    def get_nowait(self):
        res =  self.queue.get_nowait()
        self.get_event.set()
        return res

    async def put(self, item):
        await self.queue.put(item)
        self.put_event.set()

    async def get(self):
        res = await self.queue.get()
        self.get_event.set()
        return res

    async def wait_empty(self):
        while not self.queue.empty():
            await self.get_event.wait()
            self.get_event.clear()

    async def wait_full(self):
        while not self.queue.full():
            await self.put_event.wait()
            self.put_event.clear()

    async def wait_not_empty(self):
        while self.queue.empty():
            await self.put_event.wait()
            self.put_event.clear()

    async def wait_not_full(self):
        while self.queue.full():
            await self.get_event.wait()
            self.get_event.clear()
