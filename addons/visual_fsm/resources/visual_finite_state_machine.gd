tool
class_name VisualFiniteStateMachine
extends Resource

var _states := {}


func has_state(name: String):
	return _states.has(name)


func get_state(name: String) -> VisualFiniteStateMachineState:
	return _states[name]


func get_states() -> Array:
	return _states.values()


func add_state(name: String, position: Vector2):
	var state := VisualFiniteStateMachineState.new()
	state.name = name
	state.position = position
	_states[name] = state
	emit_signal("changed")


func rename_state(name: String, new_name: String) -> void:
	var state = _states[name]
	_states.erase(name)
	_states[new_name] = state
#	for transition in _transitions:
#		if name == transition.from_state:
#			transition.from_state = new_name
#		if name == transition.to_state:
#			transition.to_state = new_name
#
#
#func add_transition(from_state: String, to_state: String) -> void:
#	var transition := VisualFiniteStateMachineTransition.new()
#	transition.from_state = from_state
#	transition.to_state = to_state
#	_transitions.push_back(transition)
#	emit_signal("changed")
#
#func remove_transition(from_state: String, to_state: String) -> void:
#	var transition_to_remove: VisualFiniteStateMachineTransition
#	for transition in _transitions:
#		if transition.from_state == from_state and transition.to_state == to_state:
#			transition_to_remove = transition
#
#	if transition_to_remove:
#		_transitions.erase(transition_to_remove)
#		emit_signal("changed")


func _get(property: String):
	var parts = property.split("/")

	match parts[0]:
		"states":
			var name: String = parts[1]
			return _states[name]
	return null


func _set(property: String, value) -> bool:
	var parts = property.split("/")

	match parts[0]:
		"states":
			add_state(value.name, value.position)
			return true
	return false


func _get_property_list() -> Array:
	var property_list := []
	for state in _states.values():
		property_list += [
			{
				"name": "states/" + state.name,
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "VisualFiniteStateMachineState",
				"usage": PROPERTY_USAGE_NOEDITOR
			}
		]

	return property_list
