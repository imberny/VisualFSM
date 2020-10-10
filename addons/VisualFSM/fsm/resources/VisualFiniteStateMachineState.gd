extends Resource
class_name VisualFiniteStateMachineState

var _name: String
var _position: Vector2

#func _init(name, pos):
#	_name = name
#	_position = pos

func _get(property):
	match property:
		"name":
			return _name
		"position":
			return _position
	return null

func _set(property: String, value):
	match property:
		"name":
			_name = value
			return true
		"position":
			_position = value
			return true
	return false

func _get_property_list():
	return [
		{
			"name": "name", 
			"type": TYPE_STRING, 
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE
		}
	] 
