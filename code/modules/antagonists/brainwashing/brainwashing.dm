/proc/brainwash(mob/living/L, directives)
	if(!L.mind)
		return
	if(!islist(directives))
		directives = list(directives)
	var/datum/mind/M = L.mind
	var/datum/antagonist/brainwashed/B = M.has_antag_datum(/datum/antagonist/brainwashed)
	if(B)
		for(var/O in directives)
			var/datum/objective/brainwashing/objective = new(O)
			B.objectives += objective
			M.objectives += objective
		B.greet()
	else
		B = new(directives)
		M.add_antag_datum(B)

/datum/antagonist/brainwashed
	name = "Brainwashed Victim"
	job_rank = ROLE_BRAINWASHED
	roundend_category = "brainwashed victims"
	show_in_antagpanel = FALSE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/brainwashed/New(list/directives)
	..()
	for(var/O in directives)
		var/datum/objective/brainwashing/objective = new(O)
		objectives += objective

/datum/antagonist/brainwashed/on_gain()
	for(var/O in objectives)
		owner.objectives += O
	. = ..()

/datum/antagonist/brainwashed/on_removal()
	for(var/O in objectives)
		owner.objectives -= O
	. = ..()

/datum/antagonist/brainwashed/greet()
	to_chat(owner, "<span class='warning'>Your mind reels as it begins focusing on a single purpose...</span>")
	to_chat(owner, "<big><span class='warning'><b>Follow the Directives, at any cost!</b></span></big>")
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++

/datum/antagonist/brainwashed/farewell()
	to_chat(owner, "<span class='warning'>Your mind suddenly clears...</span>")
	to_chat(owner, "<big><span class='warning'><b>You feel the weight of the Directives disappear! You no longer have to obey them.</b></span></big>")
	owner.announce_objectives()

/datum/objective/brainwashing
	completed = TRUE