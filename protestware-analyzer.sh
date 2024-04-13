#!/bin/bash

RESULTS_DIR=${RESULTS_DIR:-"/tmp/results"}
LOCALE_PACKAGE=${LOCALE_PACKAGE:-"/tmp/packages"}

function print_usage {
    echo "Protestware-analyzer"
    echo "Использовать: ./protestware-analyzer.sh <опции настройки запуска Docker контейнера> <опции настройки анализатора>"
    echo "Опции Docker контейнера:"
    echo   "-h, --help: выводит краткую инструкцию использованию"
    echo   "-o, --offline: полностью отключает контейнер от сети интернет (использовать только с опцией local)"
    echo   "-d <путь к папку>, --directory: путь к проверяемым файлам"
    echo   "-p <название пакета>, --package: название пакета (версия указывается вместе с названием)"
    echo   "-t <название программы>, --trigger: приложение для запуска/скачивания пакетов"
    echo   "-I <параметр>, --identify: настроить фильтр (network, file)"
    echo   "-l <путь к файлу>, --logfile: путь к файлу с выводом результатов сканирования"
    echo   "-f <путь к файлу>, --filterfile: путь к файлу с отфильтрованным вывод"
    echo   "-c <количество ядер>, --cpu: количество выделяемых ядер процессора"
    echo   "-m <(в Мб), --memory: количество выделяемой оперативной памяти"
    echo   "-r, --remove: удалить контейнер, после завершения сканирования"
    echo
}


LOGFILE="/var/log/audit/audit.log"

# оповестить о конечных папках
function print_results_dirs {
	echo "Результаты анализа:      $RESULTS_DIR"
	echo "Auditd вывод: 		    "
	echo "Сетевой вывод:			"
}


args=("$@")
HELP=0
MODIFIED=false


i=0
while [[ $i -lt $# ]]; do
	case "${args[$i]}" in
        "-h")
            HELP=1
            unset "args[i]"
            ;;
        "-o")
            OFFLINE=1
            unset "args[i]"
            ;;
        "-d")
            DIRECTORY=1
            DIR_VALUE=${args[$i+1]}
            ;;
        "-p")
            PACKAGE_NAME=${args[$i+1]}
            ;;
        "-t")
            TRIGGER=${args[$i+1]}
            ;;
        "-I")
            if [[ ${args[$i+1]} -eq "network" ]]; then
            NETWORK=1
            elif [[ ${args[$i+1]} -eq "file" ]]; then
            FILE=1
            fi
            ;;
        "-l")
            LOGFILE=1
            LOGFILE_VALUE=${args[$i+1]}
            ;;
        "-f")
            FILTERFILE=1
            FILTERFILE_VALUE=${args[$i+1]}
            ;;
        "-c")
            CPU=1
            CPU_VALUE=${args[$i+1]}
            ;;
        "-m")
            MEMORY=1
            MEMORY_VALUE=${args[$i+1]}
            ;;
        "-r")
            REMOVE=1
            ;;

	esac
	i=$((i+1))
done

DOCKET_NAME="protest"
DOCKER_OPTS=("exec" "-it")

case $TRIGGER in
    "npm")
        # docker exec -it protest python3 pip install $PACKAGE_NAME > /dev/null
        DOCKER_OPTS+=("npm" "install" "$PACKAGE_NAME")
        unset $TRIGGER
        ;;
    "pip")
        DOCKER_OPTS+=("python3" "-m" "pip" "install" "$PACKAGE_NAME")
        unset $TRIGGER
        ;;
    "gem")
        DOCKER_OPTS+=("gem" "install" "$PACKAGE_NAME")
        unset $TRIGGER
        ;;
    "composer")
        DOCKER_OPTS+=("composer" "require" "$PACKAGE_NAME")
        unset $TRIGGER
        ;;
    "cargo")
        DOCKER_OPTS+=("cargo" "install" "$PACKAGE_NAME")
        unset $TRIGGER
        ;;
    "yarn")
        DOCKER_OPTS+=("yarn" "add" "$PACKAGE_NAME")
        unset $TRIGGER
        ;;
    "nuget")
        DOCKER_OPTS+=("nuget" "install" "$PACKAGE_NAME")
        unset $TRIGGER
        ;;
    "git")
        DOCKER_OPTS+=("git" "clone" "$PACKAGE_NAME")
        ;;
esac

if [[ $DOCKER_OFFLINE -eq 1 ]]; then
	DOCKER_OPTS+=("--network" "none")
fi

if [[ $DIRECTORY -eq 1 ]]; then
    DOCKER_OPTS+=(("-v" "$DIRECTORY_VALUE:/tmp"))
fi

if [[ $MEMORY -eq 1 ]]; then
    DOCKER_OPTS+=(("-m" "$MEMORY_VALUE"))
fi

if [[ $CPU -eq 1 ]]; then
    DOCKER_OPTS+=(("-cpus" "$CPU_VALUE"))
fi

if [[ $HELP -eq 1 ]]; then
    sleep 1
    print_usage
    sleep 1
else
    sleep 1
    echo "Protestware-analyzer"
    sleep 1
    echo "Создание контейнера:"
    docker run -d -it --name protest protestware-analyzer
    echo "Поиск контейнера:"
    CONTAINER_PID=$(python3 main.py 1)
    sleep 5
    echo "Начало сканирования"
    sysdig -pc container.name=protest > $LOGFILE_VALUE &
    docker "${DOCKER_OPTS[@]}" "$DOCKER_NAME"
    echo "Сканирование окончено"

    if [[ $REMOVE -eq 1 ]]; then
        docker kill protest
        docker rm protest
    fi
    echo "Фильтрация вывода"
    python3 output_filter.py ("$LOGFILE_VALUE" "$FILTERFILE_VALUE")
    echo "Файл отфильтрован"
fi

DOCKER_EXIT_CODE=$?

if [[ $PACKAGE_DEFINED -eq 1 ]]; then
    if [[ $DOCKER_EXIT_CODE -eq 0 ]]; then
        echo "Анализ успешно завершён"
        echo logfile.log
    else
        echo "Программа заршила свою работы с ошибкой: $DOCKER_EXIT_CODE"
    fi
fi

exit $DOCKER_EXIT_CODE