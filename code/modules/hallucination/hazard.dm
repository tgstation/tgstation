/* Hazard Hallucinations
 *
 * Contains:
 * Lava
 * Chasm
 * Anomaly
 */

/datum/hallucination/dangerflash

/datum/hallucination/dangerflash/New(mob/living/carbon/C, forced = TRUE, danger_type)
	set waitfor = FALSE
	..()
	//Flashes of danger

	var/list/possible_points = list()
	for(var/turf/open/floor/F in view(target,world.view))
		possible_points += F
	if(possible_points.len)
		var/turf/open/floor/danger_point = pick(possible_points)
		if(!danger_type)
			danger_type = pick("lava","chasm","anomaly")
		switch(danger_type)
			if("lava")
				new /obj/effect/hallucination/danger/lava(danger_point, target)
			if("chasm")
				new /obj/effect/hallucination/danger/chasm(danger_point, target)
			if("anomaly")
				new /obj/effect/hallucination/danger/anomaly(danger_point, target)

	qdel(src)

/obj/effect/hallucination/danger
	var/image/image

/obj/effect/hallucination/danger/proc/show_icon()
	return

/obj/effect/hallucination/danger/proc/clear_icon()
	if(image && target.client)
		target.client.images -= image

/obj/effect/hallucination/danger/Initialize(mapload, _target)
	. = ..()
	target = _target
	show_icon()
	QDEL_IN(src, rand(200, 450))

/obj/effect/hallucination/danger/Destroy()
	clear_icon()
	. = ..()

/obj/effect/hallucination/danger/lava
	name = "lava"

/obj/effect/hallucination/danger/lava/Initialize(mapload, _target)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/lava/show_icon()
	var/turf/danger_turf = get_turf(src)
	image = image('icons/turf/floors/lava.dmi', src, "lava-[danger_turf.smoothing_junction || 0]", TURF_LAYER)
	if(target.client)
		target.client.images += image

/obj/effect/hallucination/danger/lava/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == target)
		target.adjustStaminaLoss(20)
		new /datum/hallucination/fire(target)

/obj/effect/hallucination/danger/chasm
	name = "chasm"

/obj/effect/hallucination/danger/chasm/Initialize(mapload, _target)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/chasm/show_icon()
	var/turf/danger_turf = get_turf(src)
	image = image('icons/turf/floors/chasms.dmi', src, "chasms-[danger_turf.smoothing_junction || 0]", TURF_LAYER)
	if(target.client)
		target.client.images += image

/obj/effect/hallucination/danger/chasm/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == target)
		if(istype(target, /obj/effect/dummy/phased_mob))
			return
		to_chat(target, span_userdanger("You fall into the chasm!"))
		target.Paralyze(40)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, target, span_notice("It's surprisingly shallow.")), 15)
		QDEL_IN(src, 30)

/obj/effect/hallucination/danger/anomaly
	name = "flux wave anomaly"

/obj/effect/hallucination/danger/anomaly/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/anomaly/process(delta_time)
	if(DT_PROB(45, delta_time))
		step(src,pick(GLOB.alldirs))

/obj/effect/hallucination/danger/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/hallucination/danger/anomaly/show_icon()
	image = image('icons/effects/effects.dmi',src,"electricity2",OBJ_LAYER+0.01)
	if(target.client)
		target.client.images += image

/obj/effect/hallucination/danger/anomaly/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == target)
		new /datum/hallucination/shock(target)
