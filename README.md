# Task Dispatcher
Addon that allows you to offload tasks to another thread. There are no thread pool, only a single thread working in the background. Can be used either as a child node or as an autoload/singleton.

## Task
Small class that is similar to a Promise/Task/Future in other languages. Each Task has a state that can be either PENDING or FINISHED. You can access the state using the method `get_state()` and you can obtain the result value (that can be an error) using the method `get_result()`. Tasks will emit a signal called `finished(value)` when the task is succeed or fail.

## Example
```gdscript
extends Node2D


func _ready() -> void:
    var task = dispatcher.run(self, "_heavy_task", [1, 2])
    task.connect("finished", self, "_on_task_finished")

func _heavy_task(a: int, b: int) -> int:
    return a + b

func _on_task_finished(value: int) -> void:
    print(value)
```
