/// Hallucinations that create a hazard somewhere nearby that actually has a danger associated.
/datum/hallucination/hazard
	/// The type of effect we create
	var/hazard_type = /obj/effect/hallucination/danger

/datum/hallucination/hazard/start()
	var/list/possible_points = list()
	for(var/turf/open/floor/floor_in_view in view(hallucinator))
		possible_points += floor_in_view

	if(!length(possible_points))
		return FALSE

	new hazard_type(pick(possible_points), src)
	QDEL_IN(src, rand(20 SECONDS, 45 SECONDS))
	return TRUE

/datum/hallucination/hazard/lava
	hazard_type = /obj/effect/hallucination/danger/lava

/datum/hallucination/hazard/chasm
	hazard_type = /obj/effect/hallucination/danger/chasm

/datum/hallucination/hazard/anomaly
	hazard_type = /obj/effect/hallucination/danger/anomaly

/// These hallucination effects cause side effects when the hallucinator walks into them.
/obj/effect/hallucination/danger
	image_layer = TURF_LAYER

/obj/effect/hallucination/danger/Initialize(mapload, datum/hallucination/parent)
	. = ..()
	if(!parent)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(entered != parent.hallucinator)
		return

	on_hallucinator_entered(entered)

/// Applies effects whenever the hallucinator enters the turf with our hallucination present.
/obj/effect/hallucination/danger/proc/on_hallucinator_entered(mob/living/afflicted)
	return

/obj/effect/hallucination/danger/lava
	name = "lava"
	image_icon = 'icons/turf/floors/lava.dmi'

/obj/effect/hallucination/danger/lava/generate_image()
	var/turf/danger_turf = get_turf(src)
	image_state = "lava-[danger_turf.smoothing_junction || 0]"
	return ..()

/obj/effect/hallucination/danger/lava/on_hallucinator_entered(mob/living/afflicted)
	afflicted.adjustStaminaLoss(20)
	afflicted.cause_hallucination(/datum/hallucination/fire, source = "fake lava hallucination")

/obj/effect/hallucination/danger/chasm
	name = "chasm"
	image_icon = 'icons/turf/floors/chasms.dmi'

/obj/effect/hallucination/danger/chasm/generate_image()
	var/turf/danger_turf = get_turf(src)
	image_state = "chasms-[danger_turf.smoothing_junction || 0]"
	return ..()

/obj/effect/hallucination/danger/chasm/on_hallucinator_entered(mob/living/afflicted)
	to_chat(afflicted, span_userdanger("You fall into the chasm!"))
	afflicted.Paralyze(4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, afflicted, span_notice("...It's surprisingly shallow.")), 1.5 SECONDS)
	QDEL_IN(src, 3 SECONDS)

/obj/effect/hallucination/danger/anomaly
	name = "flux wave anomaly"
	image_icon = 'icons/effects/effects.dmi'
	image_state = "electricity2"
	image_layer = OBJ_LAYER + 0.01

/obj/effect/hallucination/danger/anomaly/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/hallucination/danger/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/hallucination/danger/anomaly/process(delta_time)
	if(DT_PROB(45, delta_time))
		step(src, pick(GLOB.alldirs))

/obj/effect/hallucination/danger/anomaly/on_hallucinator_entered(mob/living/afflicted)
	afflicted.cause_hallucination(/datum/hallucination/shock, source = "fake anomaly hallucination")
