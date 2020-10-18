extends Node2D


onready var _fsm := $VisualFSM


func _process(delta):
	_fsm.update(delta, null, null)
	$StateContainer/State.text = _fsm._current_state.name


func green():
	$TrafficLights/Green/Cover.visible = false
	$TrafficLights/Yellow/Cover.visible = true
	$TrafficLights/Red/Cover.visible = true


func yellow():
	$TrafficLights/Green/Cover.visible = true
	$TrafficLights/Yellow/Cover.visible = false
	$TrafficLights/Red/Cover.visible = true


func red():
	$TrafficLights/Green/Cover.visible = true
	$TrafficLights/Yellow/Cover.visible = true
	$TrafficLights/Red/Cover.visible = false
