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
		node.state_name = state.name
		# center node on position
		node.offset = state.position - node.rect_size / 2
		add_child(node)

	# add transition nodes
	# for transition in _fsm.get_transition():
		# add_connection .... 

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
			_fsm.add_state(state_name, mouse_pos)
		1:
			print("adding new transition...")


func _on_VisualFSMGraphEdit_connection_request(
		from: String, from_slot: int, to: String, to_slot: int
	) -> void:
	if from.empty() or to.empty():
		printerr("ERROR: States must have names.")
		return
	if from != to:
#		_fsm.add_transition(from, from_slot, to, to_slot)
		connect_node(from, from_slot, to, to_slot)


func _on_VisualFSMGraphEdit_disconnection_request(from, from_slot, to, to_slot):
	if from != to:
		disconnect_node(from, from_slot, to, to_slot)

func _on_StateNode_state_removed(state_node: VisualFSMStateNode) -> void:
	for connection in get_connection_list():
		var from: String = connection.from
		var from_port: int = connection.from_port
		var to: String = connection.to
		var to_port: int = connection.to_port
		if from == state_node.name or to == state_node.name:
			disconnect_node(from, from_port, to, to_port)
			var from_node: VisualFSMStateNode = find_node(from, false)
			var to_node: VisualFSMStateNode = find_node(to, false)
			_fsm.remove_transition(from_node, to_node.state_name)

	emit_signal("draw")


func _on_StateNode_name_change(state_node: VisualFSMStateNode, new_name: String) -> void:
	if new_name.empty():
		printerr("ERROR: States must have names.")
		return
	if find_node(new_name, false):
		printerr("ERROR: The state " + new_name + " already exists.")
		return

	_fsm.rename_state(state_node.state_name, new_name)
	state_node.state_name = new_name


func _on_StateNode_new_event_request(node: VisualFSMStateNode) -> void:
	_state_node_creating_event = node
	_new_event_dialog.show()


func _on_Dialog_event_name_request(event_name: String) -> void:
	if not _events.has(event_name):
		_new_event_dialog.event_name = event_name
	else:
		printerr("ERROR: An event named \"" + event_name + "\" already exists.")
		_new_event_dialog.event_name = ""


func _on_Dialog_new_event_created(event: VisualFiniteStateMachineEvent) -> void:
	_events[event.event_name] = event
	_state_node_creating_event.add_event(event)
	_state_node_creating_event = null
	_new_event_dialog.hide()
