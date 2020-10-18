tool
extends GraphEdit

#onready var _state_base_script: Script = preload("../resources/visual_fsm_state_base.gd")
onready var _new_event_dialog: ConfirmationDialog = $"../DialogLayer/Dialog"

var _fsm_start_scene: PackedScene = preload("visual_fsm_start_node.tscn")
var _fsm_state_scene: PackedScene = preload("visual_fsm_state_node.tscn")
var _fsm: VisualFiniteStateMachine
var _popup_options := ["New state", "New transition", "save", "load"]
var _popup: PopupMenu
var _events := {}
var _state_node_creating_event: VisualFSMStateNode
var _state_custom_script_template: String


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

	var state_template_path = "res://addons/visual_fsm/resources/state_template.txt"
	var f = File.new()
	var err = f.open(state_template_path, File.READ)
	if err != OK:
		printerr("Could not open file \"%s\", error code: %s" % [state_template_path, err])
		return
	var _state_custom_script_template = f.get_as_text()
	f.close()

	edit(VisualFiniteStateMachine.new())


func edit(fsm: VisualFiniteStateMachine) -> void:
	if _fsm:
		_fsm.disconnect("changed", self, "_on_fsm_changed")
	_fsm = fsm
	if _fsm:
		_fsm.connect("changed", self, "_on_fsm_changed")
	_redraw_graph()


func _on_fsm_changed():
	_redraw_graph()


func _redraw_graph():
	print_debug("Redrawing fsm graph.............")
	clear_connections()
	# clear graph elements
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()

	if not _fsm:
		return

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
		node.state = state
		state.custom_script.reload()
		add_child(node)

	# add event slots
	for transition in _fsm.get_transitions():
		var from_node: VisualFSMStateNode
		var to_node: VisualFSMStateNode
		for child in get_children():
			if child is VisualFSMStateNode:
				if child.state.name == transition.from:
					from_node = child
				if child.state.name == transition.to:
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

	# add start node
	var start_node = _fsm_start_scene.instance()
	start_node.name = "VisualFSMStartNode"
	start_node.offset = _fsm.start_position
	add_child(start_node)

	# add start connection
	if not _fsm.start_target.empty():
		for child in get_children():
			if child is VisualFSMStateNode:
				if _fsm.start_target == child.state.name:
					connect_node(start_node.name, 0, child.name, 0)


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
			
##			var custom_script: VisualFSMStateBase = _state_base_script.new()
#			_state_base_script.source_code = _state_custom_script_template
			var my_script = GDScript.new()
			my_script.source_code = """
extends VisualFSMStateBase

func enter():
	pass

func update(delta: float, object, params):
	pass

func exit():
	pass
"""
			my_script.reload()
			state.custom_script = my_script
#			state.custom_script.reload()
			_fsm.add_state(state)
		1:
			print_debug("adding new transition...")


func _on_connection_request(
		from: String, from_slot: int, to: String, to_slot: int
	) -> void:
	if from.empty() or to.empty():
		printerr("VisualFSM States must have names.")
		return
	
	var from_node: GraphNode = get_node(from)
	var to_node: VisualFSMStateNode = get_node(to)
	if from_node is VisualFSMStateNode:
		var event_names := _fsm.get_state_event_names(from_node.state.name)
		var event: String = event_names[from_slot]
		_fsm.add_transition(from_node.state.name, event, to_node.state.name)
	else: # start node connection
		_fsm.start_target = to_node.state.name


func _on_disconnection_request(from, from_slot, to, to_slot):
	# cheap way to prevent weird connection lines when button held
	while Input.is_mouse_button_pressed(BUTTON_LEFT):
		yield(get_tree(), "idle_frame")
	# may have been removed during redraw. If so do nothing
	if not has_node(from) or not has_node(to):
		return
	
	var from_node: GraphNode = get_node(from)
	var to_node: VisualFSMStateNode = get_node(to)
	
	if from_node is VisualFSMStateNode:
		var event_names := _fsm.get_state_event_names(from_node.state.name)
		var event: String = event_names[from_slot]
		_fsm.remove_transition(from_node.state.name, event)
	else: # start node connection
		# start_target may have been reconnected during yield
		if _fsm.start_target == to_node.state.name:
			_fsm.start_target = ""


func _on_StateNode_state_removed(state_node: VisualFSMStateNode) -> void:
	_fsm.remove_state(state_node.state.name)
#	emit_signal("draw")


func _on_StateNode_rename_request(
	state_node: VisualFSMStateNode, new_name: String) -> void:
	var old_name := state_node.state.name
	var request_denied = false
	if new_name.empty():
		printerr("VisualFSM: States must have names.")
		request_denied = true
	if _fsm.has_state(new_name):
		printerr("VisualFSM: A state named \"%s\" already exists." % new_name)
		request_denied = true
	if "Start" == new_name:
		printerr("VisualFSM: The name \"Start\" is reserved." % new_name)
		request_denied = true

	if request_denied:
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
	_fsm.add_transition(_state_node_creating_event.state.name, event.name)
	_state_node_creating_event = null
	_new_event_dialog.hide()


func _on_end_node_move():
	for child in get_children():
		if child is VisualFSMStateNode:
			var state := _fsm.get_state(child.state.name)
			state.position = child.offset
		elif child is GraphNode and child.name == "VisualFSMStartNode":
			_fsm.start_position = child.offset
