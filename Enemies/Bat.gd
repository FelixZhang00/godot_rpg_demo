extends KinematicBody2D



const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200


enum{
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var stats =$Status
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

func _ready():
	print(stats.max_health)
	print(stats.health)
	randomize()
	state = pick_random_state([IDLE,WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,FRICTION*delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,FRICTION*delta)
			seek_player()
			
			if wanderController.get_timer_left() == 0:
				state = pick_random_state([IDLE,WANDER])
				wanderController.start_wander_timer(rand_range(1,3))
		WANDER:
			seek_player()
			
			if wanderController.get_timer_left() == 0:
				state = pick_random_state([IDLE,WANDER])
				wanderController.start_wander_timer(rand_range(1,3))
			var direction = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED,ACCELERATION * delta)	
			sprite.flip_h = velocity.x < 0		
			
			if global_position.distance_to(wanderController.target_position) <= 4:
				state = pick_random_state([IDLE,WANDER])
				wanderController.start_wander_timer(rand_range(1,3))
		CHASE:
			var player = playerDetectionZone.player
			if player!=null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction*MAX_SPEED,ACCELERATION *delta)
			else:
				state = IDLE
				
			sprite.flip_h = velocity.x < 0		
	if softCollision.is_colliding():
		velocity += 	softCollision.get_push_vector()*delta*300		
	velocity = move_and_slide(velocity)		

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 100
	hurtbox.create_hit_effect()


func _on_Status_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
