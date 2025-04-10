/**
 * Eye mob used to look around a [camera network][/datum/cameranet]. \
 * As it moves, it makes requests to the network to update what the user can and cannot see.
 */
/mob/eye/camera
	name = "Inactive Camera Eye"
	icon = 'icons/mob/eyemob.dmi'
	icon_state = "generic_camera"

	invisibility = INVISIBILITY_OBSERVER
	interaction_range = INFINITY
	/// If TRUE, the eye will cover turfs hidden to the cameranet with static.
	var/use_visibility = TRUE
	/// List of [camera chunks][/datum/camerachunk] visible to this camera.
	/// Please don't interface with this directly. Use the [cameranet][/datum/cameranet].
	VAR_FINAL/list/datum/camerachunk/visibleCameraChunks = list()
	/// NxN Range of a single camera chunk.
	var/static_visibility_range = 16

/mob/eye/camera/Initialize(mapload)
	. = ..()
	GLOB.camera_eyes += src

/mob/eye/camera/Destroy()
	for(var/datum/camerachunk/chunk in visibleCameraChunks)
		chunk.remove(src)
	GLOB.camera_eyes -= src
	return ..()

/**
 * Getter proc for getting the current user's client.
 *
 * The base version of this proc returns null.
 * Subtypes are expected to overload this proc and make it return something meaningful.
 */
/mob/eye/camera/proc/GetViewerClient()
	RETURN_TYPE(/client)
	SHOULD_BE_PURE(TRUE)

	return null

/**
 * Use this when setting the camera eye's location directly. \
 * It will also attempt to update visible chunks.
 */
/mob/eye/camera/proc/setLoc(destination, force_update = FALSE)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	destination = get_turf(destination)
	if(!force_update && (destination == get_turf(src)))
		return

	if(destination)
		abstract_move(destination)
	else
		moveToNullspace()

	if(use_visibility)
		update_visibility()
	update_parallax_contents()

/// Sends a visibility query to the cameranet.
/// Can be used as a signal handler.
/mob/eye/camera/proc/update_visibility()
	SIGNAL_HANDLER
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(use_visibility)
		GLOB.cameranet.visibility(src)

/mob/eye/camera/zMove(dir, turf/target, z_move_flags = NONE, recursions_left = 1, list/falling_movs)
	. = ..()
	if(.)
		setLoc(loc, force_update = TRUE)

/mob/eye/camera/Move()
	SHOULD_NOT_OVERRIDE(TRUE)
	return
