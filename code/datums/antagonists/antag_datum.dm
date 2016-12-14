//The datum antagonist! Each one holds different information about the role and how it interacts with other roles.
/datum/antagonist
	var/name = "antagonist" //What's our short name?
	var/desc = "You exist to make the crew's lives suck." //What do we do?
	var/gain_fluff = "You're an antagonist! Go kill people, it's what everyone else does." //What do we hear when we turn into the antagonist?
	var/loss_fluff = "The gods have revoked your license to grief. Sucks to be you." //What do we hear when we lose our antagonism?
	var/mob/living/owner //who's our owner and accordingly an antagonist
	var/list/prevented_antag_datum_types = list() //types of antag datum that this datum can't coexist with
	var/silent_update = FALSE //if we suppress messages during on_gain, apply_innate_effects, remove_innate_effects, and on_remove
	var/can_coexist_with_other_antagonists = TRUE //If we can be multiple antagonists at the same time
	var/allegiance_priority = ANTAGONIST_PRIORITY_NONE //Our priority for allegiances. If we can't coexist and something higher-priority is applied, we lose everything below it.

	//Objective-related variables.
	var/has_objectives = TRUE //Do we use objectives?
	var/number_of_objectives = 1 //How many objectives we have.
	var/datum/objective/constant_objective //An objective we'll always have. This is usually an objective to survive.

/datum/antagonist/Destroy()
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(mob/living/new_body)
	if(new_body.has_antag_datum(type, TRUE))
		return 0
	for(var/D in prevented_antag_datum_types)
		if(D == type)
			return 0
	for(var/V in datum_antags)
		var/datum/antagonist/A = V
		if(A.allegiance_priority < allegiance_priority && !can_coexist)
			A.owner.on_remove() //Destroy other antagonists that we can't be friends with
	return new_body

/datum/antagonist/proc/give_to_body(mob/living/new_body) //tries to give an antag datum to a mob. cancels out if it can't be owned by the new body
	if(new_body && can_be_owned(new_body))
		new_body.antag_datums += src
		owner = new_body
		owner.mind.special_role = name
		log_game("[owner.key] (ckey) became a(n) [name]!")
		on_gain()
		if(has_objectives)
			forge_objectives()
		. = src //return the datum if successful
	else
		qdel(src)
		. = FALSE

/datum/antagonist/proc/on_gain() //on initial gain of antag datum, do this. should only be called once per datum
	if(!silent_update && gain_fluff)
		greet()
	apply_innate_effects()

/datum/antagonist/proc/greet() //Sends some text to our new owner.
	if(!owner || !gain_fluff)
		return
	owner << gain_fluff

/datum/antagonist/proc/farewell() //Sends some text to our owner before we leave.
	if(!owner || !loss_fluff)
		return
	owner << loss_fluff

/datum/antagonist/proc/forge_objectives() //Assigns primary objectives and the constant one.
	generate_objectives()
	if(constant_objective)
		var/datum/objective/O = new constant_objective
		O.owner = owner
		owner.mind.objectives += O

/datum/antagonist/proc/generate_objectives() //Assigns primary objectives. Override this for every antag type.
	return

/datum/antagonist/proc/apply_innate_effects() //applies innate effects to the owner, may be called multiple times due to mind transferral, but should only be called once per mob
	//antag huds would go here if antag huds were less completely unworkable as-is

/datum/antagonist/proc/remove_innate_effects() //removes innate effects from the owner, may be called multiple times due to mind transferral, but should only be called once per mob
	//also antag huds but see above antag huds a shit

/datum/antagonist/proc/on_remove() //totally removes the antag datum from the owner; can only be called once per owner
	if(!silent_update && loss_fluff)
		farewell()
	remove_innate_effects()
	owner.antag_datums -= src
	qdel(src)

/datum/antagonist/proc/transfer_to_new_body(mob/living/new_body)
	remove_innate_effects()
	if(!islist(new_body.antag_datums))
		new_body.antag_datums = list()
	new_body.antag_datums += src
	owner.antag_datums -= src
	spawn(1) //Give the game time to sort out new minds, bodies...
		owner = new_body
		apply_innate_effects()

//mob var and helper procs/Destroy override
/mob/living
	var/list/antag_datums = list()

/mob/living/Destroy() //TODO: merge this with the living/Destroy() in code\modules\mob\living\living.dm (currently line 29)
	if(islist(antag_datums))
		for(var/i in antag_datums)
			qdel(i)
		antag_datums = null
	return ..()

/mob/living/proc/can_have_antag_datum(datum_type) //if we can have this specific antagonist datum; neccessary, but requires creating a new antag datum each time.
	var/datum/antagonist/D = new datum_type()
	. = D.can_be_owned(src) //we can't exactly cache the results, either, because conditions might change. avoid use? TODO: better proc
	qdel(D)

/mob/living/proc/gain_antag_datum(datum_type) //tries to give a mob a specific antagonist datum; returns the datum if successful.
	if(!islist(antag_datums))
		antag_datums = list()
	var/datum/antagonist/D = new datum_type()
	. = D.give_to_body(src)

/mob/living/proc/lose_antag_datum(datum_type) //tries to remove an antagonist datum from a mob
	for(var/V in antag_datums)
		var/datum/antagonist/A = V
		if(A.type == datum_type)
			A.on_remove()

/mob/living/proc/has_antag_datum(type, check_subtypes) //checks this mob for if it has the antagonist datum. can either check specific type or subtypes
	if(!islist(antag_datums))
		return FALSE
	for(var/i in antag_datums)
		var/datum/antagonist/D = i
		if(check_subtypes)
			if(istype(D, type))
				return D //if it finds the datum, will return it so you can mess with it
		else
			if(D.type == type)
				return D
	return FALSE

/mob/living/proc/call_antag_datum_proc(datum, proc_to_call, ...)
	var/datum/antagonist/A = has_antag_datum(datum, TRUE)
	if(!A)
		return
	call(A, proc_to_call)(arglist(args))
	return 1
