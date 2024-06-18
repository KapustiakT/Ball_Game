extends RigidBody3D

# Reference to the player
var player = null
# Function to set the player reference
func set_player(player_ref):
	player = player_ref

func _process(_delta):
	# If the player is holding the ball, update the ball's position
	if player and player.is_holding_ball():
		global_transform.origin = player.get_hand_position()

