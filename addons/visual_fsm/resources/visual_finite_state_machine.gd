tool
class_name VisualFiniteStateMachine
extends Resource

var _states := {}
var _transitions: Array


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


func _get(property: String):
	print("FSM: getting property: " + property)
	var parts = property.split("/")

	match parts[0]:
		"states":
			var name: String = parts[1]
			return _states[name]
		"transitions":
			return _transitions
	return null


func _set(property: String, value) -> bool:
	print("FSM: setting property: " + property)
	var parts = property.split("/")

	match parts[0]:
		"states":
			add_state(value.name, value.position)
		"transitions":
			_transitions = value
			return true
	return false


func _get_property_list() -> Array:
	print("Returning FSM property list...")
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
	property_list += [
		{
			"name": "transitions",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	]
	return property_list
