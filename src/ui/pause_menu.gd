extends CanvasLayer


func _on_continue_pressed() -> void:
	GameManager.close_pause_overlay()

func _on_quit_pressed() -> void:
	GameManager.quit_game()

func _on_save_pressed() -> void:
	GameManager.save_game()

func _on_load_pressed() -> void:
	GameManager.load_game()
