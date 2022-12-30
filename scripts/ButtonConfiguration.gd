extends Node2D


onready var _action_button = $ActionButton
onready var _input_label = $InputLabel
onready var _action_input_container = $MarginContainer/VBoxContainer/MarginContainer/ActionInputContainer
onready var _clear_action_button = $MarginContainer/VBoxContainer/ClearActionButton
onready var _popup_dialog = $MarginContainer/PopupDialog
onready var _popup_dialog_label = $MarginContainer/PopupDialog/MarginContainer/Label
onready var _accept_dialog = $MarginContainer/AcceptDialog
onready var _accept_dialog_label = $MarginContainer/AcceptDialog/MarginContainer/Label
onready var _back_button = $BackButton


const ACTIONS = [
	{'display_name': 'Accept / Shoot', 'key': 'ui_accept'},
	{'display_name': 'Pause', 'key': 'ui_cancel'},
	{'display_name': 'Left', 'key': 'ui_left'},
	{'display_name': 'Right', 'key': 'ui_right'},
	{'display_name': 'Up', 'key': 'ui_up'},
	{'display_name': 'Down', 'key': 'ui_down'},
	{'display_name': 'Toggle Camera', 'key': 'toggle_camera'},
]

var action_for_input = null


func _ready():
	draw_action_labels()
	_back_button.focus_neighbour_bottom = NodePath(_clear_action_button.get_path())
	_clear_action_button.focus_neighbour_top = NodePath(_back_button.get_path())


func _input(event):
	if action_for_input != null:
		var action_in_use = null
		for action in ACTIONS:
			if event.is_action(action['key']):
				action_in_use = action
				break
		
		if action_for_input['key'] == 'clear':
			if action_in_use != null:
				InputMap.action_erase_event(action_in_use['key'], event)
				_accept_dialog_label.text = (get_input_name(event)
					+ ' has been unbinded from '
					+ action_in_use['display_name'])
				draw_action_labels()
			else:
				_accept_dialog_label.text = get_input_name(event) + ' is not binded to an action.'
		else:
			if action_in_use != null:
				_accept_dialog_label.text = (get_input_name(event)
					+ ' is already binded to '
					+ action_in_use['display_name'])
			else:
				InputMap.action_add_event(action_for_input['key'], event)
				_accept_dialog_label.text = (get_input_name(event)
					+ ' has been set for '
					+ action_for_input['display_name'])
				draw_action_labels()
		action_for_input = null
		_popup_dialog.hide()
		_accept_dialog.popup()


func get_input_name(input) -> String:
	if input is InputEventKey:
		return input.as_text()
	elif input is InputEventJoypadButton:
		return 'Button ' + String(input.button_index)
	return ''


func draw_action_labels():
	# Remove all children except headings and separator before drawing
	for i in range(6, _action_input_container.get_child_count()):
		_action_input_container.get_child(i).queue_free()
	
	var action_buttons = []
	for action in ACTIONS:
		var new_action_button = _action_button.duplicate()
		new_action_button.connect("pressed", self, "_on_action_button_pressed", [action])
		action_buttons.append(new_action_button)
		
		var new_key_label = _input_label.duplicate()
		var new_button_label = _input_label.duplicate()
		
		_action_input_container.add_child(new_action_button)
		_action_input_container.add_child(new_key_label)
		_action_input_container.add_child(new_button_label)
		
		new_action_button.show()
		new_key_label.show()
		new_button_label.show()
		
		new_action_button.text = action['display_name']
		var action_list = InputMap.get_action_list(action['key'])
		for input in action_list:
			if input is InputEventKey:
				var text = input.as_text() + ', '
				new_key_label.text += ('' if (new_key_label.text + text).length() <= 20 else '\n') + text
			elif input is InputEventJoypadButton:
				var text = ('Button '
					+ String(input.button_index)
					+ ', ')
				new_button_label.text += ('' if (new_button_label.text + text).length() <= 20 else '\n') + text
	
	action_buttons[0].grab_focus()
	_back_button.focus_neighbour_top = NodePath(action_buttons[action_buttons.size() - 1].get_path())
	action_buttons[action_buttons.size() - 1].focus_neighbour_bottom = NodePath(_back_button.get_path())


func _on_action_button_pressed(action: Dictionary):
	_popup_dialog_label.text = 'Press button to bind to ' + action['display_name']
	_popup_dialog.popup()
	action_for_input = action


func _on_AcceptDialog_confirmed():
	_action_input_container.get_child(6).grab_focus()


func _on_ClearActionButton_pressed():
	_popup_dialog_label.text = 'Press button to unbind'
	_popup_dialog.popup()
	action_for_input = {'key': 'clear'}


func _on_BackButton_pressed():
	get_tree().change_scene('res://scenes/MainMenu.tscn')
