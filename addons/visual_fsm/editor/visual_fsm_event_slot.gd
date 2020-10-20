tool
class_name VisualFSMEventSlot
extends PanelContainer

signal close_request(event_slot)
signal rename_request(event_slot)

onready var _set_timer_dialog := $DialogLayer/SetTimerDurationDialog

var event: VisualFiniteStateMachineEvent setget _set_event


func _ready() -> void:
	_set_timer_dialog.rect_position = get_viewport_rect().size / 2 - _set_timer_dialog.rect_size / 2


func _set_event(value: VisualFiniteStateMachineEvent) -> void:
	event = value

	if event is VisualFiniteStateMachineEventAction:
		$Action.visible = true
	elif event is VisualFiniteStateMachineEventTimer:
		$Timer.visible = true
		$Timer/DurationMargins/Duration.text = str(event.duration)
	elif event is VisualFiniteStateMachineEventScript:
		$Script.visible = true;
		$Script/TitleMargins/Title.text = event.name


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request", self)


func _on_Script_pressed() -> void:
	assert(event is VisualFiniteStateMachineEventScript,
		"VisualFSM: Event \"%s\" should be of type VisualFiniteStateMachineEventScript" % event.name)
	$"/root/VisualFSMSingleton".emit_signal("edit_custom_script", event.custom_script)


func _on_Timer_pressed() -> void:
	assert(event is VisualFiniteStateMachineEventTimer,
		"VisualFSM: Event \"%s\" should be of type VisualFiniteStateMachineEventTimer" % event.name)
	_set_timer_dialog.open(event)
