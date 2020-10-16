tool
class_name VisualFSMStateNode
extends GraphNode

signal state_rename_request(state_node, new_name)
signal state_removed(state_node)
signal new_event_request(state_node)

var _event_slot_scene: PackedScene = preload("visual_fsm_event_slot.tscn")
var state_name: String setget _set_state_name, _get_state_name
var fsm: VisualFiniteStateMachine

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
	var add_event_menu: PopupMenu = $AddEventDropdown.get_popup()
	add_event_menu.connect(
		"about_to_show", self, "_on_AddEvent_about_to_show")
	add_event_menu.connect(
		"index_pressed", self, "_on_AddEvent_index_pressed")
	add_event_menu.connect("focus_exited", add_event_menu, "hide")
	$StateName.grab_focus()


func add_event(event: VisualFiniteStateMachineEvent):
	var slot_idx = get_child_count() - 1
	var next_to_last = get_child(slot_idx - 1)
	var event_slot: VisualFSMEventSlot = _event_slot_scene.instance()
	event_slot.event = event
	add_child_below_node(next_to_last, event_slot)
	set_slot(slot_idx, false, 0, Color.white, true, 0, COLORS[slot_idx])


func _set_state_name(value) -> void:
	$StateName.text = value


func _get_state_name() -> String:
	return $StateName.text


func _on_AddEvent_about_to_show() -> void:
	var popup: PopupMenu = $AddEventDropdown.get_popup()
	popup.clear()
	for event in fsm.get_event_names():
		popup.add_item(event)
	if 0 < popup.items.size():
		popup.add_separator()
	popup.add_item("New event")


func _on_AddEvent_index_pressed(index: int) -> void:
	var popup: PopupMenu = $AddEventDropdown.get_popup()
	var num_items = popup.get_item_count()
	if num_items - 1 == index: # new item option is last
		emit_signal("new_event_request", self)


func _on_StateGraphNode_close_request():
	emit_signal("state_removed", self)
	queue_free()


func _on_StateGraphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_StateName_text_changed(new_text):
	emit_signal("state_rename_request", self, new_text)
