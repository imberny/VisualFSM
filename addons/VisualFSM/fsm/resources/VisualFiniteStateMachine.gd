tool
class_name VisualFiniteStateMachine
extends Resource

var _states := {}
var _transitions: Array


class StateInfo:
	var position: Vector2
	var state: VisualFiniteStateMachineState


class TransitionInfo:
	var from: String
	var to: String
	var transition: VisualFiniteStateMachineTransition


#func _init():
#	print("adding states: " + val1 + " " + val2)
#	_states = {}
#	_states[val1] = State.new(Vector2(0, 0), VisualFiniteStateMachineState.new())
#	_states[val2] = State.new(Vector2(-100, 100), VisualFiniteStateMachineState.new())
#	_transitions = []
#	_transitions.push_back(Transition.new(val1, val2, VisualFiniteStateMachineTransition.new()))
#	_transitions.push_back(Transition.new(val2, val2, VisualFiniteStateMachineTransition.new()))
#	_transitions[1].node.transition_type = VisualFiniteStateMachineTransition.TransitionType.TYPE_B


func has_state(name: String):
	return _states.has(name)


func get_state(name: String) -> VisualFiniteStateMachineState:
	return _states[name].state


func get_state_position(name: String) -> Vector2:
	return _states[name].position


func get_node_list() -> Array:
	return _states.keys()


func add_node(name: String, position: Vector2, node: VisualFiniteStateMachineState):
	var state := StateInfo.new()
	state.position = position
	state.node = node
	_states[name] = state
	emit_signal("changed")


func _get_multipart(parts: Array):
	var kind: String = parts[0]
	var name: String = parts[1]
	var what: String = parts[2]

	match kind:
		"states":
			match what:
				"node":
					print("Getting node for state: " + name)
					return _states[name].state
				"position":
					return _states[name].position
	return null


func _get(property: String):
	print("FSM: getting property: " + property)
	var parts = property.split("/")
	if parts.size() > 1:
		return _get_multipart(parts)

	match property:
		"transitions":
			var transition_list = []
			for trans_info in _transitions:
				transition_list += [trans_info.from, trans_info.to, trans_info.transition]
			return transition_list
		"test":
			return "Hello!"
	return null


func _set_multipart(parts: Array, value) -> bool:
	var kind: String = parts[0]
	var name: String = parts[1]
	var what: String = parts[2]

	match kind:
		"states":
			if not _states.has(name):
				_states[name] = StateInfo.new()
			match what:
				"node":
					print("Setting node for state: " + name)
					_states[name].state = value
					# TODO: add node
					return true
				"position":
					_states[name].position = value
					return true
	return false


func _set(property: String, value) -> bool:
	print("FSM: setting property: " + property)
	var parts = property.split("/")
	if parts.size() > 1:
		return _set_multipart(parts, value)

	match property:
		"transitions":
			var num_transitions := (value as Array).size() % 2  #3
			for i in range(num_transitions):
				var trans_info := TransitionInfo.new()
				trans_info.from = value[i]
				trans_info.to = value[i + 1]
				trans_info.node = value[i + 2]
				_transitions.push_back(trans_info)
			return true
		"test":
			return true
	return false


func _get_property_list() -> Array:
	print("Returning FSM property list...")
	var property_list := []
	for state in _states.keys():
		property_list += [
			{
				"name": "states/" + state + "/node",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "VisualFiniteStateMachineState",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "states/" + state + "/position",
				"type": TYPE_VECTOR2,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
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
