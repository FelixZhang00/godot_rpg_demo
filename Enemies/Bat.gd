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

func _ready():
	print(stats.max_health)
	print(stats.health)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,FRICTION*delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,FRICTION*delta)
		WANDER:
			pass
		CHASE:
			pass		

func seek_player():
	pass

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 100


func _on_Status_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
