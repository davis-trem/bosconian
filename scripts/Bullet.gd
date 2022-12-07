extends Area


onready var _collision_shape = $CollisionShape
onready var _mesh = $MeshInstance


var speed = 90

const KILL_TIME = 4
var kill_timer = 0
var is_from_player = false


func _ready():
	if not is_from_player:
		speed = 20
		_collision_shape.scale.z /= 2
		_mesh.scale.z /= 2


func _physics_process(delta):
	var forward_diection = global_transform.basis.z.normalized()
	global_translate(forward_diection * delta * speed)
	
	if not is_from_player:
		_collision_shape.rotation.y += 0.5
		_mesh.rotation.y += 0.5
	
	kill_timer += delta
	if kill_timer > KILL_TIME:
		queue_free()


func handle_bullet_hit(target):
	var node_to_explode = target.get_parent() if target is Area else target
	# player shoots enemy
	if is_from_player and not node_to_explode.is_in_group('player'):
		if node_to_explode.is_in_group('enemy_base'):
			if node_to_explode == target:
				node_to_explode.on_core_hit()
			elif target.is_in_group('cannon_orb'):
				node_to_explode.on_cannon_orb_hit(target)
	# enemy shoots player
	elif not is_from_player and node_to_explode.is_in_group('player'):
		pass

	queue_free()


func _on_body_entered(body):
	handle_bullet_hit(body)


func _on_area_entered(area:Area):
	handle_bullet_hit(area)
