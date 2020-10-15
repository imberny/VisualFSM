tool
extends VBoxContainer

signal slot

var _transition_slot_scene: PackedScene = preload("transition_slot.tscn")


func _on_AddTransitionButton_pressed():
	var slot: VisualFSMTransitionSlot = _transition_slot_scene.instance()
	slot.connect("close_request", self, "_on_Slot_close_request")
	$TransitionList.add_child(slot)


func _on_Slot_close_request(slot: VisualFSMTransitionSlot):
	$TransitionList.remove_child(slot)
	slot.queue_free()
