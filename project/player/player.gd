extends CharacterBody2D
#Make this thing walk as a top down character instead of as a platformer character (aka no gravity, up down left right)
#Give them the ability to run
#Add inputs via the Input manager (project -> project settings -> input manager) for up down left right (WASD, maybe arrow keys and maybe 
var health = 10
var maxHealth = 10
var damage = 100
var attackable = true
var inRange: Array = []
var SPEED = 100.0
var stamina = 100
const JUMP_VELOCITY = -400.0
var save_dictionary : Dictionary
var latestKey
var arrayLeft = []
var arrayRight = []
var arrayUp = []
var arrayDown = []

func _ready() -> void:
	save_dictionary = await Saves.get_save_dictionary()
	GlobalVars.player = self
	
	#Setup
	global_position.x = save_dictionary.get_or_add("player_pose_x", 0)
	global_position.y = save_dictionary.get_or_add("player_pose_y", 0)
	print_debug("Loaded player at: " + str(global_position))

func _physics_process(delta: float) -> void:
	if attackable == true and Input.is_action_pressed("attack"):
		attackable = false
		for enemies in inRange:
			enemies.HEALTH = enemies.HEALTH-damage
			print("Attacking")
		print("on cooldown")
		await get_tree().create_timer(2.0).timeout
		attackable = true
		print("off cooldown")
			
	if Input.is_action_just_pressed("Up"):
		latestKey = "Up"
	if Input.is_action_just_pressed("Down"):
		latestKey = "Down"
	if Input.is_action_just_pressed("Left"):
		latestKey = "Left"
	if Input.is_action_just_pressed("Right"):
		latestKey = "Right"
	if Input.is_action_pressed("Sprint") && stamina >= 10: #min stamina set to 10 so no infinite sprint
		SPEED = 150.0 #1.5 times the speed of the plc
		stamina = stamina - 10 #reduce stamina so plc can't sprint infinitely
	else: #handles release of SHIFT key
		SPEED = 100.0 #bring speed back to walking pace for plc
		stamina = stamina + 2 #increase by 2 so there is no infinite sprint capability,
							  #and so plc has to rest somewhat before they can sprint again
		

	$ProgressBar.value = health * 100 / maxHealth
	
	if health < 0:
		queue_free()
		health = health - 1
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	velocity.y = 0
	velocity.x = 0
	
	if Input.is_action_pressed("Up"):
		velocity.y = -SPEED
	if Input.is_action_pressed("Down"):
		velocity.y = velocity.y +SPEED
	if Input.is_action_pressed("Left"):
		velocity.x = -SPEED
	if Input.is_action_pressed("Right"):
		velocity.x = velocity.x +SPEED
		
	if velocity.x == 0 and velocity.y == 0:
		if latestKey == "Up":
			$AnimatedSprite2D.play("idle_up")
		if latestKey == "Down":
			$AnimatedSprite2D.play("idle_down")
		if latestKey == "Right":
			$AnimatedSprite2D.play("idle_right")
		if latestKey == "Left":
			$AnimatedSprite2D.play("idle_left")
	else:
		if latestKey == "Up":
			$AnimatedSprite2D.play("walk_up")
		if latestKey == "Down":
			$AnimatedSprite2D.play("walk_down")
		if latestKey == "Right":
			$AnimatedSprite2D.play("walk_right")
		if latestKey == "Left":
			$AnimatedSprite2D.play("walk_left")
			
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()

	#Store pose in dictionary
	
	save_dictionary["player_pose_x"] = global_position.x
	save_dictionary["player_pose_y"] = global_position.y
	




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		print("CHICKEN")
		inRange.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	inRange.erase(body)

func on_right(body: Node2D) -> void:
	print("ON RIGHT")
	arrayRight.append(body)

func on_left(body: Node2D) -> void:
	print("ON LEFT")
	arrayLeft.append(body)

func on_up(body: Node2D) -> void:
	print("ON UP")
	arrayUp.append(body)

func on_down(body: Node2D) -> void:
	print("ON DOWN")
	arrayDown.append(body)


func on_left_exited(body: Node2D) -> void:
	arrayLeft.erase(body)


func on_right_exited(body: Node2D) -> void:
	arrayRight.erase(body)


func on_down_exited(body: Node2D) -> void:
	arrayDown.erase(body)


func on_up_exited(body: Node2D) -> void:
	arrayUp.erase(body)
