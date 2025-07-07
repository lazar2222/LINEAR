import sys
import util

SCHEMA_SCHEMA = {
}

class Config:

    def __init__(self):
        pass

def load_config(configs : list | dict, default_config : str | None = None, default_config_file : str | None = None, args : str | list | dict | bool | None = None, schema : Config | dict | str | None = None, logger_prefix : str | None = None) -> Config:
    if isinstance(configs, dict):
        if "." not in configs:
            configs["."] = "default"
            default_config = "default"
        else:
            default_config = configs["."]
        configs = [configs]
    match args:
        case str():
            args = util.parse_args(util.smart_split(args))
        case list():
            args = util.parse_args(args)
        case bool():
            args = util.parse_args(sys.argv) if args else {}
        case None:
            args = {}
    
 

def load_schema(configs : list | dict, default_config : str | None = None, default_config_file : str | None = None, logger_prefix : str | None = None) -> Config:
    return load_config(configs, default_config, default_config_file, schema = SCHEMA_SCHEMA, logger_prefix = logger_prefix)
