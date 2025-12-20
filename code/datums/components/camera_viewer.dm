/datum/component/camera_viewer
	var/vector/view_size

	var/list/view_chunks = list()
	var/list/view_static = list()

	var/list/static_images = list()

/datum/component/camera_viewer/Initialize(...)
	if (!istype(parent, /client))
		return COMPONENT_INCOMPATIBLE

	var/client/viewer_client = parent
	set_view(viewer_client.view)

/datum/component/camera_viewer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLIENT_SET_EYE, PROC_REF(set_eye))
	RegisterSignal(parent, COMSIG_VIEW_SET, PROC_REF(set_view))

/datum/component/camera_viewer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CLIENT_SET_EYE)

/datum/component/camera_viewer/proc/set_eye(client/viewer_client, atom/old_eye, atom/new_eye)
	SIGNAL_HANDLER

	if (old_eye)
		if (!new_eye)
			clear_view()
		UnregisterSignal(old_eye, COMSIG_MOVABLE_MOVED)

	if (new_eye)
		update_view()
		RegisterSignal(new_eye, COMSIG_MOVABLE_MOVED, PROC_REF(update_view))

/datum/component/camera_viewer/proc/set_view(client/viewer_client, view_size_string)
	SIGNAL_HANDLER

	var/list/view_size_list = getviewsize(view_size_string)

	view_size = vector(view_size_list[1], view_size_list[2])

	if (viewer_client.eye)
		update_view()

/datum/component/camera_viewer/proc/update_view()
	SIGNAL_HANDLER

	var/client/viewer_client = parent

	for (var/image/static_image as anything in view_static)
		static_image.loc = null
	view_static.Cut()

	for (var/datum/camerachunk/chunk as anything in view_chunks)
		chunk.viewers -= src
	view_chunks.Cut()

	var/atom/eye = viewer_client.eye
	var/turf/turf = get_turf(eye)

	if (!turf)
		return

	SScameras.populate_view_chunks(view_chunks, BOUNDS_CENTER_AND_SIZE(vector(turf.x, turf.y, turf.z), view_size), create_new_if_null = FALSE)

	for (var/datum/camerachunk/chunk as anything in view_chunks)
		chunk.viewers += src

/datum/component/camera_viewer/proc/clear_view()
	var/client/viewer_client = parent
