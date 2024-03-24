'''
команда выполнения
python3 main.py package_manager=<package_name> package=<package_main> package_version=<version> 

package_manager {
    pypi
    npm
    git
}
'''

import sys

def print_input_options(options):
    passd
def main(options):
    pass

def list2dict(list_value):
   result_dict = {}
   for option in list_value:
       result_dict[option[0]] = option[1]
   return result_dict
 


if __name__ == "__main__":
    if sys.argv[1:]:
        options = list()
        for option_value in sys.argv[1:]:
            option_value = option_value.split("=")
            if option_value[0] in ("package_manager", "package", "package_version"):
                options.append(option_value)
            else:
                print(f"Некорректный ввод: {option_value}, ознакомтесь с параметрами использования:\n > ...")
                sys.exit(1)
        print_input_options(options)   
        main(list2dict(options))
    else:
        print(f"Пустой ввод, ознакомтесь с параметрами использования:\n > ...")