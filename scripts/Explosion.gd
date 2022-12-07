extends Particles

onready var _timer = $Timer

export var explode_on_start = false
var exploding = false


# Called when the node enters the scene tree for the first time.
func _ready():
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
