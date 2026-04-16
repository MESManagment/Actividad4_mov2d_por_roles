extends CharacterBody2D

# CONFIGURACION
@export_group("Movimiento Horizontal")
@export var max_speed: float = 300.0
@export var acceleration: float = 700.0
@export var friction: float = 600.0
@export var skid_force: float = 1600.0

@export_group("Salto")
@export var jump_force: float = -450.0
@export var spin_jump_force: float = -400.0
@export var max_jumps: int = 2
@export var gravity: float = 1300.0

# ESTADOS
enum State { IDLE, RUNNING, JUMPING, FALLING }
var current_state: State = State.IDLE

# VARIABLES
var jump_count: int = 0
var was_jump_pressed: bool = false

func _ready() -> void:
	# Limpieza de UI inicial
	if has_node("CanvasLayer"):
		await get_tree().create_timer(5.0).timeout
		$CanvasLayer.queue_free()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_input(delta)
	update_state_machine()
	move_and_slide()
	update_animations()

# FUNCIONES DE LOGICA

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_count = 0

func handle_input(delta: float) -> void:
	# Movimiento Horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		if velocity.x != 0 and sign(direction) != sign(velocity.x):
			velocity.x = move_toward(velocity.x, direction * max_speed, skid_force * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Logica de Salto
	var pressing_jump := Input.is_action_pressed("ui_up")
	if pressing_jump and not was_jump_pressed:
		if is_on_floor() or jump_count < max_jumps:
			velocity.y = jump_force if is_on_floor() else spin_jump_force
			jump_count += 1
	
	was_jump_pressed = pressing_jump

func update_state_machine() -> void:
	# Cambiamos de estado segun lo que esta pasando
	if not is_on_floor():
		if velocity.y < 0:
			current_state = State.JUMPING
		else:
			current_state = State.FALLING
	else:
		if velocity.x == 0:
			current_state = State.IDLE
		else:
			current_state = State.RUNNING

func update_animations() -> void:
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0
