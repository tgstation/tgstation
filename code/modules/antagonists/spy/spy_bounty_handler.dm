/datum/spy_bounty_handler
	var/refresh_time = 10 MINUTES

	var/list/bounties_to_give = list(
		SPY_DIFFICULTY_EASY = 6,
		SPY_DIFFICULTY_MEDIUM = 4,
		SPY_DIFFICULTY_HARD = 2,
	)

	var/list/list/bounties = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

	var/list/list/bounty_types = list(
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

/datum/spy_bounty_handler/proc/get_all_bounties() as /list
	var/list/all_bounties = list()
	for(var/difficulty in bounties)
		all_bounties += bounties[difficulty]

	return all_bounties

/datum/spy_bounty_handler/proc/refresh_bounty_list()
	for(var/difficulty in bounties)
		QDEL_LIST(bounties[difficulty])

		var/list/pool = bounty_types[difficulty]
		var/amount_to_give = bounties_to_give[difficulty]
		var/failed_attempts = 8
		while(amount_to_give > 0 && failed_attempts > 0)
			var/picked_bounty = pick(pool)
			var/datum/spy_bounty/bounty = new picked_bounty()
			if(bounty.initalized)
				amount_to_give -= 1
				bounties[difficulty] += bounty

			else
				failed_attempts -= 1
				qdel(bounty)

	addtimer(CALLBACK(src, PROC_REF(refresh_bounty_list)), refresh_time)

/datum/spy_bounty_handler/proc/complete_bounty(atom/stealing, mob/living/spy, datum/spy_bounty/completed)
	bounties[completed.difficulty] -= completed
	completed.clean_up_stolen_item(stealing, stealing)
	new completed.reward_item.item(spy.loc)
	qdel(completed)
