extends Area3D

const PRECIOUS_TINT := Color(0.8, 0.0, 0.8)

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _mesh: MeshInstance3D = $MeshInstance3D

var resource: int
var is_precious: bool = false

func _ready() -> void:
	if is_precious:
		var mat := _mesh.mesh.material.duplicate() as StandardMaterial3D
		mat.albedo_color = PRECIOUS_TINT
		_mesh.material_override = mat
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var ship := GameManager.PlayerShip as Node3D
	# if the player ship is the same as the body that entered the area, collect the resource
	if ship == body:
		_collect()

func _collect() -> void:
	SignalBus.player_resource_received.emit(resource)
	hide()
	collision_shape_3d.disabled = true
	audio_stream_player.play()
	await audio_stream_player.finished
	queue_free()
