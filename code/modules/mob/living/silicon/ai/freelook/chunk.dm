/**
 * A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed. \
 * Allows Camera Eyes to stream these chunks and know what it can and cannot see.
 */

/datum/camerachunk
	/// List of cameras that are within viewing range of this camera chunk.
	var/list/cameras = list()
	/// List of turf visibility in this camera chunk. (list[coord_index] = viewing_camera_count)
	var/list/visibility = list()
	/// List of atoms that caused this camera chunk to update.
	var/list/sources = list()

	var/x = 0
	var/y = 0
	var/z = 0

/datum/camerachunk/New()
	SScameras.chunks += src

/datum/camerachunk/Destroy(force)
	SScameras.chunks -= src
