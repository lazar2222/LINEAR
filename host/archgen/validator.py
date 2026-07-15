from collections.abc   import Callable
from dataclasses       import dataclass, fields, is_dataclass, InitVar, KW_ONLY
from enum              import Enum, EnumType
from inspect           import signature
from types             import FunctionType, ModuleType
from typing            import get_args, get_origin, get_type_hints
from typing            import Annotated, Any, ClassVar, TypeAliasType, Union
from typing_extensions import TypeForm

import diagnostics

from checker           import check
from util              import is_in, nothrow
from exceptions        import InternalException, ValidationException

# Exports

__all__ = []

# Validator types

@dataclass(frozen=True)
class Constraint[TConstraint]:
    name:       str
    valid_type: TypeForm[TConstraint]
    validator:  Callable[[TConstraint], bool]

    def annot(self) -> TypeForm[TConstraint]: return Annotated[self.valid_type, self]

# Validator functions

def is_simple_hint  (hint: Any) -> bool:
    is_value_type     = is_in(hint, (bool, str, int))
    is_module_type    =       hint  is ModuleType
    is_enum_type      = type (hint) is EnumType and issubclass  (hint, Enum)
    is_dataclass_type = type (hint) is type     and is_dataclass(hint      )
    return is_value_type or is_module_type or is_enum_type or is_dataclass_type

def is_runtime_field(hint: Any) -> bool:
    is_KW_ONLY  = hint is KW_ONLY
    is_InitVar  = hint is InitVar  or type      (hint) is InitVar
    is_ClassVar = hint is ClassVar or get_origin(hint) is ClassVar
    return not (is_KW_ONLY or is_InitVar or is_ClassVar)

def validate_hint(scope: str, hint: Any) -> None:
    origin = get_origin(hint)
    args   = get_args  (hint)
    if   type(hint)       is TypeAliasType:
        validate_hint(scope, hint.__value__)
    elif      hint        is type(None) or is_simple_hint(hint):
        pass
    elif origin           is Annotated:
        if  len(args   ) != 2:              raise InternalException("Annotated hint must have 2 arguments",         scope=scope, hint=hint, count=len(args))
        if type(args[1]) is not Constraint: raise InternalException("Annotated hint metadata must be a Constraint", scope=scope, hint=hint, metadata  =args[1],  metadata_type=type(args[1]          ))
        if not callable(args[1].validator): raise InternalException("Constraint validator must be callable",        scope=scope, hint=hint, constraint=args[1], validator_type=type(args[1].validator))
        validate_hint(scope, args[0]           )
        validate_hint(scope, args[1].valid_type)
    elif origin           is Union:
        if  len(args   )  < 2:              raise InternalException("Union hint must have at least 2 options",      scope=scope, hint=hint, count=len(args))
        for hint in args: validate_hint(scope, hint)
    elif origin           is tuple and len(args) == 2 and args[1] is Ellipsis:
        validate_hint(scope, args[0]           )
    elif origin           is tuple:
        if  len(args   )  < 1:              raise InternalException("Tuple hint must have at least 1 element",      scope=scope, hint=hint, count=len(args))
        for hint in args: validate_hint(scope, hint)
    else:
        raise InternalException("Unsupported type hint", scope=scope, hint=hint, type=type(hint))

def check_value(scope: str, value: Any, hint: Any) -> None:
    origin = get_origin(hint)
    args   = get_args  (hint)
    if   type(hint)       is TypeAliasType:
        check_value(scope, value, hint.__value__)
    elif      hint        is type(None):
        check(     value  is      None,                                                                        diagnostics.value_type_invalid      (scope, value, None     ))
    elif is_simple_hint(hint):
        check(type(value) is hint,                                                                             diagnostics.value_type_invalid      (scope, value, hint     ))
    elif origin           is Annotated:
        check_value(scope, value, args[0]           )
        check_value(scope, value, args[1].valid_type)
        check(args[1].validator(value),                                                                        diagnostics.value_constraint_invalid(scope, value, args[1]  ))
    elif origin           is Union:
        check(any(nothrow(lambda: check_value(scope, value, option), ValidationException) for option in args), diagnostics.value_type_invalid      (scope, value, args     ))
    elif origin           is tuple and len(args) == 2 and args[1] is Ellipsis:
        check(type(value) is tuple,                                                                            diagnostics.value_type_invalid      (scope, value, tuple    ))
        for i, element in enumerate(value):
            check_value(f"{scope}[{i}]", element, args[0])
    elif origin           is tuple:
        check(type(value) is tuple,                                                                            diagnostics.value_type_invalid      (scope, value, tuple    ))
        check( len(value) == len(args),                                                                        diagnostics.value_length_invalid    (scope, value, len(args)))
        for i, element in enumerate(value):
            check_value(f"{scope}[{i}]", element, args[i])
    else:
        raise InternalException("Validated type hint is not handled", scope=scope, hint=hint, type=type(hint))

def check_field(scope: str, value: Any, hint: Any) -> None:
    validate_hint(scope,        hint)
    check_value  (scope, value, hint)

def validate_dataclass(obj: Any) -> None:
    hints          = get_type_hints(obj.__class__, include_extras=True)
    field_names    = {field.name for field in fields(obj)}
    hint_names     = {name for name, hint in hints.items() if is_runtime_field(hint)}
    missing_fields = tuple(sorted(hint_names  - field_names))
    extra_fields   = tuple(sorted(field_names - hint_names ))
    if len(missing_fields) != 0 or len(extra_fields) != 0: raise InternalException("Dataclass annotated field-name set must match runtime field-name set", cls=obj.__class__.__name__, missing_fields=missing_fields, extra_fields=extra_fields)
    for name in (field.name for field in fields(obj)): check_field(obj.__class__.__name__ + "." + name, getattr(obj, name), hints[name])

def validate_function(func: FunctionType, values: dict[str, Any]) -> None:
    hints           = get_type_hints(func, include_extras=True)
    parameter_names = signature(func).parameters
    hint_names      = {name for name, hint in hints.items() if name != "return"}
    missing_values  = tuple(sorted(hint_names - set(values)         ))
    extra_hints     = tuple(sorted(hint_names - set(parameter_names)))
    if len(missing_values) != 0 or len(extra_hints) != 0: raise InternalException("Function annotated parameter set must be available in locals and signature", func=func.__name__, missing_values=missing_values, extra_hints=extra_hints)
    for name in (name for name in parameter_names if name in hint_names): check_field(func.__name__ + "." + name, values[name], hints[name])
