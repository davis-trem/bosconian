extends StaticBody


signal enemy_base_destroyed

const explosion_path = preload('res://scenes/Explosion.tscn')
const bullet_path = preload('res://scenes/Bullet.tscn')

export var oriented_horizontally = false

const MIN_FIRE_WAIT_TIME = 4
const MAX_FIRE_WAIT_TIME = 10

var cannon_orbs_left = 6
var fire_wait_time = randi() % MAX_FIRE_WAIT_TIME + MIN_FIRE_WAIT_TIME
var firing_time_delay = 0


func _ready():
	if oriented_horizontally:
		rotation.y = PI/2


func _process(delta):
	handle_cannon_orb_shooting(delta)


func handle_cannon_orb_shooting(delta):
	var closest_player = Global.find_closest_player(global_transform.origin)
	if closest_player == null:
		return

	# find closest orb to player
	var closest_cannon_orb
	for child in get_children():
		if (
			child.is_in_group('cannon_orb')
			and is_instance_valid(child.get_child(0))
			and child.get_child(0).name == 'Orb'
		):
			if (
				closest_cannon_orb == null
				or closest_player.global_transform.origin.distance_to(child.get_child(0).global_transform.origin)
					< closest_player.global_transform.origin.distance_to(closest_cannon_orb.global_transform.origin)
			):
				closest_cannon_orb = child.get_child(0)

	if closest_cannon_orb:
		closest_cannon_orb.look_at(
			closest_player.translation,
			Vector3.UP
		)

		if firing_time_delay > fire_wait_time:
			fire_wait_time = randi() % MAX_FIRE_WAIT_TIME + MIN_FIRE_WAIT_TIME
			firing_time_delay = 0
			var bullet = bullet_path.instance()
			
			bullet.is_from_player = false

			get_parent().add_child(bullet)
			bullet.global_transform = closest_cannon_orb.get_child(1).global_transform
	firing_time_delay += delta
	


func on_cannon_orb_hit(node):
	Global.increase_current_score(200)
	cannon_orbs_left -= 1
	# If all orbs are destoryed then destroy the whole base
	if cannon_orbs_left == 0:
		on_core_hit(false)

	var orb = node.get_child(0)
	var explosion = explosion_path.instance()
	node.add_child(explosion)
	explosion.global_transform = orb.global_transform
	explosion.explode()
	orb.queue_free()


func on_core_hit(increase_score = true):
	if increase_score:
		Global.increase_current_score(1500)
	var explosion = explosion_path.instance()
	get_parent().add_child(explosion)
	explosion.global_transform = global_transform
	explosion.explode()
	emit_signal('enemy_base_destroyed')
	queue_free()


func _on_CannonOrb_body_entered(body):
	if body.is_in_group('player'):
		body.end_life()
