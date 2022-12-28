/// Sends a fake bubblegum charging through a nearby wall to our target.
/datum/hallucination/oh_yeah
	random_hallucination_weight = 1
	/// An image overlayed to the wall bubblegum comes out of, to look destroyed.
	var/image/fake_broken_wall
	/// An image put where bubblegum is expected to land, to mimic his charge "rune" icon.
	var/image/fake_rune
	/// if TRUE, we will also send one of the hallucination lines when we start.
	var/haunt_them = FALSE
	/// if haunt_them is TRUE, they will also be shown one of these lines when the hallucination occurs
	var/static/list/hallucination_lines = BUBBLEGUM_HALLUCINATION_LINES

/datum/hallucination/oh_yeah/New(mob/living/hallucinator, source = "an external source", haunt_them = FALSE)
	src.haunt_them = haunt_them
	return ..()

/datum/hallucination/oh_yeah/Destroy()
	if(fake_broken_wall)
		hallucinator.client?.images -= fake_broken_wall
		fake_broken_wall = null
	if(fake_rune)
		hallucinator.client?.images -= fake_rune
		fake_rune = null

	return ..()

/datum/hallucination/oh_yeah/start()
	var/turf/closed/wall/wall_source = locate() in range(7, hallucinator)
	if(!wall_source)
		return FALSE

	feedback_details += "Source: ([wall_source.x], [wall_source.y], [wall_source.z])"

	var/turf/target_landing_turf = get_turf(hallucinator)
	var/turf/target_landing_image_turf = get_step(target_landing_turf, SOUTHWEST) // The icon is 3x3, so we shift down+left

	if(hallucinator.client)

		fake_broken_wall = image('icons/turf/floors.dmi', wall_source, "plating", layer = TURF_LAYER)
		SET_PLANE_EXPLICIT(fake_broken_wall, FLOOR_PLANE, wall_source)
		fake_broken_wall.override = TRUE
		fake_rune = image('icons/effects/96x96.dmi', target_landing_image_turf, "landing", layer = ABOVE_OPEN_TURF_LAYER)
		SET_PLANE_EXPLICIT(fake_rune, FLOOR_PLANE, wall_source)

		hallucinator.client?.images |= fake_broken_wall
		hallucinator.client?.images |= fake_rune

		hallucinator.playsound_local(wall_source, 'sound/effects/meteorimpact.ogg', 150, TRUE)

	if(haunt_them)
		to_chat(hallucinator, pick(hallucination_lines))

	var/obj/effect/client_image_holder/hallucination/bubblegum/fake_bubbles = new(wall_source, hallucinator, src)
	addtimer(CALLBACK(src, PROC_REF(charge_loop), fake_bubbles, target_landing_turf), 1 SECONDS)
	return TRUE

/**
 * Recursive function that operates as a "fake charge" of our effect towards the target turf.
 */
/datum/hallucination/oh_yeah/proc/charge_loop(obj/effect/client_image_holder/hallucination/bubblegum/fake_bubbles, turf/landing_turf)
	if(QDELETED(src))
		return

	if(QDELETED(hallucinator) \
		|| QDELETED(fake_bubbles) \
		|| !landing_turf \
		|| fake_bubbles.z != hallucinator.z \
		|| fake_bubbles.z != landing_turf.z \
	)
		qdel(src)
		return

	if(get_turf(fake_bubbles) == landing_turf || hallucinator.stat == DEAD)
		QDEL_IN(src, 3 SECONDS)
		return

	fake_bubbles.forceMove(get_step_towards(fake_bubbles, landing_turf))
	fake_bubbles.setDir(get_dir(fake_bubbles, landing_turf))
	hallucinator.playsound_local(get_turf(fake_bubbles), 'sound/effects/meteorimpact.ogg', 150, TRUE)
	shake_camera(hallucinator, 2, 1)

	if(fake_bubbles.Adjacent(hallucinator))
		hallucinator.Paralyze(8 SECONDS)
		hallucinator.adjustStaminaLoss(40)
		step_away(hallucinator, fake_bubbles)
		shake_camera(hallucinator, 4, 3)
		hallucinator.visible_message(
			span_warning("[hallucinator] jumps backwards, falling on the ground!"),
			span_userdanger("[fake_bubbles] slams into you!"),
		)
		QDEL_IN(src, 3 SECONDS)

	else
		addtimer(CALLBACK(src, PROC_REF(charge_loop), fake_bubbles, landing_turf), 0.2 SECONDS)

/// Fake bubblegum hallucination effect for the oh yeah hallucination
/obj/effect/client_image_holder/hallucination/bubblegum
	name = "Bubblegum"
	image_icon = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	image_state = "bubblegum"
	image_pixel_x = -32
