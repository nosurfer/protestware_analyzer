'''
Программа установки пакетов
'''

import os 
import sys
import functions

def download_pypi_package(package_name, package_version):

    if package_version:
        command = f"pip3 install {package_name}=={package_version}"
    else:
        command = f"pip3 install {package_name}"
    try:
        print()
        return_code = os.system(command)
        
        if return_code == 0:
            print(f"Пакет '{package_name}' успешно установлен.")
        else:
            functions.print_usage_message(package_name)
            sys.exit(1)
        
    except Exception as e:
        functions.print_usage_message(e)
        sys.exit(1)