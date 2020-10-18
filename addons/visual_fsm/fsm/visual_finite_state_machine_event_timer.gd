class_name VisualFiniteStateMachineEventTimer
extends VisualFiniteStateMachineEvent

export(float) var duration

var _timer: float


func enter() -> void:
	_timer = 0


func is_triggered(delta: float, object, params) -> bool:
	_timer += delta
	if duration < _timer:
		return true
	return false
