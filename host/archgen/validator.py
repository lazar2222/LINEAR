from collections.abc   import Callable
from dataclasses       import dataclass, fields, is_dataclass, InitVar, KW_ONLY
from enum              import Enum, EnumType
from sys               import stderr
from types             import FunctionType
from typing            import get_args, get_origin, get_type_hints, overload
from typing            import Annotated, Any, ClassVar, TypeAliasType, Union
from typing_extensions import TypeForm
from warnings          import warn

# Exports

__all__ = [
    "WaiveMode",
    "set_waive_mode",
    "waive_warning",
    "check",
    "Constraint",
    "validated",
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
def check(condition: bool,                                *, warning: bool = False, message: str) -> None: ...
@overload
def check(enable:    bool, condition: bool,               *, warning: bool = False, message: str) -> None: ...

def check(enable:    bool, condition: bool | None = None, *, warning: bool = False, message: str) -> None:
    if condition is None:
        condition = enable
        enable    = True
    if enable and not condition:
        if warning:
            if message in _WAIVED_WARNINGS:
                if   _WAIVED_MODE is WaiveMode.GENERIC:
                    print(f"Warning waived",            file=stderr)
                elif _WAIVED_MODE is WaiveMode.FULL:
                    print(f"Warning waived: {message}", file=stderr)
            else:
                warn(message, stacklevel=2)
        else:
            raise ValueError(message)

def nothrow(func: Callable[[], Any], ex: type[BaseException] = Exception) -> bool:
    try:
        func()
        return True
    except ex:
        return False

def name(cls: Any) -> str:
    return getattr(cls, "__name__", repr(cls))

def tname(obj: Any) -> str:
    return name(type(obj))

def got(obj: Any) -> str:
    return f"\"{obj!r}\""

def seq(iterable: Any) -> str:
    return f"({', '.join(str(item) for item in iterable)})"

# Validator

@dataclass(frozen=True)
class Constraint[TConstraint]:
    name:       str
    valid_type: TypeForm[TConstraint]
    validator:  Callable[[TConstraint], bool]

    def __post_init__(self) -> None:
        resolve_hint(self.valid_type)
        check(type(self.name) is str,               message=
            f"Constraint.name must be a non-empty string, got {got(self.name)}, which is a {got(tname(self.name))}")
        check(bool(self.name.strip()),              message=
            f"Constraint.name must be a non-empty string, got {got(self.name)}, which is an empty or whitespace-only string")
        check(type(self.validator) is FunctionType, message=
            f"Constraint.validator must be a function, got {got(self.validator)}, which is a {got(tname(self.validator))}")

    def __str__(self) -> str:
        return self.name

    def annot(self) -> TypeForm[TConstraint]:
        return Annotated[self.valid_type, self]

type ValidType = SimpleType | ConstraintType | UnionType | FixedTupleType | UniformTupleType

def is_valid_type(value: Any) -> bool:
    return any(type(value) is t for t in (SimpleType, ConstraintType, UnionType, FixedTupleType, UniformTupleType))

@dataclass(frozen=True)
class SimpleType:
    type: type

    def __post_init__(self) -> None:
        is_value_type     = any(self.type is t for t in (bool, str, int, type(None)))
        is_enum_type      = type(self.type) is EnumType and issubclass(self.type, Enum)
        is_validated_type = type(self.type) is type     and is_validated(self.type)
        check(is_value_type or is_enum_type or is_validated_type, message=
            f"SimpleType.type must be a value type, Enum, or @validated class, got {got(name(self.type))}, which is neither")

    def __str__(self) -> str:
        return self.type.__name__

@dataclass(frozen=True)
class ConstraintType:
    type:       ValidType
    constraint: Constraint[Any]

    def __post_init__(self) -> None:
        check(is_valid_type(self.type),                              message=
            f"ConstraintType.type must be a ValidType matching ConstraintType.constraint.valid_type, got {got(self.type)}, which is a {got(tname(self.type))}")
        check(type(self.constraint) is Constraint,                   message=
            f"ConstraintType.constraint must be a Constraint, got {got(self.constraint)}, which is a {got(tname(self.constraint))}")
        check(self.type == resolve_hint(self.constraint.valid_type), message=
            f"ConstraintType.type must be a ValidType matching ConstraintType.constraint.valid_type, got {got(self.type)}, "
            f"which does not match {got(resolve_hint(self.constraint.valid_type))}")

    def __str__(self) -> str:
        return str(self.constraint)

@dataclass(frozen=True)
class UnionType:
    options: tuple[ValidType, ...]

    def __post_init__(self) -> None:
        check(type(self.options) is tuple,                           message=
            f"UnionType.options must be a tuple of ValidType elements with at least 2 elements, got {got(self.options)}, "
            f"which is a {got(tname(self.options))}")
        check(all(is_valid_type(option) for option in self.options), message=
            f"UnionType.options must be a tuple of ValidType elements with at least 2 elements, got {got(self.options)}, "
            f"which has the following non-ValidType elements {got([option for option in self.options if not is_valid_type(option)])} "
            f"of types {got([tname(option) for option in self.options if not is_valid_type(option)])}")
        check(len(self.options) >= 2,                                message=
            f"UnionType.options must be a tuple of ValidType elements with at least 2 elements, got {got(self.options)}, "
            f"which has {got(len(self.options))} elements")

    def __str__(self) -> str:
        return " | ".join(str(option) for option in self.options)

@dataclass(frozen=True)
class FixedTupleType:
    elements: tuple[ValidType, ...]

    def __post_init__(self) -> None:
        check(type(self.elements) is tuple,                             message=
            f"FixedTupleType.elements must be a tuple of ValidType elements with at least 1 element, got {got(self.elements)}, "
            f"which is a {got(tname(self.elements))}")
        check(all(is_valid_type(element) for element in self.elements), message=
            f"FixedTupleType.elements must be a tuple of ValidType elements with at least 1 element, got {got(self.elements)}, "
            f"which has the following non-ValidType elements {got([element for element in self.elements if not is_valid_type(element)])} "
            f"of types {got([tname(element) for element in self.elements if not is_valid_type(element)])}")
        check(len(self.elements) >= 1,                                  message=
            f"FixedTupleType.elements must be a tuple of ValidType elements with at least 1 element, got {got(self.elements)}, "
            f"which has {got(len(self.elements))} elements")

    def __str__(self) -> str:
        return f"({", ".join(str(element) for element in self.elements)})"

@dataclass(frozen=True)
class UniformTupleType:
    element: ValidType

    def __post_init__(self) -> None:
        check(is_valid_type(self.element), message=
            f"UniformTupleType.element must be a ValidType, got {got(self.element)}, which is a {got(tname(self.element))}")

    def __str__(self) -> str:
        return f"({self.element}, ...)"

def resolve_hint(hint: Any) -> ValidType:
    origin = get_origin(hint)
    args   = get_args(hint)
    if   type(hint) is TypeAliasType:
        return resolve_hint(hint.__value__)
    elif any(hint is t for t in (bool, str, int, type(None))):
        return SimpleType(hint)
    elif type(hint) is EnumType and issubclass(hint, Enum):
        return SimpleType(hint)
    elif type(hint) is type and is_validated(hint):
        return SimpleType(hint)
    elif origin is Annotated:
        check(len(args) == 2, message=f"Annotated hint args must be a tuple with 2 elements, got {got(args)}, which has {got(len(args))} arguments")
        return ConstraintType(resolve_hint(args[0]), args[1])
    elif origin is Union:
        return UnionType(tuple(resolve_hint(arg) for arg in get_args(hint)))
    elif origin is tuple:
        if len(args) == 2 and args[1] is Ellipsis:
            return UniformTupleType(resolve_hint(args[0]))
        else:
            return FixedTupleType(tuple(resolve_hint(arg) for arg in args))
    else:
        check(False,          message=f"hint must be a supported type hint, got {got(hint)}, which is a {got(tname(hint))}")

def check_field(cls_name: str, field: str, value: Any, hint: ValidType) -> None:
    if   type(hint) is SimpleType:
        if hint.type is type(None):
            check(value is None,                                                                                       message=
                f"{cls_name}.{field} must be None, got {got(value)}, which is not None")
        else:
            check(type(value) is hint.type,                                                                            message=
                f"{cls_name}.{field} must be a {str(hint)}, got {got(value)}, which is a {got(tname(value))}")
    elif type(hint) is ConstraintType:
        check_field(cls_name, field, value, hint.type)
        check(hint.constraint.validator(value),                                                                        message=
            f"{cls_name}.{field} must be a {str(hint)}, got {got(value)}, which does not satisfy constraint")
    elif type(hint) is UnionType:
        check(any(nothrow(lambda: check_field(cls_name, field, value, option), ValueError) for option in hint.options), message=
            f"{cls_name}.{field} must be one of {str(hint)}, got {got(value)}, which is a {got(tname(value))}")
    elif type(hint) is FixedTupleType:
        check(type(value) is tuple,                                                                                    message=
            f"{cls_name}.{field} must be a tuple with {len(hint.elements)} elements, got {got(value)}, which is a {got(tname(value))}")
        check(len(value) == len(hint.elements),                                                                        message=
            f"{cls_name}.{field} must be a tuple with {len(hint.elements)} elements, got {got(value)}, which has {got(len(value))} elements")
        for i, (element, element_hint) in enumerate(zip(value, hint.elements)):
            check_field(cls_name, f"{field}[{i}]", element, element_hint)
    elif type(hint) is UniformTupleType:
        check(type(value) is tuple,                                                                                    message=
            f"{cls_name}.{field} must be a tuple, got {got(value)}, which is a {got(tname(value))}")
        for i, element in enumerate(value):
            check_field(cls_name, f"{field}[{i}]", element, hint.element)
    else:
        assert False, "unreachable"

def is_runtime_field(hint: Any) -> bool:
    is_KW_ONLY  = hint is KW_ONLY
    is_InitVar  = hint is InitVar  or type(hint)       is InitVar
    is_ClassVar = hint is ClassVar or get_origin(hint) is ClassVar
    return not (is_KW_ONLY or is_InitVar or is_ClassVar)

def check_types(obj: Any) -> None:
    cls_name = obj.__class__.__name__
    hints    = get_type_hints(obj.__class__, include_extras=True)

    dataclass_field_names = {field.name for field in fields(obj)}
    hint_field_names      = {name for name, hint in hints.items() if is_runtime_field(hint)}
    missing               = sorted(dataclass_field_names - hint_field_names)
    extra                 = sorted(hint_field_names - dataclass_field_names)
    check(not missing and not extra, message=
        f"{cls_name} runtime field-name set must be equal to its annotated field-name set, got {got(sorted(dataclass_field_names))}, "
        f"which is missing {got(missing)} and has extra {got(extra)}")

    for field in fields(obj):
        name = field.name
        hint = resolve_hint(hints[name])
        check_field(cls_name, name, getattr(obj, name), hint)

_VALIDATOR_VALIDATED_SENTINEL = object()

def validated[TClass: type](cls: TClass) -> TClass:
    check(    is_dataclass(cls), message=f"Class must be a not already validated dataclass, got {got(name(cls))}, which is not a dataclass")
    check(not is_validated(cls), message=f"Class must be a not already validated dataclass, got {got(name(cls))}, which is already validated")
    cls.__validator_validated__ = _VALIDATOR_VALIDATED_SENTINEL

    if hasattr(cls, "__post_init__"):
        original = cls.__post_init__
        def __post_init__(self, *args: Any, **kwargs: Any) -> None:
            check_types(self)
            original(self, *args, **kwargs)
            check_types(self)
        cls.__post_init__ = __post_init__
    else:
        original = cls.__init__
        def __init__(self, *args: Any, **kwargs: Any) -> None:
            original(self, *args, **kwargs)
            check_types(self)
        cls.__init__ = __init__
    return cls

def is_validated(cls: type) -> bool:
    return cls.__dict__.get("__validator_validated__", None) is _VALIDATOR_VALIDATED_SENTINEL
