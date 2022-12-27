extends Node2D


func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/StartGameButton.grab_focus()
	prints(InputMap.get_action_list('ui_accept'))


func _on_StartGameButton_pressed():
#	get_tree().change_scene("res://scenes/Level.tscn")
	print('starrrrrt')


func _on_ConfigButton_pressed():
	pass # Replace with function body.
	print('options')


func _on_QuitButton_pressed():
	get_tree().quit()
