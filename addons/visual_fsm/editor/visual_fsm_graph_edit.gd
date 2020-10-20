tool
extends GraphEdit

const STATE_TEMPLATE_PATH := "res://addons/visual_fsm/resources/state_template.txt"
const EVENT_TEMPLATE_PATH := "res://addons/visual_fsm/resources/event_template.txt"

onready var _new_event_dialog := $"../DialogLayer/Dialog"
onready var _new_state_dialog := $"../DialogLayer/NewStateDialog"

var _fsm_start_scene: PackedScene = preload("visual_fsm_start_node.tscn")
var _fsm_state_scene: PackedScene = preload("visual_fsm_state_node.tscn")
var _fsm: VisualFiniteStateMachine
var _events := {}
var _state_node_creating_event: VisualFSMStateNode
var _state_custom_script_template: String
var _event_custom_script_template: String


func _read_from_file(path: String) -> String:
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file \"%s\", error code: %s" % [path, err])
		return ""
	var content = f.get_as_text()
	f.close()
	return content


func _ready() -> void:
	add_valid_left_disconnect_type(0)

	_new_event_dialog.rect_position = get_viewport_rect().size / 2 - _new_event_dialog.rect_size / 2

	_state_custom_script_template = _read_from_file(STATE_TEMPLATE_PATH)
	_event_custom_script_template = _read_from_file(EVENT_TEMPLATE_PATH)

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
#	print_debug("Redrawing fsm graph.............")
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
		var node: VisualFSMStateNode = _fsm_state_scene.instance()
		add_child(node)
		node.connect("state_removed", self, "_on_StateNode_state_removed")
		node.connect(
			"new_script_request", self, "_on_StateNode_new_script_request")
		node.fsm = _fsm
		node.state = state
#		state.custom_script.reload()

	# add event slots
	for transition in _fsm.get_timer_transitions():
		var from_node: VisualFSMStateNode
		var to_node: VisualFSMStateNode
		for child in get_children():
			if child is VisualFSMStateNode:
				if child.state.name == transition.from:
					from_node = child
				if child.state.name == transition.to:
					to_node = child
		var state_event_names: Array = _fsm.get_state_timer_event_names(transition.from)
		var event := _fsm.get_timer_event(transition.event)
		from_node.add_event(event)
		var event_index := 0
		while state_event_names[event_index] != transition.event:
			event_index += 1
		if from_node and to_node:
			connect_node(from_node.name, event_index, to_node.name, 0)
	
	for transition in _fsm.get_action_transitions():
		var from_node: VisualFSMStateNode
		var to_node: VisualFSMStateNode
		for child in get_children():
			if child is VisualFSMStateNode:
				if child.state.name == transition.from:
					from_node = child
				if child.state.name == transition.to:
					to_node = child
		var state_event_names: Array = _fsm.get_state_action_event_names(transition.from)
		var event := _fsm.get_action_event(transition.event)
		from_node.add_event(event)
		var event_index := 0
		while state_event_names[event_index] != transition.event:
			event_index += 1
		if from_node and to_node:
			connect_node(from_node.name, event_index, to_node.name, 0)

	for transition in _fsm.get_script_transitions():
		var from_node: VisualFSMStateNode
		var to_node: VisualFSMStateNode
		for child in get_children():
			if child is VisualFSMStateNode:
				if child.state.name == transition.from:
					from_node = child
				if child.state.name == transition.to:
					to_node = child
		var state_event_names: Array = _fsm.get_state_script_event_names(transition.from)
		var event := _fsm.get_script_event(transition.event)
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


#func _on_popup_request(position: Vector2) -> void:
#	_popup.set_position(position)
#	_popup.show()
#	_popup.grab_focus()


func _on_popup_index_pressed(index: int) -> void:
	match index:
		0:
			
			var base_name := "State"
			var state_name := base_name
			var suffix := 1
			while _fsm.has_state(state_name):
				state_name = base_name + str(suffix)
				suffix += 1
			
			


func _try_create_new_state(from: String, from_slot: int, position: Vector2) -> void:
	if not yield():
		return

	var state := VisualFiniteStateMachineState.new()
	state.name = _new_state_dialog.state_name
	state.position = position - Vector2(115, 40)
			
	var custom_script = GDScript.new()
	custom_script.source_code = _state_custom_script_template % state.name
	custom_script.reload(true)
	state.custom_script = custom_script

	var from_node: GraphNode = get_node(from)
	print_debug("Adding state %s" % state.name)
	_fsm.add_state(state)
	if from_node is VisualFSMStateNode:
		var event_name = _fsm.get_event_names()[from_slot]
		_fsm.add_transition(from_node.state.name, event_name, state.name)
	else: # start node
		_fsm.start_target = state.name


func _on_connection_to_empty(from: String, from_slot: int, release_position: Vector2):
	var mouse_pos: Vector2 = get_parent().get_global_mouse_position()
	_new_state_dialog.rect_position = mouse_pos - _new_state_dialog.rect_size / 2
	_new_state_dialog.try_create(_try_create_new_state(from, from_slot, release_position))
	_new_state_dialog.show()


func _on_connection_request(
		from: String, from_slot: int, to: String, to_slot: int
	) -> void:
	if from.empty() or to.empty():
		printerr("VisualFSM States must have names.")
		return
	
	var from_node: GraphNode = get_node(from)
	var to_node: VisualFSMStateNode = get_node(to)
	if from_node is VisualFSMStateNode:
		var event_name := _fsm.get_state_event_name_from_index(from_node.state.name, from_slot)
		_fsm.add_transition(from_node.state.name, event_name, to_node.state.name)
	else: # start node connection
		_fsm.start_target = to_node.state.name


func _on_disconnection_request(from, from_slot, to, to_slot):
	# hacky way to prevent weird connection lines when button held
	while Input.is_mouse_button_pressed(BUTTON_LEFT):
		yield(get_tree(), "idle_frame")

	# may have been removed during redraw. If so do nothing
	if not has_node(from) or not has_node(to):
		return


	yield(get_tree(), "idle_frame")
	var from_node: GraphNode = get_node(from)
	var to_node: VisualFSMStateNode = get_node(to)
	
	if from_node is VisualFSMStateNode:
		var event_name = _fsm.get_state_event_name_from_index(from_node.state.name, from_slot)
		_fsm.remove_transition(from_node.state.name, event_name)
	else: # start node connection
		# start_target may have been reconnected during yield
		if _fsm.start_target == to_node.state.name:
			_fsm.start_target = ""


func _on_StateNode_state_removed(state_node: VisualFSMStateNode) -> void:
	_fsm.remove_state(state_node.state.name)


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

#	print_debug("Renaming from %s to %s" % [old_name, new_name])
	_fsm.rename_state(old_name, new_name)


func _on_end_node_move():
	for child in get_children():
		if child is VisualFSMStateNode:
			var state := _fsm.get_state(child.state.name)
			state.position = child.offset
		elif child is GraphNode and child.name == "VisualFSMStartNode":
			_fsm.start_position = child.offset


func _on_StateNode_new_script_request(node: VisualFSMStateNode) -> void:
	_state_node_creating_event = node
	_new_event_dialog.show()


func _on_Dialog_new_event_created(event: VisualFiniteStateMachineEvent) -> void:
	_fsm.add_event(event)
	_fsm.add_script_transition(_state_node_creating_event.state.name, event.name)
	_state_node_creating_event = null
	_new_event_dialog.hide()


func _on_Dialog_event_name_request(event_name: String) -> void:
	if not _fsm.has_script_event(event_name):
		_new_event_dialog.event_name = event_name
	else:
		_new_event_dialog.event_name = ""
		_new_event_dialog.name_request_denied(event_name)

func _on_StateCreateDialog_state_name_request(name: String) -> void:
	if not _fsm.has_state(name):
		_new_state_dialog.approve_name_request(name)
	else:
		_new_state_dialog.deny_name_request(name)
