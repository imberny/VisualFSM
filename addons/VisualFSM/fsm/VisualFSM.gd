tool
extends Node


export(Resource) var FiniteStateMachine setget _set_fsm, _get_fsm


func _set_fsm(fsm: Resource) -> void:
	if not is_inside_tree():
		yield(self, "tree_entered")
	
	if not fsm:
		FiniteStateMachine = null
		return
	
	if not $"/root/VisualFSMSingleton":
		printerr("ERROR: VisualFSM plugin not installed.")
		return
	
	FiniteStateMachine = VisualFiniteStateMachine.new()
	$"/root/VisualFSMSingleton".FSM = FiniteStateMachine
#	if fsm is VisualFiniteStateMachine:
#		FiniteStateMachine = VisualFiniteStateMachine.new(10)
#	else:
#		print("ERROR: This node only supports resources of type VisualFiniteStateMachine")
#		FiniteStateMachine = null


func _get_fsm() -> VisualFiniteStateMachine:
	return FiniteStateMachine
