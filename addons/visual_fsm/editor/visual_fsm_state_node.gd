tool
class_name VisualFSMStateNode
extends GraphNode

signal name_change_request(state_node, new_name)
signal state_removed(state_node)

var _transition_slot_scene: PackedScene = preload("visual_fsm_transition_slot.tscn")
var state_name: String setget _set_state_name, _get_state_name

const COLORS := [
	Color.coral,
	Color.lightgreen,
	Color.aquamarine,
	Color.beige,
	Color.orchid,
	Color.brown,
	Color.gold,
	Color.magenta
]


func _ready() -> void:
	set_slot(0, true, 0, COLORS[0], false, 0, Color.white)
	$StateName.grab_focus()


func _set_state_name(value) -> void:
	$StateName.text = value


func _get_state_name() -> String:
	return $StateName.text


func _on_AddTransitionButton_pressed():
	var slot_idx = get_child_count() - 1
	var next_to_last = get_child(slot_idx - 1)
	add_child_below_node(next_to_last, _transition_slot_scene.instance())
	set_slot(slot_idx, false, 0, Color.white, true, 0, COLORS[slot_idx])


func _on_StateGraphNode_close_request():
	emit_signal("state_removed", self)
	queue_free()


func _on_StateGraphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_StateName_text_changed(new_text):
	emit_signal("name_change_request", self, new_text)
