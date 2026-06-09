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

/datum/brain_trauma/special/obsessed/on_life(seconds_per_tick)
	if(isnull(obsession) || obsession.stat == DEAD)
		viewing = FALSE//important, makes sure you no longer stutter when happy if you murdered them while viewing
		return
	if(get_dist(get_turf(owner), get_turf(obsession)) > 7)
		viewing = FALSE //they are further than our view range they are not viewing us
		out_of_view(seconds_per_tick)
		return//so we're not searching everything in view every tick

	viewing = (owner in viewers(7, obsession))
	if(viewing)
		owner.add_mood_event("creeping", /datum/mood_event/creeping, obsession.name)
		total_time_creeping += seconds_per_tick SECONDS
		time_spend_creeping += seconds_per_tick SECONDS
		time_spent_away = 0 SECONDS
		for(var/datum/objective/spendtime/objective in antagonist?.objectives)
			objective.timer -= seconds_per_tick SECONDS
	else
		out_of_view(seconds_per_tick)

/datum/brain_trauma/special/obsessed/proc/out_of_view(seconds_per_tick)
	time_spent_away += seconds_per_tick SECONDS
	time_spend_creeping = 0 SECONDS
	if(time_spent_away > 3 MINUTES) //3 minutes
		owner.add_mood_event("creeping", /datum/mood_event/notcreepingsevere, obsession.name)
	else
		owner.add_mood_event("creeping", /datum/mood_event/notcreeping, obsession.name)

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

/datum/brain_trauma/special/obsessed/proc/obession_deleted(datum/source)
	SIGNAL_HANDLER
	obsession = null

/datum/brain_trauma/special/obsessed/handle_speech(datum/source, list/speech_args)
	if(!viewing)
		return
	if(prob(25)) // 25% chances to be nervous and stutter.
		if(prob(50)) // 12.5% chance (previous check taken into account) of doing something suspicious.
			addtimer(CALLBACK(src, PROC_REF(on_failed_social_interaction)), rand(1 SECONDS, 3 SECONDS))
		else if(!owner.has_status_effect(/datum/status_effect/speech/stutter))
			to_chat(owner, span_warning("Being near [obsession] makes you nervous and you begin to stutter..."))
		owner.set_stutter_if_lower(6 SECONDS)

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

	var/list/datum/mind/all_assassination_targets = list()
	for(var/datum/objective/assassinate/objective in antagonist?.objectives)
		all_assassination_targets += objective.target

	// We always grab our obsession, or similar targets, with extra strength
	if(grabbed == obsession || (grabbed.mind in all_assassination_targets))
		grab_stats[GRAB_STAT_EFFECTIVE_STATE] += 1
		grab_stats[GRAB_STAT_FAIL_DAMAGE] += 5

	// If we're hanging with our obsession for a while, the bonus applies to any mob (though to a lesser extent)
	else if(time_spend_creeping >= 20 SECONDS)
		grab_stats[GRAB_STAT_EFFECTIVE_STATE] += 1
		grab_stats[GRAB_STAT_ESCAPE_CHANCE] += 10 // 10% EASIER to escape

/// Signal proc for [COMSIG_MOB_APPLY_DAMAGE_MODIFIERS], take less stamina damage when near our obsession
/datum/brain_trauma/special/obsessed/proc/on_damage_mod(datum/source, list/damage_mods, damage, damage_type, ...)
	SIGNAL_HANDLER

	if(time_spend_creeping >= 20 SECONDS && damage_type == STAMINA)
		damage_mods += 0.8

/datum/brain_trauma/special/obsessed/proc/on_failed_social_interaction()
	SIGNAL_HANDLER

	if(QDELETED(owner) || owner.stat >= UNCONSCIOUS)
		return
	switch(rand(1, 100))
		if(1 to 40)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), pick("blink", "blink_r"))
			owner.set_eye_blur_if_lower(20 SECONDS)
			to_chat(owner, span_userdanger("You sweat profusely and have a hard time focusing..."))
		if(41 to 80)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "pale")
			shake_camera(owner, 15, 1)
			owner.adjust_stamina_loss(70)
			to_chat(owner, span_userdanger("You feel your heart lurching in your chest..."))
		if(81 to 100)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "cough")
			owner.adjust_dizzy(20 SECONDS)
			owner.adjust_disgust(5)
			to_chat(owner, span_userdanger("You gag and swallow a bit of bile..."))

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
