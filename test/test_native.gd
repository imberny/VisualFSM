extends Node2D

onready var data = preload("res://simple.gdns").new()

func _on_Button_pressed():
	$Label.text = "Data = " + data.get_data()
