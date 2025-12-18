/datum/camerachunk
	/// List of cameras that are within viewing range of this camera chunk.
	var/list/cameras = list()
	/// List of turf visibility in this camera chunk. (list[coord_index] = viewing_camera_count)
	var/list/visibility = list()
	/// List of turfs covered by static in this camera chunk. (list[coord_index] = TRUE)
	var/list/obscured = list()
	/// List of atoms that caused this camera chunk to update.
	var/list/sources = list()

	var/x = 0
	var/y = 0
	var/z = 0

/datum/camerachunk/New(x, y, z)
	src.x = x
	src.y = y
	src.z = z
	visibility.len = CHUNK_SIZE ** 2
	obscured.len = CHUNK_SIZE ** 2
	SScameras.chunks[GET_CHUNK_COORDS(x, y, z)] = src

/datum/camerachunk/Destroy(force)
	SScameras.chunks -= src

	for (var/obj/machinery/camera/camera as anything in cameras)
		camera.last_view_chunks -= src

	cameras.Cut()
	visibility.Cut()
	obscured.Cut()
	sources.Cut()
