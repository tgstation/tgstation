/datum/brain_trauma/special/obsessed
	name = "Psychotic Schizophrenia"
	desc = "Patient has a subtype of delusional disorder, becoming irrationally attached to someone."
	scan_desc = "psychotic schizophrenic delusions"
	symptoms = "Exhibits obsessive behaviors towards a specific individual, \
		including frequent staring, intrusive thoughts, and an overwhelming desire to be near them. \
		This obsession can lead to social withdrawal, anxiety, and impaired daily functioning."
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = span_warning("The voices in your head fall silent.")
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	/// Reference to the actual mob we're obsessed with
	VAR_FINAL/mob/living/obsession
	/// Reference to our antag datum
	VAR_FINAL/datum/antagonist/obsessed/antagonist
	/// Tracks if the target is currently in view
	VAR_FINAL/viewing = FALSE
	/// Tracks the total amount of time spend near the target
	VAR_FINAL/total_time_creeping = 0 SECONDS
	/// Tracks the current period of time spent away from the target (resetting when near)
	VAR_FINAL/time_spent_away = 0 SECONDS
	/// Tracks the current period of time spent near the target (resetting when away)
	VAR_FINAL/time_spend_creeping = 0 SECONDS
	/// If we've seen our obsession be dead
	VAR_FINAL/witnessed_death = FALSE

/datum/brain_trauma/special/obsessed/on_gain()
	//setup, linking, etc//
	if(!obsession)//admins didn't set one
		obsession = find_obsession()
		if(!obsession)//we didn't find one
			lose_text = ""
			return FALSE

	gain_text = span_warning("You hear a sickening, raspy voice in your head. It wants one small task of you...")
	antagonist = owner.mind.add_antag_datum(/datum/antagonist/obsessed)
	antagonist.trauma = src
	RegisterSignal(obsession, COMSIG_MOB_EYECONTACT, PROC_REF(stare))
	RegisterSignal(obsession, COMSIG_QDELETING, PROC_REF(obession_deleted))
	. = ..()
	//antag stuff//
	antagonist.forge_objectives(obsession.mind)
	antagonist.greet()
	log_game("[key_name(antagonist)] has developed an obsession with [key_name(obsession)].")
	RegisterSignal(owner, COMSIG_CARBON_HELPED, PROC_REF(on_hug))
	RegisterSignal(owner, COMSIG_MOVABLE_GRABBED_RESISTING, PROC_REF(grab_resisting))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_damage_mod))
	RegisterSignal(owner, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF, PROC_REF(on_mind_lost))
	RegisterSignal(owner, COMSIG_MOB_MIND_TRANSFERRED_INTO, PROC_REF(on_mind_gain))
	owner.apply_status_effect(/datum/status_effect/desensitized, REF(src), DESENSITIZED_THRESHOLD)
	owner.apply_status_effect(/datum/status_effect/speech/stutter/obsession, INFINITY)

/datum/brain_trauma/special/obsessed/on_life(seconds_per_tick)
	if(isnull(obsession))
		viewing = FALSE
		return

	// viewing needs to be updated regardless of the obsession's state
	viewing = IN_GIVEN_RANGE(owner, obsession, 7) && (owner in viewers(7, obsession))
	if(!viewing)
		if(witnessed_death)
			return

		time_spent_away += seconds_per_tick SECONDS
		time_spend_creeping = 0 SECONDS
		if(time_spent_away > 3 MINUTES) //3 minutes
			owner.add_mood_event("creeping", /datum/mood_event/notcreepingsevere, obsession.name)
		else
			owner.add_mood_event("creeping", /datum/mood_event/notcreeping, obsession.name)
		return

	if(obsession.stat == DEAD)
		if(!witnessed_death)
			witnessed_death = TRUE
			owner.add_mood_event("creeping", /datum/mood_event/creeping/dead)
		return

	witnessed_death = FALSE
	owner.add_mood_event("creeping", /datum/mood_event/creeping, obsession.name)
	total_time_creeping += seconds_per_tick SECONDS
	time_spend_creeping += seconds_per_tick SECONDS
	time_spent_away = 0 SECONDS
	for(var/datum/objective/spendtime/objective in antagonist?.objectives)
		objective.timer -= seconds_per_tick SECONDS

/datum/brain_trauma/special/obsessed/on_lose()
	. = ..()
	antagonist?.trauma = null
	antagonist = null
	if (owner.mind.remove_antag_datum(/datum/antagonist/obsessed))
		owner.mind.add_antag_datum(/datum/antagonist/former_obsessed)
	owner.clear_mood_event("creeping")
	if(!isnull(obsession))
		log_game("[key_name(owner)] is no longer obsessed with [key_name(obsession)].")
		UnregisterSignal(obsession, list(
			COMSIG_MOB_EYECONTACT,
			COMSIG_QDELETING,
		))
		obsession = null

	UnregisterSignal(owner, list(
		COMSIG_CARBON_HELPED,
		COMSIG_MOVABLE_GRABBED_RESISTING,
		COMSIG_MOB_APPLY_DAMAGE_MODIFIERS,
		COMSIG_MOB_MIND_TRANSFERRED_INTO,
		COMSIG_MOB_MIND_TRANSFERRED_OUT_OF,
	))
	owner.remove_status_effect(/datum/status_effect/desensitized, REF(src))
	owner.remove_status_effect(/datum/status_effect/speech/stutter/obsession)

/datum/brain_trauma/special/obsessed/proc/obession_deleted(datum/source)
	SIGNAL_HANDLER
	obsession = null

/datum/brain_trauma/special/obsessed/handle_speech(datum/source, list/speech_args)
	if(viewing && !witnessed_death && prob(12 * max(1 - (time_spend_creeping / (40 SECONDS)), 0.02) ))
		addtimer(CALLBACK(src, PROC_REF(do_something_nervous)), rand(1 SECONDS, 3 SECONDS))

/// Singal proc for [COMSIG_CARBON_HELPED], when our obsessed helps (hugs) our obsession, increases hug count
/datum/brain_trauma/special/obsessed/proc/on_hug(datum/source, mob/living/hugged)
	SIGNAL_HANDLER

	if(hugged != obsession)
		return

	for(var/datum/objective/hug/objective in antagonist?.objectives)
		objective.hugs_needed -= 1

/// Signal proc for [COMSIG_MOVABLE_GRABBED_RESISTING] to improve the obsessed's grabs
/datum/brain_trauma/special/obsessed/proc/grab_resisting(datum/source, mob/living/grabbed, list/grab_stats)
	SIGNAL_HANDLER

	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return

	var/list/datum/mind/all_targets = list()
	for(var/datum/objective/objective in antagonist?.objectives)
		if(isnull(objective.target))
			continue
		all_targets |= objective.target

	// We always grab our obsession, or similar targets, with extra strength
	if(grabbed == obsession || (grabbed.mind in all_targets))
		grab_stats[GRAB_STAT_EFFECTIVE_STATE] += 1
		grab_stats[GRAB_STAT_FAIL_DAMAGE] += 5

	// If we're hanging with our obsession for a while, the bonus applies to any mob (though to a lesser extent)
	else if(is_defensive())
		grab_stats[GRAB_STAT_EFFECTIVE_STATE] += 1
		grab_stats[GRAB_STAT_ESCAPE_CHANCE] += 10 // 10% EASIER to escape

/// Signal proc for [COMSIG_MOB_APPLY_DAMAGE_MODIFIERS], take less stamina damage when near our obsession
/datum/brain_trauma/special/obsessed/proc/on_damage_mod(datum/source, list/damage_mods, damage, damage_type, ...)
	SIGNAL_HANDLER

	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return

	if(damage_type == STAMINA && is_defensive())
		damage_mods += 0.75

/// Checks if if we're being defensive over our obsession
/datum/brain_trauma/special/obsessed/proc/is_defensive()
	if(time_spend_creeping >= 20 SECONDS)
		return TRUE
	if(obsession.stat >= UNCONSCIOUS)
		return (owner in viewers(7, obsession))
	return FALSE

/datum/brain_trauma/special/obsessed/proc/do_something_nervous()
	if(QDELETED(owner) || owner.stat >= UNCONSCIOUS || HAS_TRAIT(owner, TRAIT_FEARLESS))
		return


	switch(rand(1, 10))
		if(1 to 4)
			owner.adjust_jitter_up_to(10 SECONDS, 20 SECONDS)
			owner.adjust_dizzy_up_to(10 SECONDS, 20 SECONDS)
			to_chat(owner, span_warning("You feel a bit nervous."))
		if(5 to 8)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "cough")
			to_chat(owner, span_warning("You clear your throat."))
		if(9)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "laugh")
			to_chat(owner, span_warning("You chuckle nervously."))
		if(10)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "blink")
			owner.adjust_eye_blur_up_to(10 SECONDS, 20 SECONDS)
			to_chat(owner, span_warning("You forget to blink for a moment."))

// if the creep examines first, then the obsession examines them, have a 50% chance to possibly blow their cover. wearing a mask avoids this risk
/datum/brain_trauma/special/obsessed/proc/stare(datum/source, mob/living/examining_mob, triggering_examiner)
	SIGNAL_HANDLER

	if(examining_mob != owner || !triggering_examiner || prob(50))
		return

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), obsession, span_warning("You catch [examining_mob] staring at you..."), 3))
	return COMSIG_BLOCK_EYECONTACT

/datum/brain_trauma/special/obsessed/proc/on_mind_lost(datum/source, mob/new_body, datum/mind/the_mind)
	SIGNAL_HANDLER

	INVOKE_ASYNC(antagonist, TYPE_PROC_REF(/datum/antagonist, store_datum))

/datum/brain_trauma/special/obsessed/proc/on_mind_gain(datum/source, mob/new_body, datum/mind/the_mind)
	SIGNAL_HANDLER

	INVOKE_ASYNC(antagonist, TYPE_PROC_REF(/datum/antagonist, restore_datum), the_mind)

/datum/brain_trauma/special/obsessed/proc/find_obsession()
	var/list/generic_pool = list()
	var/list/special_pool = list()

	var/list/trait_obsessions = list(
		JOB_MIME = TRAIT_MIME_FAN,
		JOB_CLOWN = TRAIT_CLOWN_ENJOYER,
		JOB_CHAPLAIN = TRAIT_SPIRITUAL,
	)

	for(var/datum/mind/crewmember as anything in get_crewmember_minds())
		if(!ishuman(crewmember.current) || crewmember.current.stat == DEAD || !GET_CLIENT(crewmember.current))
			continue

		var/job = crewmember.assigned_role.title
		if (trait_obsessions[job] && HAS_MIND_TRAIT(owner, trait_obsessions[job]))
			special_pool += crewmember.current

		generic_pool += crewmember.current

	if(length(special_pool))
		return pick(special_pool)

	if(length(generic_pool))
		return pick(generic_pool)

	return null
