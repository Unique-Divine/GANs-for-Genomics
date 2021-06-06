import os, sys

def access_root_dir(depth = 1):
    current_dir = os.path.dirname(os.path.realpath(__file__))
    parent_dir = os.path.dirname(current_dir)
    if depth >= 1:
        assert isinstance(depth, int)
        args: list = [parent_dir]
        for _ in range(depth):
            args.append('..')
        rel_path = os.path.join(*args)
    elif depth == 0:
        rel_path = parent_dir
    else:
        raise ValueError("Invalid depth")

    sys.path.append(rel_path) 

access_root_dir(depth=1)

import genomics_gans
import warnings
warnings.filterwarnings("ignore")

