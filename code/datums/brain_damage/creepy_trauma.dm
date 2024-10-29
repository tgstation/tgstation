/datum/brain_trauma/special/obsessed
	name = "Psychotic Schizophrenia"
	desc = "Patient has a subtype of delusional disorder, becoming irrationally attached to someone."
	scan_desc = "psychotic schizophrenic delusions"
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = span_warning("The voices in your head fall silent.")
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	var/mob/living/obsession
	var/datum/objective/spendtime/attachedobsessedobj
	var/datum/antagonist/obsessed/antagonist
	var/viewing = FALSE //it's a lot better to store if the owner is watching the obsession than checking it twice between two procs

	var/total_time_creeping = 0 //just for round end fun
	var/time_spent_away = 0
	var/obsession_hug_count = 0

/datum/brain_trauma/special/obsessed/on_gain()
	//setup, linking, etc//
	if(!obsession)//admins didn't set one
		obsession = find_obsession()
		if(!obsession)//we didn't find one
			lose_text = ""
			qdel(src)
			return
	gain_text = span_warning("You hear a sickening, raspy voice in your head. It wants one small task of you...")
	owner.mind.add_antag_datum(/datum/antagonist/obsessed)
	antagonist = owner.mind.has_antag_datum(/datum/antagonist/obsessed)
	antagonist.trauma = src
	RegisterSignal(obsession, COMSIG_MOB_EYECONTACT, PROC_REF(stare))
	..()
	//antag stuff//
	antagonist.forge_objectives(obsession.mind)
	antagonist.greet()
	log_game("[key_name(antagonist)] has developed an obsession with [key_name(obsession)].")
	RegisterSignal(owner, COMSIG_CARBON_HELPED, PROC_REF(on_hug))

/datum/brain_trauma/special/obsessed/on_life(seconds_per_tick, times_fired)
	if(!obsession || obsession.stat == DEAD)
		viewing = FALSE//important, makes sure you no longer stutter when happy if you murdered them while viewing
		return
	if(get_dist(get_turf(owner), get_turf(obsession)) > 7)
		viewing = FALSE //they are further than our view range they are not viewing us
		out_of_view()
		return//so we're not searching everything in view every tick
	if(obsession in view(7, owner))
		viewing = TRUE
	else
		viewing = FALSE
	if(viewing)
		owner.add_mood_event("creeping", /datum/mood_event/creeping, obsession.name)
		total_time_creeping += seconds_per_tick SECONDS
		time_spent_away = 0
		if(attachedobsessedobj)//if an objective needs to tick down, we can do that since traumas coexist with the antagonist datum
			attachedobsessedobj.timer -= seconds_per_tick SECONDS //mob subsystem ticks every 2 seconds(?), remove 20 deciseconds from the timer. sure, that makes sense.
	else
		out_of_view()

/datum/brain_trauma/special/obsessed/proc/out_of_view()
	time_spent_away += 20
	if(time_spent_away > 1800) //3 minutes
		owner.add_mood_event("creeping", /datum/mood_event/notcreepingsevere, obsession.name)
	else
		owner.add_mood_event("creeping", /datum/mood_event/notcreeping, obsession.name)

/datum/brain_trauma/special/obsessed/on_lose()
	..()
	if (owner.mind.remove_antag_datum(/datum/antagonist/obsessed))
		owner.mind.add_antag_datum(/datum/antagonist/former_obsessed)
	owner.clear_mood_event("creeping")
	if(obsession)
		log_game("[key_name(owner)] is no longer obsessed with [key_name(obsession)].")
		UnregisterSignal(obsession, COMSIG_MOB_EYECONTACT)

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

	obsession_hug_count++

/datum/brain_trauma/special/obsessed/proc/on_failed_social_interaction()
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
			owner.adjustStaminaLoss(70)
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

/datum/brain_trauma/special/obsessed/proc/find_obsession()
	var/list/viable_minds = list() //The first list, which excludes hijinks
	var/list/possible_targets = list() //The second list, which filters out silicons and simplemobs
	var/static/list/trait_obsessions = list(
		JOB_MIME = TRAIT_MIME_FAN,
		JOB_CLOWN = TRAIT_CLOWN_ENJOYER,
		JOB_CHAPLAIN = TRAIT_SPIRITUAL,
	) // Jobs and their corresponding quirks
	var/list/special_pool = list() //The special list, for quirk-based
	var/chosen_victim  //The obsession target

	for(var/mob/player as anything in GLOB.player_list)//prevents crew members falling in love with nuke ops they never met, and other annoying hijinks
		if(!player.client || !player.mind || isnewplayer(player) || player.stat == DEAD || isbrain(player) || player == owner)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		viable_minds += player.mind
	for(var/datum/mind/possible_target as anything in viable_minds)
		if(possible_target != owner && ishuman(possible_target.current))
			var/job = possible_target.assigned_role.title
			if (trait_obsessions[job] != null && HAS_TRAIT(owner, trait_obsessions[job]))
				special_pool += possible_target.current
			possible_targets += possible_target.current

	//Do we have any special target?
	if(length(special_pool))
		chosen_victim = pick(special_pool)
		return chosen_victim

	//If not, pick any other ordinary target
	if(possible_targets.len > 0)
		chosen_victim = pick(possible_targets)
	return chosen_victim
