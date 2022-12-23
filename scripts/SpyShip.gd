extends 'res://scripts/BaseFighter.gd'


const is_spy = true
const score_value_options = [200, 400, 800]


func _ready():
	self.speed = 16.0
	self.should_retreat = true
	self.score_value = score_value_options[randi() % score_value_options.size()]
	self.times_allowed_to_retreated = 1


func escape():
	Global.set_status(Global.STATUS_RED)
	.escape()
