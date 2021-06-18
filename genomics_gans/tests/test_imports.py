import os, sys
try: 
    import genomics_gans
except:
    exec(open('__init__.py').read())
    import genomics_gans
    print("complete")

class TestImports:

    def test_root(self):
        current_file = os.path.realpath(__file__)
        current_file_parent_dir = os.path.dirname(current_file)
        root_dir = os.path.dirname(current_file_parent_dir)
        os.chdir(root_dir)
        exec(open('__init__.py').read()) 
    
    def test_prepare_data_dir(self):
        current_file = os.path.realpath(__file__)
        current_file_parent_dir = os.path.dirname(current_file)
        root_dir = os.path.dirname(current_file_parent_dir)
        os.chdir(root_dir)
        os.chdir("prepare_data")
        exec(open('__init__.py').read()) 
    