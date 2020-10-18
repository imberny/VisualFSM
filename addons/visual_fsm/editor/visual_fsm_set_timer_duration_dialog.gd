tool
extends AcceptDialog

onready var _duration_field := $Margins/Content/Margins/Display/Duration
onready var _duration_slider := $Margins/Content/DurationSlider

var _event: VisualFiniteStateMachineEventTimer

func open(event: VisualFiniteStateMachineEventTimer) -> void:
	_event = event
	_duration_field.text = str(event.duration)
	show()


func _on_Duration_text_changed(new_text: String) -> void:
	if new_text.ends_with("."):
		return
	var new_duration = float(new_text)
	_duration_slider.value = new_duration


func _on_DurationSlider_value_changed(value) -> void:
	var caret_pos = _duration_field.caret_position
	_duration_field.text = str(_duration_slider.value)
	if value == 0:
		caret_pos = 1
	_duration_field.caret_position = caret_pos


func _on_confirmed():
	_event.duration = _duration_slider.value
