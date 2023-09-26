extends KinematicBody2D


var velocity = Vector2.ZERO
var roll_velocity = Vector2.RIGHT
var stats = PlayerStats

export var ACCELEPATION = 25
export var MAX_SPEED = 200
export var FRICTION = 25
export var ROLL_SPEED = 10

enum{
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
onready var animatorPlayer = $AnimationPlayer
onready var animatorTree = $AnimationTree
onready var animationState = animatorTree.get("parameters/playback")
onready var swordHitBox = $HitBoxPivot/SwordHitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	print("player _ready")
	stats.connect("no_health",self,"queue_free")
	animatorTree.active = true
	swordHitBox.knockback_vector = roll_velocity
	

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)		


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animatorTree.set("parameters/Idle/blend_position",input_vector)
		animatorTree.set("parameters/Run/blend_position",input_vector)
		animatorTree.set("parameters/Attack/blend_position",input_vector)
		animatorTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		velocity += input_vector * ACCELEPATION * delta
		velocity = velocity.clamped(MAX_SPEED*delta) 
		roll_velocity = input_vector
		swordHitBox.knockback_vector = input_vector
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO,FRICTION*delta)	
	
	velocity = input_vector
#	move_and_collide(velocity * delta * MAX_SPEED)	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
func attack_state(delta):
#	print("attack_state")
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_animation_finish():
	velocity = Vector2.ZERO
	state = MOVE	

func roll_state(delta):
	velocity = roll_velocity * 0.8
	animationState.travel("Roll")
	move()
	
func roll_animation_finish():
	velocity = velocity * 0.3
	state = MOVE	

func move():
	velocity = move_and_slide(velocity * MAX_SPEED)	
	


func _on_Hurtbox_area_entered(area):
	print("player _on_Hurtbox_area_entered")
	stats.health -= 1 
