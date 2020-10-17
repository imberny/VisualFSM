tool
extends ConfirmationDialog

signal new_event_created(event)
signal event_name_request(name)

export(Texture) var timer_icon
export(Texture) var action_icon
export(Texture) var script_icon

const EVENT_TYPE_TITLE = "Event type"
const EVENT_TYPE_ACTION = "Input action"
const EVENT_TYPE_TIMEOUT = "Timer timeout"
const EVENT_TYPE_SCRIPT = "Custom script"

var event_name: String setget _set_event_name, _get_event_name
var event_type: String setget _set_event_type, _get_event_type

onready var _event_name := $Margins/Content/EventName
onready var _event_type := $Margins/Content/EventType
onready var _name_status := $Margins/Content/Prompt/Margin/VBox/Name
onready var _type_status := $Margins/Content/Prompt/Margin/VBox/Type


func _ready() -> void:
	connect("about_to_show", self, "_on_about_to_show")
	_event_name.connect("text_changed", self, "_on_EventName_text_changed")
	_event_type.text = EVENT_TYPE_TITLE
	_event_type.get_popup().clear()
	_event_type.get_popup().add_icon_item(action_icon, EVENT_TYPE_ACTION)
	_event_type.get_popup().add_icon_item(timer_icon, EVENT_TYPE_TIMEOUT)
	_event_type.get_popup().add_icon_item(script_icon, EVENT_TYPE_SCRIPT)
	_event_type.get_popup().connect(
		"index_pressed", self, "_on_EventType_pressed")
	get_ok().text = "Create event"
	get_cancel().connect("pressed", self, "close")
	_validate()


func _set_event_name(value: String) -> void:
	var caret_pos = _event_name.caret_position
	_event_name.text = value
	_event_name.caret_position = caret_pos
	_validate()


func _get_event_name() -> String:
	return _event_name.text


func _set_event_type(value) -> void:
	_event_type.text = value
	_validate()


func _get_event_type() -> String:
	return _event_type.text


func close() -> void:
	self.event_name = ""
	self.event_type = EVENT_TYPE_TITLE
	hide()


func name_request_denied(name: String) -> void:
	_name_status.text = "An event with the name \"%s\" already exists." % name
	_name_status.add_color_override("font_color", Color.red)


func _validate() -> void:
	var ok_button = get_ok()
	var invalid_event_name: bool = self.event_name.empty()
	var invalid_event_type: bool = self.event_type == EVENT_TYPE_TITLE
	var invalid := invalid_event_name or invalid_event_type
	if invalid_event_name:
		_name_status.text = "Event name must not be empty."
		_name_status.add_color_override("font_color", Color.red)
	else:
		_name_status.text = "Event name is OK."
		_name_status.add_color_override("font_color", Color.green)

	if invalid_event_type:
		_type_status.text = "Must select an event type from the dropdown."
		_type_status.add_color_override("font_color", Color.red)
	else:
		_type_status.text = "Event type is OK."
		_type_status.add_color_override("font_color", Color.green)
	
	ok_button.disabled = invalid


func _on_about_to_show() -> void:
	self.grab_focus()
	_event_name.grab_focus()


func _on_confirmed() -> void:
	var event: VisualFiniteStateMachineEvent
	match _event_type.text:
		EVENT_TYPE_ACTION:
			event = VisualFiniteStateMachineEventAction.new()
		EVENT_TYPE_TIMEOUT:
			event = VisualFiniteStateMachineEventTimer.new()
		EVENT_TYPE_SCRIPT:
			event = VisualFiniteStateMachineEventScript.new()
	event.name = self.event_name
	emit_signal("new_event_created", event)
	close()


func _on_EventName_text_changed(text: String) -> void:
	emit_signal("event_name_request", text)


func _on_EventType_pressed(index: int) -> void:
	match index:
		0:
			self.event_type = EVENT_TYPE_ACTION
		1:
			self.event_type = EVENT_TYPE_TIMEOUT
		2:
			self.event_type = EVENT_TYPE_SCRIPT

