tool
extends Node


export(Resource) var FiniteStateMachine setget _set_fsm, _get_fsm


func _set_fsm(fsm: Resource) -> void:
	if not is_inside_tree():
		yield(self, "tree_entered")
	
	if not $"/root/VisualFSMSingleton":
		printerr("ERROR: VisualFSM plugin is not installed.")
		return
	
	if fsm is VisualFiniteStateMachine:
		FiniteStateMachine = fsm
		$"/root/VisualFSMSingleton".FSM = FiniteStateMachine
	
	printerr("ERROR: This node only supports resources of type VisualFiniteStateMachine.")
	FiniteStateMachine = null
	$"/root/VisualFSMSingleton".FSM = FiniteStateMachine


func _get_fsm() -> VisualFiniteStateMachine:
	return FiniteStateMachine
