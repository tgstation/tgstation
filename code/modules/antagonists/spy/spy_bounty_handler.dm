/datum/spy_bounty_handler
	var/refresh_time = 10 MINUTES

	var/list/bounties_to_give = list(
		SPY_DIFFICULTY_EASY = 6,
		SPY_DIFFICULTY_MEDIUM = 4,
		SPY_DIFFICULTY_HARD = 2,
	)

	var/list/datum/spy_bounty/bounties = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

	var/list/bounty_types = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

/datum/spy_bounty_handler/New()
	for(var/datum/spy_bounty/bounty as anything in subtypesof(/datum/spy_bounty))
		var/difficulty = bounty::difficulty
		if(!islist(bounty_types[difficulty]))
			continue
		bounty_types[difficulty] += bounty

	refresh_bounty_list()

/datum/spy_bounty_handler/proc/refresh_bounty_list()
	for(var/difficulty in bounties)
		QDEL_LIST(bounties[difficulty])
		for(var/i in 1 to bounties_to_give[difficulty])
			var/picked_bounty = pick(bounty_types[difficulty])
			bounties[difficulty] += new picked_bounty()

	addtimer(CALLBACK(src, PROC_REF(refresh_bounty_list)), refresh_time)
