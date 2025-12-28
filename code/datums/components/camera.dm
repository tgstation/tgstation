/datum/component/camera
	/// Whether the camera can see anything at all.
	var/enabled
	/// How far the camera can see in turfs, not including the center turf.
	var/range

	/// The turfs that the camera can see.
	var/alist/turfs
	/// The chunks that the camera can see.
	var/alist/chunks

/datum/component/camera/Initialize(enabled = TRUE, view_range = 0)
	if (!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE

	SScameras.cameras += src

	set_enabled(enabled)
	set_view_range(view_range)

/datum/component/camera/Destroy(force)
	SScameras.cameras -= src
	SScameras.camera_queue -= src

	return ..()

/datum/component/camera/proc/set_enabled(new_enabled)
	new_enabled = !!new_enabled // Force it into a boolean value.

	if (enabled == new_enabled)
		return

	enabled = new_enabled

	if ((enabled && !view_data) || (!enabled && view_data))
		SScameras.camera_queue += src
	else
		SScameras.camera_queue -= src

/datum/component/camera/proc/set_range(new_range)
	if (!isnum(new_range))
		CRASH("/datum/component/camera/proc/set_range(): new_range must be a number")

	if (range == new_range)
		return

	range = new_range

	if (enabled)
		SScameras.camera_queue += src
