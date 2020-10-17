tool
extends GraphEdit

var _fsm_state_scene: PackedScene = preload("visual_fsm_state_node.tscn")
var _fsm: VisualFiniteStateMachine
var _popup_options := ["New state", "New transition", "save", "load"]
var _popup: PopupMenu
var _events := {}
var _state_node_creating_event: VisualFSMStateNode

onready var _new_event_dialog: ConfirmationDialog = $"../DialogLayer/Dialog"


func _ready() -> void:
	add_valid_left_disconnect_type(0)

	connect("popup_request", self, "_on_popup_request")
	_popup = PopupMenu.new()
	_popup.connect("index_pressed", self, "_on_popup_index_pressed")
	_popup.connect("focus_exited", _popup, "hide")
	for opt in _popup_options:
		_popup.add_item(opt)
	add_child(_popup)

	_new_event_dialog.rect_position = get_viewport_rect().size / 2 - _new_event_dialog.rect_size / 2

	edit(VisualFiniteStateMachine.new())


func edit(fsm: VisualFiniteStateMachine) -> void:
	if _fsm:
		_fsm.disconnect("changed", self, "_on_fsm_changed")
	_fsm = fsm
	_fsm.connect("changed", self, "_on_fsm_changed")
	_redraw_graph()


func _on_fsm_changed():
	_redraw_graph()


func _redraw_graph():
	print_debug("Redrawing fsm graph.............")
	clear_connections()
	# clear graph elements
	for child in get_children():
		if child is VisualFSMStateNode:
			remove_child(child)
			child.queue_free()

	# add state nodes
	for state in _fsm.get_states():
		print_debug("VisualFSMGraphEdit: adding state node: " + state.name)
		var node: VisualFSMStateNode = _fsm_state_scene.instance()
		node.connect("state_removed", self, "_on_StateNode_state_removed")
		node.connect(
			"state_rename_request", self, "_on_StateNode_rename_request")
		node.connect(
			"new_event_request", self, "_on_StateNode_new_event_request")
		node.fsm = _fsm
		node.state_name = state.name
		# center node on position
		node.offset = state.position
		add_child(node)

	# add event slots
	for transition in _fsm.get_transitions():
		var from_node: VisualFSMStateNode
		var to_node: VisualFSMStateNode
		for child in get_children():
			if child is VisualFSMStateNode:
				if child.state_name == transition.from:
					from_node = child
				if child.state_name == transition.to:
					to_node = child
		var state_event_names: Array = _fsm.get_state_event_names(transition.from)
#		for event_name in state_event_names:
		var event := _fsm.get_event(transition.event)
		from_node.add_event(event)
		var event_index := 0
		while state_event_names[event_index] != transition.event:
			event_index += 1
		if from_node and to_node:
			connect_node(from_node.name, event_index, to_node.name, 0)


func _on_popup_request(position: Vector2) -> void:
	_popup.set_position(position)
	_popup.show()
	_popup.grab_focus()


func _on_popup_index_pressed(index: int) -> void:
	match index:
		0:
			print_debug("adding new state...")
			var mouse_pos: Vector2 = get_parent().get_local_mouse_position()
			var base_name := "State"
			var state_name := base_name
			var suffix := 1
			while _fsm.has_state(state_name):
				state_name = base_name + str(suffix)
				suffix += 1
			var state := VisualFiniteStateMachineState.new()
			state.name = state_name
			state.position = mouse_pos - Vector2(115, 40)
			_fsm.add_state(state)
		1:
			print_debug("adding new transition...")


func _on_connection_request(
		from: String, from_slot: int, to: String, to_slot: int
	) -> void:
	if from.empty() or to.empty():
		printerr("VisualFSM States must have names.")
		return
	
	var from_node: VisualFSMStateNode = get_node(from)
	var to_node: VisualFSMStateNode = get_node(to)
	var event_names := _fsm.get_state_event_names(from_node.state_name)
	var event: String = event_names[from_slot]
	_fsm.add_transition(from_node.state_name, event, to_node.state_name)


func _on_disconnection_request(from, from_slot, to, to_slot):
	var from_node: VisualFSMStateNode = get_node(from)
	var event_names := _fsm.get_state_event_names(from_node.state_name)
	var event: String = event_names[from_slot]
	_fsm.remove_transition(from_node.state_name, event)


func _on_StateNode_state_removed(state_node: VisualFSMStateNode) -> void:
	_fsm.remove_state(state_node.state_name)
	emit_signal("draw")


func _on_StateNode_rename_request(
	state_node: VisualFSMStateNode, old_name: String, new_name: String) -> void:
	if new_name.empty():
		printerr("VisualFSM States must have names.")
		state_node.state_name = old_name
		return

	print_debug("Renaming from %s to %s" % [old_name, new_name])
	_fsm.rename_state(old_name, new_name)


func _on_StateNode_new_event_request(node: VisualFSMStateNode) -> void:
	_state_node_creating_event = node
	_new_event_dialog.show()


func _on_Dialog_event_name_request(event_name: String) -> void:
	if not _fsm.has_event(event_name):
		_new_event_dialog.event_name = event_name
	else:
		_new_event_dialog.event_name = ""
		_new_event_dialog.name_request_denied(event_name)


func _on_Dialog_new_event_created(event: VisualFiniteStateMachineEvent) -> void:
	_fsm.add_event(event)
	_fsm.add_transition(_state_node_creating_event.state_name, event.name)
	_state_node_creating_event = null
	_new_event_dialog.hide()


func _on_end_node_move():
	for child in get_children():
		if child is VisualFSMStateNode:
			var state := _fsm.get_state(child.state_name)
			state.position = child.offset
