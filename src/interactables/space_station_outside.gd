extends Node

func _ready() -> void:
	var area_3d: Area3D = get_node("Hull/Area3D")
	area_3d.body_entered.connect(_on_area_3d_body_entered)
	area_3d.body_exited.connect(_on_area_3d_body_exited)

func _on_area_3d_body_entered(body: Node3D) -> void:
	SignalBus.display_action_label.emit("Press G to enter")
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	SignalBus.display_action_label.emit("")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("interact"):
		get_tree().change_scene_to_file("res://scenes/Station.tscn")
