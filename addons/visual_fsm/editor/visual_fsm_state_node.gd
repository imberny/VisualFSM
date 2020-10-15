tool
class_name VisualFSMStateNode
extends GraphNode

var _transition_slot_scene: PackedScene = preload("transition_slot.tscn")
var state_name: String setget _set_state_name
var _state_line_edit: LineEdit

const COLORS := [
	Color.coral,
	Color.lightgreen,
	Color.lightblue,
	Color.beige,
	Color.orchid,
	Color.brown,
	Color.gold,
	Color.magenta
]


func _init():
	set_slot(0, true, 0, COLORS[0], false, 0, Color.white)


func _set_state_name(value):
	_state_line_edit.text = value


func _on_AddTransitionButton_pressed():
	var slot_idx = get_child_count() - 1
	var next_to_last = get_child(slot_idx - 1)
	add_child_below_node(next_to_last, _transition_slot_scene.instance())
	set_slot(slot_idx, false, 0, Color.white, true, 0, COLORS[slot_idx])
