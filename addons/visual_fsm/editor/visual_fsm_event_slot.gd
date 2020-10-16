tool
class_name VisualFSMEventSlot
extends HBoxContainer

signal close_request(event_slot)
signal rename_request(event_slot)

var event: VisualFiniteStateMachineEvent setget _set_event


func _ready() -> void:
	$EventLabel.grab_focus()


func _set_event(event: VisualFiniteStateMachineEvent) -> void:
	$EventLabel.text = event.event_name


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request", self)
