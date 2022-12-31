extends Particles

onready var _timer = $Timer
onready var _exposive_area = $ExplosiveArea

export var explode_on_start = false
var exploding = false
var inflict_damage = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_exposive_area.monitoring = inflict_damage
	if explode_on_start:
		explode()


func explode():
	emitting = true
	exploding = true
	_timer.start(0.4)


func _on_Timer_timeout():
	if exploding:
		emitting = false
		exploding = false
		_timer.start(0.2)
	else:
		queue_free()


func _on_ExplosiveArea_body_entered(body):
	if body.has_method('explode'):
		body.explode()
