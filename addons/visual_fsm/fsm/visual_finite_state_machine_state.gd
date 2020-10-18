tool
class_name VisualFiniteStateMachineState
extends Resource

export(String) var name: String
export(Vector2) var position: Vector2
export(Script) var custom_script: Script


func enter() -> void:
	self.custom_script.enter()


func update(delta: float, object, params) -> void:
	self.custom_script.update(delta, object, params)


func exit() -> void:
	self.custom_script.exit()

