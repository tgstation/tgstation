/// Xeno crawls from nearby vent, jumps at you, and goes back in.
/datum/hallucination/xeno_attack
	random_hallucination_weight = 2

/datum/hallucination/xeno_attack/start()
	var/turf/xeno_attack_source
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/nearby_pump in orange(7, hallucinator))
		if(nearby_pump.welded)
			continue
		xeno_attack_source = get_turf(nearby_pump)
		break

	if(!xeno_attack_source)
		return FALSE

	feedback_details += "Vent Coords: ([xeno_attack_source.x], [xeno_attack_source.y], [xeno_attack_source.z])"

	var/obj/effect/client_image_holder/hallucination/xeno/fake_xeno = new(xeno_attack_source, hallucinator, src)
	addtimer(CALLBACK(src, PROC_REF(leap_at_target), fake_xeno, xeno_attack_source), 1 SECONDS)
	return TRUE

/// Leaps from the vent to the hallucinator.
/datum/hallucination/xeno_attack/proc/leap_at_target(obj/effect/client_image_holder/hallucination/xeno/fake_xeno, turf/attack_source)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno))
		qdel(src)
		return

	fake_xeno.set_leaping()
	fake_xeno.throw_at(hallucinator, 7, 1, spin = FALSE, diagonals_first = TRUE)
	addtimer(CALLBACK(src, PROC_REF(leap_back_to_pump), fake_xeno), 1 SECONDS)

/// Leaps from the hallucinator back to the vent.
/datum/hallucination/xeno_attack/proc/leap_back_to_pump(obj/effect/client_image_holder/hallucination/xeno/fake_xeno, turf/attack_source)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno) || !attack_source)
		qdel(src)
		return

	fake_xeno.set_leaping()
	fake_xeno.throw_at(attack_source, 7, 1, spin = FALSE, diagonals_first = TRUE)
	addtimer(CALLBACK(src, PROC_REF(begin_crawling), fake_xeno), 1 SECONDS)

/// Mimics ventcrawling into the vent.
/datum/hallucination/xeno_attack/proc/begin_crawling(obj/effect/client_image_holder/hallucination/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno))
		qdel(src)
		return

	to_chat(hallucinator, span_notice("[fake_xeno.name] begins climbing into the ventilation system..."))
	addtimer(CALLBACK(src, PROC_REF(disappear), fake_xeno), 3 SECONDS)

/// Disappears into the vent, ending the hallucination.
/datum/hallucination/xeno_attack/proc/disappear(obj/effect/client_image_holder/hallucination/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(!QDELETED(fake_xeno))
		to_chat(hallucinator, span_notice("[fake_xeno.name] scrambles into the ventilation ducts!"))

	qdel(src)

/// The xeno hallucination that goes with the xeno attack hallucination.
/obj/effect/client_image_holder/hallucination/xeno
	image_icon = 'icons/mob/nonhuman-player/alien.dmi'
	image_state = "alienh_pounce"

/obj/effect/client_image_holder/hallucination/xeno/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent)
	. = ..()
	name = "alien hunter ([rand(1, 1000)])"

// The hallucination "throws" us at the hallucinator, so whenever we impact, we're actually landing a "leap".
/obj/effect/client_image_holder/hallucination/xeno/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set_unleaping()
	if(!isliving(hit_atom))
		return
	var/mob/living/hit_living = hit_atom
	if(hit_living != parent.hallucinator || hit_living.stat == DEAD)
		return
	hit_living.Paralyze(10 SECONDS)
	hit_living.visible_message(
		span_warning("[hit_living] flails around wildly."),
		span_userdanger("[name] pounces on you!"),
	)

/// Sets our icon to look like we're leaping.
/obj/effect/client_image_holder/hallucination/xeno/proc/set_leaping()
	image_icon = 'icons/mob/nonhuman-player/alienleap.dmi'
	image_state = "alienh_leap"
	image_pixel_x = -32
	image_pixel_y = -32
	update_appearance(UPDATE_ICON)

/// Resets our icon to our initial state.
/obj/effect/client_image_holder/hallucination/xeno/proc/set_unleaping()
	image_icon = initial(image_icon)
	image_state = initial(image_state)
	image_pixel_x = initial(image_pixel_x)
	image_pixel_y = initial(image_pixel_y)
	update_appearance(UPDATE_ICON)
