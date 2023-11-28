/datum/spy_bounty_handler
	var/refresh_time = 10 MINUTES
	var/refresh_timer

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

	var/list/possible_uplink_items = list()

/datum/spy_bounty_handler/New()
	for(var/datum/spy_bounty/bounty as anything in subtypesof(/datum/spy_bounty))
		var/difficulty = bounty::difficulty
		if(!islist(bounty_types[difficulty]))
			continue
		bounty_types[difficulty] += bounty

	for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
		if(isnull(item.item) || istype(item, /obj/effect/gibspawner/generic)) // gibspawner is a placeholder becuase uplink items are cringe and use gibspawners for placehodlers
			continue
		if(!(item.purchasable_from & UPLINK_SPY))
			continue
		possible_uplink_items += item

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
			var/datum/spy_bounty/bounty = new picked_bounty(src)
			if(bounty.initalized)
				amount_to_give -= 1
				bounties[difficulty] += bounty

			else
				failed_attempts -= 1
				qdel(bounty)

	refresh_timer = addtimer(CALLBACK(src, PROC_REF(refresh_bounty_list)), refresh_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/datum/spy_bounty_handler/proc/complete_bounty(atom/stealing, mob/living/spy, datum/spy_bounty/completed)
	if(completed.claimed)
		CRASH("completed_bounty called on already claimed bounty.")

	completed.clean_up_stolen_item(stealing, stealing)
	completed.claimed = TRUE

	new completed.reward_item.item(spy.loc)
