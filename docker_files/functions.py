'''
Дополнительные функции
'''

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

    message = "\n    Protestware Analyzer"

    print(message)

def print_goodbye_message() -> print:
    '''
    Вывод сообщения об окончании работы
    '''
    message = f'''
    {line}
    Программа успешно закончила свою работу!
    {line}
    '''
    print(message)

def print_input_options(options) -> print:
    '''
    Краткая инструкция использования приложения
    '''

    information = f'''
    {line}
    Пакетный менеджер:       {options["package_manager"]}
    Название пакет:          {options["package"]}
    Версия пакета:           {options["package_version"]}
    Расположение:            {options["location"]}
    {line}
    '''
    print(information)

def print_error_message(error_value) -> print:
    message = f'''
    {line}
    Программа закончила работу с ошибкой: {error_value}
    {line}
    '''
    print(message)