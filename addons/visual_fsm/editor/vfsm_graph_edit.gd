tool
extends GraphEdit

const STATE_TEMPLATE_PATH := "res://addons/visual_fsm/resources/state_template.txt"
const EVENT_TEMPLATE_PATH := "res://addons/visual_fsm/resources/event_template.txt"

onready var _new_event_dialog := $"../DialogLayer/NewScriptEventDialog"
onready var _new_state_dialog := $"../DialogLayer/NewStateDialog"
onready var _timer_duration_dialog := $"../DialogLayer/TimerDurationDialog"
onready var _input_action_dialog := $"../DialogLayer/InputActionDialog"

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
#	var hbox := get_zoom_hbox()
#	var event_dropdown := MenuButton.new()
#	event_dropdown.text = "ScriptEvents"
#	event_dropdown.flat = false
#	hbox.add_child(event_dropdown)
#	hbox.move_child(event_dropdown, 0)

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


func _find_state_node(state: VisualFiniteStateMachineState) -> VisualFSMStateNode:
	for child in get_children():
		if child is VisualFSMStateNode and child.state == state:
			return child
	return null


func _redraw_graph():
#	print_debug("Redrawing fsm graph.............")

	# clear dialogs
	_new_state_dialog.close()
	_timer_duration_dialog.close()
	_input_action_dialog.close()

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
		node.timer_duration_dialog = _timer_duration_dialog
		node.input_action_dialog = _input_action_dialog
		add_child(node)
		node.connect("state_removed", self, "_on_StateNode_state_removed")
		node.connect(
			"new_script_request", self, "_on_StateNode_new_script_request")
		node.fsm = _fsm
		node.state = state
		node.offset = state.position
		# add event slots
		for event in _fsm.get_events_in_state(state):
			node.add_event(event)

	# add connections
	for from_state in _fsm.get_states():
		var from_node := _find_state_node(from_state)
		for event in _fsm.get_events_in_state(from_state):
			var to_state := _fsm.get_to_state(from_state, event)
			if to_state:
				var to_node := _find_state_node(to_state)
				var from_port = from_state.get_event_index(event)
				assert(-1 < from_port, 
					"VisualFSM: Missing event \"%s\" in state \"%s\"" 
					% [event.name, from_state.name])
				connect_node(from_node.name, from_port, to_node.name, 0)

	# add start node
	var start_node = _fsm_start_scene.instance()
	start_node.name = "VisualFSMStartNode"
	start_node.offset = _fsm.start_position
	add_child(start_node)

	# add start connection
	var start_state := _fsm.get_start_state()
	if start_state:
		var start_state_node := _find_state_node(start_state)
		connect_node(start_node.name, 0, start_state_node.name, 0)


func _try_create_new_state(from: String, from_slot: int, position: Vector2) -> void:
	if not yield():
		return

	var state_name: String = _new_state_dialog.state_name
	var state_position := position - Vector2(0, 40)
	var from_node = get_node(from)
	assert(from_node, "Missing node in create new state")
	if from_node is VisualFSMStateNode:
		var from_state: VisualFiniteStateMachineState = from_node.state
		var from_event_id := from_state.get_event_id_from_index(from_slot)
		var from_event := _fsm.get_event(from_event_id)
		_fsm.create_state(state_name, state_position, from_state, from_event)
	else: # from start node
		_fsm.create_state(state_name, state_position)


func _on_connection_to_empty(from: String, from_slot: int, release_position: Vector2):
	var mouse_pos := get_global_mouse_position()
	_new_state_dialog.rect_position = mouse_pos - _new_state_dialog.rect_size / 2
	_new_state_dialog.open(_try_create_new_state(from, from_slot, release_position))


func _on_connection_request(
		from: String, from_slot: int, to: String, to_slot: int
	) -> void:
	if from.empty() or to.empty():
		printerr("VisualFSM States must have names.")
		return
	
	var from_node: GraphNode = get_node(from)
	assert(from_node, "Missing from node in connection request")
	var to_node: VisualFSMStateNode = get_node(to)
	assert(to_node, "Missing tonode in connection request")
	if from_node is VisualFSMStateNode:
		var event_id: int = from_node.state.get_event_id_from_index(from_slot)
		var event := _fsm.get_event(event_id)
		_fsm.add_transition(from_node.state, event, to_node.state)
	else: # start node connection
		_fsm.set_start_state(to_node.state)


func _on_disconnection_request(from, from_slot, to, to_slot):
	# hacky way to prevent weird connection lines when button held
	while Input.is_mouse_button_pressed(BUTTON_LEFT):
		yield(get_tree(), "idle_frame")

	yield(get_tree(), "idle_frame")
	# may have been removed during redraw. If so do nothing
	if not has_node(from) or not has_node(to):
		return

	var from_node: GraphNode = get_node(from)
	var to_node: VisualFSMStateNode = get_node(to)
	if from_node is VisualFSMStateNode:
		var event_id: int = from_node.state.get_event_id_from_index(from_slot)
		var event := _fsm.get_event(event_id)
		_fsm.remove_transition(from_node.state, event)
	else: # start node connection
		# start_target may have been reconnected during yield
		if _fsm.get_start_state().fsm_id == to_node.state.fsm_id:
			_fsm.set_start_state(null)


func _on_StateNode_state_removed(state_node: VisualFSMStateNode) -> void:
	_fsm.remove_state(state_node.state)
	_fsm.remove_state(state_node.state)


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
			var state := _fsm.get_state(child.state.fsm_id)
			state.position = child.offset
		elif child is GraphNode and child.name == "VisualFSMStartNode":
			_fsm.start_position = child.offset


func _try_create_new_script_event(state: VisualFiniteStateMachineState) -> void:
	if not yield():
		return

	var event_name: String = _new_event_dialog.event_name
	_fsm.create_script_event(state, event_name)


func _on_StateNode_new_script_request(node: VisualFSMStateNode) -> void:
	_new_event_dialog.try_create(_try_create_new_script_event(node.state))


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
