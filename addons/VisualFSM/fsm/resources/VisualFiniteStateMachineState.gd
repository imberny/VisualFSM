extends Resource
class_name VisualFiniteStateMachineState

var name: String
var position: Vector2

func _init(name_):
	name = name_

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
