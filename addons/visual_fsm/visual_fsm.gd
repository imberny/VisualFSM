tool
extends Node

onready var _parent_node = get_parent() 
var fsm: VFSM
var _current_state: VFSMState


func _set_current_state(_state : VFSMState):
	if _current_state:
		_current_state.exit(self)
		for trigger_id in _current_state.trigger_ids:
			fsm.get_trigger(trigger_id).exit(self, _state)
	
	_current_state = _state
	
	if _current_state:
		_current_state.enter(self)
		for trigger_id in _current_state.trigger_ids:
			fsm.get_trigger(trigger_id).enter(self, _state)

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		if not self.fsm:
			self.fsm = VFSM.new()
	else:
		_set_current_state(fsm.get_start_state())
		assert(_current_state, "VisualFSM: %s's finite state machine doesn't point to a starting state." % _parent_node.name)


func _unhandled_input(event: InputEvent) -> void:
	var next_state: VFSMState
	for trigger_id in _current_state.trigger_ids:
		var trigger := fsm.get_trigger(trigger_id)
		var go_to_next_trigger := false
		if trigger is VFSMTriggerAction:
			go_to_next_trigger = trigger.is_trigger_action(event)

		if go_to_next_trigger:
			next_state = fsm.get_next_state(_current_state, trigger)
			break

	if next_state:
		_set_current_state(next_state)


func _process(delta) -> void:
	_current_state.update(self, delta)

	var next_state: VFSMState
	for trigger_id in _current_state.trigger_ids:
		var trigger := fsm.get_trigger(trigger_id)
		var go_to_next_trigger := false
		if trigger is VFSMTriggerTimer:
			go_to_next_trigger = trigger.is_over(delta)
		elif trigger is VFSMTriggerScript:
			go_to_next_trigger = trigger.is_triggered(self, _current_state, delta)

		if go_to_next_trigger:
			next_state = fsm.get_next_state(_current_state, trigger)
			break

	if next_state:
		_set_current_state(next_state)


func _set(property, value):
	match property:
		"finite_state_machine":
			fsm = value
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
			"hint_string": "VFSM",
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	]
