tool
class_name VisualFiniteStateMachine
extends Resource

const STATE_TEMPLATE_PATH := "res://addons/visual_fsm/resources/state_template.txt"
const EVENT_TEMPLATE_PATH := "res://addons/visual_fsm/resources/event_template.txt"

export(int) var start_state_fsm_id: int
export(Vector2) var start_position: Vector2

var _next_state_fsm_id := 0
var _next_event_fsm_id := 0
var _states := {} # fsm_id to VisualFiniteStateMachineState
var _event_fsm_id_map := {} # fsm_id to VisualFiniteStateMachineEvent
var _transitions := {
#   from_state_fsm_id_1: {
#		event_fsm_id_1: to_state_fsm_id_1,
#		event_fsm_id_2: to_state_fsm_id_2
#		etc...
#	},
#	from_state_fsm_id_1: {
#		etc...
#	},
#	etc...
}
var _state_custom_script_template: String
var _event_custom_script_template: String


func _read_from_file(path: String) -> String:
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file \"%s\", error code: %s" % [path, err])
		return ""
	var content = f.get_as_text()
	f.close()
	return content


func _init():
	if not start_position:
		start_position = Vector2(100, 100)
	_state_custom_script_template = _read_from_file(STATE_TEMPLATE_PATH)
	_event_custom_script_template = _read_from_file(EVENT_TEMPLATE_PATH)


func has_state(name: String) -> bool:
	for state in _states.values():
		if name == state.name:
			return true
	return false


func get_start_state() -> VisualFiniteStateMachineState:
	if 0 > self.start_state_fsm_id:
		return null
	return _states.get(self.start_state_fsm_id)


func set_start_state(state: VisualFiniteStateMachineState) -> void:
	if state:
		self.start_state_fsm_id = state.fsm_id
	else:
		self.start_state_fsm_id = -1
	_changed()


func get_state(fsm_id: int) -> VisualFiniteStateMachineState:
	return _states.get(fsm_id)


func get_next_state(
	state: VisualFiniteStateMachineState,
	event: VisualFiniteStateMachineEvent
) -> VisualFiniteStateMachineState:
	var next_state_id = _transitions.get(state.fsm_id).get(event.fsm_id)
	return _states.get(next_state_id)


func get_events_in_state(state: VisualFiniteStateMachineState) -> Array:
	var events := []
	for event_fsm_id in state.event_ids:
		events.push_back(_event_fsm_id_map[event_fsm_id])
	return events


func get_to_state(
	from_state: VisualFiniteStateMachineState,
	event: VisualFiniteStateMachineEvent
) -> VisualFiniteStateMachineState:
	var events = _transitions.get(from_state.fsm_id)
	if not events.has(event.fsm_id):
		return null

	var to_state_fsm_id: int = events.get(event.fsm_id)
	return _states.get(to_state_fsm_id)


func get_states() -> Array:
	return _states.values()


func get_event(fsm_id: int) -> VisualFiniteStateMachineEvent:
	return _event_fsm_id_map.get(fsm_id)


func has_script_event(name: String) -> bool:
	for event in _event_fsm_id_map.values():
		if event is VisualFiniteStateMachineEventScript:
			return name == event.name
	return false


func get_script_events() -> Array:
	var script_events := []
	for event in _event_fsm_id_map.values():
		if event is VisualFiniteStateMachineEventScript:
			script_events.push_back(event)
	return script_events


func create_state(name: String, position: Vector2,
	from_state: VisualFiniteStateMachineState = null, 
	from_event: VisualFiniteStateMachineEvent = null) -> void:
	var state := VisualFiniteStateMachineState.new()
	state.connect("changed", self, "_changed")
	state.fsm_id = _next_state_fsm_id
	_next_state_fsm_id += 1
	state.name = name
	state.position = position
	var custom_script := GDScript.new()
	custom_script.source_code = _state_custom_script_template % state.name
	state.custom_script = custom_script
	_states[state.fsm_id] = state
	_transitions[state.fsm_id] = {}
	if from_state and from_event:
		_transitions[from_state.fsm_id][from_event.fsm_id] = state.fsm_id
		_changed()
	else:
		self.set_start_state(state)


func remove_state(state: VisualFiniteStateMachineState) -> void:
	_states.erase(state.fsm_id)
	_transitions.erase(state.fsm_id)
	for from_fsm_id in _transitions:
		var events_to_erase := []
		for event_fsm_id in _transitions.get(from_fsm_id):
			if state.fsm_id == _transitions.get(from_fsm_id).get(event_fsm_id):
				events_to_erase.push_back(event_fsm_id)
		for event_fsm_id in events_to_erase:
			_transitions[from_fsm_id].erase(event_fsm_id)
	_changed()


func create_timer_event(state: VisualFiniteStateMachineState) -> void:
	var timer_event := VisualFiniteStateMachineEventTimer.new()
	timer_event.fsm_id = _next_event_fsm_id
	_next_event_fsm_id += 1
	timer_event.duration = 1
	_event_fsm_id_map[timer_event.fsm_id] = timer_event
	state.add_event(timer_event)


func create_action_event(state: VisualFiniteStateMachineState) -> void:
	var action_event := VisualFiniteStateMachineEventAction.new()
	action_event.fsm_id = _next_event_fsm_id
	_next_event_fsm_id += 1
	_event_fsm_id_map[action_event.fsm_id] = action_event
	state.add_event(action_event)


func create_script_event(
	state: VisualFiniteStateMachineState,
	event_name: String 
) -> void:
	assert(not has_script_event(event_name))
	var script_event := VisualFiniteStateMachineEventScript.new()
	script_event.fsm_id = _next_event_fsm_id
	_next_event_fsm_id += 1
	script_event.name = event_name
	var custom_script := GDScript.new()
	custom_script.source_code = _event_custom_script_template
	script_event.custom_script = custom_script
	_event_fsm_id_map[script_event.fsm_id] = script_event
	state.add_event(script_event)


func remove_event_from_state(
	state: VisualFiniteStateMachineState,
	event: VisualFiniteStateMachineEvent
) -> void:
	_transitions[state.fsm_id].erase(event.fsm_id)
	state.remove_event(event)


func remove_event(event: VisualFiniteStateMachineEvent) -> void:
	_event_fsm_id_map.erase(event.fsm_id)
	for state_fsm_id in _states:
		_states.get(state_fsm_id).remove_event(event)
	_changed()


func add_transition(
	from_state: VisualFiniteStateMachineState,
	from_event: VisualFiniteStateMachineEvent,
	to_state: VisualFiniteStateMachineState
) -> void:
	_transitions[from_state.fsm_id][from_event.fsm_id] = to_state.fsm_id
	_changed()


func remove_transition(
	from_state: VisualFiniteStateMachineState,
	from_event: VisualFiniteStateMachineEvent
) -> void:
	_transitions[from_state.fsm_id].erase(from_event.fsm_id)
	_changed()


func _changed() -> void:
	call_deferred("emit_signal", "changed")


func _get(property: String):
#	print_debug("FSM: Getting property: %s" % property)
	match property:
		"states":
			return _states.values()
		"events":
			return _event_fsm_id_map.values()
		"transitions":
			var transitions := []
			for from_fsm_id in _transitions:
				for event_fsm_id in _transitions[from_fsm_id]:
					var to_fsm_id = _transitions[from_fsm_id][event_fsm_id]
					transitions += [
						from_fsm_id,
						event_fsm_id,
						to_fsm_id
					]
			return transitions
	return null


func _set(property: String, value) -> bool:
	match property:
		"states":
			for state in value:
				state.connect("changed", self, "_changed")
				_states[state.fsm_id] = state
				_transitions[state.fsm_id] = {}
				if _next_state_fsm_id <= state.fsm_id:
					_next_state_fsm_id = state.fsm_id + 1
			return true
		"events":
			for event in value:
				_event_fsm_id_map[event.fsm_id] = event
				if _next_event_fsm_id <= event.fsm_id:
					_next_event_fsm_id = event.fsm_id + 1
			return true
		"transitions":
			var num_transitions = value.size() / 3
			for fsm_idx in range(num_transitions):
				var from_fsm_id = value[3 * fsm_idx]
				var event_fsm_id = value[3 * fsm_idx + 1]
				var to_fsm_id = value[3 * fsm_idx + 2]
				if not _transitions.has(from_fsm_id):
					_transitions[from_fsm_id] = {}
				_transitions[from_fsm_id][event_fsm_id] = to_fsm_id
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
				"name": "events",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "transitions",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			}
		]

	return property_list
