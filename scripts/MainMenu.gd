extends Node2D


func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/StartGameButton.grab_focus()


func _on_StartGameButton_pressed():
	get_tree().change_scene('res://scenes/Level.tscn')


func _on_ConfigButton_pressed():
	get_tree().change_scene('res://scenes/ButtonConfiguration.tscn')


func _on_QuitButton_pressed():
	get_tree().quit()
