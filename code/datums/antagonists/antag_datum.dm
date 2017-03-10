//The Datum, Antagonist. Handles various antag things via a datum.
/datum/antagonist
	var/mob/living/owner //who's our owner and accordingly an antagonist
	var/some_flufftext = "yer an antag larry"
	var/prevented_antag_datum_type //the type of antag datum that this datum can't coexist with; should probably be a list
	var/silent_update = FALSE //if we suppress messages during on_gain, apply_innate_effects, remove_innate_effects, and on_remove

/datum/antagonist/New()
	if(!prevented_antag_datum_type)
		prevented_antag_datum_type = type

/datum/antagonist/Destroy()
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(mob/living/new_body)
	return new_body && !new_body.has_antag_datum(prevented_antag_datum_type, TRUE)

/datum/antagonist/proc/give_to_body(mob/living/new_body) //tries to give an antag datum to a mob. cancels out if it can't be owned by the new body
	if(new_body && can_be_owned(new_body))
		new_body.antag_datums += src
		owner = new_body
		on_gain()
		. = src //return the datum if successful
	else
		qdel(src)
		. = FALSE

/datum/antagonist/proc/on_gain() //on initial gain of antag datum, do this. should only be called once per datum
	apply_innate_effects()
	if(!silent_update && some_flufftext)
		to_chat(owner, some_flufftext)

/datum/antagonist/proc/apply_innate_effects() //applies innate effects to the owner, may be called multiple times due to mind transferral, but should only be called once per mob
	//antag huds would go here if antag huds were less completely unworkable as-is

/datum/antagonist/proc/remove_innate_effects() //removes innate effects from the owner, may be called multiple times due to mind transferral, but should only be called once per mob
	//also antag huds but see above antag huds a shit

/datum/antagonist/proc/on_remove() //totally removes the antag datum from the owner; can only be called once per owner
	remove_innate_effects()
	owner.antag_datums -= src
	qdel(src)

/datum/antagonist/proc/transfer_to_new_body(mob/living/new_body)
	remove_innate_effects()
	if(!islist(new_body.antag_datums))
		new_body.antag_datums = list()
	new_body.antag_datums += src
	owner.antag_datums -= src
	owner = new_body
	apply_innate_effects()

//mob var and helper procs/Destroy override
/mob/living
	var/list/antag_datums

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
