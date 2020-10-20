tool
class_name VisualFiniteStateMachine
extends Resource

export(Vector2) var start_position: Vector2
var start_target: String setget _set_start_target
var _states := {} # name to VisualFiniteStateMachineState
var _timer_events := {} # name to VisualFiniteStateMachineEventTimer
var _action_events := {} # name to VisualFiniteStateMachineEventAction
var _script_events := {} # name to VisualFiniteStateMachineEventScript

# transition maps:
# {
#   from_state_name_1: {
#		event_name_1: to_state_name_1,
#		event_name_2: to_state_name_2
#		etc...
#	},
#	from_state_name_1: {
#		etc...
#	},
#	etc...
# }
var _timer_transitions := {}
var _action_transitions := {}
var _script_transitions := {}


func _init():
	start_position = Vector2(100, 100)


func has_state(name: String) -> bool:
	return _states.has(name)


func get_start_state() -> VisualFiniteStateMachineState:
	if self.start_target.empty():
		return null
	return _states[self.start_target]


func get_state(name: String) -> VisualFiniteStateMachineState:
	return _states[name]


func get_next_state(current: String, event: VisualFiniteStateMachineEvent) -> VisualFiniteStateMachineState:
	var active_transition_map
	if event is VisualFiniteStateMachineEventTimer:
		active_transition_map = _timer_transitions
	elif event is VisualFiniteStateMachineEventAction:
		active_transition_map = _action_transitions
	elif event is VisualFiniteStateMachineEventScript:
		active_transition_map = _script_transitions
	else:
		assert(false, "VisualFSM: Unrecognized event type: %s" % event.get_class())
	assert(active_transition_map.has(current), "VisualFSM: Missing state: %s" % current)
	assert(active_transition_map[current].has(event.name), "Missing transition on event: %s" % event.name)
	return active_transition_map[current][event.name]


# gets event at index
func get_state_event_name_from_index(state_name: String, index: int) -> String:
	var timer_events: Array = _timer_transitions[state_name].keys()
	if index < timer_events.size():
		return timer_events[index]
	index -= timer_events.size()
	var action_events: Array = _action_transitions[state_name].keys()
	if index < action_events.size():
		return action_events[index]
	index -= action_events.size()
	var script_events: Array = _script_transitions[state_name].keys()
	assert(index < script_events.size())
	return script_events[index]


func get_state_timer_event_names(name: String) -> Array:
	assert(_timer_transitions.has(name), "Missing state: %s" % name)
	return _timer_transitions[name].keys()


func get_state_action_event_names(name: String) -> Array:
	assert(_action_transitions.has(name), "Missing state: %s" % name)
	return _action_transitions[name].keys()


func get_state_script_event_names(name: String) -> Array:
	assert(_script_transitions.has(name), "Missing state: %s" % name)
	return _script_transitions[name].keys()


func get_states() -> Array:
	return _states.values()


func add_state(state: VisualFiniteStateMachineState) -> void:
	_timer_transitions[state.name] = {}
	_action_transitions[state.name] = {}
	_script_transitions[state.name] = {}
	_states[state.name] = state
	_changed()


func _erase_from_transition_map(map: Dictionary, state_name: String) -> void:
	map.erase(state_name)
	for from in map.keys():
		for event in map[from].keys():
			if state_name == map[from][event]:
				map[from][event] = ""


func remove_state(state_name: String) -> void:
	assert(_states.has(state_name), "Missing state: %s" % state_name)
	_states.erase(state_name)
	_erase_from_transition_map(_timer_transitions, state_name)
	_erase_from_transition_map(_action_transitions, state_name)
	_erase_from_transition_map(_script_transitions, state_name)
	_changed()


#func rename_state(name: String, new_name: String) -> void:
#	var state: VisualFiniteStateMachineState = _states[name]
#	state.name = new_name
#	_states[new_name] = state
#	var source_code: String = state.custom_script.source_code
#	var first_endline = source_code.find('\n')
#	var new_first_line = "# State name: %s    <--- DO NOT TOUCH" % new_name
#	state.custom_script.source_code = new_first_line + source_code.substr(first_endline)
#	state.custom_script.reload(true)
#
#	if start_target == name:
#		start_target = new_name
#	var transitions: Dictionary = _transitions[name]
#	_transitions[new_name] = transitions
#	for from in _transitions.keys():
#		for event in _transitions[from].keys():
#			if name == _transitions[from][event]:
#				_transitions[from][event] = new_name
#	remove_state(name)


func has_timer_event(name: String) -> bool:
	return _timer_events.has(name)


func get_timer_event_names() -> Array:
	return _timer_events.keys()


func get_timer_event(name: String) -> VisualFiniteStateMachineEventTimer:
	return _timer_events[name]


func has_action_event(name: String) -> bool:
	return _action_events.has(name)


func get_action_event_names() -> Array:
	return _action_events.keys()


func get_action_event(name: String) -> VisualFiniteStateMachineEventAction:
	return _action_events[name]


func has_script_event(name: String) -> bool:
	return _script_events.has(name)


func get_script_event_names() -> Array:
	return _script_events.keys()


func get_script_event(name: String) -> VisualFiniteStateMachineEventScript:
	return _script_events[name]


func add_event(event: VisualFiniteStateMachineEvent) -> void:
	if event is VisualFiniteStateMachineEventTimer:
		_timer_events[event.name] = event
	elif event is VisualFiniteStateMachineEventAction:
		_action_events[event.name] = event
	elif event is VisualFiniteStateMachineEventScript:
		_script_events[event.name] = event
	else:
		assert(false, "VisualFSM: Unrecognized event type: %s" % event.get_class())
	_changed()


func remove_event(event: VisualFiniteStateMachineEvent) -> void:
	if event is VisualFiniteStateMachineEventTimer:
		_timer_events.erase(event.name)
	elif event is VisualFiniteStateMachineEventAction:
		_action_events.erase(event.name)
	elif event is VisualFiniteStateMachineEventScript:
		_script_events.erase(event.name)
	else:
		assert(false, "VisualFSM: Unrecognized event type: %s" % event.get_class())

	for state_name in _states.keys():
		if _timer_transitions.has(state_name):
			_timer_transitions[state_name].erase(event.name)
		if _action_transitions.has(state_name):
			_action_transitions[state_name].erase(event.name)
		if _script_transitions.has(state_name):
			_script_transitions[state_name].erase(event.name)
	_changed()


func remove_state_event(state_name: String, event: VisualFiniteStateMachineEvent) -> void:
	if event is VisualFiniteStateMachineEventTimer:
		assert(_timer_transitions.has(state_name))
		_timer_transitions[state_name].erase(event.name)
	elif event is VisualFiniteStateMachineEventAction:
		assert(_action_transitions.has(state_name))
		_action_transitions[state_name].erase(event.name)
	elif event is VisualFiniteStateMachineEventScript:
		assert(_script_transitions.has(state_name))
		_script_transitions[state_name].erase(event.name)
	else:
		assert(false, "VisualFSM: Unrecognized event type: %s" % event.get_class())
	_changed()


func _extract_transitions(map: Dictionary):
	var transitions := []
	for from in map.keys():
		for event in map[from].keys():
			transitions.push_back({
				"from": from,
				"event": event,
				"to": map[from][event]
			})
	return transitions


func get_timer_transitions() -> Array:
	return _extract_transitions(_timer_transitions)


func get_action_transitions() -> Array:
	return _extract_transitions(_action_transitions)


func get_script_transitions() -> Array:
	return _extract_transitions(_script_transitions)


func add_timer_transition(from: String, event_name: String, to: String = ""):
	assert(_states.has(from), "Missing state: %s" % from)
	assert(_timer_transitions.has(from), "Missing state: %s" % from)
	assert(_timer_events.has(event_name), "Missing event: %s" % event_name)

	_timer_transitions[from][event_name] = to
	_changed()


func remove_timer_transition(from: String, event_name: String):
	add_timer_transition(from, event_name)


func add_action_transition(from: String, event_name: String, to: String = ""):
	assert(_states.has(from), "Missing state: %s" % from)
	assert(_action_transitions.has(from), "Missing state: %s" % from)
	assert(_action_events.has(event_name), "Missing event: %s" % event_name)

	_action_transitions[from][event_name] = to
	_changed()


func remove_action_transition(from: String, event_name: String):
	add_action_transition(from, event_name)


func add_script_transition(from: String, event_name: String, to: String = ""):
	assert(_states.has(from), "Missing state: %s" % from)
	assert(_script_transitions.has(from), "Missing state: %s" % from)
	assert(_script_events.has(event_name), "Missing event: %s" % event_name)

	_script_transitions[from][event_name] = to
	_changed()


func remove_script_transition(from: String, event_name: String):
	add_script_transition(from, event_name)


func _changed() -> void:
	call_deferred("emit_signal", "changed")


func _set_start_target(value: String) -> void:
	if not value.empty():
		assert(_states.has(value), "Missing state: %s" % value)
	start_target = value
	_changed()


func _transition_map_to_array(map: Dictionary) -> Array:
	var transitions := []
	for from in map.keys():
		if 0 == map[from].keys().size():
			transitions += [from, "", ""]
		for event in map[from].keys():
			var to = map[from][event]
			transitions += [
				from,
				event,
				to
			]
	return transitions


func _get(property: String):
#	print_debug("FSM: Getting property: %s" % property)
	match property:
		"states":
			return _states.values()
		"timer_events":
			return _timer_events.values()
		"action_events":
			return _action_events.values()
		"script_events":
			return _script_events.values()
		"timer_transitions":
			return _transition_map_to_array(_timer_transitions)
		"action_transitions":
			return _transition_map_to_array(_action_transitions)
		"script_transitions":
			return _transition_map_to_array(_script_transitions)
		"start":
			return self.start_target
	return null


func _set(property: String, value) -> bool:
	match property:
		"states":
			for state in value:
				add_state(state)
			return true
		"timer_events":
			for event in value:
				add_event(event)
			return true
		"action_events":
			for event in value:
				add_event(event)
			return true
		"script_events":
			for event in value:
				add_event(event)
			return true
		"timer_transitions":
			var num_transitions = value.size() / 3
			for idx in range(num_transitions):
				var from = value[3 * idx]
				var event = value[3 * idx + 1]
				var to = value[3 * idx + 2]
				if event.empty():
					_timer_transitions[from] = {}
				else:
					add_timer_transition(from, event, to)
			return true
		"action_transitions":
			var num_transitions = value.size() / 3
			for idx in range(num_transitions):
				var from = value[3 * idx]
				var event = value[3 * idx + 1]
				var to = value[3 * idx + 2]
				if event.empty():
					_action_transitions[from] = {}
				else:
					add_action_transition(from, event, to)
			return true
		"script_transitions":
			var num_transitions = value.size() / 3
			for idx in range(num_transitions):
				var from = value[3 * idx]
				var event = value[3 * idx + 1]
				var to = value[3 * idx + 2]
				if event.empty():
					_script_transitions[from] = {}
				else:
					add_script_transition(from, event, to)
			return true
		"start":
			self.start_target = value
			return true
	return false


func _get_property_list() -> Array:
	var property_list := []
	property_list += [
			{
				"name": "states",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "timer_events",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "action_events",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "script_events",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "timer_transitions",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "action_transitions",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "script_transitions",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "start",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			}
		]

	return property_list
