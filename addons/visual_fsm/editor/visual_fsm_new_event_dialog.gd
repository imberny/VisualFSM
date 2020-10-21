tool
extends ConfirmationDialog

signal new_event_created(event)
signal event_name_request(name)

export(Texture) var script_icon

var event_name: String setget _set_event_name, _get_event_name

onready var _event_name := $Margins/Content/EventName
onready var _name_status := $Margins/Content/Prompt/Margin/VBox/Name

var _context: GDScriptFunctionState


func _ready() -> void:
	get_ok().text = "Create event"
	get_cancel().connect("pressed", self, "_on_canceled")
	_validate()


func show() -> void:
	self.event_name = ""
	.show()
	_event_name.grab_focus()


func try_create(context: GDScriptFunctionState) -> void:
	if _context:
		_context.resume(false)
	_context = context
	show()


func close() -> void:
	self.event_name = ""
	_context = null
	hide()


func deny_name_request(name: String) -> void:
	_name_status.text = "An event with this name already exists."
	_name_status.add_color_override("font_color", Color.red)


func approve_name_request(name: String) -> void:
	self.state_name = name


func _unhandled_input(event: InputEvent) -> void:
	if not _context:
		return

	if event is InputEventKey and event.scancode == KEY_ENTER and not get_ok().disabled:
		emit_signal("confirmed")
		hide()


func _set_event_name(value: String) -> void:
	var caret_pos = _event_name.caret_position
	_event_name.text = value
	_event_name.caret_position = caret_pos
	_validate()


func _get_event_name() -> String:
	return _event_name.text


func _validate() -> void:
	var ok_button = get_ok()
	var invalid_event_name: bool = self.event_name.empty()
	if invalid_event_name:
		_name_status.text = "Event must have a name."
		_name_status.add_color_override("font_color", Color.red)
	else:
		_name_status.text = "Event name is available."
		_name_status.add_color_override("font_color", Color.green)

	ok_button.disabled = invalid_event_name


func _on_about_to_show() -> void:
	_event_name.grab_focus()


func _on_confirmed() -> void:
	_context.resume(true)
	close()


func _on_canceled() -> void:
	_context.resume(false)
	close()


func _on_EventName_text_changed(text: String) -> void:
	emit_signal("event_name_request", text)

