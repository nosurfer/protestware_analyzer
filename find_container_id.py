import psutil

def find_docker_process_id_recursive(process):
    all = list()
    try:
        for child in process.children():
            if "containerd-shim" in child.name():
                all.append(child)
            docker_pid = find_docker_process_id_recursive(child)
        if all:
            return all
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        pass
    return None

def find_docker_process_id():
    # Проходимся по всем процессам
    for proc in psutil.process_iter(['pid', 'name']):
        try:
            # Вызываем функцию поиска Docker-процесса рекурсивно, начиная с containerd-shim
            docker_pid = find_docker_process_id_recursive(proc)
            if docker_pid:
                time = max([str(shim)[-10:-2] for shim in docker_pid])
                for shim in docker_pid:
                    if time in str(shim):
                        return shim.pid
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return None