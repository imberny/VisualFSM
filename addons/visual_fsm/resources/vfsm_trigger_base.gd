class_name VFSMTriggerBase
extends Object

var name: String


func enter(_fsm, _state : VFSMStateBase) -> void:
	pass


func exit(_fsm, _state : VFSMStateBase) -> void:
	pass


func is_triggered(_fsm,  _state : VFSMStateBase, _delta: float) -> bool:
	assert(false, "VisualFSM: Method \"is_triggered\" is unimplemented.")
	return false
