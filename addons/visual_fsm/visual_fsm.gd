tool
extends Node

var fsm: VisualFiniteStateMachine


func _ready():
	if not self.fsm:
		self.fsm = VisualFiniteStateMachine.new()


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
