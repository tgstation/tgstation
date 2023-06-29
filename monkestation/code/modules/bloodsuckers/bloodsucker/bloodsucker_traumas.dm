/**
 * # Phobetor Brain Trauma
 *
 * Beefmen's Brain trauma, causing phobetor tears to traverse through.
 */

/datum/brain_trauma/special/bluespace_prophet/phobetor
	name = "Sleepless Dreamer"
	desc = "The patient, after undergoing untold psychological hardship, believes they can travel between the dreamscapes of this dimension."
	scan_desc = "awoken sleeper"
	gain_text = "<span class='notice'>Your mind snaps, and you wake up. You <i>really</i> wake up."
	lose_text = "<span class='warning'>You succumb once more to the sleepless dream of the unwoken."

	///Created tears, only checking the FIRST one, not the one it's created to link to.
	var/list/created_firsts = list()

///When the trauma is removed from a mob.
/datum/brain_trauma/special/bluespace_prophet/phobetor/on_lose(silent)
	for(var/obj/effect/client_image_holder/phobetor/phobetor_tears as anything in created_firsts)
		qdel(phobetor_tears)

/datum/brain_trauma/special/bluespace_prophet/phobetor/on_life(seconds_per_tick, times_fired)
	if(!COOLDOWN_FINISHED(src, portal_cooldown))
		return
	COOLDOWN_START(src, portal_cooldown, 10 SECONDS)
	var/list/turf/possible_tears = list()
	for(var/turf/nearby_turfs as anything in RANGE_TURFS(8, owner))
		if(nearby_turfs.density)
			continue
		possible_tears += nearby_turfs
	if(!LAZYLEN(possible_tears))
		return

	var/turf/first_tear
	var/turf/second_tear
	first_tear = return_valid_floor_in_range(owner, 6, 0, TRUE)
	if(!first_tear)
		return
	second_tear = return_valid_floor_in_range(first_tear, 20, 6, TRUE)
	if(!second_tear)
		return

	var/obj/effect/client_image_holder/phobetor/first = new(first_tear, owner)
	var/obj/effect/client_image_holder/phobetor/second = new(second_tear, owner)

	first.linked_to = second
	first.seer = owner
	first.desc += " This one leads to [get_area(second)]."
	first.name += " ([get_area(second)])"
	created_firsts += first

	second.linked_to = first
	second.seer = owner
	second.desc += " This one leads to [get_area(first)]."
	second.name += " ([get_area(first)])"

	// Delete Next Portal if it's time (it will remove its partner)
	var/obj/effect/client_image_holder/phobetor/first_on_the_stack = created_firsts[1]
	if(created_firsts.len && world.time >= first_on_the_stack.created_on + first_on_the_stack.exist_length)
		var/targetGate = first_on_the_stack
		created_firsts -= targetGate
		qdel(targetGate)

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/return_valid_floor_in_range(atom/targeted_atom, checkRange = 8, minRange = 0, check_floor = TRUE)
	// FAIL: Atom doesn't exist. Aren't you real?
	if(!istype(targeted_atom))
		return FALSE
	var/delta_x = rand(minRange,checkRange)*pick(-1,1)
	var/delta_y = rand(minRange,checkRange)*pick(-1,1)
	var/turf/center = get_turf(targeted_atom)

	var/target = locate((center.x + delta_x),(center.y + delta_y), center.z)
	if(check_turf_is_valid(target, check_floor))
		return target
	return FALSE

/**
 * Used as a helper that checks if you can successfully teleport to a turf.
 * Returns a boolean, and checks for if the turf has density, if the turf's area has the NOTELEPORT flag,
 * and if the objects in the turf have density.
 * If check_floor is TRUE in the argument, it will return FALSE if it's not a type of [/turf/open/floor].
 * Arguments:
 * * turf/open_turf - The turf being checked for validity.
 * * check_floor - Checks if it's a type of [/turf/open/floor]. If this is FALSE, lava/chasms will be able to be selected.
 */
/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/check_turf_is_valid(turf/open_turf, check_floor = TRUE)
	if(check_floor && !istype(open_turf, /turf/open/floor))
		return FALSE
	if(open_turf.density)
		return FALSE
	var/area/turf_area = get_area(open_turf)
	if(turf_area.area_flags & NOTELEPORT)
		return FALSE
	// Checking for Objects...
	for(var/obj/object in open_turf)
		if(object.density)
			return FALSE
	return TRUE

/**
 * # Phobetor Tears
 *
 * The phobetor tears created by the Brain trauma.
 */

/obj/effect/client_image_holder/phobetor
	name = "phobetor tear"
	desc = "A subdimensional rip in reality, which gives extra-spacial passage to those who have woken from the sleepless dream."
	image_icon = 'monkestation/icons/effects/phobetor_tear.dmi'
	image_state = "phobetor_tear"
	// Place this above shadows so it always glows.
	image_layer = ABOVE_MOB_LAYER

	/// How long this will exist for
	var/exist_length = 50 SECONDS
	/// The time of this tear's creation
	var/created_on
	/// The phobetor tear this is linked to
	var/obj/effect/client_image_holder/phobetor/linked_to
	/// The person able to see this tear.
	var/mob/living/carbon/seer

/obj/effect/client_image_holder/phobetor/Initialize()
	. = ..()
	created_on = world.time

/obj/effect/client_image_holder/phobetor/Destroy()
	if(linked_to)
		linked_to.linked_to = null
		QDEL_NULL(linked_to)
	return ..()

/obj/effect/client_image_holder/phobetor/proc/check_location_seen(atom/subject, turf/target_turf)
	if(!target_turf)
		return FALSE
	if(!isturf(target_turf))
		return FALSE
	if(!target_turf.lighting_object || !target_turf.get_lumcount() >= 0.1)
		return FALSE
	for(var/mob/living/nearby_viewers in viewers(target_turf))
		if(nearby_viewers == subject)
			continue
		if(!isliving(nearby_viewers) || !nearby_viewers.mind)
			continue
		if(nearby_viewers.has_unlimited_silicon_privilege || nearby_viewers.is_blind())
			continue
		return TRUE
	return FALSE

/obj/effect/client_image_holder/phobetor/attack_hand(mob/living/user, list/modifiers)
	if(user != seer || !linked_to)
		return
	if(user.loc != src.loc)
		to_chat(user, "Step into the Tear before using it.")
		return
	for(var/obj/item/implant/tracking/imp in user.implants)
		if(imp)
			to_chat(user, span_warning("[imp] gives you the sense that you're being watched."))
			return
	// Is this, or linked, stream being watched?
	if(check_location_seen(user, get_turf(user)))
		to_chat(user, span_warning("Not while you're being watched."))
		return
	if(check_location_seen(user, get_turf(linked_to)))
		to_chat(user, span_warning("Your destination is being watched."))
		return
	to_chat(user, span_notice("You slip unseen through [src]."))
	user.playsound_local(null, 'sound/magic/wand_teleport.ogg', 30, FALSE, pressure_affected = FALSE)
	user.forceMove(get_turf(linked_to))
