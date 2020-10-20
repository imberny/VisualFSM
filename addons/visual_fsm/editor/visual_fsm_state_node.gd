tool
class_name VisualFSMStateNode
extends GraphNode

signal state_removed(state_node)
signal new_script_request(state_node)

const COLORS := [
	Color.coral,
	Color.lightgreen,
	Color.aquamarine,
	Color.beige,
	Color.orchid,
	Color.brown,
	Color.magenta,
	Color.gold,
	Color.pink,
	Color.limegreen
]

export(Texture) var timer_icon
export(Texture) var action_icon
export(Texture) var script_icon

onready var _state_label := $TitlePanel/HBox/Margins/Name
onready var _add_event_dropdown := $BottomPanel/AddEventDropdown

var state: VisualFiniteStateMachineState setget _set_state
var fsm: VisualFiniteStateMachine
var _event_slot_scene: PackedScene = preload("visual_fsm_event_slot.tscn")


func _ready() -> void:
	set_slot(0, true, 0, COLORS[0], false, 0, Color.white)
	var add_event_menu: PopupMenu = _add_event_dropdown.get_popup()
	add_event_menu.connect(
		"index_pressed", self, "_on_AddEvent_index_pressed")
	add_event_menu.connect("focus_exited", add_event_menu, "hide")


func add_event(event: VisualFiniteStateMachineEvent) -> void:
	if get_child_count() == COLORS.size() - 2:
		printerr("VisualFSM: Maximum number of events in state %s reached!" 
			% self.state.name)
		return

	var slot_idx = get_child_count() - 1
	var next_to_last = get_child(slot_idx - 1)
	var event_slot: VisualFSMEventSlot = _event_slot_scene.instance()
	event_slot.connect("close_request", self, "_on_EventSlot_close_request")
	event_slot.event = event
	add_child_below_node(next_to_last, event_slot)
	set_slot(slot_idx, false, 0, Color.white, true, 0, COLORS[slot_idx])


func _set_state(value: VisualFiniteStateMachineState) -> void:
	offset = value.position
	_state_label.text = value.name
	state = value


func _on_AddEvent_about_to_show() -> void:
	var popup: PopupMenu = _add_event_dropdown.get_popup()
	if not popup.is_inside_tree():
		yield(popup, "tree_entered")
	popup.clear()
	# important: this steals focus from state name and triggers validation
	popup.grab_focus()
	var script_event_names = fsm.get_script_event_names()
	for state_event_name in fsm.get_state_script_event_names(self.state.name):
		var idx = script_event_names.find(state_event_name)
		if 0 <= idx:
			script_event_names.remove(idx)
	for event in script_event_names:
		popup.add_item(event)
	if 0 < popup.get_item_count():
		popup.add_separator()
	popup.add_icon_item(timer_icon, "New timer event")
	popup.add_icon_item(action_icon, "New input action event")
	popup.add_icon_item(script_icon, "New script event")


func _on_AddEvent_index_pressed(index: int) -> void:
	var popup: PopupMenu = _add_event_dropdown.get_popup()
	var num_items = popup.get_item_count()
	if num_items - 3 == index: # new timer
		var timer_event := VisualFiniteStateMachineEventTimer.new()
		timer_event.duration = 1
		var suffix = 0
		var event_name = "Timer" + str(suffix)
		while fsm.has_timer_event(event_name):
			suffix += 1
			event_name = "Timer" + str(suffix)
		timer_event.name = event_name
		fsm.add_event(timer_event)
		fsm.add_timer_transition(self.state.name, timer_event.name)
	elif num_items - 2 == index: # new input action
		var action_event := VisualFiniteStateMachineEventAction.new()
		var suffix = 0
		var event_name = "Action" + str(suffix)
		while fsm.has_action_event(event_name):
			suffix += 1
			event_name = "Action" + str(suffix)
		action_event.name = event_name
		fsm.add_event(action_event)
		fsm.add_action_transition(self.state.name, action_event.name)
	elif num_items - 1 == index: # new script
		emit_signal("new_script_request", self)
	else:
		fsm.add_transition(self.state.name, popup.get_item_text(index))


func _on_StateGraphNode_close_request() -> void:
	emit_signal("state_removed", self)
	queue_free()


func _on_StateGraphNode_resize_request(new_minsize) -> void:
	rect_size = new_minsize


func _on_EventSlot_close_request(event_slot: VisualFSMEventSlot) -> void:
	# TODO: Confirm
	fsm.remove_state_event(self.state.name, event_slot.event)


func _on_Script_pressed() -> void:
	$"/root/VisualFSMSingleton".emit_signal(
		"edit_custom_script", self.state.custom_script
	)
