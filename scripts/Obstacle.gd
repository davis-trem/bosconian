extends StaticBody

const explosion_path = preload('res://scenes/Explosion.tscn')

var score_value = 0
var inflict_damage = false
var exploding = false


func explode(increase_score: bool = false):
	if not exploding:
		exploding = true
		if increase_score:
			Global.increase_current_score(score_value)

		var explosion = explosion_path.instance()
		if inflict_damage:
			explosion.inflict_damage = true
			explosion.process_material.color_ramp.gradient.colors[1] = Color('#033280')
			explosion.process_material.color_ramp.gradient.colors[2] = Color('#033280')
			explosion.process_material.color_ramp.gradient.colors[3] = Color('#bdd6ff')
		
		get_parent().add_child(explosion)
		explosion.global_transform = global_transform
		explosion.explode()
		queue_free()


func _on_Area_body_entered(body):
	if body != self:
		explode()
