extends Area3D

var ball = null
var ball_spawn_point = Vector3.ZERO

# Timer node reference
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_body_entered(body):
	# Check if the body is the ball
	if body.name == "ball":
		
		ball = body
		ball_spawn_point = ball.global_transform.origin
		# Start the timer
		timer.start()
		print("goal!")

func _on_timer_timeout():
	if ball:
		ball.global_transform.origin = ball_spawn_point
		# Optionally reset velocity if it's a RigidBody3D
	if ball is RigidBody3D:
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO 
