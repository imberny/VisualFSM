tool
extends EditorInspectorPlugin


func can_handle(object):
	return object is CustomResource


func parse_property(object, type, path, hint, hint_text, usage):
	# We will handle properties of type integer.
	if type == TYPE_INT:
		# Register *an instance* of the custom property editor that we'll define next.
#		add_property_editor(path, MyIntEditor.new())
		# We return `true` to notify the inspector that we'll be handling
		# this integer property, so it doesn't need to parse other plugins
		# (including built-in ones) for an appropriate editor.
		return true
	else:
		return false
