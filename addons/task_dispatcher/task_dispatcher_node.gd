extends Node


const Task := preload("res://addons/task_dispatcher/task.gd")
const TaskDispatcher := preload("res://addons/task_dispatcher/task_dispatcher.gd")


var _dispatcher: TaskDispatcher


func _ready():
    _dispatcher = TaskDispatcher.new(8)
    _dispatcher.start()

func run(object: Object, method: String, args: Array = []) -> Task:
    return _dispatcher.run(object, method, args)

func _process(_delta: float) -> void:
    _dispatcher.poll()

func _exit_tree() -> void:
    _dispatcher.stop()
