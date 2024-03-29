extends Node3D
var counter = 1
var direction
var gameovercontrol


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# calculates direction from bullet to player
	if counter == 1:
		direction = (GlobalVars.PlayerPos - position).normalized()
		counter = 0
	# Set the speed at which the bullet moves (adjust as needed)
	var speed = 30
	
	# Move the bullet towards the player
	position += direction * speed * delta
	position.y = 0
	
	
func _on_bullet_death_timeout():
	queue_free()


func _on_body_entered(body):
	if body.name == "Player":
		gameovercontrol.visible = true
	queue_free()
