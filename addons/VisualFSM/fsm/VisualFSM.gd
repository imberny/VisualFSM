tool
extends Node


export(AnimationRootNode) var FiniteStateMachine setget _set_fsm, _get_fsm


func _set_fsm(fsm: Resource) -> void:
	if not fsm:
		FiniteStateMachine = null
		return
	
	FiniteStateMachine = VisualFiniteStateMachine.new("Start", "End")
#	if fsm is VisualFiniteStateMachine:
#		FiniteStateMachine = VisualFiniteStateMachine.new(10)
#	else:
#		print("ERROR: This node only supports resources of type VisualFiniteStateMachine")
#		FiniteStateMachine = null


func _get_fsm() -> VisualFiniteStateMachine:
	return FiniteStateMachine
