tool
extends Node

var fsm: VisualFiniteStateMachine
var _current_state: VisualFiniteStateMachineState

func _ready():
	if not self.fsm:
		self.fsm = VisualFiniteStateMachine.new()


func _input(event):
	# handle transitions based on input action
	pass


func update(delta: float, object, params) -> void:
	if not _current_state:
		_current_state = fsm.get_start_state()
		_current_state.enter()

	_current_state.update(delta, object, params)
	var next_state: VisualFiniteStateMachineState
	for event_name in fsm.get_state_event_names(_current_state.name):
		var event := fsm.get_event(event_name)
		if event.is_triggered(delta, object, params):
			next_state = fsm.get_next_state(_current_state.name, event_name)
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
			return true
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
			"hint_string": "VisualFiniteStateMachine",
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	]
