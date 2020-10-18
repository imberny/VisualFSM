tool
extends Node

#export (Resource) var finite_state_machine setget _set_fsm, _get_fsm
var fsm: VisualFiniteStateMachine


func _ready():
	if not self.fsm:
		self.fsm = VisualFiniteStateMachine.new()

#
#func _set_fsm(fsm: Resource) -> void:
#	if not is_inside_tree():
#		yield(self, "tree_entered")
#
#	if fsm and not fsm is VisualFiniteStateMachine:
#		printerr("VisualFSM: This node only supports resources of type VisualFiniteStateMachine.")
#		printerr("VisualFSM: But since Godot's custom resources support is lacking, I'll just create a VisualFiniteStateMachine for you :)")
#		finite_state_machine = VisualFiniteStateMachine.new()
#	else:
#		finite_state_machine = fsm
#
#
#func _get_fsm() -> VisualFiniteStateMachine:
#	return finite_state_machine

func _set(property, value):
	match property:
		"finite_state_machine":
			fsm = value
			return true
	return false


func _get(property):
	match property:
		"finite_state_machine":
			return fsm
	return null


func _get_property_list() -> Array:
	return [
		{
			"name": "finite_state_machine",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "VisualFiniteStateMachine",
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	]
