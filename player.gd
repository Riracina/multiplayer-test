extends CharacterBody3D
@onready var camera = $Camera3D
var accel = 0

#make this a var later
const SENSITIVITY = 0.01

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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

	move_and_slide()
