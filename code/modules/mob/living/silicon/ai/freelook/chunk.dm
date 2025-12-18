/datum/camerachunk
	/// List of cameras that are within viewing range of this camera chunk.
	var/list/cameras = list()
	/// List of turfs in this camera chunk. (list[coord_index] = turf)
	var/list/turfs = list()
	/// List of turf visibility in this camera chunk. (list[coord_index] = viewing_camera_count)
	var/list/visibility = list()
	/// List of turfs covered by static in this camera chunk. (list[coord_index] = static_image)
	var/list/obscured = list()
	/// List of static images in this camera chunk.
	var/list/static_images = list()
	/// List of atoms that caused this camera chunk to update.
	var/list/sources = list()

	var/x = 0
	var/y = 0
	var/z = 0

	var/world_x = 0
	var/world_y = 0

/datum/camerachunk/New(x, y, z)
	src.x = x
	src.y = y
	src.z = z

	src.world_x = CHUNK_TO_WORLD(x)
	src.world_y = CHUNK_TO_WORLD(y)

	turfs.len = CHUNK_SIZE ** 2
	obscured.len = CHUNK_SIZE ** 2
	visibility.len = CHUNK_SIZE ** 2

	for (var/turf/turf as anything in block(world_x, world_y, z, world_x + CHUNK_SIZE - 1, world_y + CHUNK_SIZE - 1))
		turfs[1 + (turf.x - world_x) + (turf.y - world_y) * CHUNK_SIZE] = turf // +1 because lists are 1-based

	SScameras.chunks[GET_CHUNK_COORDS(x, y, z)] = src

/datum/camerachunk/Destroy(force)
	SScameras.chunks -= src
	SScameras.chunk_queue -= src

	for (var/obj/machinery/camera/camera as anything in cameras)
		camera.last_view_chunks -= src

	cameras.Cut()
	visibility.Cut()
	obscured.Cut()
	sources.Cut()

	return ..()
