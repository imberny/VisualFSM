tool
class_name VisualFiniteStateMachineState
extends Resource

export(String) var name: String
export(Vector2) var position: Vector2
export(GDScript) var custom_script: GDScript setget _set_custom_script

var custom_script_instance: VisualFSMStateBase


func enter() -> void:
	custom_script_instance.enter()


func update(delta: float, object, params) -> void:
	custom_script_instance.update(delta, object, params)


func exit() -> void:
	custom_script_instance.exit()


func _set_custom_script(value: GDScript) -> void:
	custom_script = value
	custom_script.reload()
	custom_script_instance = custom_script.new() as VisualFSMStateBase
	assert(custom_script_instance, "VisualFSM: Script in state \"%s\" must extend VisualFSMStateBase" % self.name)
	custom_script_instance.name = name
