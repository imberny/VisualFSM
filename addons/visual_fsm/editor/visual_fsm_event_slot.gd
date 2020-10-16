tool
class_name VisualFSMEventSlot
extends HBoxContainer

signal close_request(event_slot)
signal rename_request(event_slot)

var event: VisualFiniteStateMachineEvent setget _set_event


func _ready() -> void:
	$EventLabel.grab_focus()


func _set_event(value: VisualFiniteStateMachineEvent) -> void:
	$EventLabel.text = value.name
	event = value


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request", self)
