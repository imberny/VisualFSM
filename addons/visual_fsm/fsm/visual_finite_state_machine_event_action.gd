class_name VisualFiniteStateMachineEventAction
extends VisualFiniteStateMachineEvent

export(String) var action_name: String


func is_trigger_action(input: InputEvent) -> bool:
	return input.is_action(action_name)


# add down, released, duration held...
