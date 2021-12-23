/datum/component/cult_status
	// keeps track of a cultist's visible status
	// use this to update its current state:
	// eyes
	// halos
	// add overlays, manage the traits.
	// add support for multiple mobs
	// make sure not to remove this on transformation (see changelings, human -> monkey -> human)

	// this may need to be true to handle cross transformation? check this out
	can_transfer = FALSE

	///Which stage of visibilty is the cultist at?
	var/stage = STAGE_UNSEEN

/datum/component/cult_status/Initialize(...)
	. = ..()
	// register a signal here
	RegisterSignal(parent, COMSIG_CULT_VIS, .proc/raise_level)
	// idk init here

/datum/component/cult_status/proc/raise_level(var/new_stage)
	// if a stage wasn't supplied
	// this is probably just sanity checking
	// TODO: see if this is ever actually needed when done
	if (!new_stage)
		new_stage = stage + 1

	var/datum/mind/mind = parent // probably a different type path
	switch(stage)
		if (STAGE_CULT_UNSEEN)
			pass
		if (STAGE_CULT_RED_EYES)
			SEND_SOUND(parent, 'sound/hallucinations/i_see_you2.ogg')
			to_chat(mind.current, span_cultlarge(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
			addtimer(CALLBACK(src, .proc/set_eyes, mind), 20 SECONDS)
		if (STAGE_CULT_HALOS)
			SEND_SOUND(parent, 'sound/hallucinations/im_here1.ogg')
			to_chat(mind.current, span_cultlarge(span_warning("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")))
			addtimer(CALLBACK(src, .proc/set_halo, mind), 20 SECONDS)

	// TODO: raise the level?
	// apply trait or whatever

/datum/component/cult_status/proc/set_eyes()
