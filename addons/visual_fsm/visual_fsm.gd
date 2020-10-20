tool
extends Node

onready var _parent_node = get_parent() 
var fsm: VisualFiniteStateMachine
var _current_state: VisualFiniteStateMachineState

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		if not self.fsm:
			self.fsm = VisualFiniteStateMachine.new()
	else:
		_current_state = fsm.get_start_state()
		assert(_current_state, "VisualFSM: %s's finite state machine doesn't point to a starting state." % _parent_node.name)
		if _current_state:
			_current_state.enter()


func _input(event):
	# handle transitions based on input action
	pass


func _process(delta) -> void:
	_current_state.update(_parent_node, delta)

	var next_state: VisualFiniteStateMachineState
	for event_id in _current_state.event_ids:
		var event := fsm.get_event(event_id)
		var go_to_next_event := false
		if event is VisualFiniteStateMachineEventTimer:
			go_to_next_event = event.is_over(delta)
		elif event is VisualFiniteStateMachineEventScript:
			go_to_next_event = event.is_triggered(_parent_node, delta)

		if go_to_next_event:
			next_state = fsm.get_next_state(_current_state, event)
			break

	if next_state:
		_current_state.exit()

		_current_state = next_state
		_current_state.enter()
		for event_id in _current_state.event_ids:
			fsm.get_event(event_id).enter()


func _set(property, value):
	match property:
		"finite_state_machine":
			fsm = value
	return false


func _get(property):
	match property:
		"finite_state_machine":
			return fsm
			return true
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
