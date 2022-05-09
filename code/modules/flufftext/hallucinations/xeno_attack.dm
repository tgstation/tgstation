/// Xeno crawls from nearby vent, jumps at you, and goes back in.
/datum/hallucination/xeno_attack
	/// The turf the xeno attack is coming from. Has a vent on it.
	var/turf/xeno_attack_source

/datum/hallucination/xeno_attack/New(mob/living/target, source = "an external source")
	. = ..()
	if(!target || QDELETED(src))
		return

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/nearby_pump in orange(7, target))
		if(nearby_pump.welded)
			continue
		xeno_attack_source = get_turf(chosen_pump)
		break

	if(!xeno_attack_source)
		qdel(src)
		return

	feedback_details += "Vent Coords: ([pump_location.x], [pump_location.y], [pump_location.z])"

/datum/hallucination/xeno_attack/Destroy()
	xeno_attack_source = null
	return ..()

/datum/hallucination/xeno_attack/start()
	var/obj/effect/hallucination/simple/xeno/fake_xeno = new(xeno_attack_source, src)
	addtimer(CALLBACK(src, .proc/leap_at_target, fake_xeno), 1 SECONDS)

/// Leaps from the vent to the hallucinator.
/datum/hallucination/xeno_attack/proc/leap_at_target(obj/effect/hallucination/simple/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno))
		qdel(src)
		return

	fake_xeno.set_leaping()
	fake_xeno.throw_at(target, 7, 1, spin = FALSE, diagonals_first = TRUE)
	stage = XENO_ATTACK_STAGE_LEAP_AT_PUMP

	addtimer(CALLBACK(src, .proc/leap_back_to_pump, fake_xeno), 1 SECONDS)

/// Leaps from the hallucinator back to the vent.
/datum/hallucination/xeno_attack/proc/leap_back_to_pump(obj/effect/hallucination/simple/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno))
		qdel(src)
		return

	fake_xeno.set_leaping()
	fake_xeno.throw_at(pump_location, 7, 1, spin = FALSE, diagonals_first = TRUE)
	addtimer(CALLBACK(src, .proc/begin_crawling, fake_xeno), 1 SECONDS)

/// Mimics ventcrawling into the vent.
/datum/hallucination/xeno_attack/proc/begin_crawling(obj/effect/hallucination/simple/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno))
		qdel(src)
		return

	to_chat(target, span_notice("[fake_xeno.name] begins climbing into the ventilation system..."))
	addtimer(CALLBACK(src, .proc/disappear, fake_xeno), 3 SECONDS)

/// Disappears into the vent, ending the hallucination.
/datum/hallucination/xeno_attack/proc/disappear(obj/effect/hallucination/simple/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(!QDELETED(fake_xeno))
		to_chat(target, span_notice("[xeno.name] scrambles into the ventilation ducts!"))

	qdel(src)

/// The xeno hallucination that goes with the xeno attack hallucination.
/obj/effect/hallucination/simple/xeno
	image_icon = 'icons/mob/alien.dmi'
	image_state = "alienh_pounce"

/obj/effect/hallucination/simple/xeno/Initialize(mapload, datum/hallucination/parent)
	name = "alien hunter ([rand(1, 1000)])"
	return ..()

// The hallucination "throws" us at the hallucinator, so whenever we impact, we're actually landing a "leap".
/obj/effect/hallucination/simple/xeno/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set_unleaping()
	if(!isliving(hit_atom))
		return
	var/mob/living/hit_living = hit_atom
	if(hit_living != parent.target || hit_living.stat != DEAD)
		return
	hit_living.Paralyze(10 SECONDS)
	hit_living.visible_message(
		span_danger("[target] flails around wildly."),
		span_userdanger("[name] pounces on you!"),
	)

/// Sets our icon to look like we're leaping.
/obj/effect/hallucination/simple/xeno/proc/set_leaping()
	image_icon = 'icons/mob/alienleap.dmi'
	image_state = "alienh_leap"
	image_pixel_x = -32
	image_pixel_y = -32
	update_icon()

/// Resets our icon to our initial state.
/obj/effect/hallucination/simple/xeno/proc/set_unleaping()
	image_icon = initial(image_icon)
	image_state = initial(image_state)
	image_pixel_x = initial(image_pixel_x)
	image_pixel_y = initial(image_pixel_y)
	update_icon()
