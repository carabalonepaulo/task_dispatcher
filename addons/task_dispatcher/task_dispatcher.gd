extends Reference


const Task := preload("res://addons/task_dispatcher/task.gd")
const ConcurrentQueue := preload("res://addons/task_dispatcher/concurrent_queue.gd")


var _in: ConcurrentQueue
var _out: ConcurrentQueue
var _semaphore: Semaphore
var _quit: bool
var _workers: Array


func _init(workers_count: int = -1):
    _in = ConcurrentQueue.new()
    _out = ConcurrentQueue.new()
    _semaphore = Semaphore.new()
    _quit = false
    _workers = _create_workers(workers_count)

func _create_workers(count: int) -> Array:
    var workers = []
    for i in (count if count > 0 else OS.get_processor_count()):
        workers.push_back(Thread.new())
    return workers

func _loop(id: int) -> int:
    while true:
        _semaphore.wait()
        if _quit: break

        var data = _in.try_dequeue()
        if data != null:
            var result = data[0].callv(data[1], data[2])
            _out.enqueue([data[3], result])

    return OK

func start() -> void:
    for i in _workers.size():
        _workers[i].start(self, "_loop", i)

func stop() -> void:
    _quit = true
    for i in _workers.size():
        _semaphore.post()
    for worker in _workers:
        worker.wait_to_finish()

func poll() -> void:
    var value = _out.try_dequeue()
    while value != null:
        value[0].complete(value[1])
        value = _out.try_dequeue()

func run(object: Object, method: String, args: Array) -> Task:
    var task := Task.new()
    _in.enqueue([object, method, args, task])
    _semaphore.post()
    return task
