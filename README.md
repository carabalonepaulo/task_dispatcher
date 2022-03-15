# Task Dispatcher
Addon that allows you to offload tasks to another thread. Unless you know what you are doing use it only with pure functions for a no headache experience.

## Changes
- `finished` signal renamed to `completed` for sake of compatibility with GDScriptFunctionState.
- Multiple workers, if you don't specify how many it will automatically launch one worker for each available thread.
- Using `ConcurrentQueue` instead of `Queue`.

## Task
Small class that is similar to a Promise/Task/Future in other languages. Each Task has a state that can be either PENDING or COMPLETED. You can access the state using the method `get_state()` and you can obtain the result value (that can be an error) using the method `get_result()`. Tasks will emit a signal called `completed(task)` when the task is succeed or fail.

## Examples
Using *res://addons/task_dispatcher/task_dispatcher_node.gd* as child node.
```gdscript
extends Node2D


const Task := preload("res://addons/task_dispatcher/task.gd")
const TaskDispatcher := preload("res://addons/task_dispatcher/task_dispatcher_node.gd")


onready var _dispatcher: TaskDispatcher = $TaskDispatcher


func _ready() -> void:
    var task = _dispatcher.run(self, "_heavy_task", [1, 2])
    task.connect("completed", self, "_on_task_completed")

func _heavy_task(a: int, b: int) -> int:
    return a + b

func _on_task_completed(result: int) -> void:
    print(result)
```

Using *res://addons/task_dispatcher/task_dispatcher.gd* (not a node).
```gdscript
extends Control


const Task := preload("res://addons/task_dispatcher/task.gd")
const TaskDispatcher := preload("res://addons/task_dispatcher/task_dispatcher.gd")


var _expected := 3000
var _all_tasks: Task
var _start := 0
var _dispatcher: TaskDispatcher


func _ready():
    _dispatcher = TaskDispatcher.new(4)
    _dispatcher.start()

    _all_tasks = Task.new()
    _all_tasks.connect("completed", self, "_on_all_tasks_completed")

    _do_tasks_async()

func _process(delta: float) -> void:
    _dispatcher.poll()

func _exit_tree():
    _dispatcher.stop()

func _do_tasks_async() -> void:
    _start = OS.get_ticks_msec()
    for i in _expected:
        var task := _dispatcher.run(self, "_no_io_heavy_task", [i])
        task.connect("completed", self, "_on_heavy_task_completed")

func _on_all_tasks_completed(_void) -> void:
    print(str(OS.get_ticks_msec() - _start) + "ms")

func _no_io_heavy_task(num: int) -> int:
    var x := 0
    for i in num:
        x = randi() % num * num
    return x

func _on_heavy_task_completed(_void) -> void:
    _expected -= 1
    if _expected == 0: _all_tasks.complete()

```