/datum/brain_trauma/special/bluespace_prophet
	name = "Bluespace Prophecy"
	desc = "Patient can sense the bob and weave of bluespace around them, showing them passageways no one else can see."
	scan_desc = "bluespace attunement"
	gain_text = "<span class='notice'>You feel the bluespace pulsing around you...</span>"
	lose_text = "<span class='warning'>The faint pulsing of bluespace fades into silence.</span>"

	/// The typepath of stream we spawn in
	var/stream_type = /obj/effect/client_image_holder/bluespace_stream
	/// Cooldown so we can't teleport literally everywhere on a whim
	COOLDOWN_DECLARE(portal_cooldown)

/datum/brain_trauma/special/bluespace_prophet/on_life(delta_time, times_fired)
	if(!COOLDOWN_FINISHED(src, portal_cooldown))
		return

	COOLDOWN_START(src, portal_cooldown, 10 SECONDS)
	var/list/turf/possible_turfs = list()
	for(var/turf/T as anything in RANGE_TURFS(8, owner))
		if(T.density)
			continue

		var/clear = TRUE
		for(var/obj/O in T)
			if(O.density)
				clear = FALSE
				break
		if(clear)
			possible_turfs += T

	if(!LAZYLEN(possible_turfs))
		return

	var/turf/first_turf = pick(possible_turfs)
	if(!first_turf)
		return

	possible_turfs -= (possible_turfs & range(first_turf, 3))

	var/turf/second_turf = pick(possible_turfs)
	if(!second_turf)
		return

	new stream_type(first_turf, owner, second_turf)

/obj/effect/client_image_holder/bluespace_stream
	name = "bluespace stream"
	desc = "You see a hidden pathway through bluespace..."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "bluestream"
	image_layer = ABOVE_MOB_LAYER
	image_plane = GAME_PLANE_UPPER
	var/obj/effect/client_image_holder/bluespace_stream/linked_to

/obj/effect/client_image_holder/bluespace_stream/Initialize(mapload, list/mobs_which_see_us, turf/other_stream_loc, obj/effect/client_image_holder/bluespace_stream/first_stream)
	. = ..()
	//properly sync up
	if(other_stream_loc)
		linked_to = new type(other_stream_loc, mobs_which_see_us, null, src)
	if(first_stream)
		linked_to = first_stream
	QDEL_IN(src, 30 SECONDS)

/obj/effect/client_image_holder/bluespace_stream/Destroy()
	if(!QDELETED(linked_to))
		qdel(linked_to)
	linked_to = null
	return ..()

/obj/effect/client_image_holder/bluespace_stream/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!(user in who_sees_us) || !linked_to)
		return

	attempt_teleport(user, modifiers)

/obj/effect/client_image_holder/bluespace_stream/proc/attempt_teleport(mob/user, list/modifiers)
	SHOULD_CALL_PARENT(FALSE)
	to_chat(user, span_notice("You try to align with the bluespace stream..."))
	if(!do_after(user, 2 SECONDS, target = src))
		return

	var/turf/source_turf = get_turf(src)
	var/turf/destination_turf = get_turf(linked_to)

	new /obj/effect/temp_visual/bluespace_fissure(source_turf)
	new /obj/effect/temp_visual/bluespace_fissure(destination_turf)

	var/slip_in_message = pick(
		"slides sideways in an odd way, and disappears",
		"jumps into an unseen dimension",
		"sticks one leg straight out, wiggles [user.p_their()] foot, and is suddenly gone",
		"stops, then blinks out of reality",
		"is pulled into an invisible vortex, vanishing from sight",
	)
	var/slip_out_message = pick(
		"silently fades in",
		"leaps out of thin air",
		"appears",
		"walks out of an invisible doorway",
		"slides out of a fold in spacetime",
	)

	user.visible_message(span_warning("[user] [slip_in_message]."), ignored_mobs = user)

	if(do_teleport(user, destination_turf, no_effects = TRUE))
		user.visible_message(span_warning("[user] [slip_out_message]."), span_notice("...and find your way to the other side."))
	else
		user.visible_message(span_warning("[user] [slip_out_message], ending up exactly where they left."), span_notice("...and find yourself where you started?"))

/obj/effect/client_image_holder/bluespace_stream/attack_tk(mob/user)
	to_chat(user, span_warning("\The [src] actively rejects your mind, and the bluespace energies surrounding it disrupt your telekinesis!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Phobetor trauma, given to Beefmen
/datum/brain_trauma/special/bluespace_prophet/phobetor
	name = "Sleepless Dreamer"
	desc = "The patient, after undergoing untold psychological hardship, believes they can travel between the dreamscapes of this dimension."
	scan_desc = "awoken sleeper"
	gain_text = "<span class='notice'>Your mind snaps, and you wake up. You <i>really</i> wake up."
	lose_text = "<span class='warning'>You succumb once more to the sleepless dream of the unwoken."

	stream_type = /obj/effect/client_image_holder/bluespace_stream/phobetor

/**
 * Phobetor tear
 * A bluespace tear, but you can't be watched at the arrival or destination of the tears.
 */
/obj/effect/client_image_holder/bluespace_stream/phobetor
	name = "phobetor tear"
	desc = "A subdimensional rip in reality, which gives extra-spacial passage to those who have woken from the sleepless dream."
	image_state = "phobetor_tear"
	// Place this above shadows so it always glows.
	image_layer = ABOVE_LIGHTING_PLANE

/obj/effect/client_image_holder/bluespace_stream/phobetor/Initialize(mapload, list/mobs_which_see_us, turf/other_stream_loc, obj/effect/client_image_holder/bluespace_stream/first_stream)
	. = ..()
	name += " - ([get_area(linked_to)])"
	desc += " This one leads to [get_area(linked_to)]."

/obj/effect/client_image_holder/bluespace_stream/phobetor/attempt_teleport(mob/living/user, list/modifiers)
	if(user.loc != loc)
		to_chat(user, "Step into the Tear before using it.")
		return
	var/obj/item/implant/tracking/imp = locate() in user.implants
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
	user.playsound_local(src, 'sound/magic/wand_teleport.ogg', 30, FALSE, pressure_affected = FALSE)
	user.forceMove(get_turf(linked_to))

/obj/effect/client_image_holder/bluespace_stream/phobetor/proc/check_location_seen(atom/subject, turf/target_turf)
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
