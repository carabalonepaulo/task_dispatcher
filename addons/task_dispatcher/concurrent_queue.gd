extends Reference


const VALUE = 0
const NEXT = 1
const EMPTY = [null, null]


var _first: Array = [null, null]
var _last: Array = _first
var _size: int = 0
var _mutex: Mutex


func _init():
    _mutex = Mutex.new()

func size() -> int: return _size

func is_empty() -> bool: return _size == 0

func enqueue(object):
    var node = [object, null]
    _mutex.lock()
    if _size == 0: _first = node
    else: _last[NEXT] = node
    _last = node
    _size += 1
    _mutex.unlock()

func try_dequeue():
    var value = null
    _mutex.lock()
    if _size > 0:
        value = _first[VALUE]
        if _size == 1: _first = EMPTY
        else: _first = _first[NEXT]
        _size -= 1
    _mutex.unlock()
    return value
