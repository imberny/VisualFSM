tool
class_name VisualFiniteStateMachineState
extends Resource

export(int) var id: int
export(String) var name: String
export(Vector2) var position: Vector2
export(Array) var event_ids: Array
export(GDScript) var custom_script: GDScript setget _set_custom_script

var custom_script_instance: VisualFSMStateBase


func has_event(id: int) -> bool:
	return event_ids.find(id) > 0


func add_event(event: VisualFiniteStateMachineEvent) -> void:
	event_ids.push_back(event.id)
	_changed()


func remove_event(event: VisualFiniteStateMachineEvent) -> void:
	event_ids.erase(event.id)
	_changed()


func get_event_id_from_index(index: int) -> int:
	return event_ids[index]


func get_event_index(event: VisualFiniteStateMachineEvent) -> int:
	for i in range(len(event_ids)):
		if event.id == event_ids[i]:
			return i
	return -1


func enter() -> void:
	custom_script_instance.enter()


func update(object, delta: float) -> void:
	custom_script_instance.update(object, delta)


func exit() -> void:
	custom_script_instance.exit()


func _set_custom_script(value: GDScript) -> void:
	custom_script = value
	custom_script.reload(true)
	custom_script.connect("script_changed", self, "_init_script")
	_init_script()


func _init_script() -> void:
	custom_script_instance = self.custom_script.new() as VisualFSMStateBase
	assert(custom_script_instance, "VisualFSM: Script in state \"%s\" must extend VisualFSMStateBase" % self.name)
	custom_script_instance.name = self.name


func _changed() -> void:
	call_deferred("emit_signal", "changed")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if custom_script_instance:
			custom_script_instance.free()
