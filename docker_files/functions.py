'''
Дополнительные функции
'''

import sys
import functions

# def list2dict(list_value) -> dict:
#     '''
#     Конвертировать двумерный лист в словарь
#     '''
# 
#     result_dict = {}
#     for option in list_value:
#         result_dict[option[0]] = option[1]
#     return result_dict

line = "= = = = = = = = = = = = = = = = = = ="

def print_greeting_message() -> print:
    '''
    Вывод приветсвтенное сообщение в консоль
    '''

    message = "Protestware Analyzer"

    print(message)

def print_goodbye_message() -> print:
    '''
    Вывод сообщения об окончании работы
    '''
    message = f'''{line}
Программа успешно закончила свою работу!
{line}'''

    print(message)

def print_input_options(options) -> print:
    '''
    Вывод анализируемой инфорации
    '''

    information = f'''{line}
Пакетный менеджер:       {options["package_manager"]}
Название пакет:          {options["package_name"]}
Версия пакета:           {options["package_version"]}
Расположение:            {options["location"]}
{line}
'''

    print(information)

def print_usage_message(input_value="") -> print:
    '''
    Краткая инструкция использования
    '''
    message ='''analyzer
Использование: -m <package-manager_name> -p <package_main> -v <version>
Опции анализатора:
    -m: пакетный менеджер (pypi, npm, ...)
    -p: название пакета (requests, ...)
    -v: версия пакета (13.2, ...)'''
    if input_value:
        message = f"Некорректный ввод: {input_value}, ознакомтесь с параметрами использования:\n\n" + message

    print(message)


def verification(packet_manager, package_name) -> bool:
    '''
    Проверка на наличие необходимых данных
    '''
    if packet_manager:
        if package_name:
            return True
        else:
            functions.print_usage_message("не указано название пакета")
            sys.exit(1)
    else:
        functions.print_usage_message("не указан пакетный менеджер")
        sys.exit(1)