import math
import cocotb
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep
from cocotb.queue import Queue

from ..util.event_queue import EventQueue

class BusMaster:
    def __init__(self, entity, name, clk = "clk", latency = 1):
        self.latency = latency
        self.clk         = entity._id(clk)
        self.data_ctp    = entity._id(name + "_data_ctp")
        self.data_ptc    = entity._id(name + "_data_ptc")
        self.address     = entity._id(name + "_address")
        self.byte_enable = entity._id(name + "_byte_enable")
        self.hit_address = entity._id(name + "_hit_address")
        self.hit_mask    = entity._id(name + "_hit_mask")
        self.read_       = entity._id(name + "_read")
        self.write_      = entity._id(name + "_write")
        self.hit         = entity._id(name + "_hit")
        self.complete    = entity._id(name + "_complete")
        self.error       = entity._id(name + "_error")

        self.DATA_WIDTH         = entity._id("DATA_WIDTH_" + name).value
        self.BYTE_ADDRESS_WIDTH = entity._id("BYTE_ADDRESS_WIDTH_" + name).value
        self.BYTE_WIDTH         = entity._id("BYTE_WIDTH_" + name).value
        self.WORD_SIZE          = entity._id("WORD_SIZE_" + name).value
        self.WORD_ADDRESS_WIDTH = entity._id("WORD_ADDRESS_WIDTH_" + name).value

        self.driver_queue         = EventQueue(Queue())
        self.verif_monitor_queue  = EventQueue(Queue())
        self.result_monitor_queue = EventQueue(Queue())
        self.operation_queue      = EventQueue(Queue())
        self.result_queue         = EventQueue(Queue())

        cocotb.start_soon(self.driver())
        cocotb.start_soon(self.monitor())

    def set(self, data_ctp, address, byte_enable, read, write):
        if data_ctp is not None:
            self.data_ctp.value    = data_ctp
        if address is not None:
            self.address.value     = address
        if byte_enable is not None:
            self.byte_enable.value = byte_enable
        if read is not None:
            self.read_.value       = read
        if write is not None:
            self.write_.value      = write

    def get(self):
        res = {}
        res["data_ctp"]    = self.data_ctp.value.integer
        res["data_ptc"]    = self.data_ptc.value.integer
        res["address"]     = self.address.value.integer
        res["byte_enable"] = self.byte_enable.value.integer
        res["hit_address"] = self.hit_address.value.integer
        res["hit_mask"]    = self.hit_mask.value.integer
        res["read"]        = self.read_.value.integer
        res["write"]       = self.write_.value.integer
        res["hit"]         = self.hit.value.integer
        res["complete"]    = self.complete.value.integer
        res["error"]       = self.error.value.integer
        return res

    def drive_read(self, address, size = None):
        offset = address % self.WORD_SIZE
        self.set(0, address // self.WORD_SIZE, 0, 1, 0)
        assert self.verif_monitor_queue.qsize() == 0
        self.verif_monitor_queue.put_nowait((size, offset))

    def drive_write(self, address, data, size = None):
        offset = address % self.WORD_SIZE
        self.set(data << (offset * self.BYTE_WIDTH), address // self.WORD_SIZE, (2 ** size - 1) << offset, 0, 1)
        assert self.verif_monitor_queue.qsize() == 0
        self.verif_monitor_queue.put_nowait((size, offset))

    def validate_op(self, size, offset):
        dict = self.get()
        if dict["hit"] == 0:
            self.operation_queue.put_nowait(("miss", dict["address"], "read" if dict["read"] == 1 else "write"))
        elif dict["error"] == 1:
            self.operation_queue.put_nowait(("error", dict["address"], "read" if dict["read"] == 1 else "write"))
        elif dict["complete"] == 0:
            self.operation_queue.put_nowait(("incomplete", dict["address"], "read" if dict["read"] == 1 else "write"))
        else:
            self.operation_queue.put_nowait(("complete", dict["address"], "read" if dict["read"] == 1 else "write"))
            assert self.result_monitor_queue.qsize() < self.latency + 1
            while self.result_monitor_queue.qsize() < self.latency:
                self.result_monitor_queue.put_nowait(("wait", None, None, None))
            self.result_monitor_queue.put_nowait(("read" if dict["read"] == 1 else "write", dict["address"], size, offset))

    def calculate_result(self, op, address, size, offset):
        dict = self.get()
        if op == "read":
            data = dict["data_ptc"] >> (offset * self.BYTE_WIDTH)
            data = data & (2 ** (size * self.BYTE_WIDTH) - 1)
            self.result_queue.put_nowait((op, address, data))
        elif op == "write":
            self.result_queue.put_nowait((op, address, None))

    async def driver(self):
        while True:
            self.set(0, 0, 0, 0, 0)
            if not self.driver_queue.empty():
                op, address, size, data = self.driver_queue.get_nowait()
                if op == "read":
                    self.drive_read(address, size)
                elif op == "write":
                    self.drive_write(address, data, size)
            await RisingEdge(self.clk)

    async def monitor(self):
        while True:
            await ReadOnly()
            if not self.verif_monitor_queue.empty():
                size, offset = self.verif_monitor_queue.get_nowait()
                self.validate_op(size, offset)
            if not self.result_monitor_queue.empty():
                op, address, size, offset = self.result_monitor_queue.get_nowait()
                self.calculate_result(op, address, size, offset)
            await RisingEdge(self.clk)
            await NextTimeStep()

    def read(self, address, size = None):
        if size is None:
            size = self.WORD_SIZE
        if size > self.WORD_SIZE or not math.log2(size).is_integer():
            return "invalid_size"
        if address % size != 0:
            return "misaligned"
        self.driver_queue.put_nowait(("read", address, size, None))
        return "ok"

    def write(self, address, data, size = None):
        if size is None:
            size = self.WORD_SIZE
        if size > self.WORD_SIZE or not math.log2(size).is_integer():
            return "invalid_size"
        if address % size != 0:
            return "misaligned"
        self.driver_queue.put_nowait(("write", address, size, data))
        return "ok"

    def transaction(self, operation, address, data = None, size = None):
        if operation == "read":
            return self.read(address, size)
        elif operation == "write":
            return self.write(address, data, size)

    def get_status_nowait(self):
        result, address, op = self.operation_queue.get_nowait()
        return result

    def get_result_nowait(self):
        op, address, data = self.result_queue.get_nowait()
        return data

    def status_ready(self):
        return not self.operation_queue.empty()

    def result_ready(self):
        return not self.result_queue.empty()

    async def wait_flush(self):
        await self.driver_queue.wait_empty()

    async def wait_complete(self, all = False):
        if all:
            await self.wait_flush()
        await self.verif_monitor_queue.wait_empty()

    async def wait_result(self, all = False):
        if all:
            await self.wait_complete(True)
        await self.result_monitor_queue.wait_empty()

    async def flush(self, clearOutstanding = False):
        await self.wait_complete(True)
        while not self.operation_queue.empty():
            result, address, op = self.operation_queue.get_nowait()
        while not self.result_queue.empty():
            op, address, data = self.result_queue.get_nowait()
        if clearOutstanding:
            while not self.result_monitor_queue.empty():
                op, address, size, offset = self.result_monitor_queue.get_nowait()
        else:
            return self.result_monitor_queue.qsize()

    async def get_status(self):
        result, address, op = await self.operation_queue.get()
        return result

    async def get_result(self):
        op, address, data = await self.result_queue.get()
        return data

    async def read_with_status(self, address, size = None, retry = False):
        await self.flush()
        while True:
            status = self.read(address, size)
            if status != "ok":
                return status
            res = await self.get_status()
            if res == "complete" or not retry:
                return res
            if res != "incomplete":
                return res

    async def write_with_status(self, address, data, size = None, retry = True):
        await self.flush()
        while True:
            status = self.write(address, data, size)
            if status != "ok":
                return status
            res = await self.get_status()
            if res == "complete" or not retry:
                return res
            if res != "incomplete":
                return res

    async def transaction_with_status(self, operation, address, data = None, size = None, retry = True):
        await self.flush()
        while True:
            status = self.transaction(operation, address, data, size)
            if status != "ok":
                return status
            res = await self.get_status()
            if res == "complete" or not retry:
                return res
            if res != "incomplete":
                return res

    async def read_with_result(self, address, size = None):
        await self.flush(True)
        status = await self.read_with_status(address, size, True)
        if status != "complete":
            return status
        return await self.get_result()

    async def write_with_result(self, address, data, size = None):
        await self.flush(True)
        status = await self.write_with_status(address, data, size, True)
        if status != "complete":
            return status
        return await self.get_result()

    async def transaction_with_result(self, operation, address, data = None, size = None):
        await self.flush(True)
        status = await self.transaction_with_status(operation, address, data, size, True)
        if status != "complete":
            return status
        return await self.get_result()

class BusSlave:
    def __init__(self, entity, name, clk = "clk", latency = 1, base_address = None, size_bytes = None):
        self.latency = latency
        self.clk         = entity._id(clk)
        self.data_ctp    = entity._id(name + "_data_ctp")
        self.data_ptc    = entity._id(name + "_data_ptc")
        self.address     = entity._id(name + "_address")
        self.byte_enable = entity._id(name + "_byte_enable")
        self.hit_address = entity._id(name + "_hit_address")
        self.hit_mask    = entity._id(name + "_hit_mask")
        self.read_       = entity._id(name + "_read")
        self.write_      = entity._id(name + "_write")
        self.hit         = entity._id(name + "_hit")
        self.complete    = entity._id(name + "_complete")
        self.error       = entity._id(name + "_error")

        self.DATA_WIDTH         = entity._id("DATA_WIDTH_" + name).value
        self.BYTE_ADDRESS_WIDTH = entity._id("BYTE_ADDRESS_WIDTH_" + name).value
        self.BYTE_WIDTH         = entity._id("BYTE_WIDTH_" + name).value
        self.WORD_SIZE          = entity._id("WORD_SIZE_" + name).value
        self.WORD_ADDRESS_WIDTH = entity._id("WORD_ADDRESS_WIDTH_" + name).value

        if base_address is not None and size_bytes is not None:
            size_words = size_bytes // self.WORD_SIZE
            local_address_width = math.ceil(math.log2(size_words))
            device_address_width = self.WORD_ADDRESS_WIDTH - local_address_width
            self._hit_mask = (2 ** device_address_width - 1) << local_address_width
            self._hit_address = base_address & self._hit_mask
        else:
            self._hit_mask = None
            self._hit_address = None

        self.operation_queue = EventQueue(Queue())
        self.hit_queue       = EventQueue(Queue())
        self.status_queue    = EventQueue(Queue())
        self.data_queue      = EventQueue(Queue())

        cocotb.start_soon(self.monitor())
        cocotb.start_soon(self.driver_hit())
        cocotb.start_soon(self.driver_status_set())
        cocotb.start_soon(self.driver_status_reset())
        cocotb.start_soon(self.driver_data())

    def set(self, data_ptc, hit_address, hit_mask, hit, complete, error):
        if data_ptc is not None:
            self.data_ptc.value    = data_ptc
        if hit_address is not None:
            self.hit_address.value = hit_address
        if hit_mask is not None:
            self.hit_mask.value    = hit_mask
        if hit is not None:
            self.hit.value         = hit
        if complete is not None:
            self.complete.value    = complete
        if error is not None:
            self.error.value       = error

    def get(self):
        res = {}
        res["data_ctp"]    = self.data_ctp.value.integer
        res["data_ptc"]    = self.data_ptc.value.integer
        res["address"]     = self.address.value.integer
        res["hit_address"] = self.hit_address.value.integer
        res["hit_mask"]    = self.hit_mask.value.integer
        res["byte_enable"] = self.byte_enable.value.integer
        res["read"]        = self.read_.value.integer
        res["write"]       = self.write_.value.integer
        res["hit"]         = self.hit.value.integer
        res["complete"]    = self.complete.value.integer
        res["error"]       = self.error.value.integer
        return res

    def drive_hit(self, address, mask):
        self.set(None, address, mask, None, None, None)

    def drive_status(self, hit, complete, error):
        self.set(None, None, None, hit, complete, error)

    def drive_data(self, data):
        self.set(data, None, None, None, None, None)

    def detect_operation(self):
        dict = self.get()
        data = dict["data_ctp"]
        address = dict["address"]
        byte_enable = dict["byte_enable"]
        read = dict["read"]
        write = dict["write"]
        hit = self._hit_address is None or (address & self._hit_mask) == self._hit_address
        if hit:
            self.operation_queue.put_nowait(("read" if read == 1 else ("write" if write == 1 else "hit"), address, data, byte_enable))
        else:
            self.operation_queue.put_nowait(("miss", address, data, byte_enable))

    async def driver_hit(self):
        while True:
            self.drive_hit(self._hit_address, self._hit_mask)
            address, mask = await self.hit_queue.get()
            self.drive_hit(address, mask)
            await RisingEdge(self.clk)

    async def driver_status_set(self):
        while True:
            hit, complete, error = await self.status_queue.get()
            await NextTimeStep()
            self.drive_status(hit, complete, error)

    async def driver_status_reset(self):
        while True:
            self.drive_status(0, 0, 0)
            await RisingEdge(self.clk)

    async def driver_data(self):
        while True:
            self.drive_data(0)
            if not self.data_queue.empty():
                self.drive_data(self.data_queue.get_nowait())
            await RisingEdge(self.clk)

    async def monitor(self):
        while True:
            await ReadOnly()
            self.detect_operation()
            await RisingEdge(self.clk)

    def get_operation_nowait(self, filter = False, last = False):
        operation = self.operation_queue.get_nowait()
        if last:
            while not self.operation_queue.empty():
                operation = self.operation_queue.get_nowait()
            if filter:
                return operation if operation[0] != "miss" else None
            return operation
        if filter:
            while operation[0] == "miss":
                operation = self.operation_queue.get_nowait()
            return operation
        return operation

    def operation_available(self):
        return not self.operation_queue.empty()

    async def get_operation(self, filter = False, last = False):
        operation = await self.operation_queue.get()
        if last:
            while not self.operation_queue.empty():
                operation = await self.operation_queue.get()
            if filter:
                return operation if operation[0] != "miss" else None
            return operation
        if filter:
            while operation[0] == "miss":
                operation = await self.operation_queue.get()
            return operation
        return operation

    async def wait_operation_available(self):
        await self.operation_queue.wait_not_empty()

    def set_hit_nowait(self, address, mask):
        self.hit_queue.put_nowait((address, mask))

    def hit_complete(self):
        return self.hit_queue.empty()

    async def wait_hit_complete(self):
        await self.hit_queue.wait_empty()

    def set_status_nowait(self, hit, complete, error):
        self.status_queue.put_nowait((hit, complete, error))

    def status_complete(self):
        return self.status_queue.empty()

    async def wait_status_complete(self):
        await self.status_queue.wait_empty()

    def set_data_nowait(self, data):
        assert self.data_queue.qsize() < self.latency
        while self.data_queue.qsize() < self.latency - 1:
            self.data_queue.put_nowait(None)
        self.data_queue.put_nowait(data)

    def data_complete(self):
        return self.data_queue.empty()

    async def wait_data_complete(self):
        await self.data_queue.wait_empty()

    def respond(self, data):
        self.set_status_nowait(1, data is not None, data is None)
        if data is not None:
            self.set_data_nowait(data)
