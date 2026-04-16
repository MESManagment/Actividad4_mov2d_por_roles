extends CharacterBody2D

@export_group("IA de Movimiento")
@export var speed: float = 200.0 
@export var detection_range: float = 250.0
@export var attack_range: float = 65.0 

@export_group("Ruta de Patrullaje")
@export var patrol_points: Array[Node2D] 

enum State { PATROL, CHASE, ATTACK }
var current_state: State = State.PATROL
var target_index: int = 0
var player: CharacterBody2D = null
var gravity: float = 1200.0 # Fuerza de gravedad

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# GRAVEDAD
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# LOGICA DE ESTADOS
	match current_state:
		State.PATROL:
			patrol_state()
		State.CHASE:
			chase_state()
		State.ATTACK:
			attack_state()
	
	# EJECUTAR MOVIMIENTO
	move_and_slide()
	
	# GIRAR SPRITE SEGUN DIRECCION
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0

func patrol_state():
	if patrol_points.is_empty(): return
	
	var target = patrol_points[target_index].global_position
	var direction = sign(target.x - global_position.x)
	velocity.x = direction * (speed * 0.6)
	
	if abs(global_position.x - target.x) < 20:
		target_index = (target_index + 1) % patrol_points.size()
	
	if player and global_position.distance_to(player.global_position) < detection_range:
		current_state = State.CHASE

func chase_state():
	if not player: return
	
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * speed
	
	# Si entra en rango de ataque
	if global_position.distance_to(player.global_position) < attack_range:
		current_state = State.ATTACK
	
	# Si el jugador se aleja mucho
	if global_position.distance_to(player.global_position) > detection_range * 1.1:
		current_state = State.PATROL

func attack_state():
	velocity.x = 0 # Se detiene para atacar
	
	# Mensaje de daño
	print("¡EL ENEMIGO TE ESTÁ DAÑANDO!") 
	
	# Logica para salir del ataque si el jugador se aleja
	if player and global_position.distance_to(player.global_position) > attack_range + 20:
		current_state = State.CHASE
