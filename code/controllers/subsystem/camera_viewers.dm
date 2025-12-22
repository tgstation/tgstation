#define MAX_STATIC_IMAGES_PER_VIEWER 500

/// Manages viewers of camera visibility
SUBSYSTEM_DEF(camera_viewers)
	name = "Camera Viewers"
	flags = SS_TICKER | SS_NO_INIT
	priority = FIRE_PRIORITY_CAMERA_VIEWERS
	wait = 1
	dependencies = list(
		/datum/controller/subsystem/cameras, // duh
	)

	/// All camera viewers on the map.
	var/list/viewers = list()
	/// All viewed chunks on the map.
	var/list/viewed_chunks = list()

	/// All camera viewers that must be updated. (alist[viewer] = null)
	var/alist/viewer_queue = alist()

	/// The base static image that we mirror from.
	var/image/base_static_image
	/// A list of available static images for camera chunks to use.
	var/list/available_static_images = list()

/datum/controller/subsystem/camera_viewers/fire(resumed)
	for (var/datum/component/camera_viewer/viewer as anything in viewer_queue)
		if (MC_TICK_CHECK)
			return

		viewer_queue -= viewer

		var/client/viewer_client = viewer.parent

		var/atom/eye = viewer_client.eye
		var/turf/turf = get_turf(eye)

		var/list/old_view_chunks = viewer.view_chunks

		if (!eye || !turf)
			remove_viewer_from_chunks(viewer, old_view_chunks)
			continue

		var/list/new_view_chunks = list()

		SScameras.populate_view_chunks(new_view_chunks, BOUNDS_CENTER_AND_SIZE(vector(turf.x, turf.y, turf.z), viewer.view_size))

		add_viewer_to_chunks(viewer, new_view_chunks - old_view_chunks)

		remove_viewer_from_chunks(viewer, old_view_chunks - new_view_chunks)

		viewer.view_chunks = new_view_chunks

	available_static_images.len = min(length(available_static_images), MAX_STATIC_IMAGES_PER_VIEWER * length(viewers))

/datum/controller/subsystem/camera_viewers/proc/add_viewer_to_chunks(datum/component/camera_viewer/viewer, list/chunks)
	var/client/viewer_client = viewer.parent

	for (var/datum/camera_chunk/chunk as anything in chunks)
		if (!length(chunk.viewers))
			chunk.init_viewers()
			viewed_chunks += chunk

		chunk.viewers += viewer

		var/list/static_images = chunk.static_images

		for (var/i in 1 to length(static_images))
			var/image/static_image = static_images[i]

			if (static_image)
				viewer_client.images += static_image

/datum/controller/subsystem/camera_viewers/proc/remove_viewer_from_chunks(datum/component/camera_viewer/viewer, list/chunks)
	var/client/viewer_client = viewer.parent

	for (var/datum/camera_chunk/chunk as anything in chunks)
		chunk.viewers -= viewer

		var/list/static_images = chunk.static_images

		for (var/i in 1 to length(static_images))
			var/image/static_image = static_images[i]

			if (static_image)
				viewer_client.images -= static_image

		if (!length(chunk.viewers))
			chunk.deinit_viewers()
			viewed_chunks -= chunk
