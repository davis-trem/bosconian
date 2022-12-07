extends Spatial


onready var _hi_score_label = $GridContainer/SideMenu/GridContainer/HiScore
onready var _current_score_label = $GridContainer/SideMenu/GridContainer/CurrentScore
onready var _status_label = $GridContainer/SideMenu/GridContainer/Status
onready var _current_round_label = $GridContainer/SideMenu/GridContainer/RoundContainer/CurrentRound


func _ready():
	Global._level = self
	_hi_score_label.text = str(Global.hi_score)
	_current_score_label.text = str(Global.current_score)
	_status_label.text = Global.status
	_current_round_label.text = str(Global.current_round)
