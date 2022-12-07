extends KinematicBody


const SPEED = 10.0

func _ready():
	var player = Global.find_closest_player(global_transform.origin)
	
	var player_direction = (player.global_transform.origin - global_transform.origin).normalized()
	print(player.global_transform.origin)
	print(global_transform.origin)
	print(player.global_transform.origin - global_transform.origin)
	print(player_direction)


func _physics_process(delta):
	var player = Global.find_closest_player(global_transform.origin)
	
	var player_direction = (player.global_transform.origin - global_transform.origin).normalized()
	var look_direction = Vector2(-player_direction.z, -player_direction.x)
	if rotation.y != look_direction.angle():
		rotation = rotation.move_toward(
			Vector3(0, look_direction.angle(), 0),
			0.5
		)
	
#	var closest_front_or_back = Global.find_closest_node_in_list_to_target(
#		global_transform.origin,
#		player.get_child(player.BULLET_PROJECT_ARM_INDEX).get_children()
#	)
	var closest_front_or_back = Global.find_closest_node_in_list_to_target(
		global_transform.origin,
		player.get_child(player.SIDE_ARM_INDEX).get_children()
	)
#	var front_or_back_direction = (
#		closest_front_or_back.global_transform.origin - global_transform.origin
#	).normalized()
	var front_or_back_direction = global_transform.origin.direction_to(closest_front_or_back.global_transform.origin).normalized()
	print(front_or_back_direction)
	print(front_or_back_direction)
	print('------------')
	move_and_slide(SPEED * -front_or_back_direction)
