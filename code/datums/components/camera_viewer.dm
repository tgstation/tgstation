/datum/component/camera_viewer
	var/vector/view_size

	var/list/view_chunks = list()

/datum/component/camera_viewer/Initialize(...)
	if (!istype(parent, /client))
		return COMPONENT_INCOMPATIBLE

	SScamera_viewers.viewers += src

	var/client/viewer_client = parent

	set_view(viewer_client.view)

	if (viewer_client.eye)
		set_eye(viewer_client, null, viewer_client.eye)

/datum/component/camera_viewer/Destroy(force)
	var/client/viewer_client = parent

	if (viewer_client.eye)
		set_eye(viewer_client, viewer_client.eye, null)

	SScamera_viewers.remove_viewer_from_chunks(src, view_chunks)

	SScamera_viewers.viewers -= src
	SScamera_viewers.viewer_queue -= src

	return ..()

/datum/component/camera_viewer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLIENT_SET_EYE, PROC_REF(set_eye))
	RegisterSignal(parent, COMSIG_VIEW_SET, PROC_REF(set_view))

/datum/component/camera_viewer/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CLIENT_SET_EYE, COMSIG_VIEW_SET))

/datum/component/camera_viewer/proc/set_eye(client/viewer_client, atom/old_eye, atom/new_eye)
	SIGNAL_HANDLER

	if (old_eye)
		UnregisterSignal(old_eye, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

	if (new_eye)
		RegisterSignal(new_eye, COMSIG_MOVABLE_MOVED, PROC_REF(on_eye_moved))
		RegisterSignal(new_eye, COMSIG_QDELETING, PROC_REF(on_eye_qdeleting))

	SScamera_viewers.viewer_queue += src

/datum/component/camera_viewer/proc/set_view(client/viewer_client, view_size_string)
	SIGNAL_HANDLER

	var/list/view_size_list = getviewsize(view_size_string)

	view_size = vector(view_size_list[1], view_size_list[2])

	SScamera_viewers.viewer_queue += src

/datum/component/camera_viewer/proc/on_eye_moved(atom/eye, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if (get_turf(eye) != get_turf(old_loc))
		SScamera_viewers.viewer_queue += src

/datum/component/camera_viewer/proc/on_eye_qdeleting(atom/eye, force)
	SIGNAL_HANDLER

	set_eye(parent, eye, null)
