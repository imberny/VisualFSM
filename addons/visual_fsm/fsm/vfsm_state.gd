tool
class_name VFSMState
extends Resource

export(int) var vfsm_id: int
export(String) var name: String
export(Vector2) var position: Vector2
export(Array) var trigger_ids: Array
export(GDScript) var custom_script: GDScript setget _set_custom_script

const STATE_TEMPLATE_PATH := "res://addons/visual_fsm/resources/state_template.txt"
const SCRIPT_FIRST_LINE_TEMPLATE = "# State: %s\n"

var _state_custom_script_template: String
var custom_script_instance: VFSMStateBase


func _read_from_file(path: String) -> String:
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		push_warning("Could not open file \"%s\", error code: %s" % [path, err])
		return ""
	var content = f.get_as_text()
	f.close()
	return content


func _init():
	_state_custom_script_template = _read_from_file(STATE_TEMPLATE_PATH)

func has_trigger(vfsm_id: int) -> bool:
	return trigger_ids.find(vfsm_id) > -1


func add_trigger(trigger: VFSMTrigger) -> void:
	trigger_ids.push_back(trigger.vfsm_id)
	_changed()


func remove_trigger(trigger: VFSMTrigger) -> void:
	trigger_ids.erase(trigger.vfsm_id)
	_changed()


func get_trigger_id_from_index(index: int) -> int:
	return trigger_ids[index]


func get_trigger_index(trigger: VFSMTrigger) -> int:
	for i in range(len(trigger_ids)):
		if trigger.vfsm_id == trigger_ids[i]:
			return i
	return -1


func enter() -> void:
	custom_script_instance.enter()


func update(object, delta: float) -> void:
	custom_script_instance.update(object, delta)


func exit() -> void:
	custom_script_instance.exit()


func rename(new_name: String) -> void:
	var old_name = self.name
	self.name = new_name


func new_script() -> void:
	assert(not self.name.empty())
	var custom_script := GDScript.new()
	custom_script.source_code = (SCRIPT_FIRST_LINE_TEMPLATE % self.name) + _state_custom_script_template
	self.custom_script = custom_script


func _set_custom_script(value: GDScript) -> void:
	custom_script = value
	custom_script.reload(true)
	custom_script.connect("script_changed", self, "_init_script")
	_init_script()


func _init_script() -> void:
	custom_script_instance = self.custom_script.new() as VFSMStateBase
	assert(custom_script_instance, "VisualFSM: Script in state \"%s\" must extend VFSMStateBase" % self.name)
	custom_script_instance.name = self.name


func _changed() -> void:
	call_deferred("emit_signal", "changed")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if custom_script_instance:
			custom_script_instance.free()
