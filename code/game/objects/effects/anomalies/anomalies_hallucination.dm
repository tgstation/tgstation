
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
		span_warning("Something's whispering around you!"),
		span_warning("You are going insane!"),
	)
	///Do we spawn misleading decoys?
	var/spawn_decoys = TRUE

/obj/effect/anomaly/hallucination/Initialize(mapload, new_lifespan)
	. = ..()
	apply_wibbly_filters(src)
	generate_decoys()

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

	hallucination_pulse(
		center = get_turf(src),
		radius = 15,
		hallucination_duration = 50 SECONDS,
		hallucination_max_duration = 300 SECONDS,
		optional_messages = messages,
	)

/obj/effect/anomaly/hallucination/proc/generate_decoys()
	if(!spawn_decoys)
		return

	for(var/turf/floor in orange(1, src))
		if(prob(35))
			new /obj/effect/anomaly/hallucination/decoy(floor)

/obj/effect/anomaly/hallucination/decoy
	anomaly_core = null
	///Stores the fake analyzer scan text, so the result is always consistent for each anomaly.
	var/report_text

/obj/effect/anomaly/hallucination/decoy/Initialize(mapload, new_lifespan)
	. = ..()
	ADD_TRAIT(src, TRAIT_ILLUSORY_EFFECT, INNATE_TRAIT)
	report_text = pick(
		"[src]'s unstable field is fluctuating along frequency 9999999.99999, code 9999999.99999. No, no, that can't be right?",
		"It doesn't detect anything. It awaits an input, as if you're pointing it towards nothing at all. What?",
		"The interface displays [pick("a bad memory from your past", "the frequency numbers in a language you cannot read", "the first 15 digits of Pi", "yourself, from behind, angled at a 3/4ths isometric perspective")]. What the hell?",
		"Nothing happens?",
		"It reports that you are a [pick("moron", "idiot", "cretin", "lowlife", "worthless denthead", "gump")]. Huh?",
		"It tells you to try again, because you're doing it all wrong. What?",
		"It occurs to you that the anomaly you're scanning isn't actually there.",
		"It's not working. You activate %TOOL% again. Still broken. You activate %TOOL%. You activate %TOOL%. Why isn't this working??",
		"Something happens. You can't tell what. The interface on %TOOL% remains blank.",
		"What are you even trying to accomplish here? Did you really think that was going to work?",
		"Someone behind you whispers the frequency code to you, but you can't quite hear them. The interface on %TOOL% remains blank.",
		"For a brief moment, you see yourself traversing a frozen forest, before snapping back to reality. The interface on %TOOL% remains blank.",
		"Nothing interesting happens. Are you sure you're actually using it on anything?",
		"For a moment you can feel your skin falling off, then blink as the sensation vanishes. What the hell did that mean?",
		"The interface reports that you are a complete failure, and have screwed everything up again. Great work.",
		"You realize that the formatting of this message is completely wrong, and get confused. Now why would that be?",
		"%TOOL% stares back at you. It looks dissapointed, its screen practically saying 'You missed the anomaly, you dolt. There's nothing there!'",
		"Nothing. Weird, maybe %TOOL% must be broken or something?",
		"You activate %TOOL%. You activate %TOOL%. You activate %TOOL%. You activate %TOOL%. You activate %TOOL%. You activate %TOOL%. You activate %TOOL%. Why isn't it working??",
	)

/obj/effect/anomaly/hallucination/decoy/anomalyEffect(seconds_per_tick)
#ifndef UNIT_TESTS // These might move away during a CI run and cause a flaky mapping nearstation errors
	if(SPT_PROB(move_chance, seconds_per_tick))
		move_anomaly()
#endif

/obj/effect/anomaly/hallucination/decoy/analyzer_act(mob/living/user, obj/item/analyzer/tool)
	to_chat(user, span_notice("You activate [tool]. [replacetext(report_text, "%TOOL%", "[tool]")]"))
	return ITEM_INTERACT_BLOCKING

/obj/effect/anomaly/hallucination/decoy/detonate()
	do_sparks(3, source = src)
	return

/obj/effect/anomaly/hallucination/decoy/generate_decoys()
	return

///Subtype for the SM that doesn't spawn decoys, because otherwise the whole area gets flooded with dummies.
/obj/effect/anomaly/hallucination/supermatter
	spawn_decoys = FALSE
