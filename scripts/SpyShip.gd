extends 'res://scripts/BaseFighter.gd'


const is_spy = true


func _ready():
	self.speed = 16.0
	self.should_retreat = true
	self.score_value = 200
	self.times_allowed_to_retreated = 1


func escape():
	Global.set_status(Global.STATUS_RED)
	.escape()
