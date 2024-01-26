extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 30
@export var dash_speed = 30  # Speed for dashing
var is_dashing = false
var dash_direction = Vector3.ZERO
var CurrentDirection = null
@onready
var ship = $GalagaShip
var dashcooldownover = true

func _physics_process(delta):
	velocity = Vector3.ZERO
	if is_dashing:
		if CurrentDirection == "right":
			velocity.z += -1 * dash_speed
		if CurrentDirection == "left":
			velocity.z += 1 * dash_speed 
			#$GalagaShip.rotate_x(.1)
		if CurrentDirection == "down":
			velocity.x += 1 * dash_speed 
		if CurrentDirection == "up":
			velocity.x += -1 * dash_speed 
		move_and_collide(velocity*delta)

	#checks inputed directional button
	if not is_dashing:
		if $DashCooldown.is_stopped():
			if Input.is_action_just_pressed("dash") and not is_dashing:
				
				if CurrentDirection == "none":
					pass
				else:
					is_dashing = true
					$DashTimer.start()
		if Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("down") or Input.is_action_pressed("up"):
			if Input.is_action_pressed("right"):
				velocity.z -= delta * speed
				CurrentDirection = "right"
				if ship.rotation > Vector3(-0.7,0,0):
					ship.rotate_x(-0.03)
					if ship.rotation < Vector3(-0.7,0,0):
						ship.rotation = Vector3(-0.7,0,0)
				
			if Input.is_action_pressed("left"):
				velocity.z += delta * speed
				CurrentDirection = "left"
				if ship.rotation < Vector3(.7,0,0):
					ship.rotate_x(.03)
					if ship.rotation > Vector3(.7,0,0):
						ship.rotation = Vector3(.7,0,0)
				
			if Input.is_action_pressed("down"):
				velocity.x += delta * speed
				CurrentDirection = "down"
				#checks to make sure left it doesn't try to stablize the ship while moving diagonaly
				if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
					pass
				else:
					shipstablization()
				
			if Input.is_action_pressed("up"):
				velocity.x -= delta * speed
				#checks to make sure left it doesn't try to stablize the ship while moving diagonaly
				if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
					pass
				else:
					shipstablization()
		else:
			CurrentDirection = "none"
			shipstablization()

	#resets velocity if nothing is pressed 
	if velocity != Vector3.ZERO:
		velocity = velocity.normalized()
		#normalizes the speed if going diagonal
	#fixes sliding on edge
	var collision = move_and_collide(velocity * delta * speed)
	#checks which wall is being hit
	if collision && velocity.x > 0 and collision.get_collider().name == "RightWall":
		move_and_collide((Vector3(-0.41972920696325,0,0.58027079303675) /2)* delta * speed)
	elif collision && velocity.x > 0 and collision.get_collider().name == "LeftWall":
		move_and_collide((Vector3(0.41972920696325,0,-0.58027079303675) /2)* delta * speed)
	
	#stops the player from going outside of view
	if position.x < 5:
		position.x = 5
	elif position.x > 17:
		position.x = 17
func shipstablization():
	if ship.rotation > Vector3(0,0,0):
		ship.rotate_x(-0.025)
		if ship.rotation < Vector3(0,0,0):
			ship.rotation = Vector3(0,0,0)
	elif ship.rotation < Vector3(0,0,0):
		ship.rotate_x(.025)
		if ship.rotation > Vector3(0,0,0):
			ship.rotation = Vector3(0,0,0)

func _dash_timeout():
	is_dashing = false
	$DashCooldown.start()
