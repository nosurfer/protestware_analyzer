import sys
import output_filter
import find_container_id

def first() -> int:
    '''
    id процесса контейнера
    '''
    container_pid = find_container_id.find_docker_process_id()
    print(container_pid)

def second():
    '''
    Фильтрация лог файла
    '''
    output_filter.filtering()

if __name__ == "__main__":
    if sys.argv[1] == "1":
        first()
    elif sys.argv[1] == "2":
        second()