/* Hostile Mob Hallucinations
 *
 * Contains:
 * Xeno
 * Clown
 * Bubblegum
 */

/obj/effect/hallucination/simple/xeno
	image_icon = 'icons/mob/alien.dmi'
	image_state = "alienh_pounce"

/obj/effect/hallucination/simple/xeno/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	name = "alien hunter ([rand(1, 1000)])"

/obj/effect/hallucination/simple/xeno/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	update_icon(ALL, "alienh_pounce")
	if(hit_atom == target && target.stat!=DEAD)
		target.Paralyze(100)
		target.visible_message(span_danger("[target] flails around wildly."),span_userdanger("[name] pounces on you!"))

// The numbers of seconds it takes to get to each stage of the xeno attack choreography
#define XENO_ATTACK_STAGE_LEAP_AT_TARGET 1
#define XENO_ATTACK_STAGE_LEAP_AT_PUMP 2
#define XENO_ATTACK_STAGE_CLIMB 3
#define XENO_ATTACK_STAGE_FINISH 6

/// Xeno crawls from nearby vent,jumps at you, and goes back in
/datum/hallucination/xeno_attack
	var/turf/pump_location = null
	var/obj/effect/hallucination/simple/xeno/xeno = null
	var/time_processing = 0
	var/stage = XENO_ATTACK_STAGE_LEAP_AT_TARGET

/datum/hallucination/xeno_attack/New(mob/living/carbon/C, forced = TRUE)
	..()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			pump_location = get_turf(U)
			break

	if(pump_location)
		feedback_details += "Vent Coords: [pump_location.x],[pump_location.y],[pump_location.z]"
		xeno = new(pump_location, target)
		START_PROCESSING(SSfastprocess, src)
	else
		qdel(src)

/datum/hallucination/xeno_attack/process(delta_time)
	time_processing += delta_time

	if (time_processing >= stage)
		switch (time_processing)
			if (XENO_ATTACK_STAGE_FINISH to INFINITY)
				to_chat(target, span_notice("[xeno.name] scrambles into the ventilation ducts!"))
				qdel(src)
			if (XENO_ATTACK_STAGE_CLIMB to XENO_ATTACK_STAGE_FINISH)
				to_chat(target, span_notice("[xeno.name] begins climbing into the ventilation system..."))
				stage = XENO_ATTACK_STAGE_FINISH
			if (XENO_ATTACK_STAGE_LEAP_AT_PUMP to XENO_ATTACK_STAGE_CLIMB)
				xeno.update_icon(ALL, "alienh_leap", 'icons/mob/alienleap.dmi', -32, -32)
				xeno.throw_at(pump_location, 7, 1, spin = FALSE, diagonals_first = TRUE)
				stage = XENO_ATTACK_STAGE_CLIMB
			if (XENO_ATTACK_STAGE_LEAP_AT_TARGET to XENO_ATTACK_STAGE_LEAP_AT_PUMP)
				xeno.update_icon(ALL, "alienh_leap", 'icons/mob/alienleap.dmi', -32, -32)
				xeno.throw_at(target, 7, 1, spin = FALSE, diagonals_first = TRUE)
				stage = XENO_ATTACK_STAGE_LEAP_AT_PUMP

/datum/hallucination/xeno_attack/Destroy()
	. = ..()

	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(xeno)
	pump_location = null

#undef XENO_ATTACK_STAGE_LEAP_AT_TARGET
#undef XENO_ATTACK_STAGE_LEAP_AT_PUMP
#undef XENO_ATTACK_STAGE_CLIMB
#undef XENO_ATTACK_STAGE_FINISH

/obj/effect/hallucination/simple/clown
	image_icon = 'icons/mob/animal.dmi'
	image_state = "clown"

/obj/effect/hallucination/simple/clown/Initialize(mapload, mob/living/carbon/T, duration)
	..(loc, T)
	name = pick(GLOB.clown_names)
	QDEL_IN(src,duration)

/obj/effect/hallucination/simple/clown/scary
	image_state = "scary_clown"

/obj/effect/hallucination/simple/bubblegum
	name = "Bubblegum"
	image_icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	image_state = "bubblegum"
	px = -32

/datum/hallucination/oh_yeah
	var/obj/effect/hallucination/simple/bubblegum/bubblegum
	var/image/fakebroken
	var/image/fakerune
	var/turf/landing
	var/charged
	var/next_action = 0

/datum/hallucination/oh_yeah/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	. = ..()
	var/turf/closed/wall/wall
	for(var/turf/closed/wall/W in range(7,target))
		wall = W
		break
	if(!wall)
		return INITIALIZE_HINT_QDEL
	feedback_details += "Source: [wall.x],[wall.y],[wall.z]"

	fakebroken = image('icons/turf/floors.dmi', wall, "plating", layer = TURF_LAYER)
	landing = get_turf(target)
	var/turf/landing_image_turf = get_step(landing, SOUTHWEST) //the icon is 3x3
	fakerune = image('icons/effects/96x96.dmi', landing_image_turf, "landing", layer = ABOVE_OPEN_TURF_LAYER)
	fakebroken.override = TRUE
	if(target.client)
		target.client.images |= fakebroken
		target.client.images |= fakerune
	target.playsound_local(wall,'sound/effects/meteorimpact.ogg', 150, 1)
	bubblegum = new(wall, target)
	addtimer(CALLBACK(src, .proc/start_processing), 10)

/datum/hallucination/oh_yeah/proc/start_processing()
	if (isnull(target))
		qdel(src)
		return
	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/oh_yeah/process(delta_time)
	next_action -= delta_time

	if (next_action > 0)
		return

	if (get_turf(bubblegum) != landing && target?.stat != DEAD)
		if(!landing || (get_turf(bubblegum)).loc.z != landing.loc.z)
			qdel(src)
			return
		bubblegum.forceMove(get_step_towards(bubblegum, landing))
		bubblegum.setDir(get_dir(bubblegum, landing))
		target.playsound_local(get_turf(bubblegum), 'sound/effects/meteorimpact.ogg', 150, 1)
		shake_camera(target, 2, 1)
		if(bubblegum.Adjacent(target) && !charged)
			charged = TRUE
			target.Paralyze(80)
			target.adjustStaminaLoss(40)
			step_away(target, bubblegum)
			shake_camera(target, 4, 3)
			target.visible_message(span_warning("[target] jumps backwards, falling on the ground!"),span_userdanger("[bubblegum] slams into you!"))
		next_action = 0.2
	else
		STOP_PROCESSING(SSfastprocess, src)
		QDEL_IN(src, 3 SECONDS)

/datum/hallucination/oh_yeah/Destroy()
	if(target.client)
		target.client.images.Remove(fakebroken)
		target.client.images.Remove(fakerune)
	QDEL_NULL(fakebroken)
	QDEL_NULL(fakerune)
	QDEL_NULL(bubblegum)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()
