tool
extends EditorPlugin

const CONTROL_LABEL := "Finite State Machine"

var fsm_control: Control
var tool_button: ToolButton
var fsm_script := preload("visual_fsm.gd")
var fsm_type_name := "VisualFSM"


func _enter_tree():
	print("Installing VisualFSM plugin")
	add_custom_type(fsm_type_name, "Node", fsm_script, preload("icon.png"))
	yield(get_tree(), "idle_frame")
	fsm_control = preload("editor/visual_fsm_editor.tscn").instance()
	tool_button = add_control_to_bottom_panel(fsm_control, CONTROL_LABEL)
	tool_button.hide()
	var selected_nodes := get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() > 0:
		make_visible(handles(selected_nodes[0]))


func _exit_tree():
	print("Uninstalling VisualFSM plugin")
	remove_custom_type(fsm_type_name)
	remove_control_from_bottom_panel(fsm_control)
	# using queue_free causes memory leaks. Bug?
	fsm_control.free()


func make_visible(visible):
	if visible:
		tool_button.show()
		make_bottom_panel_item_visible(fsm_control)
		fsm_control.set_process(true)
	else:
		if fsm_control.visible:
			hide_bottom_panel()
		tool_button.hide()
		fsm_control.set_process(false)


func handles(object) -> bool:
	return object is VisualFiniteStateMachine


func edit(object) -> void:
	fsm_control.edit(object)
