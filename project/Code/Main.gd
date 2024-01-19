extends Node3D
#prepare yourself for some of the worst code you will ever since in your life

var fireholecount = 1
var enemy_instance
var canShoot = true
@onready var Game_over_visibility = $UI/GameOverText

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVars.restart_pressed.connect(_on_restart)
	GlobalVars.target_hit.connect(_enemy_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GlobalVars.PlayerPos = $Player.position
	
	if Input.is_action_just_pressed("fire"):
		if canShoot:
			$Player/FiringSound.play()
			$Player/ShootCooldown.start()
			canShoot = false
			var scene = preload("res://Scenes/Bullet.tscn")
			var instance = scene.instantiate()
			instance.add_to_group("ToReset")
			add_child(instance)
			if fireholecount == 1: 
				instance.position = $Player/FireHole1.global_position
				fireholecount += 1
			elif fireholecount == 2:
				instance.position = $Player/FireHole2.global_position
				fireholecount += 1
			elif fireholecount == 3:
				instance.position = $Player/FireHole3.global_position
				fireholecount += 1
			elif fireholecount == 4:
				instance.position = $Player/FireHole4.global_position
				fireholecount = 1
	if Input.is_action_just_pressed("locate"):
		print($Player/Locator.global_position)
	$UI/ProgressBar.value = ($Player/DashCooldown.time_left /  3)*100
	$UI/ProgressBar/Percentage.text = "[center]" + str(roundf(($Player/DashCooldown.time_left /  3)*30)/10) + "s"
	$UI/ScoreBoard.text = "[center]Score: " + str(GlobalVars.score)

func _on_mob_spawn_timeout(): # there has got to be a better way to do this
	var scene = preload("res://Scenes/Enemy.tscn") 
	if GlobalVars.enemyCount == 5:
		pass
	else:
		var random_number = randi() % 9
		enemy_instance = scene.instantiate()
		enemy_instance.add_to_group("ToReset")
		spawnplacement(enemy_instance, random_number)
		var letimer = firingtimermaker(enemy_instance)
		enemy_instance.add_child(letimer)
		$MobSpawnTimer.start()

func firingtimermaker(enemy_instance):
	var FiringTimer = Timer.new()
	if is_instance_valid(enemy_instance) == true :
		FiringTimer.timeout.connect(fire.bind(enemy_instance))
		FiringTimer.wait_time = 0.7
		FiringTimer.autostart = true
		return FiringTimer
	else:
		FiringTimer.queue_free()


func fire(parentenemy): # there has got to be a better way to do this 
	var scene = preload("res://Scenes/Enemy_Bullet.tscn") # Creates the enemy bullet
	var instance = scene.instantiate()
	instance.position = parentenemy.position
	# Calculate the direction vector from enemy to player
	var direction = ($Player.position - parentenemy.position).normalized()
	# Store the player's position for later use in bullet movement
	instance.gameovercontrol = Game_over_visibility
	instance.add_to_group("ToReset")
	add_child(instance)
	instance.look_at($Player.position, Vector3(0, 1, 0))
	instance.rotate_y(deg_to_rad(90))
	# Set the bullet's initial position to the enemy's position


func spawnplacement(instance, random_number):
	var spawn_positions = [$Location/Spawns/MobSpawn,$Location/Spawns/MobSpawn2,$Location/Spawns/MobSpawn3,
	$Location/Spawns/MobSpawn4,$Location/Spawns/MobSpawn5,$Location/Spawns/MobSpawn6,
	$Location/Spawns/MobSpawn7,$Location/Spawns/MobSpawn8,$Location/Spawns/MobSpawn9]
	add_child(instance)
	instance.position = spawn_positions[random_number].position

func _on_restart():
	get_tree().call_group("ToReset","queue_free")
	GlobalVars.enemyCount = 0
	$UI/GameOverText.visible = false
	fireholecount = 1
	$Player.position = Vector3(0,0,0)
	$MobSpawnTimer.stop()
	$MobSpawnTimer.start()
func _on_shoot_cooldown_timeout():
	canShoot = true
func _enemy_hit():
	$Player/TargetHit.play()
