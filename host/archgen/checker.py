from collections.abc import Callable
from enum            import Enum
from sys             import stderr
from typing          import overload, Any
from warnings        import warn

import diagnostics

from diagnostic      import Diagnostic, DiagnosticKind
from exceptions      import ArchGenException, ArchGenWarning, InternalException, ValidationException, ValidationWarning
from util            import is_in, unique

# Exports

__all__ = []

# Checker

class WaiveMode(Enum):
    HIDE    = "hide"
    GENERIC = "generic"
    FULL    = "full"

_WAIVED_WARNINGS = set()
_WAIVED_MODE     = WaiveMode.GENERIC

def set_waive_mode(mode: WaiveMode) -> None:
    global _WAIVED_MODE
    _WAIVED_MODE = mode

def waive_warning(message: str) -> None:
    _WAIVED_WARNINGS.add(message)

def exception_from_diagnostic(diagnostic: Diagnostic, warning: bool) -> ArchGenException | ArchGenWarning:
    table = {
        DiagnosticKind.VALIDATION: ValidationWarning if warning else ValidationException,
    }
    if diagnostic.kind not in table:
        raise InternalException(f"Unsupported diagnostic kind", kind=diagnostic.kind)
    return table[diagnostic.kind](diagnostic)

@overload
def check(condition: bool,                               diagnostic: Diagnostic,               *, warning: bool = False, stacklevel: int = 2) -> None: ...
@overload
def check(enable:    bool, condition: bool,              diagnostic: Diagnostic,               *, warning: bool = False, stacklevel: int = 2) -> None: ...

def check(enable:    bool, condition: bool | Diagnostic, diagnostic: Diagnostic | None = None, *, warning: bool = False, stacklevel: int = 2) -> None:
    if diagnostic is None:
        diagnostic = condition
        condition  = enable
        enable     = True

    message = diagnostic.render()
    exception = exception_from_diagnostic(diagnostic, warning)

    if enable and not condition:
        if warning:
            if message in _WAIVED_WARNINGS:
                if _WAIVED_MODE is WaiveMode.GENERIC:
                    print(f"Warning waived",            file=stderr)
                if _WAIVED_MODE is WaiveMode.FULL:
                    print(f"Warning waived: {message}", file=stderr)
            else:
                warn(exception, stacklevel=stacklevel)
        else:
            raise exception

def check_refs        (itr: Any, map: Callable[[Any], Any], src: Any, coll: str,  *, warning: bool = False) -> None:
    for ref, obj in ((ref, obj) for ref in itr for obj in (map(ref) if type(map(ref)) is tuple else (map(ref),))):
        check(is_in(obj, getattr(src, coll)() if callable(getattr(src, coll)) else getattr(src, coll)),   diagnostics.reference_invalid      (ref, obj, coll          ), warning=warning, stacklevel=3)

def check_unreferenced(src: Any, coll: str, map: Callable[[Any], Any], defs: Any, *, warning: bool = False) -> None:
    refs = tuple(map(ref) for ref in (getattr(src, coll)() if callable(getattr(src, coll)) else getattr(src, coll)))
    for def_ in defs:
        check(is_in(def_, tuple(obj for ref in refs for obj in (ref if type(ref) is tuple else (ref,)))), diagnostics.symbol_unreferenced    (def_,     coll          ), warning=warning, stacklevel=3)

def check_unique_by   (itr: Any, key: str, val: str,                              *, warning: bool = False) -> None:
    for k in dict.fromkeys(          getattr(obj, key) for obj in itr                           ):
        check(unique(values := tuple(getattr(obj, val) for obj in itr if getattr(obj, key) is k)),        diagnostics.value_for_key_collision(key, k, val, values, itr), warning=warning, stacklevel=3)
