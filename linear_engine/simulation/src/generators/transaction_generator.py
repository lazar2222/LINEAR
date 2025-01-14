import random

class TransactionGenerator:
    def __init__(self, operations, memory_map, sizes, alignment_requirement, byte_width=8):
        self.operations = operations
        self.memory_map = memory_map
        self.sizes = sizes
        self.alignment_requirement = alignment_requirement
        self.byte_width = byte_width

    def generate(self):
        operation = random.choice(self.operations)
        region = random.choice(self.memory_map)
        offset = random.randrange(region[1])
        address = region[0] + offset
        size = random.choice(self.sizes)
        data = random.getrandbits(size * self.byte_width)
        if self.alignment_requirement == "strict":
            address = address - (address % self.sizes[-1])
        elif self.alignment_requirement == "natural":
            address = address - (address % size)
        return operation, address, data, size
