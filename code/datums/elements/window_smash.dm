/**
 * # Window Smashing
 * An element you put on mobs to let them smash through walls on movement
 * For example, throwing someone through a glass window
 */
/datum/element/window_smashing

/datum/element/window_smashing/Attach(datum/target, duration = 1.5 SECONDS)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/living_target = target
	RegisterSignal(living_target, COMSIG_MOVABLE_MOVED, PROC_REF(flying_window_smash))
	passwindow_on(target, TRAM_PASSENGER_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(Detach), living_target), duration)

/// Smash any windows that the mob is flying through
/datum/element/window_smashing/proc/flying_window_smash(atom/movable/flying_mob, atom/old_loc, direction)
	SIGNAL_HANDLER
	var/turf/target_turf = get_turf(flying_mob)
	for(var/obj/structure/tram/tram_wall in target_turf)
		tram_wall.smash_and_injure(flying_mob, old_loc, direction)

	for(var/obj/structure/window/window in target_turf)
		window.smash_and_injure(flying_mob, old_loc, direction)

	for(var/obj/structure/grille/grille in target_turf)
		grille.smash_and_injure(flying_mob, old_loc, direction)

/datum/element/window_smashing/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	passwindow_off(source, TRAM_PASSENGER_TRAIT)
	return ..()
