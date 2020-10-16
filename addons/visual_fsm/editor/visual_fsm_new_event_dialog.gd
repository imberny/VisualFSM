tool
extends AcceptDialog

signal new_event_created(event)
signal event_name_request(name)

const EVENT_TYPE_TITLE = "Event type"
const EVENT_TYPES = [
	"Input action",
	"Timeout",
	"Script"
]

var event_name: String setget _set_event_name, _get_event_name
var event_type: String setget _set_event_type, _get_event_type


func _ready() -> void:
	$EventProperties/EventName.connect(
		"text_entered", self, "_on_EventName_text_entered")
	$EventProperties/EventType.text = EVENT_TYPE_TITLE
	for event_type in EVENT_TYPES:
		$EventProperties/EventType.get_popup().add_item(event_type)
	$EventProperties/EventType.get_popup().connect(
		"index_pressed", self, "_on_EventType_pressed")
	_validate()
	show()
	$EventProperties/EventName.grab_focus()


func _set_event_name(value) -> void:
	$EventProperties/EventName.text = value
	_validate()


func _get_event_name() -> String:
	return $EventProperties/EventName.text


func _set_event_type(value) -> void:
	$EventProperties/EventType.text = value
	_validate()


func _get_event_type() -> String:
	return $EventProperties/EventType.text


func _validate():
	var ok_button = get_ok()
	var invalid_event_name: bool = self.event_name.empty()
	var invalid_event_type: bool = self.event_type == EVENT_TYPE_TITLE
	ok_button.disabled = invalid_event_name or invalid_event_type


func _on_VisualFSMNewEventDialog_confirmed() -> void:
	var event = VisualFiniteStateMachineEvent.new()
	event.name = self.event_name
#	event.event_type = 
	emit_signal("new_event_created", event)
	self.event_name = ""
	self.event_type = EVENT_TYPE_TITLE


func _on_EventName_text_entered(text: String) -> void:
	emit_signal("event_name_request", text)


func _on_EventType_pressed(index: int) -> void:
	self.event_type = EVENT_TYPES[index]
