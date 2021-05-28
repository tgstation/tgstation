/datum/contestant
	/// The ckey we try to match with
	var/ckey
	/// Whether or not someone has been associated with this datum
	var/matched_owner

	var/client/matched_client

	var/mob/current_mob

/datum/contestant/New(new_ckey)
	ckey = new_ckey
	current_mob = get_mob_by_ckey(ckey)


	if(!current_mob)
		return
	matched_owner = TRUE
	matched_client = current_mob.client


/datum/team
