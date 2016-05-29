/datum/antag
	var/name = "Generic Baddie"
	var/antagtag = "baddie"
	var/equipped = FALSE
	var/list/mutually_exclusive = list()
	var/completely_exclusive = FALSE

	var/ticks = 0

	var/list/datum/objective/objectives = list()

	var/restricted_jobs = list("AI", "Cyborg")
	var/protected_jobs = list("Security Officer", "Warden", "Detective",
		"Head of Security", "Captain")

/datum/antag/New()
	. = ..()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

/datum/antag/proc/on_gain(datum/mind/user)
	if(!istype(user))
		return FALSE

	for(var/i in user.special_roles)
		var/datum/antag/D = user.special_roles[i]
		if(completely_exclusive)
			return FALSE
		if(D.completely_exclusive)
			return FALSE
		if(type in D.mutually_exclusive)
			return FALSE
		if(D.type in mutually_exclusive)
			return FALSE

	SSpuppetmaster.register(user, src)
	user.restricted_roles |= restricted_jobs
	user.special_roles[type] = src
	return TRUE

/datum/antag/proc/equip(mob/M)
	return

/datum/antag/proc/first_tick(datum/mind/user)
	var/mob/mob = user.current
	mob << "<B><font size=3 color=red>You are the [name].</font></B>"
	user.store_memory("<B><font size=3 color=ref>[name] Objectives</font></B>")
	var/obj_count = 1
	for(var/i in objectives)
		var/datum/objective/objective = i
		var/txt = "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		mob << txt
		user.store_memory(txt)
		obj_count++

/datum/antag/proc/tick(datum/mind/user)
	if(ticks == 0)
		first_tick(user)
	if(!equipped)
		equipped = TRUE
		equip(user.current)
	ticks++

/datum/antag/proc/count_completed_objectives()
	. = 0
	for(var/i in objectives)
		var/datum/objective/objective = i
		. += objective.check_completion()

/datum/antag/proc/on_loss(datum/mind/user)
	SSpuppetmaster.deregister(user, src)

// Solo antags
// - solo changelings
// - traitors
// - vampires
// - memes

// Team antags
// - team changelings
// - nuke ops
// - cultists
// - revolutionaries
// - gangs (competing)
// - shadowlings
// - wizard (and friends)
// - hand of god
// - blobs
