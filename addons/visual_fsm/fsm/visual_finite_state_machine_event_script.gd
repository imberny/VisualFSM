class_name VisualFiniteStateMachineEventScript
extends VisualFiniteStateMachineEvent

export(Script) var custom_script: Script


func enter() -> void:
	custom_script.enter()


func is_triggered(delta: float, object, params) -> bool:
	return custom_script.is_triggered(delta, object, params)
