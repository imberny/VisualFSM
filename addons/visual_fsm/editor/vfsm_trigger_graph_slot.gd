tool
class_name VisualFSMEventSlot
extends PanelContainer

signal close_request(event_slot)

onready var _timer_duration_field := $Timer/DurationMargins/Duration
onready var _action_title_field := $Action/ActionLabel
onready var _script_title_field := $Script/TitleMargins/Title

var timer_duration_dialog: AcceptDialog
var input_action_dialog: AcceptDialog

var event: VisualFiniteStateMachineEvent setget _set_event


func _set_event(value: VisualFiniteStateMachineEvent) -> void:
	event = value

	if event is VisualFiniteStateMachineEventAction:
		$Action.visible = true
		_update_action_label()
	elif event is VisualFiniteStateMachineEventTimer:
		$Timer.visible = true
		_timer_duration_field.text = str(event.duration)
	elif event is VisualFiniteStateMachineEventScript:
		$Script.visible = true;
		_script_title_field.text = event.name


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request", self)


func _on_Script_pressed() -> void:
	assert(self.event is VisualFiniteStateMachineEventScript,
		"VisualFSM: Event \"%s\" should be of type VisualFiniteStateMachineEventScript" % self.event.name)
	$"/root/VisualFSMSingleton".emit_signal("edit_custom_script", self.event.custom_script)


func try_set_timer_duration() -> void:
	if yield():
		self.event.duration = timer_duration_dialog.duration
		_timer_duration_field.text = str(timer_duration_dialog.duration)


func _on_Timer_pressed() -> void:
	assert(self.event is VisualFiniteStateMachineEventTimer,
		"VisualFSM: Event \"%s\" should be of type VisualFiniteStateMachineEventTimer" % self.event.name)
	var mouse_pos = get_global_mouse_position()
	timer_duration_dialog.rect_position = mouse_pos - timer_duration_dialog.rect_size / 2
	timer_duration_dialog.open(event.duration, try_set_timer_duration())


func _update_action_label() -> void:
	var action_list = self.event.action_list
	if action_list.empty():
			_action_title_field.text = "No action"
	else:
		_action_title_field.text = action_list[0]
		if action_list.size() > 1:
			_action_title_field.text += " +%s" % str(action_list.size() - 1) 


func try_set_action_list() -> void:
	if yield():
		self.event.action_list = input_action_dialog.get_selected_actions()
	else:
		self.event.action_list = []
	_update_action_label()


func _on_Action_pressed():
	assert(self.event is VisualFiniteStateMachineEventAction,
		"VisualFSM: Event \"%s\" should be of type VisualFiniteStateMachineEventAction" % self.event.name)
	var mouse_pos = get_global_mouse_position()
	input_action_dialog.rect_position = mouse_pos - input_action_dialog.rect_size + Vector2(80, 50)
	input_action_dialog.open(event.action_list, try_set_action_list())
