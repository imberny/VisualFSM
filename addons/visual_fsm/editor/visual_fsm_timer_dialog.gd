tool
extends AcceptDialog

var duration: float

onready var _duration_field := $Margins/Content/Duration

var _timer_event: VisualFiniteStateMachineEventTimer


func open(event: VisualFiniteStateMachineEventTimer) -> void:
	_timer_event = event
	duration = event.duration
	show()
	_duration_field.text = str(duration)
	_duration_field.caret_position = len(_duration_field.text)
	_duration_field.grab_focus()


func _unhandled_input(event) -> void:
	if not _timer_event:
		return

	if event.is_action("ui_accept"):
		emit_signal("confirmed")
		hide()


func _on_Duration_text_changed(new_text: String) -> void:
	if new_text.ends_with('.'):
		return
	duration = max(0, float(new_text))
	var caret_position = _duration_field.caret_position
	if 0 == duration:
		_duration_field.text = ""
	else:
		_duration_field.text = str(duration)
		_duration_field.caret_position = caret_position


func _on_confirmed() -> void:
	if not _timer_event:
		return

	_timer_event.duration = float(_duration_field.text)
	_timer_event = null
