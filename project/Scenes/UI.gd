extends Control

func _on_restart_pressed():
	GlobalVars.restart_pressed.emit()
