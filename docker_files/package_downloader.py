'''
Программа установки пакетов
'''

import sys 
import subprocess 

def download_pypi_package(package_name):
    try:
        result = subprocess.run(['pip', 'install', package_name], capture_output=True, text=True)
        print(f"Пакет успешно установлен, при помощи: {' '.join(result.args)}")
        print(f"Выполнена команда: {' '.join(result.args)}")
        
        if result.stdout:
            print("Стандартный вывод:")
            print(result.stdout)
        
        if result.stderr:
            print("Стандартная ошибка:")
            print(result.stderr)
    except:
        pass

    return result.returncode