'''
Основная программа исполнения

команда выполнения
python3 main.py -package_manager=<package_name> -package=<package_main> -package_version=<version> 

package_manager {
    pypi
    npm
    git
}
'''

import sys
import functions
import package_analyzer
import package_downloader


def main(arguments: dict):
    functions.print_greeting_message()
    functions.print_input_options(arguments)
    print(arguments)
    
    if arguments["package_manager"] == "pypi":
        if (rescode := package_downloader.download_pypi_package(arguments["package"])) != 0:
            functions.print_error_message(rescode)
            sys.exit(rescode)

    functions.print_goodbye_message()


if __name__ == "__main__":
    if len(sys.argv[1:]) >= 2:
        options = {
            "package_manager": "",
            "package": "",
            "package_version": "",
            "location": "Удалённое"
            }
        for arg in range(1, len(sys.argv), 2):
            option_value = [sys.argv[arg], sys.argv[arg + 1]] 
            if option_value[0] == "-m":
                options["package_manager"] = option_value[1]
            elif option_value[0] == "-p":
                options["package"] = option_value[1]
            elif option_value[0] == "-v":
                options["package_version"] = option_value[1]
            elif option_value[0] == "-l":
                options["location"] = option_value[1]
            else:
                # дописать вывод
                print(f"Некорректный ввод опции: {option_value[0]}, ознакомтесь с параметрами использования:\n > ...") 
                sys.exit(1)
        main(options)
    else:
        # дописать вывод
        print(f"Пустой ввод, ознакомтесь с параметрами использования:\n > ...")
        sys.exit(1)