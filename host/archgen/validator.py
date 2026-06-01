from collections.abc   import Callable
from dataclasses       import dataclass, fields, is_dataclass, InitVar, KW_ONLY
from enum              import Enum, EnumType
from functools         import wraps
from types             import FunctionType
from typing            import get_args, get_origin, get_type_hints
from typing            import Annotated, Any, ClassVar, TypeAliasType, Union
from typing_extensions import TypeForm

from checker           import check, cname, empty, fxmby, got, is_in, nothrow, seq, sseq, tname, tnames
from checker           import REPR

# Exports

__all__ = [
    "Constraint",
    "validated",
]

# Validator types

@dataclass(frozen=True)
class Constraint[TConstraint]:
    name:       str
    valid_type: TypeForm[TConstraint]
    validator:  Callable[[TConstraint], bool]

    def __post_init__(self) -> None:
        resolve_hint(self.valid_type)
        check(type(self.name) is str,               message=fxmby("Constraint.name",      "a non-empty string", got(self.name,      REPR), "a " + got(tname(self.name))        ))
        check(bool(self.name.strip()),              message=fxmby("Constraint.name",      "a non-empty string", got(self.name           ), "an empty or whitespace-only string"))
        check(type(self.validator) is FunctionType, message=fxmby("Constraint.validator", "a function",         got(self.validator, REPR), "a " + got(tname(self.validator))   ))

    def annot(self) -> TypeForm[TConstraint]: return Annotated[self.valid_type, self]

    def __str__(self) -> str: return self.name

type ValidType = SimpleType | ConstraintType | UnionType | FixedTupleType | UniformTupleType

def is_valid_type(value: Any) -> bool: return is_in(type(value), (SimpleType, ConstraintType, UnionType, FixedTupleType, UniformTupleType))

@dataclass(frozen=True)
class SimpleType:
    type: type

    def __post_init__(self) -> None:
        is_value_type     = is_in(self.type, (bool, str, int, type(None)))
        is_enum_type      =  type(self.type) is EnumType and issubclass  (self.type, Enum)
        is_validated_type =  type(self.type) is type     and is_validated(self.type      )
        check(is_value_type or is_enum_type or is_validated_type, message=fxmby("SimpleType.type", "a value type, Enum, or @validated class", got(cname(self.type)), "neither"))

    def __str__(self) -> str: return self.type.__name__

@dataclass(frozen=True)
class ConstraintType:
    type:       ValidType
    constraint: Constraint[Any]

    def __post_init__(self) -> None:
        check(is_valid_type(self.type),                              message=fxmby("ConstraintType.type",       "a ValidType matching ConstraintType.constraint.valid_type", got(self.type,       REPR), "a " + got(tname(self.type))                                        ))
        check(type(self.constraint) is Constraint,                   message=fxmby("ConstraintType.constraint", "a Constraint",                                              got(self.constraint, REPR), "a " + got(tname(self.constraint))                                  ))
        check(self.type == resolve_hint(self.constraint.valid_type), message=fxmby("ConstraintType.type",       "a ValidType matching ConstraintType.constraint.valid_type", got(self.type,       REPR), "not same as " + got(resolve_hint(self.constraint.valid_type), REPR)))

    def __str__(self) -> str: return str(self.constraint)

@dataclass(frozen=True)
class UnionType:
    options: tuple[ValidType, ...]

    def __post_init__(self) -> None:
        check( type(self.options) is tuple,  message=fxmby("UnionType.options", "a tuple of ValidType elements with at least 2 elements", got(self.options, REPR), "a " + got(tname(self.options))                                                                                                             ))
        check(empty(self.invalid_options()), message=fxmby("UnionType.options", "a tuple of ValidType elements with at least 2 elements", got(self.options, REPR), "a tuple with the following non-ValidType elements " + got(self.invalid_options()) + " of types " + got(seq(tnames(self.invalid_options())))))
        check(  len(self.options) >= 2,      message=fxmby("UnionType.options", "a tuple of ValidType elements with at least 2 elements", got(self.options, REPR), "a tuple with " + got(len(self.options)) + " elements"                                                                                      ))

    def invalid_options(self) -> tuple[Any, ...]: return tuple(option for option in self.options if not is_valid_type(option))

    def __str__(self) -> str: return " | ".join(str(option) for option in self.options)

@dataclass(frozen=True)
class FixedTupleType:
    elements: tuple[ValidType, ...]

    def __post_init__(self) -> None:
        check( type(self.elements) is tuple,  message=fxmby("FixedTupleType.elements", "a tuple of ValidType elements with at least 1 element", got(self.elements, REPR), "a " + got(tname(self.elements))                                                                                                              ))
        check(empty(self.invalid_elements()), message=fxmby("FixedTupleType.elements", "a tuple of ValidType elements with at least 1 element", got(self.elements, REPR), "a tuple with the following non-ValidType elements " + got(self.invalid_elements()) + " of types " + got(seq(tnames(self.invalid_elements())))))
        check(  len(self.elements) >= 1,      message=fxmby("FixedTupleType.elements", "a tuple of ValidType elements with at least 1 element", got(self.elements, REPR), "a tuple with " + got(len(self.elements)) + " elements"                                                                                       ))

    def invalid_elements(self) -> tuple[Any, ...]: return tuple(element for element in self.elements if not is_valid_type(element))

    def __str__(self) -> str: return f"({", ".join(str(element) for element in self.elements)})"

@dataclass(frozen=True)
class UniformTupleType:
    element: ValidType

    def __post_init__(self) -> None:
        check(is_valid_type(self.element), message=fxmby("UniformTupleType.element", "a ValidType", got(self.element, REPR), "a " + got(tname(self.element))))

    def __str__(self) -> str: return f"({self.element}, ...)"

# Validator functions

def resolve_hint(hint: Any) -> ValidType:
    origin = get_origin(hint)
    args   = get_args  (hint)
    if type(hint) is TypeAliasType:
        return resolve_hint(hint.__value__)
    if is_in(hint, (bool, str, int, type(None))):
        return SimpleType(hint)
    if type(hint) is EnumType and issubclass  (hint, Enum):
        return SimpleType(hint)
    if type(hint) is type     and is_validated(hint      ):
        return SimpleType(hint)
    if origin is Annotated:
        check(len(args) == 2, message=fxmby("Annotated hint args", "a tuple with 2 elements", got(args, REPR), "a tuple with " + got(len(args)) + " elements"))
        return ConstraintType(resolve_hint(args[0]), args[1])
    if origin is Union:
        return UnionType(tuple(resolve_hint(arg) for arg in get_args(hint)))
    if origin is tuple:
        if len(args) == 2 and args[1] is Ellipsis:
            return UniformTupleType(resolve_hint(args[0]))
        else:
            return FixedTupleType(tuple(resolve_hint(arg) for arg in args))
    check(False, message=fxmby("hint", "a supported type hint", got(hint, REPR), "a " + got(tname(hint))))

def check_field(cls_name: str, field: str, value: Any, hint: ValidType) -> None:
    if type(hint) is SimpleType:
        check(hint.type is     type(None),      value  is None,                                                         message=fxmby(cls_name + "." + field, "None",                                                  got(value, REPR), "not None"                                     ))
        check(hint.type is not type(None), type(value) is hint.type,                                                    message=fxmby(cls_name + "." + field, "a "      + str(hint),                                   got(value, REPR), "a " + got(tname(value))                       ))
    if type(hint) is ConstraintType:
        check_field(cls_name, field, value, hint.type)
        check(hint.constraint.validator(value),                                                                         message=fxmby(cls_name + "." + field, "a "      + str(hint),                                   got(value, REPR), "not valid for a given constraint"             ))
    if type(hint) is UnionType:
        check(any(nothrow(lambda: check_field(cls_name, field, value, option), ValueError) for option in hint.options), message=fxmby(cls_name + "." + field, "one of " + str(hint),                                   got(value, REPR), "a " + got(tname(value))                       ))
    if type(hint) is FixedTupleType:
        check(type(value) is tuple,                                                                                     message=fxmby(cls_name + "." + field, "a tuple with " + str(len(hint.elements)) + " elements", got(value, REPR), "a " + got(tname(value))                       ))
        check( len(value) == len(hint.elements),                                                                        message=fxmby(cls_name + "." + field, "a tuple with " + str(len(hint.elements)) + " elements", got(value, REPR), "a tuple with " + got(len(value)) + " elements"))
        for i, (element, element_hint) in enumerate(zip(value, hint.elements)):
            check_field(cls_name, f"{field}[{i}]", element, element_hint)
    if type(hint) is UniformTupleType:
        check(type(value) is tuple,                                                                                     message=fxmby(cls_name + "." + field, "a tuple",                                               got(value, REPR), "a " + got(tname(value))                       ))
        for i, (element,             ) in enumerate(zip(value,              )):
            check_field(cls_name, f"{field}[{i}]", element, hint.element)

def is_runtime_field(hint: Any) -> bool:
    is_KW_ONLY  = hint is KW_ONLY
    is_InitVar  = hint is InitVar  or type      (hint) is InitVar
    is_ClassVar = hint is ClassVar or get_origin(hint) is ClassVar
    return not (is_KW_ONLY or is_InitVar or is_ClassVar)

def check_types(obj: Any) -> None:
    cls_name = obj.__class__.__name__
    hints    = get_type_hints(obj.__class__, include_extras=True)

    dataclass_field_names = {field.name for field in fields(obj)}
    hint_field_names      = {name for name, hint in hints.items() if is_runtime_field(hint)}
    missing               = hint_field_names - dataclass_field_names
    extra                 = dataclass_field_names - hint_field_names
    check(empty(missing) and empty(extra), message=fxmby(cls_name + " runtime field-name set", "equal to its annotated field-name set", got(sseq(dataclass_field_names)), "missing " + got(sseq(missing)) + " and has extra " + got(sseq(extra))))

    for field in fields(obj):
        name = field.name
        hint = resolve_hint(hints[name])
        check_field(cls_name, name, getattr(obj, name), hint)

_VALIDATOR_VALIDATED_SENTINEL = object()

def validated[TClass: type](cls: TClass) -> TClass:
    check(    is_dataclass(cls), message=fxmby("Class", "a not already validated dataclass", got(cname(cls)), "not a dataclass"  ))
    check(not is_validated(cls), message=fxmby("Class", "a not already validated dataclass", got(cname(cls)), "already validated"))
    cls.__validator_validated__ = _VALIDATOR_VALIDATED_SENTINEL

    if hasattr(cls, "__post_init__"):
        original = cls.__post_init__
        @wraps(original)
        def wrapped(self, *args: Any, **kwargs: Any) -> None:
            check_types(self)
            original(self, *args, **kwargs)
            check_types(self)
        cls.__post_init__ = wrapped
    else:
        original = cls.__init__
        @wraps(original)
        def wrapped(self, *args: Any, **kwargs: Any) -> None:
            original(self, *args, **kwargs)
            check_types(self)
        cls.__init__      = wrapped
    return cls

def is_validated(cls: type) -> bool: return cls.__dict__.get("__validator_validated__", None) is _VALIDATOR_VALIDATED_SENTINEL
