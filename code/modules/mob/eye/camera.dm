/**
 * An invisible (no icon) mob used to look around the cameranet. \
 * It streams chunks as it moves around, which will show what the user can and cannot see.
 */
/mob/eye/camera
	name = "Inactive Camera Eye"
	icon = 'icons/mob/eyemob.dmi'
	icon_state = "generic_camera"

	invisibility = INVISIBILITY_MAXIMUM
	interaction_range = INFINITY
	/// If TRUE, the eye will cover turfs hidden to the cameranet with static.
	var/use_visibility = TRUE
	/// List of [/datum/camerachunk]s seen by this camera.
	var/list/visibleCameraChunks = list()
	/// NxN Range of a single camera chunk.
	var/static_visibility_range = 16

/mob/eye/camera/Initialize(mapload)
	. = ..()
	GLOB.camera_eyes += src
	setLoc(loc, TRUE)

/**
 * Returns a list of turfs visible to the client's viewsize. \
 * Note that this will return an empty list if the camera's loc is not a turf.
 */
/mob/eye/camera/proc/get_visible_turfs()
	RETURN_TYPE(/list/turf)
	SHOULD_BE_PURE(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(!isturf(loc))
		return list()
	var/client/C = GetViewerClient()
	var/view = C ? getviewsize(C.view) : getviewsize(world.view)
	var/turf/lowerleft = locate(max(1, x - (view[1] - 1)/2), max(1, y - (view[2] - 1)/2), z)
	var/turf/upperright = locate(min(world.maxx, lowerleft.x + (view[1] - 1)), min(world.maxy, lowerleft.y + (view[2] - 1)), lowerleft.z)
	return block(lowerleft, upperright)

/// Used in cases when the eye is located in a movable object (i.e. mecha)
/mob/eye/camera/proc/update_visibility()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	if(use_visibility)
		GLOB.cameranet.visibility(src)
/**
 * Use this when setting the camera eye's location. \
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

/mob/eye/camera/zMove(dir, turf/target, z_move_flags = NONE, recursions_left = 1, list/falling_movs)
	. = ..()
	if(.)
		setLoc(loc, force_update = TRUE)

/mob/eye/camera/ai/Move()
	SHOULD_NOT_OVERRIDE(TRUE)
	return

/**
 * Getter proc for getting the current user's client.
 *
 * The base version of this proc returns null. \
 * Subtypes are expected to overload this proc and make it return something meaningful.
 */
/mob/eye/camera/proc/GetViewerClient()
	RETURN_TYPE(/client)
	SHOULD_BE_PURE(TRUE)

	return null

/mob/eye/camera/ai/Destroy()
	for(var/V in visibleCameraChunks)
		var/datum/camerachunk/c = V
		c.remove(src)
	GLOB.camera_eyes -= src
	return ..()
