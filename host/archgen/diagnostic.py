from dataclasses import dataclass
from enum        import Enum

# Exports

__all__ = []

# Enum

class DiagnosticKind(Enum):
    VALIDATION = "validation"

# Dataclass

@dataclass(frozen=True)
class Diagnostic:
    kind:    DiagnosticKind
    code:    str
    message: str
    details: tuple[str, ...]

    @classmethod
    def create(cls, kind: DiagnosticKind, code: str, message: str, *details: str) -> Diagnostic:
        return cls(kind, code, message, details)

    def qualified_code(self) -> str: return f"{self.kind.value}.{self.code}"

    def render(self) -> str:
        lines = [f"{self.message}"]
        for detail in self.details: lines.append(f"    {detail}")
        lines.append(f"    code = {self.qualified_code()}")
        return "\n".join(lines)

    def __str__(self) -> str: return self.render()
