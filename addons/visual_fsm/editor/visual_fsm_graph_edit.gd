tool
extends GraphEdit

var _fsm_state_scene: PackedScene = preload("visual_fsm_state_node.tscn")
var _new_event_dialog: AcceptDialog = preload("visual_fsm_new_event_dialog.tscn").instance()
var _fsm: VisualFiniteStateMachine
var _popup_options := ["New state", "New transition", "save", "load"]
var _popup: PopupMenu
var _events := {}
var _state_node_creating_event: VisualFSMStateNode


func _ready() -> void:
	add_valid_left_disconnect_type(0)

	connect("popup_request", self, "_on_popup_request")
	_popup = PopupMenu.new()
	_popup.connect("index_pressed", self, "_on_popup_index_pressed")
	_popup.connect("focus_exited", _popup, "hide")
	for opt in _popup_options:
		_popup.add_item(opt)
	add_child(_popup)

	_new_event_dialog.connect(
		"event_name_request", self, "_on_Dialog_event_name_request")
	_new_event_dialog.connect(
		"new_event_created", self, "_on_Dialog_new_event_created")
	_new_event_dialog.rect_position = get_viewport_rect().size / 2 - _new_event_dialog.rect_size / 2
	add_child(_new_event_dialog)
	_new_event_dialog.hide()

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
	print("Redrawing fsm graph.............")
	# clear graph elements
	for child in get_children():
		if child is VisualFSMStateNode:
			remove_child(child)
			child.queue_free()

	# add state nodes
	for state in _fsm.get_states():
		print("VisualFSMGraphEdit: adding state node: " + state.name)
		var node: VisualFSMStateNode = _fsm_state_scene.instance()
		node.connect("state_removed", self, "_on_StateNode_state_removed")
		node.connect(
			"state_rename_request", self, "_on_StateNode_rename_request")
		node.connect(
			"new_event_request", self, "_on_StateNode_new_event_request")
		node.fsm = _fsm
		node.state_name = state.name
		# center node on position
		node.offset = state.position - node.rect_size / 2
		add_child(node)
	
	for transition in _fsm.get_transitions():
		var event_index := 0
		var state_events: Array = _fsm.get_state_event_names(transition.from)
		while state_events[0] != transition.event:
			event_index += 1
		if not transition.to.empty():
			connect_node(transition.from, event_index + 1, transition.to, 0)


func _on_popup_request(position: Vector2) -> void:
	_popup.set_position(position)
	_popup.show()
	_popup.grab_focus()


func _on_popup_index_pressed(index: int) -> void:
	match index:
		0:
			print("adding new state...")
			var mouse_pos: Vector2 = get_parent().get_local_mouse_position()
			var base_name := "test"
			var state_name := base_name
			var suffix := 1
			while _fsm.has_state(state_name):
				state_name = base_name + str(suffix)
				suffix += 1
			var state := VisualFiniteStateMachineState.new()
			state.name = state_name
			state.position = mouse_pos
			_fsm.add_state(state)
		1:
			print("adding new transition...")


func _on_VisualFSMGraphEdit_connection_request(
		from: String, from_slot: int, to: String, to_slot: int
	) -> void:
	if from.empty() or to.empty():
		printerr("ERROR: States must have names.")
		return
	
	var from_node: VisualFSMStateNode = find_node(from, false)
	var to_node: VisualFSMStateNode = find_node(to, false)
	var event_names := _fsm.get_state_event_names(from_node.state_name)
	var event: String = event_names[from_slot - 1]
	_fsm.add_transition(from_node.state_name, event, to_node.state_name)


func _on_VisualFSMGraphEdit_disconnection_request(from, from_slot, to, to_slot):
	var from_node: VisualFSMStateNode = find_node(from, false)
	var event_names := _fsm.get_state_event_names(from_node.state_name)
	var event: String = event_names[from_slot - 1]
	# TODO: get event with from_slot
	_fsm.remove_transition(from, event)
#	if from != to:
#		disconnect_node(from, from_slot, to, to_slot)


func _on_StateNode_state_removed(state_node: VisualFSMStateNode) -> void:
	_fsm.remove_state(state_node.state_name)
	emit_signal("draw")


func _on_StateNode_rename_request(state_node: VisualFSMStateNode, new_name: String) -> void:
	if new_name.empty():
		printerr("ERROR: States must have names.")
		return
	if find_node(new_name, false):
		printerr("ERROR: The state " + new_name + " already exists.")
		return

	_fsm.rename_state(state_node.state_name, new_name)


func _on_StateNode_new_event_request(node: VisualFSMStateNode) -> void:
	_state_node_creating_event = node
	_new_event_dialog.show()


func _on_Dialog_event_name_request(event_name: String) -> void:
	if not _fsm.has_event(event_name):
		_new_event_dialog.event_name = event_name
	else:
		printerr("ERROR: An event named \"" + event_name + "\" already exists.")
		_new_event_dialog.event_name = ""


func _on_Dialog_new_event_created(event: VisualFiniteStateMachineEvent) -> void:
	_fsm.add_event(event)
	_fsm.add_transition(_state_node_creating_event.state_name, event.name)
	_state_node_creating_event = null
	_new_event_dialog.hide()
