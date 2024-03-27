#!/bin/bash

echo Protestware-anlyzer manager
echo Создать докеры [0]
echo Обновить образы докера [1]
echo Удалить образы докера [2]
echo
read -p "Выберете функцию? [0/1/2] " choise
echo

case $choise in
    0)
        echo Создание образов докера:
        echo

        docker build --tag protestware-analyzer:latest --file ./Dockerfile.main .
        docker build --tag network-sniffer:latest --file ./Dockerfile.network .
        ;;
    1)
        echo Обновить образы докера:
        echo 

        docker rmi protestware-analyzer && docker build --tag protestware-analyzer:latest --file ./Dockerfile.main .
        docker rmi network-sniffer && docker build --tag network-sniffer:latest --file ./Dockerfile.network .
        ;;
    2)
        echo Удаление образов докера:
        echo 

        docker rmi protestware-analyzer
        docker rmi network-sniffer
        ;;
esac

DOCKER_EXIT_CODE=$?

if [[ $DOCKER_EXIT_CODE -eq 0 ]]; then
    echo
    echo "Образы успешно созданы!"
else
    echo
    echo "При выполнении программы возникла ошибка."
    echo "Докер закончил свою работу с кодом: $DOCKER_EXIT_CODE"
fi

exit $DOCKER_EXIT_CODE