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

var timer_duration_dialog: AcceptDialog
var input_action_dialog: AcceptDialog
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
	add_child_below_node(next_to_last, event_slot)
	event_slot.timer_duration_dialog = timer_duration_dialog
	event_slot.input_action_dialog = input_action_dialog
	event_slot.connect("close_request", self, "_on_EventSlot_close_request")
	event_slot.event = event
	set_slot(slot_idx, false, 0, Color.white, true, 0, COLORS[slot_idx])


func _set_state(value: VisualFiniteStateMachineState) -> void:
	offset = value.position
	_state_label.text = value.name
	state = value


func _has_timer_event(state: VisualFiniteStateMachineState) -> bool:
	for event in fsm.get_events_in_state(state):
		if event is VisualFiniteStateMachineEventTimer:
			return true
	return false


func _on_AddEvent_about_to_show() -> void:
	var popup: PopupMenu = _add_event_dropdown.get_popup()
	if not popup.is_inside_tree():
		yield(popup, "tree_entered")
	popup.clear()
	# important: this steals focus from state name and triggers validation
	popup.grab_focus()
	var options := []
	# TODO: potential issue with ordering
	for script_event in fsm.get_script_events():
		if not self.state.has_event(script_event.fsm_id):
			options.push_back(script_event)
	for event in options:
		popup.add_icon_item(script_icon, event.name)
	if 0 < popup.get_item_count():
		popup.add_separator()
	if not _has_timer_event(self.state):
		popup.add_icon_item(timer_icon, "New timer event")
	popup.add_icon_item(action_icon, "New input action event")
	popup.add_icon_item(script_icon, "New script event")


func _on_AddEvent_index_pressed(index: int) -> void:
	var popup: PopupMenu = _add_event_dropdown.get_popup()
	var num_items = popup.get_item_count()
	if num_items - 3 == index: # new timer
		fsm.create_timer_event(self.state)
	elif num_items - 2 == index: # new input action
		fsm.create_action_event(self.state)
	elif num_items - 1 == index: # new script
		emit_signal("new_script_request", self)
	else: # reuse existing script event
		var options := []
		for script_event in fsm.get_script_events():
			if not self.state.has_event(script_event.fsm_id):
				options.push_back(script_event)
		var selected_event = options[index]
		self.state.add_event(selected_event)


func _on_StateGraphNode_close_request() -> void:
	emit_signal("state_removed", self)
	queue_free()


func _on_StateGraphNode_resize_request(new_minsize) -> void:
	rect_size = new_minsize


func _on_EventSlot_close_request(event_slot: VisualFSMEventSlot) -> void:
	# TODO: Confirm
	fsm.remove_event_from_state(self.state, event_slot.event)


func _on_Script_pressed() -> void:
	$"/root/VisualFSMSingleton".emit_signal(
		"edit_custom_script", self.state.custom_script
	)
