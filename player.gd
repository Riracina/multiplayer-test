extends CharacterBody3D
@onready var camera = $Body/Camera3D
@onready var anim = $Body/AnimationPlayer
var accel = 0

#make this a var later
const SENSITIVITY = 0.004

const SPEED = 10.0
const ACCEL_FACTOR = 0.25
const AIR_ACCEL_FACTOR = 0.01
const JUMP_VELOCITY = 4.5


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		var jump_timer = 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward", 0)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		accel = ACCEL_FACTOR
	else:
		accel = AIR_ACCEL_FACTOR
		
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, abs(direction.x) * SPEED * accel)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, abs(direction.z) * SPEED * accel)
	else:
		velocity.x = move_toward(velocity.x, 0, abs(velocity.x) * accel)
		velocity.z = move_toward(velocity.z, 0, abs(velocity.z) * accel)
	
	#animation
	if input_dir != Vector2.ZERO and is_on_floor():
		anim.play("walk")
	else:
		anim.play("idle")
	
	#handle air collisions
	if is_on_wall_only():
		if Input.is_action_just_pressed("jump"):
			var normal: Vector3 = get_last_slide_collision().get_normal()
			velocity += normal * SPEED
			velocity.y = JUMP_VELOCITY / 2
		#lose ~5% of speed per frame
		else:
			velocity.x = move_toward(velocity.x, 0, abs(velocity.x) * 0.05)
			velocity.z = move_toward(velocity.z, 0, abs(velocity.z) * 0.05)
	
	move_and_slide()
