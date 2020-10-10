extends Resource
class_name VisualFiniteStateMachine

var _states: Dictionary
var _transitions: Array


class State:
	var position: Vector2
	var node: VisualFiniteStateMachineState
	
	func _init(position_: Vector2, node_: VisualFiniteStateMachineState) -> void:
		node = node_
		position = position_


class Transition:
	var from: String
	var to: String
	var node: VisualFiniteStateMachineTransition
	
	func _init(from_: String, to_: String, node_: VisualFiniteStateMachineTransition) -> void:
		from = from_
		to = to_
		node = node_


#func _init(val1, val2):
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


func get_node(name: String) -> VisualFiniteStateMachineState:
	return _states[name].node


func get_node_position(name: String) -> Vector2:
	return _states[name].position


func get_node_list() -> Array:
	return _states.keys()


func add_node(name: String, position: Vector2, node: VisualFiniteStateMachineState):
	_states[name] = State.new(position, node)
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
					return _states[name].node
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
			for transition in _transitions:
				transition_list += [
					transition.from, 
					transition.to, 
					transition.node
				]
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
			match what:
				"node":
					print("Setting node for state: " + name)
					_states[name].node = value
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
			var num_transitions := (value as Array).size() % 2#3
			for i in range(num_transitions):
				var from: String = value[i]
				var to: String = value[i + 1]
				var node: VisualFiniteStateMachineTransition = VisualFiniteStateMachineTransition.new()#value[i + 2]
				_transitions.push_back(Transition.new(from, to, node))
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
