tool
class_name VisualFSMEventSlot
extends PanelContainer

signal close_request(event_slot)
signal rename_request(event_slot)

var event: VisualFiniteStateMachineEvent setget _set_event


func _ready() -> void:
	$Content/EventLabel.grab_focus()


func _set_event(value: VisualFiniteStateMachineEvent) -> void:
	$Content/EventLabel.text = value.name
	event = value

	for button in $Content/Buttons.get_children():
		button.visible = false
	if event is VisualFiniteStateMachineEventAction:
		$Content/Buttons/Action.visible = true
	elif event is VisualFiniteStateMachineEventTimer:
		$Content/Buttons/Timer.visible = true
	elif event is VisualFiniteStateMachineEventScript:
		$Content/Buttons/Script.visible = true;


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request", self)
