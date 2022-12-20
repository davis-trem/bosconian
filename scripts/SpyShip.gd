extends KinematicBody

const SPEED = 16.0
const KILL_TIME = 5
const is_spy = true

var is_retreating = false
var start_kill_timer = false
var kill_timer = 0


func _physics_process(delta):
	if start_kill_timer:
		kill_timer += delta
		if kill_timer > KILL_TIME:
			queue_free()

	var player = Global.find_closest_player(global_transform.origin)
	
	var closest_front_or_back = Global.find_closest_node_in_list_to_target(
		global_transform.origin,
		player.get_child(player.BULLET_PROJECT_ARM_INDEX).get_children()
	)
	
	var front_or_back_direction = Global.direction_towards_and_wrap_field(
		global_transform.origin,
		closest_front_or_back.global_transform.origin
	) * (-1 if is_retreating else 1)
	
	var look_direction = Vector2(-front_or_back_direction.z, -front_or_back_direction.x)
	if rotation.y != look_direction.angle():
		rotation = rotation.move_toward(
			Vector3(0, look_direction.angle(), 0),
			0.5
		)
	move_and_slide(SPEED * front_or_back_direction)


func _on_VisibilityNotifier_camera_exited(camera):
	if camera.name == 'TopDownCamera':
		start_kill_timer = true
		print(camera)
		print('exiittt-------')


func _on_VisibilityNotifier_camera_entered(camera):
	if camera.name == 'TopDownCamera':
		is_retreating = true
		start_kill_timer = false
		kill_timer = 0
		print(camera)
		print('enterrrr-------')
