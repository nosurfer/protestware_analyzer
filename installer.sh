#!/bin/bash

echo Protestware-anlyzer manager
echo Создание докер контейнера и установка необходимых программ [0]

OS_name=$(uname -n)

echo $hostname

if [[ $hostname -eq "Ubuntu" || $hostname -eq kali || $hostname -eq CentOS ]]; then
apt install docker -y
docker build --tag protestware-analyzer:latest --file ./Dockerfile .
apt install linux-headers-$(uname -r) sysdig ncurses-term -y
elif [[ $hostname -eq "arch" ]]; then
sudo pacman -Sy docker sysdig
docker build --tag protestware-analyzer:latest --file ./Dockerfile .
fi 

EXIT_STATUS=$?

if [[ $EXIT_STATUS -eq 0 ]]; then
    echo
    echo "Образ успешно создан!"
else
    echo
    echo "При выполнении программы возникла ошибка."
    echo "Докер закончил свою работу с кодом: $EXIT_STATUS"
fi

exit $EXIT_STATUS