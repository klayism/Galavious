extends CharacterBody3D


const SPEED = 100 # speed
var zpos = 0 #for the movement in the z coordinate
var startfirstmovement = false #wheter to start making the first smart movement
var firstmoveplayerpos #saves the player's position to be used in the first smart movement
var logcurve_initialValue = 0.5
var startSecondMovement = false
var skipFirst = false
var goingRight
var goleft

func _ready():
	GlobalVars.enemyCount += 1


func _physics_process(delta):
	var rng = RandomNumberGenerator.new()
	
	if startfirstmovement:
		if isWithinRange(position.z, firstmoveplayerpos.z, .5):
			startfirstmovement = false
			zpos = 0
			skipFirst = true
		if firstmoveplayerpos.z > position.z and !skipFirst:
			zpos = logcurve(delta,false,rng.randf_range(0,3))
		elif firstmoveplayerpos.z < position.z and !skipFirst:
			zpos = -logcurve(delta,false,rng.randf_range(0,3))
			goleft = true
	elif !startfirstmovement and skipFirst:
		if goleft:
			zpos = -logcurve(delta,true,rng.randf_range(0,3))
			
		elif !goleft:
			zpos = logcurve(delta,true,rng.randf_range(0,3))
			
			

		
	#rng.randi_range(-1,1)).normalized()
	var direction = (transform.basis * Vector3(1,0,zpos/1.5).normalized())
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else: # think this is useless but not really sure. don't remove it just in case we need it later
		velocity.x = move_toward(velocity.x, 0, delta)
		velocity.z = move_toward(velocity.z, 0, delta)
		
		# Decrease the value on a logarithmic scale
	
	if position.x > 26 :
		position.x = -28

	move_and_slide()


func _on_enemy_death_timeout():
	GlobalVars.enemyCount -= 1
	queue_free()


func FirstMovement():
	startfirstmovement = true
	firstmoveplayerpos = GlobalVars.PlayerPos
	
	
func isWithinRange(value1, value2, tolerance):
	return abs(value1 - value2) <= tolerance
	
func logcurve(delta, decrease, rate):
	if decrease:
		var newValue = logcurve_initialValue * pow(1.0 + delta, -rate)
		if newValue < 100.0:
			logcurve_initialValue = newValue
		else:
			logcurve_initialValue = 100.0
	else: 
		var newValue = logcurve_initialValue * (1.0 + delta * rate)
		if newValue > 0.0:
			logcurve_initialValue 
		else:
			logcurve_initialValue = 0.0
	return logcurve_initialValue

