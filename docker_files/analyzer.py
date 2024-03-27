'''
Основная программа исполнения
'''

import sys
import time
import functions
import package_analyzer
import package_downloader

def main(arguments: dict):
    time.sleep(10)
    functions.print_greeting_message()
    functions.print_input_options(arguments)

    functions.verification(arguments["package_manager"], arguments["package_name"])

    if arguments["package_manager"] == "pypi":
        package_downloader.download_pypi_package(arguments["package_name"], arguments["package_version"])
    elif arguments["package_manager"] == "npm":
        pass
    elif arguments["package_manager"] == "gem":
        pass
    elif arguments["package_manager"] == "maven":
        pass
    elif arguments["package_manager"] == "comproser":
        pass
    elif arguments["package_manager"] == "nuget":
        pass
    else:
        functions.print_usage_message(f"неправильно указан пакетный менеджер {arguments['package_manager']}") 
        sys.exit(1)

    functions.print_goodbye_message()

if __name__ == "__main__":
    if len(sys.argv[1:]) >= 2 and len(sys.argv[1:]) % 2 == 0:
        options = {
            "package_manager": "",
            "package_name": "",
            "package_version": "",
            "location": "Удалённое"
            }
        for arg in range(1, len(sys.argv), 2):
            option_value = [sys.argv[arg], sys.argv[arg + 1]] 
            if option_value[0] == "-m":
                options["package_manager"] = option_value[1]
            elif option_value[0] == "-p":
                options["package_name"] = option_value[1]
            elif option_value[0] == "-v":
                options["package_version"] = option_value[1]
            elif option_value[0] == "-l":
                options["location"] = option_value[1]
            else:
                functions.print_usage_message(option_value[0]) 
                sys.exit(1)
        main(options)
    else:
        functions.print_usage_message(sys.argv[1:])
        sys.exit(1)