extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var my_resource: Resource = load("res://test/resource.gd").new()
	var my_resource2: Resource = load("res://test/resource.gd").new()
	my_resource.my_string = "Hello"
	my_resource2.my_string = "Goodbye"
	my_resource.set_meta("my_custom_var", 1)
	my_resource2.set_meta("my_custom_var", 2)
	print(my_resource.get_meta("my_custom_var"))
	print(my_resource2.get_meta("my_custom_var"))
	ResourceSaver.save("res://test/saved_resource.tres", my_resource)
	ResourceSaver.save("res://test/saved_resource2.tres", my_resource2)
	var my_loaded_resource = load("res://test/saved_resource.tres")
	var my_loaded_resource2 = load("res://test/saved_resource2.tres")
	print(my_loaded_resource.my_string)
	print(my_loaded_resource2.my_string)
	print(my_loaded_resource.get_meta("my_custom_var"))
	print(my_loaded_resource2.get_meta("my_custom_var"))
