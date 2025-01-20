import cocotb

class AccessBusDriver:
    def __init__(self, physical_layer, address_width = 30, data_width = 32):
        self.physical_layer = physical_layer
        self.address_width = address_width
        self.data_width = data_width

        self.min_address_size = address_width + 2
        self.physical_width = self.physical_layer.dw
        self.address_part = ((self.min_address_size + self.physical_width - 1) // self.physical_width) * self.physical_width
        self.data_part = ((self.data_width + self.physical_width - 1) // self.physical_width) * self.physical_width

        self.responses_required = 0
        self.responses = []

    def assemble(self, operation, address):
        return (operation << self.address_part - 2) | address

    def wide_transmit(self, value, width):
        mask = ((1 << self.physical_width) - 1) << (width - self.physical_width)
        for i in range(width // self.physical_width):
            self.physical_layer.transmit((value & mask) >> ((width // self.physical_width - i - 1) * self.physical_width))
            mask >>= self.physical_width

    def read(self, address, count = 1):
        if count > 1:
            for i in range(count):
                self.read(address + i)
        else:
            value = self.assemble(1, address)
            self.wide_transmit(value, self.address_part)
            self.responses_required += self.data_part // self.physical_width

    def burst(self, address, data):
        value = self.assemble(3, address)
        self.wide_transmit(value, self.address_part)
        self.wide_transmit(len(data), self.data_part)
        for i in range(len(data)):
            self.wide_transmit(data[i], self.data_part)

    def write(self, address, data):
        if isinstance(data, list):
            self.burst(address, data)
        else:
            value = self.assemble(2, address)
            self.wide_transmit(value, self.address_part)
            self.wide_transmit(data, self.data_part)

    def transaction(self, operation, address, data):
        if operation == "read":
            self.read(address, data)
        elif operation == "write":
            self.write(address, data)
        elif operation == "burst":
            self.burst(address, data)

    def complete(self):
        if self.physical_layer.complete():
            while self.physical_layer.available():
                self.responses.append(self.physical_layer.receive_nowait())
                self.responses_required -= 1
            return self.responses_required == 0
        else:
            return False

    async def wait_complete(self):
        await self.physical_layer.wait_complete()
        while self.responses_required > 0:
            self.responses.append(await self.physical_layer.receive())
            self.responses_required -= 1

    def get_result(self):
        result = 0
        for _ in range(self.data_part // self.physical_width):
            result = (result << self.physical_width) | self.responses.pop(0)
        return result
