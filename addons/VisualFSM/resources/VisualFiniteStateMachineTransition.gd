tool
class_name VisualFiniteStateMachineTransition
extends Resource

export(String) var from_state: String setget _set_from_state
export(String) var to_state: String setget _set_to_state

enum TransitionType {
	TYPE_A
	TYPE_B
	TYPE_C
}

export var transition_type = TransitionType.TYPE_A


func _set_from_state(value: String) -> void:
	from_state = value


func _set_to_state(value: String) -> void:
	to_state = value

