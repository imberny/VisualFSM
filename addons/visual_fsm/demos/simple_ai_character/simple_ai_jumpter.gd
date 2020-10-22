class_name VisualFSMSimpleAIJumper
extends KinematicBody2D

export(float) var speed = 10
export(float) var jump_speed = 50
export(float) var gravity = 9.8

onready var _gap_raycast: RayCast2D= $GapDetector

var velocity: Vector2


func _ready() -> void:
	velocity = speed * Vector2.RIGHT


func _process(delta) -> void:
	velocity = move_and_slide(velocity, Vector2.UP)
	if not is_on_floor():
		velocity.y += gravity * delta


func jump() -> void:
	if is_on_floor():
		velocity.y -= jump_speed
