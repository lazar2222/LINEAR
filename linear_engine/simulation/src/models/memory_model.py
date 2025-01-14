class SinglePortMemory():
    def __init__(self, base_address, size):
        self.base_address = base_address
        self.size = size
        self.memory = [0] * size

    def read(self, address, size):
        if address < self.base_address or address + size > self.base_address + self.size:
            return None
        return int.from_bytes(bytes(self.memory[address - self.base_address: address - self.base_address + size]), byteorder="little")

    def write(self, address, data, size, mask = None):
        if mask is None:
            mask = 2 ** size - 1
        if address < self.base_address or address + size > self.base_address + self.size:
            return None
        data_new = list(data.to_bytes(size, byteorder="little"))
        data_old = self.memory[address - self.base_address: address - self.base_address + size]
        for i in range(size):
            data_new[i] = data_new[i] if mask & 1 << i else data_old[i]
        self.memory[address - self.base_address: address - self.base_address + size] = data_new
        return None

    def transaction(self, operation, address, data, size, mask = None):
        if operation == "read":
            return self.read(address, size)
        elif operation == "write":
            return self.write(address, data, size, mask)
        return None
