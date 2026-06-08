from collections.abc import Callable
from dataclasses     import dataclass
from enum            import Enum
from sys             import stderr
from typing          import overload, Any
from warnings        import warn

# Exports

__all__ = [
    "WaiveMode",
    "set_waive_mode",
    "waive_warning",
    "check",

    "be",
    "have",
    "is_",
    "are",
    "has",
    "none",

    "fxmby",
    "xmby",
    "xsby",

    "STR",
    "REPR",
    "got",

    "cname",
    "tname",
    "seq",
    "sseq",

    "nothrow",

    "empty",
    "single",
    "unique",

    "duplicates",
    "fnames",
    "cnames",
    "tnames",

    "is_in",
    "same_elements",

    "check_refs",
    "check_unreferenced",
    "check_unique_by",
]

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

@overload
def check(condition: bool,                                *, warning: bool = False, message: str | Callable[[bool], str], stacklevel: int = 2) -> None: ...
@overload
def check(enable:    bool, condition: bool,               *, warning: bool = False, message: str | Callable[[bool], str], stacklevel: int = 2) -> None: ...

def check(enable:    bool, condition: bool | None = None, *, warning: bool = False, message: str | Callable[[bool], str], stacklevel: int = 2) -> None:
    if callable(message):
        message   = message(warning)
    if condition is None:
        condition = enable
        enable    = True
    if enable and not condition:
        if warning:
            if message in _WAIVED_WARNINGS:
                if _WAIVED_MODE is WaiveMode.GENERIC:
                    print(f"Warning waived",            file=stderr)
                if _WAIVED_MODE is WaiveMode.FULL:
                    print(f"Warning waived: {message}", file=stderr)
            else:
                warn(message, stacklevel=stacklevel)
        else:
            raise ValueError(message)

# Templates

@dataclass(frozen=True)
class Prefixed:
    prefix: str
    text:   str

def be  (text: str) -> Prefixed: return Prefixed("be",   text)
def have(text: str) -> Prefixed: return Prefixed("have", text)
def is_ (text: str) -> Prefixed: return Prefixed("is",   text)
def are (text: str) -> Prefixed: return Prefixed("are",  text)
def has (text: str) -> Prefixed: return Prefixed("has",  text)
def none(text: str) -> Prefixed: return Prefixed("",     text)

def default_prefixes(x: str, y: str | Prefixed, z: str | None = None, w: str | Prefixed | None = None) -> tuple[str, Prefixed, str | None, Prefixed | None]:
    if type(y) is str:
        y = be(y)
    if type(w) is str:
        w = is_(w)
    return x, y, z, w

def assemble(x: str, ms: str, y: Prefixed, z: str | None = None, w: Prefixed | None = None) -> str:
    res      = f"{x} {ms}{" " if y.prefix else ""}{y.prefix} {y.text}"
    if z is not None:
        res += f", got {z}"
    if w is not None:
        res += f", which{ " " if w.prefix else ""}{w.prefix} {w.text}"
    return res

def fxmby(x: str, y: str | Prefixed, z: str | None = None, w: str | Prefixed | None = None) -> Callable[[bool], str]:
    x, y, z, w = default_prefixes(x, y, z, w)
    return lambda warning: assemble(x, "should" if warning else "must", y, z, w)

def xmby(x: str, y: str | Prefixed, z: str | None = None, w: str | Prefixed | None = None) -> str: return fxmby(x, y, z, w)(False)
def xsby(x: str, y: str | Prefixed, z: str | None = None, w: str | Prefixed | None = None) -> str: return fxmby(x, y, z, w)(True )

# Helpers

class GotMode(Enum):
    STR  = "str"
    REPR = "repr"

STR  = GotMode.STR
REPR = GotMode.REPR

def got(obj: Any, mode: GotMode = STR) -> str:
    if mode is GotMode.STR:
        return f"\"{obj!s}\""
    if mode is GotMode.REPR:
        return f"\"{obj!r}\""

def cname(cls: Any) -> str: return getattr(cls, "__name__", repr(cls))
def tname(obj: Any) -> str: return cname(type(obj))
def  seq (itr: Any) -> str: return f"({", ".join(str(i) for i in itr)})"
def sseq (itr: Any) -> str: return seq(sorted(itr))

def nothrow(func: Callable[[], Any], ex: type[BaseException] = Exception) -> bool:
    try:
        func()
        return True
    except ex:
        return False

def empty     (itr: Any) -> bool: return len(itr) == 0
def single    (itr: Any) -> bool: return len(itr) == 1
def unique    (itr: Any) -> bool: return len(itr) == len(set(itr))

def duplicates(itr: Any) -> tuple[Any, ...]: return tuple(i        for i in dict.fromkeys(itr) if itr.count(i) > 1)
def fnames    (itr: Any) -> tuple[str, ...]: return tuple(i.name   for i in itr                                   )
def cnames    (itr: Any) -> tuple[str, ...]: return tuple(cname(i) for i in itr                                   )
def tnames    (itr: Any) -> tuple[str, ...]: return tuple(tname(i) for i in itr                                   )

def is_in        (obj: Any, container: Any) -> bool: return any(obj is element for element in container)
def same_elements(a:   Any, b:         Any) -> bool: return len(a) == len(b) and all(l is r for l, r in zip(a, b))

def check_refs        (x: str, y: str,         itr: Any, map: Callable[[Any], Any], defs: Any,                 *, warning: bool = False) -> None:
    for ref in itr:
        for obj in tuple(map(ref)) if is_in(type(map(ref)), (tuple, list)) else (map(ref),):
            check(is_in(obj, defs), warning=warning, message=fxmby(x + " of " + tname(ref) + " " + got(getattr(ref, "name", str(ref))), "present in " + y, got(getattr(obj, "name", str(obj))), "missing"),                stacklevel=3)

def check_unreferenced(x: str, y: str, w: str, itr: Any, map: Callable[[Any], Any], defs: Any,                 *, warning: bool = False) -> None:
    refs = tuple(obj for ref in itr for obj in (tuple(map(ref)) if is_in(type(map(ref)), (tuple, list)) else (map(ref),)))
    for def_ in defs:
        check(is_in(def_, refs),    warning=warning, message=fxmby(x + " " + got(getattr(def_, "name", str(def_))), "referenced by " + y, got(getattr(def_, "name", str(def_))), "unreferenced by " + w),                  stacklevel=3)

def check_unique_by   (x: str, y: str,         itr: Any, key: Callable[[Any], Any], val: Callable[[Any], Any], *, warning: bool = False) -> None:
    for k in dict.fromkeys(key(obj) for obj in itr):
        values =     tuple(val(obj) for obj in itr if key(obj) == k)
        check(unique(values),       warning=warning, message=fxmby(x + " for " + y + " " + got(getattr(k, "name", str(k))), "unique", got(seq(values)), has("the following duplicates " + got(seq(duplicates(values))))), stacklevel=3)
