from collections.abc import Callable
from typing          import Any

# Exports

__all__ = []

# Check utilities

def nothrow(func: Callable[[], Any], ex: type[BaseException] = Exception) -> bool:
    try:
        func()
        return True
    except ex:
        return False

def empty (itr: Any) -> bool: return len(itr) == 0
def single(itr: Any) -> bool: return len(itr) == 1
def unique(itr: Any) -> bool: return len(itr) == len(set(itr))

def duplicates(itr: Any) -> tuple[Any, ...]: return tuple(i for i in dict.fromkeys(itr) if itr.count(i) > 1)

def is_in        (obj: Any, container: Any) -> bool: return any(obj is element for element in container)
def same_elements(a:   Any, b:         Any) -> bool: return len(a) == len(b) and all(l is r for l, r in zip(a, b))

# Formatting utilities

def cname(cls: Any) -> str: return getattr(cls, "__name__", repr(cls))
def tname(obj: Any) -> str: return cname(type(obj))
def fname(obj: Any) -> str: return getattr(obj, "name", str(obj))
def  seq (itr: Any) -> str: return "(" + ", ".join(str(i) for i in itr) + ")"
def sseq (itr: Any) -> str: return seq(sorted(itr))
def nseq (itr: Any) -> str: return seq(fname(i) for i in itr)

def fnames(itr: Any) -> tuple[str, ...]: return tuple(fname(i) for i in itr)
def cnames(itr: Any) -> tuple[str, ...]: return tuple(cname(i) for i in itr)
def tnames(itr: Any) -> tuple[str, ...]: return tuple(tname(i) for i in itr)

def expected_name(expected: Any) -> str:
    if expected       is None:        return "None"
    if expected       is type(None):  return "None"
    if type(expected) is tuple:       return "one of " + seq(expected_name(option) for option in expected)
    if hasattr(expected, "__name__"): return expected.__name__
    return str(expected)
