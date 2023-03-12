
/obj/effect/anomaly/hallucination
	name = "hallucination anomaly"
	icon_state = "hallucination"
	aSignal = /obj/item/assembly/signaler/anomaly/hallucination
	/// Time passed since the last effect, increased by delta_time of the SSobj
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

/obj/effect/anomaly/hallucination/anomalyEffect(delta_time)
	. = ..()
	ticks += delta_time
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
	)
