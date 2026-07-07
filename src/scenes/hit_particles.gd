extends Node3D

@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var _owner: Node3D = get_parent()

func _ready() -> void:
	global_transform = _owner.global_transform
	print("self: ", global_position)
	print("Owner: ", _owner.global_position)

func play():
	if particles.emitting:
		return
	particles.restart()
	particles.emitting = true

func stop():
	particles.emitting = false
