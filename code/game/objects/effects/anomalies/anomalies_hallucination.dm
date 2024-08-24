
/obj/effect/anomaly/hallucination
	name = "hallucination anomaly"
	icon_state = "hallucination"
	anomaly_core = /obj/item/assembly/signaler/anomaly/hallucination
	/// Time passed since the last effect, increased by seconds_per_tick of the SSobj
	var/ticks = 0
	/// How many seconds between each small hallucination pulses
	var/release_delay = 5
	/// Messages sent to people feeling the pulses
	var/static/list/messages = list(
		span_warning("You feel your conscious mind fall apart!"),
		span_warning("Reality warps around you!"),
		span_warning("Something's wispering around you!"),
		span_warning("You are going insane!"),
	)

/obj/effect/anomaly/hallucination/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	apply_wibbly_filters(src)
	for(var/turf/floor in orange(1, src))
		new /obj/effect/anomaly/hallucination/decoy(floor)

/obj/effect/anomaly/hallucination/anomalyEffect(seconds_per_tick)
	. = ..()
	ticks += seconds_per_tick
	if(ticks < release_delay)
		return
	ticks -= release_delay
	if(!isturf(loc))
		return

	visible_hallucination_pulse(
		center = get_turf(src),
		radius = 5,
		hallucination_duration = 50 SECONDS,
		hallucination_max_duration = 300 SECONDS,
		optional_messages = messages,
	)

/obj/effect/anomaly/hallucination/detonate()
	if(!isturf(loc))
		return

	visible_hallucination_pulse(
		center = get_turf(src),
		radius = 10,
		hallucination_duration = 50 SECONDS,
		hallucination_max_duration = 300 SECONDS,
		optional_messages = messages,
		ignore_walls = TRUE,
	)

/obj/effect/anomaly/hallucination/decoy

/obj/effect/anomaly/hallucination/decoy/anomalyEffect(seconds_per_tick)
	if(SPT_PROB(move_chance, seconds_per_tick))
		move_anomaly()

/obj/effect/anomaly/hallucination/decoy/analyzer_act(mob/living/user, obj/item/analyzer/tool)
	to_chat(user, span_notice("You activate your [tool], but it does nothing. What?"))
	return ITEM_INTERACT_BLOCKING

/obj/effect/anomaly/hallucination/decoy/detonate()
	do_sparks(3, source = src)
	return
