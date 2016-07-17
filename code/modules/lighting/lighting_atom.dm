/atom
	var/light_power = 1 // Intensity of the light.
	var/light_range = 0 // Range in tiles of the light.
	var/light_color     // Hexadecimal RGB string representing the colour of the light.

	var/tmp/datum/light_source/light // Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/list/light_sources       // Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.

// The proc you should always use to set the light of this atom.
/atom/proc/set_light(var/l_range, var/l_power, var/l_color)
	if (l_power != null)
		light_power = l_power

	if (l_range != null)
		light_range = l_range

	if (l_color != null)
		light_color = l_color

	update_light()

// Will update the light (duh).
// Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	set waitfor = FALSE
	if (gcDestroyed)
		return

	if (!global.lighting_corners_initialised)
		sleep(20)

	if (!light_power || !light_range) // We won't emit light anyways, destroy the light source.
		if(light)
			light.destroy()
			light = null
	else
		if (!istype(loc, /atom/movable)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if (light) // Update the light or create it if it does not exist.
			light.update(.)
		else
			light = new/datum/light_source(src, .)

// Incase any lighting vars are on in the typepath we turn the light on in New().
/atom/New()
	. = ..()

	if (light_power && light_range)
		update_light()

	if (opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

// Destroy our light source so we GC correctly.
/atom/Destroy()
	if (light)
		light.destroy()
		light = null
	. = ..()

// If we have opacity, make sure to tell (potentially) affected light sources.
/atom/movable/Destroy()
	var/turf/T = loc
	if (opacity && istype(T))
		T.reconsider_lights()

	. = ..()

// Should always be used to change the opacity of an atom.
// It notifies (potentially) affected light sources so they can update (if needed).
/atom/proc/set_opacity(var/new_opacity)
	var/old_opacity = opacity
	opacity = new_opacity
	var/turf/T = loc
	if (old_opacity != new_opacity && istype(T))
		T.reconsider_lights()

// This code makes the light be queued for update when it is moved.
// Entered() should handle it, however Exited() can do it if it is being moved to nullspace (as there would be no Entered() call in that situation).
/atom/Entered(var/atom/movable/Obj, var/atom/OldLoc) //Implemented here because forceMove() doesn't call Move()
	. = ..()

	if (Obj && OldLoc != src)
		for (var/datum/light_source/L in Obj.light_sources) // Cycle through the light sources on this atom and tell them to update.
			L.source_atom.update_light()

/atom/Exited(var/atom/movable/Obj, var/atom/newloc)
	. = ..()

	if (!newloc && Obj && newloc != src) // Incase the atom is being moved to nullspace, we handle queuing for a lighting update here.
		for (var/datum/light_source/L in Obj.light_sources) // Cycle through the light sources on this atom and tell them to update.
			L.source_atom.update_light()
