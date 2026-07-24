import os
import shutil

resources_dir = "Resources"
if os.path.exists(resources_dir):
    shutil.rmtree(resources_dir, ignore_errors=True)
    print("Resources directory deleted")
