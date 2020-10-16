tool
extends Node

export (Resource) var finite_state_machine setget _set_fsm, _get_fsm


func _set_fsm(fsm: Resource) -> void:
	if not is_inside_tree():
		yield(self, "tree_entered")

	if fsm and not fsm is VisualFiniteStateMachine:
		printerr("ERROR: This node only supports resources of type VisualFiniteStateMachine.")
		finite_state_machine = VisualFiniteStateMachine.new()
		return

	finite_state_machine = fsm


func _get_fsm() -> VisualFiniteStateMachine:
	return finite_state_machine
