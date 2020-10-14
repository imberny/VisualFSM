tool
extends EditorPlugin

const CONTROL_LABEL := "Finite State Machine"

var fsm_control: Control = preload("editor/VisualFSMEditor.tscn").instance()
var toolbutton: ToolButton
var fsm_script := preload("VisualFSM.gd")
var fsm_type_name := "VisualFSM"


func _enter_tree():
	print("Installing VisualFSM plugin")
	add_custom_type(fsm_type_name, "Node", fsm_script, preload("icon.png"))
	yield(get_tree(), "idle_frame")
	toolbutton = add_control_to_bottom_panel(fsm_control, CONTROL_LABEL)
	toolbutton.hide()
	var selected_nodes := get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() > 0:
		make_visible(handles(selected_nodes[0]))


func _exit_tree():
	print("Uninstalling VisualFSM plugin")
	remove_custom_type(fsm_type_name)
	remove_control_from_bottom_panel(fsm_control)
	if fsm_control:
		fsm_control.queue_free()


func make_visible(visible):
	if not fsm_control:
		return

	if visible:
		toolbutton.show()
		make_bottom_panel_item_visible(fsm_control)
		fsm_control.set_process(true)
	else:
		if fsm_control.visible:
			hide_bottom_panel()
		toolbutton.hide()
		fsm_control.set_process(false)


func handles(object) -> bool:
	return object is VisualFiniteStateMachine


func edit(object) -> void:
	var fsm: VisualFiniteStateMachine = object
	if not fsm:
		return

	fsm_control.edit(fsm as VisualFiniteStateMachine)
