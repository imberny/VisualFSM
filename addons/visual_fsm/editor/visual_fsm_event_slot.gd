tool
class_name VisualFSMEventSlot
extends PanelContainer

signal close_request(event_slot)

onready var _timer_duration_field := $Timer/DurationMargins/Duration
onready var _script_title_field := $Script/TitleMargins/Title

var timer_duration_dialog: AcceptDialog
var input_action_dialog: AcceptDialog

var event: VisualFiniteStateMachineEvent setget _set_event


func _set_event(value: VisualFiniteStateMachineEvent) -> void:
	event = value

	if event is VisualFiniteStateMachineEventAction:
		$Action.visible = true
	elif event is VisualFiniteStateMachineEventTimer:
		$Timer.visible = true
		_timer_duration_field.text = str(event.duration)
	elif event is VisualFiniteStateMachineEventScript:
		$Script.visible = true;
		_script_title_field.text = event.name


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request", self)


func _on_Script_pressed() -> void:
	assert(event is VisualFiniteStateMachineEventScript,
		"VisualFSM: Event \"%s\" should be of type VisualFiniteStateMachineEventScript" % event.name)
	$"/root/VisualFSMSingleton".emit_signal("edit_custom_script", event.custom_script)


func _on_Timer_pressed() -> void:
	assert(event is VisualFiniteStateMachineEventTimer,
		"VisualFSM: Event \"%s\" should be of type VisualFiniteStateMachineEventTimer" % event.name)
	var mouse_pos = get_global_mouse_position()
	timer_duration_dialog.rect_position = mouse_pos - timer_duration_dialog.rect_size / 2
	timer_duration_dialog.open(event)
	yield(timer_duration_dialog, "confirmed")
	self.event.duration = timer_duration_dialog.duration
	_timer_duration_field.text = str(timer_duration_dialog.duration)
