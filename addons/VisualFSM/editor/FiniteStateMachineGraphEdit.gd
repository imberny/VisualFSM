tool
extends GraphEdit


var _fsm: VisualFiniteStateMachine
var _popup_options: = ["New state", "New transition"]
var _popup: PopupMenu


func edit(fsm: VisualFiniteStateMachine) -> void:
	fsm = fsm


func _ready() -> void:
	connect("popup_request", self, "_on_popup_request")
	
	_popup = PopupMenu.new()
	_popup.connect("index_pressed", self, "_on_popup_index_pressed")
	_popup.connect("focus_exited", _popup, "hide")
	for opt in _popup_options:
		_popup.add_item(opt)
	add_child(_popup)


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
			var new_state := VisualFSMState.new()
			print("adding new state")
			add_child(new_state)
			# center state on mouse
			var mouse_pos: Vector2 = get_parent().get_local_mouse_position()
			var new_pos := mouse_pos - new_state.rect_size / 2 #Vector2(mouse_pos.x + new_state.rect_size.x / 2, mouse_pos.y - new_state.rect_size.y / 2)
			new_state.offset = new_pos
		1:
			print("new transition...")
			
