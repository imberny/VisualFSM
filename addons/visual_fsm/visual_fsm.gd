tool
extends Node

onready var _controlled_entity = get_parent() 
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
		if _current_state:
			_current_state.enter()


func _input(event):
	# handle transitions based on input action
	pass


func _process(delta) -> void:
	_current_state.update(_controlled_entity, delta)

	var next_state: VisualFiniteStateMachineState
	for event_name in fsm.get_state_event_names(_current_state.name):
		var event := fsm.get_event(event_name)
		var advance := false
		if event is VisualFiniteStateMachineEventTimer:
			advance = event.is_over(delta)
		if event is VisualFiniteStateMachineEventScript:
			advance = event.is_triggered(_controlled_entity, delta)
		if advance:
			next_state = fsm.get_next_state(_current_state.name, event.name)
			break

	if next_state:
		next_state.enter()
		for event_name in fsm.get_state_event_names(next_state.name):
			var event := fsm.get_event(event_name)
			event.enter()
		_current_state = next_state


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
