#!/bin/bash

RESULTS_DIR=${RESULTS_DIR:-"/tmp/protestware-analyzer"}

function print_usage {
    echo Protestware-analyzer
	echo "Использовать: $0 <опции настройки запуска docker контейнера> <опции настройки анализатора>"
	echo "Опции docker контейнера:"
	echo "  -offline: полностью отключает контейнер от сети интернет"
	echo
}

# оповестить о конечных папках
function print_results_dirs {
	echo "Результаты анализа:      $RESULTS_DIR"
}


args=("$@")
HELP=0
MODIFIED=false


i=0
while [[ $i -lt $# ]]; do
	case "${args[$i]}" in
		"-offline")
			DOCKER_OFFLINE=1
			unset "args[i]" # аргумент не передаётся в докер
			;;
        "-help")
            HELP=1
            unset "args[i]"
            ;;
	esac
	i=$((i+1))
done

DOCKER_OPTIONS=("run" "-it" "--name" "protestware-container" "--cgroupns=host" "--privileged")

# если 0 argv, то help=1
if [[ $# -eq 0 ]]; then
	HELP=1
fi

# вывод краткой инструкции
if [[ $HELP -eq 1 ]]; then
	print_usage
fi

# отключить докер контейнер он интернета
if [[ $DOCKER_OFFLINE -eq 1 ]]; then
	DOCKER_OPTIONS+=("--network" "none")
fi

ANALYSIS_IMAGE="protestware-analyzer"

# монтирование общих папок контейнера и конечных папок сохранения
DOCKER_MOUNTS=("--volume" "$RESULTS_DIR:/protestware_analyzer/results")

ANALYSIS_ARGS=("python3" "/protestware_analyzer/analyzer.py")

ANALYSIS_ARGS=("${ANALYSIS_ARGS[@]}" "${args[@]}")

# дополнительное время на считывание ифнформации
sleep 2

# создание установленных конечных папок
mkdir -p "$RESULTS_DIR"

# включение докера
# docker run --cgroupns=host --privileged --rm |--network none| --volume $RESULTS_DIR:/protestware_analyzer/results protestware-analyzer python3 /protestware-analyzer/main.py <опции>
docker "${DOCKER_OPTIONS[@]}" "${DOCKER_MOUNTS[@]}" "$ANALYSIS_IMAGE" "${ANALYSIS_ARGS[@]}"

if [[ $DOCKER_OFFLINE -eq 0 ]]; then
    docker run --rm --volume $RESULTS_DIR:/dump --tty --net=container:protestware-container network-sniffer tcpdump -i any -w /dump/dump.pcap
fi

# проверка окончания работы докера
DOCKER_EXIT_CODE=$?

# если предыдущие условия отработали
if [[ $PACKAGE_DEFINED -eq 1 ]]; then
echo
echo 
	# если докер завершил работу корректно - вывод информации о пакете и результаты проверки
	if [[ $DOCKER_EXIT_CODE -eq 0 ]]; then
		echo "Анализ успешно окончен!"
		echo
		print_package_details
		print_results_dirs
	else
	# сообщение об ошибке
		echo "При анализе возникла ошибка"
		echo
		echo "docker exit status: $DOCKER_EXIT_CODE"
		echo
		echo Проверьте входные данные: "${DOCKER_OPTIONS[@]}", "${DOCKER_MOUNTS[@]}", "$ANALYSIS_IMAGE", "${ANALYSIS_ARGS[@]}"
        print_usage
		# удаление незадействованных папок
		rmdir --ignore-fail-on-non-empty "$RESULTS_DIR"
	fi

echo
fi

# завершить скрипт, относительно окончания работы докера
exit $DOCKER_EXIT_CODE