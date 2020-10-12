tool
extends Node

export (Resource) var _finite_state_machine setget _set_fsm, _get_fsm


func _set_fsm(fsm: Resource) -> void:
	if not is_inside_tree():
		yield(self, "tree_entered")

	if not $"/root/VisualFSMSingleton":
		printerr("ERROR: VisualFSM plugin is not installed.")
		return

	if fsm is VisualFiniteStateMachine:
		_finite_state_machine = fsm
		$"/root/VisualFSMSingleton".set_fsm(_finite_state_machine)

	printerr("ERROR: This node only supports resources of type VisualFiniteStateMachine.")
	_finite_state_machine = null
	$"/root/VisualFSMSingleton".set_fsm(_finite_state_machine)


func _get_fsm() -> VisualFiniteStateMachine:
	return _finite_state_machine
