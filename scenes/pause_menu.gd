extends CanvasLayer


func _on_continue_pressed() -> void:
	GameManager.close_pause_overlay()


func _on_quit_pressed() -> void:
	GameManager.quit_game()
