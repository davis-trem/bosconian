extends Area


onready var _limit_left_collision = $LimitLeft
onready var _limit_right_collision = $LimitRight
onready var _limit_top_collision = $LimitTop
onready var _limit_bottom_collision = $LimitBottom

onready var limits = {
	'right': _limit_right_collision.translation.x * scale.x,
	'left': _limit_left_collision.translation.x * scale.x,
	'top': -_limit_top_collision.translation.z * scale.z,
	'bottom': -_limit_bottom_collision.translation.z * scale.z
}


func _ready():
	Global._playing_field = self


func _on_PlayingField_body_entered(body):
	pass # Replace with function body.


func _on_PlayingField_body_exited(body: KinematicBody):
	if body:
		body.translation.x = wrapf(body.translation.x, limits['left'], limits['right'])
		body.translation.z = wrapf(body.translation.z, limits['bottom'], limits['top'])


func _on_PlayingField_area_exited(area: Area):
	if area:
		area.translation.x = wrapf(area.translation.x, limits['left'], limits['right'])
		area.translation.z = wrapf(area.translation.z, limits['bottom'], limits['top'])
