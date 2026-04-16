extends CharacterBody2D

@export var max_speed = 300.0
@export var acceleration = 700.0
@export var friction = 600.0
@export var skid_force = 1600.0
@export var jump_force = -450.0
@export var spin_jump_force = -400.0

var gravity = 1300.0
var jump_count = 0
var max_jumps = 2
var was_jump_pressed = false

func _ready():
	# Espera 5 segundos y luego borra el cartel de instrucciones
	await get_tree().create_timer(5.0).timeout
	$CanvasLayer.queue_free()

func _physics_process(delta):
	# 1. Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_count = 0

	# 2. Detectar Teclas Físicas (Flechas)
	var pressing_right = Input.is_physical_key_pressed(KEY_RIGHT)
	var pressing_left = Input.is_physical_key_pressed(KEY_LEFT)
	var pressing_jump = Input.is_physical_key_pressed(KEY_UP)

	# 3. Lógica de Salto
	if pressing_jump and not was_jump_pressed:
		if is_on_floor():
			velocity.y = jump_force
			jump_count = 1
		elif jump_count < max_jumps:
			velocity.y = spin_jump_force
			jump_count += 1
	
	was_jump_pressed = pressing_jump

	# 4. Movimiento Horizontal
	var direction = 0
	if pressing_right:
		direction += 1
	if pressing_left:
		direction -= 1
	
	if direction != 0:
		if velocity.x != 0 and sign(direction) != sign(velocity.x):
			velocity.x = move_toward(velocity.x, direction * max_speed, skid_force * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	
	# Girar el sprite según la dirección
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0
