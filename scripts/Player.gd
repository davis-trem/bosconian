extends KinematicBody


const bullet_path = preload('res://scenes/Bullet.tscn')

const SPEED = 18.0
const BULLET_PROJECT_ARM_INDEX = 4

onready var _top_down_camera: Camera = $TopDownCamera
onready var _cockpit_camera: Camera = $CockpitCamera
onready var _rear_view_camera = $RearViewViewportContainer/Viewport/RearViewCamera
onready var _rear_view_camera_view_port_container = $RearViewViewportContainer
onready var _model: Spatial = $SpaceShip
onready var _collision_shape = $CollisionShape
onready var _bullet_projector_arm = $BulletProjectArm
onready var _front_bullet_projector = $BulletProjectArm/FrontBulletProjector
onready var _back_bullet_projector = $BulletProjectArm/BackBulletProjector
onready var _rate_of_fire_timer = $RateOfFireTimer

var move_direction := Vector3(0, 0, -1)
var velocity := Vector3(0, 0, move_direction.z * SPEED)
var milliseconds_between_shots = 250
var can_shoot = true

# Called when the node enters the scene tree for the first time.
func _ready():
	_rate_of_fire_timer.wait_time = milliseconds_between_shots / 1000.0


func _input(event):
	if event.is_action_pressed('toggle_camera'):
		if _cockpit_camera.current:
			_model.rotation.y = rotation.y
			_collision_shape.rotation.y = rotation.y
			_bullet_projector_arm.rotation.y = rotation.y
			rotation.y = 0
			_top_down_camera.current = true
			_rear_view_camera_view_port_container.hide()
		elif _top_down_camera.current:
			rotation.y = _model.rotation.y
			_model.rotation.y = 0
			_collision_shape.rotation.y = 0
			_bullet_projector_arm.rotation.y = 0
			_cockpit_camera.current = true
			_rear_view_camera_view_port_container.show()


func _physics_process(delta: float):
	if _cockpit_camera.current:
		handle_cockpit_movement()
	elif _top_down_camera.current:
		handle_top_down_movement()

	handle_shooting()
	
	velocity = move_and_slide(velocity, Vector3.UP)


func handle_shooting():
	if Input.is_action_pressed("ui_accept"):
		if can_shoot:
			var bullet_1 = bullet_path.instance()
			var bullet_2 = bullet_path.instance()
			
			bullet_1.is_from_player = true
			bullet_2.is_from_player = true

			get_parent().add_child(bullet_1)
			get_parent().add_child(bullet_2)
			bullet_1.global_transform = _front_bullet_projector.global_transform
			bullet_2.global_transform = _back_bullet_projector.global_transform
			
			_rate_of_fire_timer.start()
			can_shoot = false


func handle_top_down_movement():
	move_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	move_direction = move_direction.normalized()
	if move_direction != Vector3.ZERO:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED

	var look_direction = Vector2(-velocity.z, -velocity.x)
	if _model.rotation.y != look_direction.angle():
		_model.rotation = _model.rotation.move_toward(
			Vector3(0, look_direction.angle(), 0),
			0.5
		)
		_collision_shape.rotation = _collision_shape.rotation.move_toward(
			Vector3(0, look_direction.angle(), 0),
			0.5
		)
		_bullet_projector_arm.rotation = _bullet_projector_arm.rotation.move_toward(
			Vector3(0, look_direction.angle(), 0),
			0.5
		)


func handle_cockpit_movement():
	var y_rotation = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if y_rotation != 0:
		rotation.y -= y_rotation * 0.05
		rotation.z = Vector3(0, 0, rotation.z).move_toward(Vector3(0, 0, -y_rotation * 0.2), 0.02).z

		var direction = Vector2(-cos(rotation.y), -sin(rotation.y)).normalized()
		velocity.x = direction.y * SPEED
		velocity.z = direction.x * SPEED
	else:
		rotation.z = Vector3(0, 0, rotation.z).move_toward(Vector3(0, 0, 0), 0.02).z
	
	_rear_view_camera.translation = Vector3(translation.x, translation.y + 3.222, translation.z)
	_rear_view_camera.rotation.y = rotation.y - PI


func _on_RateOfFireTimer_timeout():
	can_shoot = true
