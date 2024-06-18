extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	# Check if the body is the ball
	if body.name == "ball":
		print("The ball has entered the area!")


func _on_body_exited(body):
	if body.name == "ball":
		print("The ball has left the area!")
