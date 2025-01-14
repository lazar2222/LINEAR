import cocotb
from cocotb.triggers import RisingEdge

from ..models.memory_model import SinglePortMemory

class MemBankModule:
    def __init__(self, base_address, size_bytes, port_a, port_b):
        self.memory = SinglePortMemory(base_address, size_bytes)
        self.port_a = port_a
        self.port_b = port_b

        cocotb.start_soon(self.run())

    async def run(self):
        while True:
            op_a = await self.port_a.get_operation(False, True)
            op_b = await self.port_b.get_operation(False, True)
            if op_a[0] == "write" and op_b[0] == "write" and op_a[1] == op_b[1]:
                self.port_a.set_status_nowait(1, 1, 1)
                self.port_b.set_status_nowait(1, 1, 1)
                continue
            if op_a[1] == op_b[1] and op_b[0] == "read":
                res_b = self.memory.transaction(op_b[0], op_b[1] * self.port_a.WORD_SIZE, op_b[2], self.port_b.WORD_SIZE, op_b[3])
                res_a = self.memory.transaction(op_a[0], op_a[1] * self.port_a.WORD_SIZE, op_a[2], self.port_a.WORD_SIZE, op_a[3])
            else:
                res_a = self.memory.transaction(op_a[0], op_a[1] * self.port_a.WORD_SIZE, op_a[2], self.port_a.WORD_SIZE, op_a[3])
                res_b = self.memory.transaction(op_b[0], op_b[1] * self.port_a.WORD_SIZE, op_b[2], self.port_b.WORD_SIZE, op_b[3])
            if res_a is not None:
                self.port_a.respond(res_a)
            if res_b is not None:
                self.port_b.respond(res_b)
            if op_a[0] == "write":
                self.port_a.set_status_nowait(1, 1, 0)
            if op_b[0] == "write":
                self.port_b.set_status_nowait(1, 1, 0)
