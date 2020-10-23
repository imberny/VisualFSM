class_name VFSMSimpleAIJumper
extends KinematicBody2D

export(float) var speed = 10
export(float) var jump_speed = 50
export(float) var gravity = 9.8

onready var gap_raycast: RayCast2D= $GapDetector

var _velocity: Vector2


func move_x(dir: float) -> void:
	_velocity.x = clamp(dir, -1, 1)

func _ready() -> void:
	_velocity = Vector2()


func _process(delta) -> void:
	_velocity = move_and_slide(_velocity, Vector2.UP)
	
	if not is_on_floor():
		_velocity.y += gravity * delta


func jump() -> void:
	if is_on_floor():
		_velocity.y -= jump_speed
