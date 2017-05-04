/datum/antagonist
	var/name = "Antagonist"

	var/datum/mind/owner						//Mind that owns this datum

	var/silent = FALSE							//Silent will prevent the gain/lose texts to show

	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with

/datum/antagonist/New(datum/mind/new_owner)
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)
	if(new_owner)
		owner = new_owner

/datum/antagonist/Destroy()
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	. = TRUE
	if(owner.has_antag_datum(type))
		return FALSE
	for(var/i in owner.antag_datums)
		var/datum/antagonist/A = i
		if(is_type_in_typecache(src, A.typecache_datum_blacklist))
			return FALSE

/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	remove_innate_effects(old_body)
	apply_innate_effects(new_body)

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
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
		LAZYREMOVE(owner.antag_datums, src)
		if(!silent && owner.current)
			farewell()
	qdel(src)

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/farewell()
	return
