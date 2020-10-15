tool
class_name VisualFSMTransitionSlot
extends HBoxContainer

signal close_request(slot)


func _on_CloseButton_pressed():
	emit_signal("close_request", self)
