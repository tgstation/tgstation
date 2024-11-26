//Anomalies, used for anomaly events. Anomalies cause adverse effects on their surroundings and can be mitigated by signalling their respective frequency.
/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "vortex"
	density = FALSE
	anchored = TRUE
	light_range = 3

	var/obj/item/assembly/signaler/anomaly/anomaly_core = /obj/item/assembly/signaler/anomaly
	var/area/impact_area

	var/lifespan = ANOMALY_COUNTDOWN_TIMER
	var/death_time

	var/countdown_colour
	var/obj/effect/countdown/anomaly/countdown

	/// Do we drop a core when we're neutralized?
	var/drops_core = TRUE
	///Do we keep on living forever?
	var/immortal = FALSE
	///Chance per second that we will move
	var/move_chance = ANOMALY_MOVECHANCE

/obj/effect/anomaly/Initialize(mapload, new_lifespan, drops_core = TRUE)
	. = ..()

	if(!mapload)
		SSpoints_of_interest.make_point_of_interest(src)

	START_PROCESSING(SSobj, src)
	impact_area = get_area(src)

	if (!impact_area)
		return INITIALIZE_HINT_QDEL

	src.drops_core = drops_core
	if(anomaly_core)
		anomaly_core = new anomaly_core(src)
		anomaly_core.code = rand(1,100)
		anomaly_core.anomaly_type = type

		anomaly_core.set_frequency(sanitize_frequency(rand(MIN_FREE_FREQ, MAX_FREE_FREQ), free = TRUE))

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	if(immortal)
		return
	countdown.start()

/obj/effect/anomaly/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, immortal))
		if(vval)
			countdown.stop()
		else
			countdown.start()

/obj/effect/anomaly/process(seconds_per_tick)
	anomalyEffect(seconds_per_tick)
	if(death_time < world.time && !immortal)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	QDEL_NULL(anomaly_core)
	return ..()

/obj/effect/anomaly/proc/anomalyEffect(seconds_per_tick)
	if(SPT_PROB(move_chance, seconds_per_tick))
		move_anomaly()

/// Move in a direction
/obj/effect/anomaly/proc/move_anomaly()
	step(src, pick(GLOB.alldirs))

/obj/effect/anomaly/proc/detonate()
	return

/obj/effect/anomaly/ex_act(severity, target)
	if(severity >= EXPLODE_DEVASTATE)
		qdel(src)
		return TRUE

	return FALSE

/obj/effect/anomaly/proc/anomalyNeutralize()
	new /obj/effect/particle_effect/fluid/smoke/bad(loc)
	SSblackbox.record_feedback(
		"nested tally",
		"anomaly_defused",
		1,
		list(
			"[type]",
			immortal ? "immortal" : "[round((death_time - world.time) / 10)]ds time left",
		)
	)

	if(drops_core)
		if(isnull(anomaly_core))
			stack_trace("An anomaly ([src]) exists that drops a core, yet has no core!")
		else
			var/anomaly_type = anomaly_core.type
			if (SSresearch.is_core_available(anomaly_type))
				SSresearch.increment_existing_anomaly_cores(anomaly_type)
				anomaly_core.forceMove(drop_location())
				anomaly_core = null
			else // You exceeded the cap sorry
				visible_message(span_warning("[anomaly_core] loses its lustre as it falls to the ground, there is too little ambient energy to support another core of this type."))
				new /obj/item/inert_anomaly(drop_location())

	// else, anomaly core gets deleted by qdel(src).

	qdel(src)

/obj/effect/anomaly/analyzer_act(mob/living/user, obj/item/analyzer/tool)
	if(!isnull(anomaly_core))
		to_chat(user, span_notice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(anomaly_core.frequency)], code [anomaly_core.code]."))
		return ITEM_INTERACT_SUCCESS
	to_chat(user, span_notice("Analyzing... [src]'s unstable field is not fluctuating along a stable frequency."))
	return ITEM_INTERACT_BLOCKING


///Stabilize an anomaly, letting it stay around forever or untill destabilizes by a player. An anomaly without a core can't be signalled, but can be destabilized
/obj/effect/anomaly/proc/stabilize(anchor = FALSE, has_core = TRUE)
	immortal = TRUE
	name = (has_core ? "stable " : "hollow ") + name
	if(!has_core)
		drops_core = FALSE
		QDEL_NULL(anomaly_core)
	if (anchor)
		move_chance = 0
