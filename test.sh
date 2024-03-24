#!/bin/bash

# пути сохранения
RESULTS_DIR=${RESULTS_DIR:-"/tmp/results"}
STATIC_RESULTS_DIR=${STATIC_RESULTS_DIR:-"/tmp/staticResults"}
FILE_WRITE_RESULTS_DIR=${FILE_WRITE_RESULTS_DIR:-"/tmp/writeResults"}
ANALYZED_PACKAGES_DIR=${ANALYZED_PACKAGES_DIR:-"/tmp/analyzedPackages"}
LOGS_DIR=${LOGS_DIR:-"/tmp/dockertmp"}
STRACE_LOGS_DIR=${STRACE_LOGS_DIR:-"/tmp/straceLogs"}

# вывод вовзможностей приложения
function print_usage {
	echo "Использовать: $0 [-no-verbose] [-fully-offline] <analyze args...>"
	echo
	echo "Опции:"
	echo "  -no-verbose"
	echo "    	prints commmand that would be executed and exits"
	echo "  -fully-offline"
	echo "    	Полностью отключает контейнер от сети интернет"
	echo "    	Проверка будет произведени только при установленных: -local <путь к пакету> and -nopull."
	echo "    	(также смотрите: -offline)"
	echo "  -nointeractive"
	echo "      отключает терминал(TTY), ввод и предотвращает создания pseudo-tty"
	echo
}

# вывод информации о пакете
function print_package_details {
	echo "Пакетный менеджер:        $PACKAGE_MANAGER"
	echo "Пакет:                    $PACKAGE"
	echo "Версия:                   $VERSION"
	if [[ $LOCAL -eq 1 ]]; then
		LOCATION="$PKG_PATH"
	else
		LOCATION="удалённое"
	fi

	echo "Расположение:             $LOCATION"
}

# оповестить о конечных папках
function print_results_dirs {
	echo "Динамический анализ:      $RESULTS_DIR"
	echo "Статический анализ:       $STATIC_RESULTS_DIR"
	echo "Analyzed package saved:   $ANALYZED_PACKAGES_DIR"
	echo "Запись в файл:            $FILE_WRITE_RESULTS_DIR"
	echo "Аудит:                    $LOGS_DIR"
	echo "Отслеживание:             $STRACE_LOGS_DIR"
}


args=("$@")

HELP=0
NO_VERBOSE=0
LOCAL=0
DOCKER_OFFLINE=0
INTERACTIVE=1

PACKAGE_MANAGER=""
PACKAGE=""
VERSION=""
PKG_PATH=""
MOUNTED_PKG_PATH=""

i=0
while [[ $i -lt $# ]]; do
	case "${args[$i]}" in
		"-no-verbose")
			NO_VERBOSE=1
			unset "args[i]" # аргумент не передаётся в докер
			;;
		"-fully-offline")
			DOCKER_OFFLINE=1
			unset "args[i]" # аргумент не передаётся в докер
			;;
		"-nointeractive")
			INTERACTIVE=0
			unset "args[i]" # аргумент не передаётся в докер
			;;
		"-help")
			HELP=1
			;;
		"-local")
			# указания точки присоединения, чтобы указать докеру на архив с пакет(ом/ами)
			LOCAL=1
			i=$((i+1))
			# опция -m позволяет задать несуществующий путь, который будет использован далее
			PKG_PATH=$(realpath -m "${args[$i]}")
			if [[ -z "$PKG_PATH" ]]; then
				echo "-local: не указан путь к пакету"
				exit 255
			fi
			PKG_FILE=$(basename "$PKG_PATH")
			MOUNTED_PKG_PATH="/$PKG_FILE"
			# для корректного анализа необходимо указать только базовое название
			args[$i]="$MOUNTED_PKG_PATH"
			;;
		"-package-manager")
			i=$((i+1))
			PACKAGE_MANAGER="${args[$i]}"
			;;
		"-package")
			i=$((i+1))
			PACKAGE="${args[$i]}"
			;;
		"-version")
			i=$((i+1))
			VERSION="${args[$i]}"
			;;
	esac
	i=$((i+1))
done

if [[ $# -eq 0 ]]; then
	HELP=1
fi

# первоначальные найстройки докера
DOCKER_OPTIONS=("run" "--cgroupns=host" "--privileged" "--rm")

# могут возникнуть проблемы с Github-Codespace
function is_mount_type() {
	# проверка задаваемого пути и типа файловой системы при присоединение
	if [[ $(findmnt -T "$2" -n -o FSTYPE) == "$1" ]]; then
		return 0
	else
		return 1
	fi
}

# место присоединения контейнеров докера
CONTAINER_MOUNT_DIR="/var/lib/containers"

# проверка на измениение присоединяемого пути
if [[ -n "$CONTAINER_DIR_OVERRIDE" ]]; then
	CONTAINER_MOUNT_DIR="$CONTAINER_DIR_OVERRIDE"
# проверка на Github-Codespace
elif [[ $CODESPACES == "true" ]]; then
	# создание временный директории
	CONTAINER_MOUNT_DIR=$(mktemp -d)
	echo "Определён Github-Codespace, используется $CONTAINER_MOUNT_DIR для присоединения контейнера"
# проверка на наложение
elif is_mount_type overlay /var/lib; then
	if is_mount_type overlay /tmp && ! is_mount_type tmpfs /tmp; then
		CONTAINER_MOUNT_DIR=$(mktemp -d)
		echo "Внимание: в /var/lib происходит наложение, используется $CONTAINER_MOUNT_DIR для присоедениения контейнера"
	else
		echo "Ошибка: в /var/lib происходит наложение, пожалуйста установите CONTAINER_DIR_OVERRIDE в папку без наложений"
		exit 1
	fi
fi

# монтирование общих папок контейнера и конечных папок сохранения
DOCKER_MOUNTS=("-v" "$CONTAINER_MOUNT_DIR:/var/lib/containers" "-v" "$RESULTS_DIR:/results" "-v" "$STATIC_RESULTS_DIR:/staticResults" "-v" "$FILE_WRITE_RESULTS_DIR:/writeResults" "-v" "$LOGS_DIR:/tmp" "-v" "$ANALYZED_PACKAGES_DIR:/analyzedPackages" "-v" "$STRACE_LOGS_DIR:/straceLogs")

# образ докера для анализа
ANALYSIS_IMAGE=gcr.io/ossf-malware-analysis/analysis

# устанавливаемые опции
ANALYSIS_ARGS=("analyze" "-dynamic-bucket" "file:///results/" "-file-writes-bucket" "file:///writeResults/" "-static-bucket" "file:///staticResults/" "-analyzed-pkg-bucket" "file:///analyzedPackages/" "-execution-log-bucket" "file:///results")

# добавочные пользователем опции
ANALYSIS_ARGS=("${ANALYSIS_ARGS[@]}" "${args[@]}")

# вывод краткой инструкции
if [[ $HELP -eq 1 ]]; then
	print_usage
fi

# 
if [[ $INTERACTIVE -eq 1 ]]; then
	DOCKER_OPTIONS+=("-it")
fi

# загружать определёненый файл
if [[ $LOCAL -eq 1 ]]; then
	LOCATION="$PKG_PATH"

	# присоединение файла пакета в корень докер контейнера
	DOCKER_MOUNTS+=("-v" "$PKG_PATH:$MOUNTED_PKG_PATH")
else
	LOCATION="remote"
fi

# отключить докер контейнер он интернета
if [[ $DOCKER_OFFLINE -eq 1 ]]; then
	DOCKER_OPTIONS+=("--network" "none")
fi

# прокерка, что подаётся название пакета с указанным пакетным мендежером
if [[ -n "$PACKAGE_MANAGER" && -n "$PACKAGE" ]]; then
	PACKAGE_DEFINED=1
else
	PACKAGE_DEFINED=0
fi

# если предыдущее условие выполняется, выводится информация о пакете
if [[ $PACKAGE_DEFINED -eq 1 ]]; then
	echo
	echo "Информация о пакете"
	print_package_details
	echo
fi

# если включён NO_VERBOSE - вывести команду и "выйти"
if [[ $NO_VERBOSE -eq 1 ]]; then
	echo "Analysis command (dry run)"
	echo
	echo docker "${DOCKER_OPTIONS[@]}" "${DOCKER_MOUNTS[@]}" "$ANALYSIS_IMAGE" "${ANALYSIS_ARGS[@]}"

	echo
	exit 0
fi

# если предыдущие условия отработали, выполнятеся проверка
if [[ $PACKAGE_DEFINED -eq 1 ]]; then
	echo "Зависимость анализируется"
	echo
fi
# иначе продолжает работу

# проверка на читаемость предоставляемого файла
if [[ $LOCAL -eq 1 ]] && [[ ! -f "$PKG_PATH" || ! -r "$PKG_PATH" ]]; then
	echo "Error: предоставляемый путь не содержит указываемого файла или он не читаемый: $PKG_PATH"
	echo
	exit 1
fi

# дополнительное время на считывание ифнформации
sleep 2

# создание установленных конечных папок
mkdir -p "$RESULTS_DIR"
mkdir -p "$STATIC_RESULTS_DIR"
mkdir -p "$FILE_WRITE_RESULTS_DIR"
mkdir -p "$ANALYZED_PACKAGES_DIR"
mkdir -p "$LOGS_DIR"
mkdir -p "$STRACE_LOGS_DIR"

# включение докера
docker "${DOCKER_OPTIONS[@]}" "${DOCKER_MOUNTS[@]}" "$ANALYSIS_IMAGE" "${ANALYSIS_ARGS[@]}"

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
		print_package_details 
		# удаление незадействованных папок
		rmdir --ignore-fail-on-non-empty "$RESULTS_DIR"
		rmdir --ignore-fail-on-non-empty "$STATIC_RESULTS_DIR"
		rmdir --ignore-fail-on-non-empty "$FILE_WRITE_RESULTS_DIR"
		rmdir --ignore-fail-on-non-empty "$ANALYZED_PACKAGES_DIR"
		rmdir --ignore-fail-on-non-empty "$LOGS_DIR"
		rmdir --ignore-fail-on-non-empty "$STRACE_LOGS_DIR"
	fi

echo
fi

# завершить скрипт, относительно окончания работы докера
exit $DOCKER_EXIT_CODE