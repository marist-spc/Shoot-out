extends Node2D

signal player1IsKeyboard
var isPlayer1Keyboard := true

@export var keyScene:PackedScene = preload("res://key.tscn")
@export var ammoScene:PackedScene = preload("res://Ammo.tscn")

var game_over : bool

func initialize():
	for i in range(1,3):
		if isPlayer1Keyboard and i == 1:
			create_input("up",i, KEY_W)
			create_input("left",i, KEY_A)
			create_input("down",i,KEY_S)
			create_input("right",i, KEY_D)
			create_input("hold_breath",i,KEY_SPACE)
		else:
			create_input("up",i, KEY_0, Vector2(0,-1))
			create_input("left",i, KEY_0, Vector2(-1,0))
			create_input("down",i,KEY_0, Vector2(0,1))
			create_input("right",i, KEY_0, Vector2(1,0))
			create_input("aim_up",i, KEY_0, Vector2(0,-1), JOY_BUTTON_A, true)
			create_input("aim_left",i, KEY_0, Vector2(-1,0), JOY_BUTTON_A, true)
			create_input("aim_down",i,KEY_0, Vector2(0,1), JOY_BUTTON_A, true)
			create_input("aim_right",i, KEY_0, Vector2(1,0), JOY_BUTTON_A, true)
			create_input("hold_breath",i,KEY_0, Vector2.ZERO, JOY_BUTTON_A)

func create_input(
Inputname : String,
player : int,
key : Key, 
joyPadDirection := Vector2.ZERO,
joy_pad_button := JoyButton.JOY_BUTTON_A,
isRightAxis := false):
	var action_name = Inputname + str(player)
	InputMap.add_action(action_name)
	if  player == 1 and isPlayer1Keyboard :
		var input_key = InputEventKey.new() 
		input_key.keycode = key
		InputMap.action_add_event(action_name,input_key)
	else:
		if joyPadDirection != Vector2.ZERO:
			var event = InputEventJoypadMotion.new()
			var isHorizontal = joyPadDirection.x != 0
			var dir := joyPadDirection.x if isHorizontal else joyPadDirection.y
			if	!isRightAxis:
				event.axis = JOY_AXIS_LEFT_X if isHorizontal else JOY_AXIS_LEFT_Y
			else:
				event.axis = JOY_AXIS_RIGHT_X if isHorizontal else JOY_AXIS_RIGHT_Y

			event.axis_value = dir
			if isPlayer1Keyboard:
				event.device = 0
			else:
				event.device = player - 1
			InputMap.action_add_event(action_name, event)
		else:
			var input_key = InputEventJoypadButton.new() 
			input_key.button_index  = joy_pad_button
			if isPlayer1Keyboard:
				input_key.device = 0
			else:
				input_key.device = player - 1
			InputMap.action_add_event(action_name,input_key)

func distrubute_keys(keys : int):
	var nums := range(0,len($KeySpawnLocations.get_children()))
	nums.shuffle()
	var secondary_nums := []
	var count = 0
	while count < keys:
		secondary_nums.append(nums[count])
		count+=1
	for i in secondary_nums:
		var new_key = keyScene.instantiate()
		add_child.call_deferred(new_key)
		new_key.global_position = $KeySpawnLocations.get_children()[i].global_position

func _physics_process(delta: float) -> void:
	if !game_over:
		$Camera2D.position = $Player1.position.lerp($Player2.position, 0.5)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	distrubute_keys(4)
	var controllers := Input.get_connected_joypads()
	if controllers.size() >= 2:
		isPlayer1Keyboard = false
		print("2 CONTROLLERS FOUND")
	elif controllers.size() == 1:
		isPlayer1Keyboard = true
		player1IsKeyboard.emit()
		print("1 CONTROLLER FOUND")
	else:
		player1IsKeyboard.emit()
		print("NO CONTROLLER FOUND")
	initialize()

func _on_bullet_spawn_timer_timeout() -> void:
	if len($BulletHolder.get_children()) < 9:
		var spawn_pos : Vector2
		spawn_pos.x = range(0,4150).pick_random()
		spawn_pos.y = range(0,3632).pick_random()
		var new_ammo = ammoScene.instantiate()
		$BulletHolder.add_child.call_deferred(new_ammo)
		new_ammo.global_position = spawn_pos
		$BulletSpawnTimer.start()

func _on_fin_zone_body_entered(body: Node2D) -> void:
	if body.keys != 3:
		return
	if body.playerNumber == 2:
		$"Result Scene".isWinner2 = true
	$"Result Scene".show_result()
	$Camera2D.global_position = Vector2.ZERO
	$CanvasModulate.color = Color.ANTIQUE_WHITE
	game_over = true
