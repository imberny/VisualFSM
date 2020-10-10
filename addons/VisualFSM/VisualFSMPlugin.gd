tool
extends EditorPlugin


const label := "Finite State Machine"

var panel: Control = preload("editor/VisualFSMEditor.tscn").instance()
var singleton: VisualFSMSingleton = preload("editor/VisualFSMSingleton.gd").new()
var toolbutton: ToolButton
var fsm_script := preload("fsm/VisualFSM.gd")
var fsm_type_name := "VisualFSM"


func _enter_tree():
	print("Installing VisualFSM plugin")
	add_custom_type(fsm_type_name, "Node", fsm_script, preload("icon.png"))
	yield(get_tree(), "idle_frame")
	singleton.name = "VisualFSMSingleton"
	get_tree().root.add_child(singleton)
#	add_autoload_singleton("VisualFSMSingleton", "res://addons/VisualFSM/editor/VisualFSMSingleton.gd")
#	$"/root".add_child(singleton)
	toolbutton = add_control_to_bottom_panel(panel, label)
	toolbutton.hide()
	var selected_nodes := get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() > 0:
		make_visible(handles(selected_nodes[0]))


func _exit_tree():
	print("Uninstalling VisualFSM plugin")
#	remove_autoload_singleton("VisualFSMSingleton")
	$"/root".remove_child(singleton)
	remove_custom_type(fsm_type_name)
	remove_control_from_bottom_panel(panel)
	if panel:
		panel.queue_free()


func make_visible(visible):
	if not panel:
		return

	if visible:
		toolbutton.show();
		make_bottom_panel_item_visible(panel)
		panel.set_process(true)
	else:
		if panel.visible:
			hide_bottom_panel()
		toolbutton.hide();
		panel.set_process(false);


func handles(object) -> bool:
	return object is fsm_script


#func edit(object) -> void:
#	var fsm: VisualFiniteStateMachine = object.FiniteStateMachine
#	if not fsm:
#		return
#
#	print("Opening new VisualFiniteStateMachine with states: " + str(fsm.get_node_list().size()))
#	panel.edit(fsm as VisualFiniteStateMachine)
