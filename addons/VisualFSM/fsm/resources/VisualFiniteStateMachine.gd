extends Resource
class_name VisualFiniteStateMachine

var states: Dictionary 


class State:
	var node: VisualFiniteStateMachineState
	var position: Vector2
	
	func _init(node_, position_):
		node = node_
		position = position_

func _init(val1, val2):
	print("adding states: " + val1 + " " + val2)
	states = {}
	states[val1] = State.new(VisualFiniteStateMachineState.new(), Vector2(0, 0))
	states[val2] = State.new(VisualFiniteStateMachineState.new(), Vector2(-100, 100))


func _get(property):
	print("FSM: getting property: " + property)
	var parts = property.split("/")
	if parts.size() <= 1:
		return false
	
	var kind: String = parts[0]
	var node_name: String = parts[1]
	var what: String = parts[2]
	
	match kind:
		"states":
			match what:
				"node":
					return states[node_name].node
				"position":
					return states[node_name].position

func _set(property: String, value) -> bool:
	print("FSM: setting property: " + property)
	var parts = property.split("/")
	if parts.size() <= 1:
		return false
	
	var kind: String = parts[0]
	var node_name: String = parts[1]
	var what: String = parts[2]
	
	match kind:
		"states":
			match what:
				"node":
					states[node_name].node = value
					# TODO: add node
					return true
				"position":
					states[node_name].position = value
					return true
	return false

func _get_property_list() -> Array:
	print("Returning FSM property list...")
	var property_list := []
	for state in states.keys():
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
	return property_list
