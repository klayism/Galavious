extends Node3D
@export var speed = 30
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= 1 * delta * speed
	position.y = 0


func _on_bullet_death_timeout():
	queue_free()

func _on_body_entered(body):
	if body.name == "LeftWall" or body.name=="RightWall":
		pass
	else:
		GlobalVars.target_hit.emit()
		body.position = Vector3(1000000,1000000,1000000)
		GlobalVars.score += 5
		body.queue_free()
		GlobalVars.enemyCount -= 1
		GlobalVars.killedEnemys += 1
		self.queue_free()
