tool
extends EditorPlugin

#const custom_browser_type_name := "CustomResourceBrowserEditor"
var plugin = preload("controls/CustomResourceEditor.gd").new()
#var custom_resource_script = preload("CustomResource.gd")

func _enter_tree():
#	add_custom_type("CustomResource", "Resource", )
	add_inspector_plugin(plugin)
#	add_custom_type(custom_browser_type_name, "Control", custom_browser_type, preload("icon.png"))
	pass


func _exit_tree():
	remove_inspector_plugin(plugin)
	pass
