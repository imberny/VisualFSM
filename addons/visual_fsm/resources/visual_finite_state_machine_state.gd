tool
class_name VisualFiniteStateMachineState
extends Resource

export(String) var name: String #setget _set_name
export(Vector2) var position: Vector2 #setget _set_position
# map of events to other states
#var internal_events := {} 

#func _set_name(value: String) -> void:
#	name = value
#
#
#func _set_position(value: Vector2) -> void:
#	position = value

#func _get(property: String):
#	var parts = property.split("/")
#
#	match parts[0]:
#		"name":
#			return _name
#		"position":
#			return _position
#	return null
#
#
#func _set(property: String, value) -> bool:
#	var parts = property.split("/")
#
#	match parts[0]:
#		"name":
#			_name = value
#			return true
#		"position":
#			_position = value
#			return true
#	return false
#
#
#func _get_property_list() -> Array:
#	var property_list := []
#	property_list += [
#		{
#			"name": "name",
#			"type": TYPE_STRING,
#			"hint": PROPERTY_HINT_NONE,
#			"hint_string": "",
#			"usage": PROPERTY_USAGE_NOEDITOR
#		},
#		{
#			"name": "position",
#			"type": TYPE_VECTOR2,
#			"hint": PROPERTY_HINT_NONE,
#			"hint_string": "",
#			"usage": PROPERTY_USAGE_NOEDITOR
#		}
#	]
##	for event in _events.keys():
##		property_list += [
##			{
##				"name": "events/" + event,
##				"type": TYPE_OBJECT,
##				"hint": PROPERTY_HINT_RESOURCE_TYPE,
##				"hint_string": "VisualFiniteStateMachineEvent",
##				"usage": PROPERTY_USAGE_NOEDITOR
##			}
##		]
#	return property_list
