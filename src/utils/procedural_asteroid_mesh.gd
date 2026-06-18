class_name ProceduralAsteroidMesh

static func build(mesh_seed: int, radius: float = 1.0) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = mesh_seed

	var sphere_data := _build_icosphere()
	var vertices: PackedVector3Array = sphere_data[0]
	var indices: PackedInt32Array = sphere_data[1]

	var size_scale: float = rng.randf_range(0.75, 1.25)
	for i in vertices.size():
		var direction: Vector3 = vertices[i].normalized()
		var bump: float = rng.randf_range(0.65, 1.35)
		vertices[i] = direction * radius * size_scale * bump

	return _mesh_from_triangles(vertices, indices)


static func _build_icosphere() -> Array:
	var golden_ratio := (1.0 + sqrt(5.0)) * 0.5
	var vertices := PackedVector3Array([
		Vector3(-1.0, golden_ratio, 0.0),
		Vector3(1.0, golden_ratio, 0.0),
		Vector3(-1.0, -golden_ratio, 0.0),
		Vector3(1.0, -golden_ratio, 0.0),
		Vector3(0.0, -1.0, golden_ratio),
		Vector3(0.0, 1.0, golden_ratio),
		Vector3(0.0, -1.0, -golden_ratio),
		Vector3(0.0, 1.0, -golden_ratio),
		Vector3(golden_ratio, 0.0, -1.0),
		Vector3(golden_ratio, 0.0, 1.0),
		Vector3(-golden_ratio, 0.0, -1.0),
		Vector3(-golden_ratio, 0.0, 1.0),
	])
	for i in vertices.size():
		vertices[i] = vertices[i].normalized()

	var faces: Array = [
		[0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11],
		[1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
		[3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
		[4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1],
	]

	var midpoint_cache := {}
	var subdivided_faces: Array = []
	for face in faces:
		var a: int = face[0]
		var b: int = face[1]
		var c: int = face[2]
		var ab := _get_or_create_midpoint(a, b, vertices, midpoint_cache)
		var bc := _get_or_create_midpoint(b, c, vertices, midpoint_cache)
		var ca := _get_or_create_midpoint(c, a, vertices, midpoint_cache)
		subdivided_faces.append_array([
			[a, ab, ca],
			[b, bc, ab],
			[c, ca, bc],
			[ab, bc, ca],
		])

	var indices := PackedInt32Array()
	for face in subdivided_faces:
		indices.append_array(face)

	return [vertices, indices]


static func _get_or_create_midpoint(
	i1: int,
	i2: int,
	vertices: PackedVector3Array,
	cache: Dictionary
) -> int:
	var key := Vector2i(mini(i1, i2), maxi(i1, i2))
	if cache.has(key):
		return cache[key]

	var midpoint := (vertices[i1] + vertices[i2]) * 0.5
	var index := vertices.size()
	vertices.append(midpoint.normalized())
	cache[key] = index
	return index


static func _mesh_from_triangles(vertices: PackedVector3Array, indices: PackedInt32Array) -> ArrayMesh:
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	normals.fill(Vector3.ZERO)

	for i in range(0, indices.size(), 3):
		var i0: int = indices[i]
		var i1: int = indices[i + 1]
		var i2: int = indices[i + 2]
		var face_normal: Vector3 = (vertices[i1] - vertices[i0]).cross(vertices[i2] - vertices[i0])
		if face_normal.length_squared() > 0.0:
			face_normal = face_normal.normalized()
		normals[i0] += face_normal
		normals[i1] += face_normal
		normals[i2] += face_normal

	for i in normals.size():
		if normals[i].length_squared() > 0.0:
			normals[i] = normals[i].normalized()
		else:
			normals[i] = vertices[i].normalized()

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
