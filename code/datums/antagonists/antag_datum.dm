/datum/antagonist
	var/name = "Antagonist"

	var/datum/mind/owner						//Mind that owns this datum

	var/silent = FALSE							//Silent will prevent the gain/lose texts to show

	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with


/datum/antagonist/New(datum/mind/new_owner)
	. = ..()
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)
	if(new_owner)
		owner = new_owner

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects()
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/proc/remove_innate_effects()
	return

//Proc called when the datum is given to a mind.
/datum/antagonist/proc/on_gain()
	if(owner && owner.current)
		if(!silent)
			greet()
		apply_innate_effects()

/datum/antagonist/proc/on_removal()
	remove_innate_effects()
	if(owner)
		owner.antag_datums -= src
		if(!silent && owner.current)
			farewell()
	qdel(src)

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/farewell()
	return