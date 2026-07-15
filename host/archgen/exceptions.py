from typing     import Any

from diagnostic import Diagnostic

# Exports

__all__ = []

# Exceptions

class ArchGenException   (Exception          ): pass
class ArchGenWarning     (Warning            ): pass

class UserFacingException(ArchGenException   ):
    def __init__(self, diagnostic: Diagnostic) -> None:
        self.diagnostic = diagnostic
        super().__init__(str(diagnostic))

class UserFacingWarning  (ArchGenWarning     ):
    def __init__(self, diagnostic: Diagnostic) -> None:
        self.diagnostic = diagnostic
        super().__init__(str(diagnostic))

class ValidationException(UserFacingException): pass
class ValidationWarning  (UserFacingWarning  ): pass

class InternalException  (ArchGenException   ):
    def __init__(self, message: str, **details: Any) -> None:
        self.message = message
        self.details = details
        super().__init__(str(self))

    def __str__(self) -> str:
        if len(self.details) == 0:
            return self.message
        details = ", ".join(f"{key}={value!r}" for key, value in self.details.items())
        return self.message + ": " + details
