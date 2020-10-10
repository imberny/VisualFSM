tool
extends GraphEdit


var _fsm: VisualFiniteStateMachine
var _popup_options: = ["New state", "New transition"]
var _popup: PopupMenu


func _ready() -> void:
	connect("popup_request", self, "_on_popup_request")
	
	_popup = PopupMenu.new()
	_popup.connect("index_pressed", self, "_on_popup_index_pressed")
	_popup.connect("focus_exited", _popup, "hide")
	for opt in _popup_options:
		_popup.add_item(opt)
	add_child(_popup)


func edit(fsm: VisualFiniteStateMachine) -> void:
	if _fsm:
		_fsm.disconnect("changed", self, "_on_fsm_changed")
	_fsm = fsm
	_fsm.connect("changed", self, "_on_fsm_changed")
	_redraw_graph()
	# open resource
	# for each node:
		# create node at position
	# for each transition:
		# add connection between nodes

func _on_fsm_changed():
	_redraw_graph()


func _redraw_graph():
	print("Redrawing fsm graph.............")
	# clear graph elements
	for child in get_children():
		if child is VisualFSMStateNode or child is VisualFSMTransitionNode:
			remove_child(child)
			child.queue_free()
	
	# add state nodes
	for state_name in _fsm.get_node_list():
		print("VisualFSMGraphEdit: adding state node: " + state_name)
		var node: VisualFiniteStateMachineState = _fsm.get_node(state_name)
		var position: Vector2 = _fsm.get_node_position(state_name)
		var state_graph_node = VisualFSMStateNode.new()
		state_graph_node.name = state_name
		state_graph_node.offset = position
		add_child(state_graph_node)
	
	# add transition nodes
	pass


#func _gui_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		var new_state := FSMGraphState.new()
#		print("adding new state")
#		add_child(new_state)


func _on_popup_request(position: Vector2) -> void:
	_popup.set_position(position)
	_popup.show()


func _on_popup_index_pressed(index: int) -> void:
	match index:
		0: 
			print("adding new state...")
			var mouse_pos: Vector2 = get_parent().get_local_mouse_position()
#			var new_pos := mouse_pos - new_state.rect_size / 2 #Vector2(mouse_pos.x + new_state.rect_size.x / 2, mouse_pos.y - new_state.rect_size.y / 2)
			var base_name := "test"
			var state_name := base_name
			var suffix := 1
			while _fsm.has_state(state_name):
				state_name = base_name + str(suffix)
				suffix += 1
			_fsm.add_node(state_name, mouse_pos, VisualFiniteStateMachineState.new())
#			var new_state := VisualFSMStateNode.new()
#			add_child(new_state)
			# center state on mouse
#			new_state.offset = new_pos
		1:
			print("adding new transition...")

