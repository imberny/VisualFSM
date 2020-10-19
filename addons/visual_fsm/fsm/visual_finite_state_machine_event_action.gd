class_name VisualFiniteStateMachineEventAction
extends VisualFiniteStateMachineEvent

export(String) var action_name: String


func is_triggered(_delta: float, _object, params) -> bool:
	var actions = params.actions
	return action_name in actions
