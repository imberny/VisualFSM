class_name VFSMTriggerBase
extends Object

var name: String


func enter() -> void:
	pass


func exit() -> void:
	pass


func is_triggered(_fsm, _delta: float) -> bool:
	assert(false, "VisualFSM: Method \"is_triggered\" is unimplemented.")
	return false
