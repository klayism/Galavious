extends Control

func _ready():
	pass





func _on_restart_pressed():
	GlobalVars.restart_pressed.emit()
