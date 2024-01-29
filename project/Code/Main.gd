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

func _on_mob_spawn_timeout():
	var scene = preload("res://Scenes/Enemy.tscn") 
	var Bomberscene = preload("res://Scenes/Bomber.tscn")
	var bomberRatio = 1
	var enemyType
	if GlobalVars.killedEnemys > 10:
		bomberRatio = 1
	elif GlobalVars.killedEnemys > 20:
		bomberRatio = 2
	elif GlobalVars.killedEnemys > 30:
		bomberRatio = 3
	if GlobalVars.enemyCount == 3:
		pass
		
	else:
		var random_number = randi() % 9
		if bomberRatio == 0:
			enemy_instance = scene.instantiate()
			enemyType = "regular"
		elif bomberRatio == 1:
			enemy_instance = Bomberscene.instantiate()
			enemyType = "bomber"
		enemy_instance.add_to_group("ToReset")
		spawnplacement(enemy_instance, random_number)
		var letimer = firingtimermaker(enemy_instance,enemyType)
		enemy_instance.add_child(letimer)
		$MobSpawnTimer.start()

func firingtimermaker(enemy_instance,enemyType):
	var FiringTimer = Timer.new()
	if is_instance_valid(enemy_instance) == true :
		FiringTimer.timeout.connect(fire.bind(enemy_instance,enemyType))
		FiringTimer.wait_time = 1.2
		FiringTimer.autostart = true
		return FiringTimer
	else:
		FiringTimer.queue_free()

func fire(parentenemy,enemyType):
	var instance
	var scene = preload("res://Scenes/Enemy_Bullet.tscn") 
	var bomberBulletScene = preload("res://Scenes/Bomber_Bullet.tscn")
	if enemyType == "regular":
		instance = scene.instantiate()
	elif enemyType == "bomber":
		instance = bomberBulletScene.instantiate()
	instance.position = parentenemy.position
	var direction = ($Player.position - parentenemy.position).normalized() 
	instance.gameovercontrol = Game_over_visibility #allows the bullet to display the game over screen when it hits the player 
	instance.add_to_group("ToReset") # adds the bullet to the group that will help kill it when the game get's restarted
	add_child(instance)# Creates the enemy bullet
	instance.look_at($Player.position, Vector3(0, 1, 0))
	instance.rotate_y(deg_to_rad(90))
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
	GlobalVars.killedEnemys = 0 
func _on_shoot_cooldown_timeout():
	canShoot = true
func _enemy_hit():
	$Player/TargetHit.play()
