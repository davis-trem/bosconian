extends KinematicBody

const explosion_path = preload('res://scenes/Explosion.tscn')

const KILL_TIME = 7

var score_value = 0
var speed = 18.0
var should_retreat = false
var is_retreating = false
var start_kill_timer = false
var kill_timer = 0
var times_allowed_to_retreated = 0


func _physics_process(delta):
	if start_kill_timer:
		kill_timer += delta
		if kill_timer > KILL_TIME:
			if times_allowed_to_retreated == 0: 
				queue_free()
			else:
				is_retreating = false
				start_kill_timer = false
				kill_timer = 0
				times_allowed_to_retreated -= 1

	var target = get_follow_target() * (-1 if is_retreating else 1)

	var look_direction = Vector2(-target.z, -target.x)
	if rotation.y != look_direction.angle():
		rotation = rotation.move_toward(
			Vector3(0, look_direction.angle(), 0),
			0.5
		)
	move_and_slide(speed * target)


func get_follow_target() -> Vector3:
	var player = Global.find_closest_player(global_transform.origin)

	var closest_front_or_back = Global.find_closest_node_in_list_to_target(
		global_transform.origin,
		player.get_child(player.BULLET_PROJECT_ARM_INDEX).get_children()
	)
	
	var front_or_back_direction = Global.direction_towards_and_wrap_field(
		global_transform.origin,
		closest_front_or_back.global_transform.origin
	)
	
	return front_or_back_direction


func retreat():
	is_retreating = true
	start_kill_timer = false
	kill_timer = 0


func on_hit(increase_score = true):
	if increase_score:
		Global.increase_current_score(score_value)
	var explosion = explosion_path.instance()
	get_parent().add_child(explosion)
	explosion.global_transform = global_transform
	explosion.explode()
	queue_free()


func _on_VisibilityNotifier_camera_exited(camera):
	if camera.name == 'TopDownCamera' and should_retreat:
		start_kill_timer = true


func _on_VisibilityNotifier_camera_entered(camera):
	if camera.name == 'TopDownCamera' and should_retreat:
		retreat()
