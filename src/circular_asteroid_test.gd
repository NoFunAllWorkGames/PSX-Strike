extends MultiMeshInstance3D

@export var count: int = 100
@export var inner_radius: float = 10.0
@export var outer_radius: float = 20.0

# As the name says, this is just for demonstration purposes
# It creates a asteroid ring in space so movement can be seen
# Grayboxing code
func _ready():
	multimesh.instance_count = count
	for i in range(count):
		# 1. Calculate random polar coordinates
		var radius = randf_range(inner_radius, outer_radius)
		var angle = randf() * TAU # TAU is 2*PI
		
		# 2. Convert to Cartesian (x, z)
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		var y = randf_range(-1.0, 1.0) # Slight vertical jitter
		
		var pos = Vector3(x, y, z)
		var basis = Basis().rotated(Vector3.UP, randf() * TAU)
		basis = basis.scaled(Vector3.ONE * randf_range(0.5, 1.5))
		
		var t = Transform3D(basis, pos)
		multimesh.set_instance_transform(i, t)
