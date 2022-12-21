extends 'res://scripts/BaseFighter.gd'

export var is_squad_leader = false

const SPEED = 18.0

func _ready():
	self.speed = 18.0
	self.score_value = 100 if is_squad_leader else 50


#func _physics_process(delta):
#	var player = Global.find_closest_player(global_transform.origin)
#
#	var closest_front_or_back = Global.find_closest_node_in_list_to_target(
#		global_transform.origin,
#		player.get_child(player.BULLET_PROJECT_ARM_INDEX).get_children()
#	)
#
#	var front_or_back_direction = Global.direction_towards_and_wrap_field(
#		global_transform.origin,
#		closest_front_or_back.global_transform.origin
#	)
#
##	var front_or_back_direction = Global.direction_towards_and_wrap_field(
##		global_transform.origin,
##		player.global_transform.origin
###		Vector3(20*sin(player.global_transform.origin.x/6) + player.global_transform.origin.x, 0, player.global_transform.origin.z)
###		Vector3(player.global_transform.origin.x, 0, 50*sin(player.global_transform.origin.x/4))
##	)
#
##	print(front_or_back_direction)
##	var aaa = Vector2(front_or_back_direction.x, front_or_back_direction.z).angle()
##	var xxx = sin(aaa) + aaa
##	front_or_back_direction = Vector3(cos(xxx), 0, sin(xxx)).normalized()
##	front_or_back_direction = Vector3(sin(front_or_back_direction.x), 0, sin(front_or_back_direction.z)).normalized()
##	print(front_or_back_direction)
##	print('---------')
#
#	var look_direction = Vector2(-front_or_back_direction.z, -front_or_back_direction.x)
#	if rotation.y != look_direction.angle():
#		rotation = rotation.move_toward(
#			Vector3(0, look_direction.angle(), 0),
#			0.5
#		)
#	move_and_slide(SPEED * front_or_back_direction)
