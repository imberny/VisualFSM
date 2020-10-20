extends Node2D


var current_state_name: String setget _set_current_state_name


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


func _set_current_state_name(value) -> void:
	$StateContainer/State.text = value

