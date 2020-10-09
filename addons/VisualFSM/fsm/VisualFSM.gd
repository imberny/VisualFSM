tool
extends Node


export(Resource) var FiniteStateMachine setget _set_fsm, _get_fsm


func _set_fsm(fsm: Resource) -> void:
	if not fsm:
		FiniteStateMachine = null
		return
	
	if fsm is VisualFiniteStateMachine:
		FiniteStateMachine = fsm
	else:
		print("ERROR: This node only supports resources of type VisualFiniteStateMachine")
		FiniteStateMachine = null


func _get_fsm() -> VisualFiniteStateMachine:
	return FiniteStateMachine
