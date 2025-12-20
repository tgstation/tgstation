/datum/camerachunk
	/// List of cameras that are within view range of this camera chunk.
	var/list/cameras = list()
	/// List of turfs in this camera chunk. (list[coord_index] = turf)
	var/list/turfs = list()
	/// List of turf visibility in this camera chunk. (list[coord_index] = viewing_camera_count)
	var/list/visibility = list()
	/// List of static viewers viewing this camera chunk.
	var/list/viewers = list()

	var/x = 0
	var/y = 0
	var/z = 0

	var/world_x = 0
	var/world_y = 0

	var/datum/bounds/chunk_bounds = null
	var/datum/bounds/world_bounds = null

/datum/camerachunk/New(x, y, z)
	src.x = x
	src.y = y
	src.z = z

	world_x = CHUNK_TO_WORLD(x)
	world_y = CHUNK_TO_WORLD(y)

	chunk_bounds = BOUNDS_MIN_AND_SIZE(vector(x, y, z), vector(1, 1, 1))
	world_bounds = BOUNDS_MIN_AND_SIZE(vector(world_x, world_y, z), vector(CHUNK_SIZE, CHUNK_SIZE, 1))

	turfs.len = CHUNK_SIZE ** 2
	visibility.len = length(turfs)

	for (var/turf/turf as anything in block(world_x, world_y, z, world_x + CHUNK_SIZE - 1, world_y + CHUNK_SIZE - 1))
		turfs[1 + (turf.x - world_x) + (turf.y - world_y) * CHUNK_SIZE] = turf // +1 because lists are 1-based

	SScameras.chunks[GET_CHUNK_COORDS(x, y, z)] = src

/datum/camerachunk/Destroy(force)
	SScameras.chunks -= src

	for (var/obj/machinery/camera/camera as anything in cameras)
		camera.view_chunks -= src
	cameras.Cut()

	for (var/datum/component/camera_viewer/viewer as anything in viewers)
		viewer.view_chunks -= src
	viewers.Cut()

	turfs.Cut()
	visibility.Cut()

	return ..()
