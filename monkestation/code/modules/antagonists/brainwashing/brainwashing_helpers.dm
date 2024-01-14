/// Brainwash a mob, adding objectives to an existing brainwash if it already exists.)
/proc/brainwash(mob/living/victim, list/directives, source)
	. = list()
	if(!victim.mind)
		return
	if(!islist(directives))
		directives = list(directives)
	var/datum/mind/victim_mind = victim.mind
	var/datum/antagonist/brainwashed/brainwash = victim_mind.has_antag_datum(/datum/antagonist/brainwashed)
	if(brainwash)
		for(var/directive in directives)
			var/datum/objective/brainwashing/objective = new(directive)
			if(source)
				objective.source = source
			brainwash.objectives += objective
			. += WEAKREF(objective)
		brainwash.popup_shown = FALSE
		brainwash.greet()
	else
		brainwash = new()
		for(var/directive in directives)
			var/datum/objective/brainwashing/objective = new(directive)
			if(source)
				objective.source = source
			brainwash.objectives += objective
			. += WEAKREF(objective)
		victim_mind.add_antag_datum(brainwash)

	var/source_message = source ? " by [source]" : ""
	var/begin_message = " has been brainwashed with the following objective[length(directives) > 1 ? "s" : ""][source_message]: "
	var/obj_message = english_list(directives)
	var/rendered = begin_message + obj_message
	if(!(rendered[length(rendered)] in list(",",":",";",".","?","!","\'","-")))
		rendered += "." //Good punctuation is important :)
	deadchat_broadcast(rendered, "<b>[victim]</b>", follow_target = victim, turf_target = get_turf(victim), message_type = DEADCHAT_ANNOUNCEMENT)
	if(check_holidays(APRIL_FOOLS))
		// Note: most of the time you're getting brainwashed you're unconscious
		victim.say("You son of a bitch! I'm in.", forced = "That son of a bitch! They're in. (April Fools)")

/// Removes objectives from someone's brainwash.
/proc/unbrainwash(mob/living/victim, list/directives)
	var/datum/antagonist/brainwashed/brainwash = victim?.mind?.has_antag_datum(/datum/antagonist/brainwashed)
	if(!brainwash)
		return FALSE
	if(directives)
		if(!isnull(directives) && !islist(directives))
			directives = list(directives)
		var/list/removed_objectives = list()
		for(var/D in directives)
			var/datum/objective/directive
			if(istype(D, /datum/weakref))
				var/datum/weakref/directive_weakref = D
				directive = directive_weakref.resolve()
			else if(istype(D, /datum/objective))
				directive = D
			if(!directive || !istype(directive))
				continue
			brainwash.objectives -= directive
			removed_objectives += directive
		log_admin("[key_name(victim)] had the following brainwashing objective[length(removed_objectives) > 1 ? "s" : ""] removed: [english_list(removed_objectives)].")
		if(LAZYLEN(brainwash.objectives))
			to_chat(victim, span_userdanger("[length(removed_objectives) > 1 ? "Some" : "One"] of your Directives fade away! You only have to obey the remaining Directives now.</b></span></big>"))
			victim.mind.announce_objectives()
		else
			victim.mind.remove_antag_datum(/datum/antagonist/brainwashed)
		QDEL_LIST(removed_objectives)
	else
		log_admin("[key_name(victim)] had all of their brainwashing objectives removed: [english_list(brainwash.objectives)].")
		QDEL_LIST(brainwash.objectives)
		victim.mind.remove_antag_datum(/datum/antagonist/brainwashed)
