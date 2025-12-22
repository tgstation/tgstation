// Camera chunks are 16x16 holders for camera information.

// They are shared by two domains:
// - Cameras determine which turfs in a camera chunk are visible.
// - Camera viewers see camera static effects over obscured areas.

// These two roles are coordinated, yet require separate data.
// To keep chunks lightweight, they initialize data dynamically.
// If a chunk has neither viewers nor cameras, it gets destroyed.

/datum/camera_chunk
	// SHARED START //

	var/x = 0
	var/y = 0
	var/z = 0

	var/world_x = 0
	var/world_y = 0

	// SHARED END

	// CAMERAS START //

	/// List of cameras that are within view range of this camera chunk.
	var/list/cameras = null
	/// List of turf visibility in this camera chunk. (list[coord_index] = viewing_camera_count)
	var/list/visibility = null

	// CAMERAS END //

	// VIEWERS START //

	/// The static image plane for this camera chunk.
	var/static_image_plane = null

	/// List of static viewers viewing this camera chunk.
	var/list/viewers = null
	/// List of turfs in this camera chunk. (list[coord_index] = turf)
	var/list/turfs = null
	/// List of static images in this camera chunk. (list[coord_index] = static_image)
	var/list/static_images = null

	// VIEWERS END //

/datum/camera_chunk/New(x, y, z)
	src.x = x
	src.y = y
	src.z = z

	world_x = CHUNK_TO_WORLD(x)
	world_y = CHUNK_TO_WORLD(y)

	SScameras.chunks[GET_CHUNK_COORDS(x, y, z)] = src

/datum/camera_chunk/Destroy(force)
	SScameras.chunks -= src

	if (cameras)
		deinit_cameras()
	if (viewers)
		deinit_viewers()

	return ..()

/datum/camera_chunk/proc/init_cameras()
	// Init camera lists
	cameras = list()
	visibility = new /list(CHUNK_SIZE ** 2)

/datum/camera_chunk/proc/deinit_cameras()
	// Remove cameras
	for (var/obj/machinery/camera/camera as anything in cameras)
		camera.view.chunks -= src

	// Deinit camera lists
	cameras = null
	visibility = null

	// Check for chunk redundancy
	if (!viewers && !QDELING(src))
		qdel(src)

/datum/camera_chunk/proc/init_viewers()
	// Let's not waste time computing the same plane for every individual turf.
	static_image_plane = GET_NEW_PLANE(CAMERA_STATIC_PLANE, GET_Z_PLANE_OFFSET(z))

	// Init viewer lists
	viewers = list()
	turfs = new /list(CHUNK_SIZE ** 2)
	static_images = new /list(CHUNK_SIZE ** 2)

	// We'll attempt to use cached static images if we can.
	var/list/available_static_images = SScamera_viewers.available_static_images
	var/image/base_static_image = SScamera_viewers.base_static_image

	// Collect turfs
	for (var/turf/turf as anything in block(world_x, world_y, z, world_x + CHUNK_SIZE - 1, world_y + CHUNK_SIZE - 1))
		turfs[1 + (turf.x - world_x) + (turf.y - world_y) * CHUNK_SIZE] = turf

	// Add static images
	for (var/i in 1 to length(turfs))
		if (visibility?[i])
			continue

		var/image/static_image

		if (length(available_static_images))
			static_image = available_static_images[length(available_static_images)]
			available_static_images.len--
		else
			static_image = image(base_static_image)

		static_image.loc = turfs[i]
		static_image.plane = static_image_plane

/datum/camera_chunk/proc/deinit_viewers()
	// Remove viewers
	for (var/datum/component/camera_viewer/viewer as anything in viewers)
		viewer.view_chunks -= src

		var/client/viewer_client = viewer.parent

		for (var/i in 1 to length(turfs))
			var/image/static_image = static_images[i]

			if (static_image)
				viewer_client.images -= static_image

	// Let's put our static images back in the cache, shall we?
	var/list/available_static_images = SScamera_viewers.available_static_images

	// Remove static images
	for (var/i in 1 to length(turfs))
		var/image/static_image = static_images[i]

		if (!static_image)
			continue

		static_image.loc = null
		available_static_images += static_image

	// Deinit viewer lists
	viewers = null
	turfs = null
	static_images = null

	// Check for chunk redundancy
	if (!cameras && !QDELING(src))
		qdel(src)
