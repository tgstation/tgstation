/datum/brain_trauma/magic/stalker_multiple
	name = "Stalking Phantoms"
	desc = "Patient is stalked by multiple phantoms only they can see."
	scan_desc = "extra-EXTRA-sensory paranoia"
	gain_text = span_warning("You feel like the gods have released the hounds...")
	lose_text = span_notice("You no longer feel the wrath of the gods watching you.")

	var/list/stalkers = list()

	var/close_stalker = FALSE //For heartbeat

/datum/brain_trauma/magic/stalker_multiple/Destroy()
	for (var/stalker in stalkers)
		QDEL_NULL(stalker)
	return ..()

/datum/brain_trauma/magic/stalker_multiple/on_gain()
	create_stalker_multiple(10)
	return ..()

/datum/brain_trauma/magic/stalker_multiple/proc/create_stalker()
	var/turf/stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, -6, 0, 6, 12), owner.z) //random corner
	var/obj/effect/client_image_holder/stalker_phantom/stalker = new(stalker_source, owner)
	stalkers += stalker

/datum/brain_trauma/magic/stalker_multiple/proc/create_stalker_multiple(count)
	var/turf/stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, -6, 0, 6, 12), owner.z) //random corner

	for (var/x = 0; x < count; x++)
		var/obj/effect/client_image_holder/stalker_phantom/stalker = new(stalker_source, owner)
		stalkers += stalker

/datum/brain_trauma/magic/stalker_multiple/on_lose()
	for (var/stalker in stalkers)
		QDEL_NULL(stalker)
	return ..()

/datum/brain_trauma/magic/stalker_multiple/on_life(seconds_per_tick, times_fired)
	// Dead and unconscious people are not interesting to the psychic stalker.
	if(owner.stat != CONSCIOUS)
		return

	// Not even nullspace will keep it at bay.
	for (var/obj/effect/client_image_holder/stalker_phantom/stalker in stalkers)
		if(!stalker || !stalker.loc || stalker.z != owner.z)
			stalkers -= stalker
			qdel(stalker)
			create_stalker()

	for (var/obj/effect/client_image_holder/stalker_phantom/stalker in stalkers)
		if(get_dist(owner, stalker) <= 1)
			playsound(owner, 'sound/magic/demon_attack1.ogg', 10)
			owner.visible_message(span_warning("[owner] is torn apart by invisible claws!"), span_userdanger("Ghostly claws tear your body apart!"))
			owner.take_bodypart_damage(rand(20, 45), wound_bonus=CANT_WOUND)
		else if(SPT_PROB(30, seconds_per_tick))
			stalker.forceMove(get_step_towards(stalker, owner))
		if(get_dist(owner, stalker) <= 8)
			if(!close_stalker)
				var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
				owner.playsound_local(owner, slowbeat, 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
				close_stalker = TRUE
		else
			if(close_stalker)
				owner.stop_sound_channel(CHANNEL_HEARTBEAT)
				close_stalker = FALSE
	..()
