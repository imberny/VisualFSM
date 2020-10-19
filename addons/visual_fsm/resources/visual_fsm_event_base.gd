class_name VisualFSMEventBase
extends Reference

var name: String


func enter() -> void:
	pass

func is_triggered(_delta: float, _object, _params) -> bool:
	assert(false, "VisualFSM: Method \"is_triggered\" is unimplemented.")
	return false
