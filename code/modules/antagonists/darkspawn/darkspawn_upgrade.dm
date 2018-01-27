//Passive upgrades. These are applied as soon as they're purchased and then delete themselves.
/datum/darkspawn_upgrade
	var/name = "darkspawn upgrade"
	var/desc = "This is an upgrade."
	var/id
	var/lucidity_price = 0 //How much lucidity an upgrade costs to buy
	var/datum/antagonist/darkspawn/darkspawn //The datum buying this upgrade

/datum/darkspawn_upgrade/New(darkspawn_datum)
	..()
	darkspawn = darkspawn_datum

/datum/darkspawn_upgrade/proc/unlock()
	if(!darkspawn)
		return
	apply_effects()
	qdel(src)
	return TRUE

/datum/darkspawn_upgrade/proc/apply_effects()
	return
