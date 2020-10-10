extends Resource
class_name VisualFiniteStateMachineState

#export(String) var name
#export(Vector2) var position


#func _get(property):
#	match property:
#		"name":
#			return _name
#		"position":
#			return _position
#	return null
#
#func _set(property: String, value):
#	match property:
#		"name":
#			_name = value
#			return true
#		"position":
#			_position = value
#			return true
#	return false

#func _get_property_list():
#	return [
#		{
#			"name": "name", 
#			"type": TYPE_STRING,
#			"usage": PROPERTY_USAGE_NOEDITOR
#		},
#		{
#			"name": "position", 
#			"type": TYPE_VECTOR2, 
#			"usage": PROPERTY_USAGE_NOEDITOR
#		}
#	] 
