extends Reference


signal completed(task)


enum State { PENDING, COMPLETED }


var _state: int = State.PENDING
var _result = null


func complete(value = null) -> void:
    _result = value
    _state = State.COMPLETED
    emit_signal("completed", self)

func get_state() -> int: return _state

func get_result(): return _result
