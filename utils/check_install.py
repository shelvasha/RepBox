import subprocess

def check_and_install_package(package_name):
    try:
        # Check if the package is already installed
        __import__(package_name)
        print(f"{package_name} is already installed.")
    except ImportError:
        # Package is not installed, so install it
        print(f"{package_name} is not found. Installing...")
        subprocess.check_call(['pip3', 'install', package_name])
        print(f"{package_name} has been successfully installed.")


