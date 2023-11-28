/**
 * ## Spy bounty handler
 *
 * Singleton datum that handles determining active bounties for spies.
 */
/datum/spy_bounty_handler
	/// Timer between when all bounties are refreshed.
	var/refresh_time = 10 MINUTES
	/// timerID of the active refresh timer.
	var/refresh_timer // melbert todo : admin button to force refresh

	/// Assoc list that dictates how much of each bounty difficulty to give out at once.
	var/list/bounties_to_give = list(
		SPY_DIFFICULTY_EASY = 4,
		SPY_DIFFICULTY_MEDIUM = 2,
		SPY_DIFFICULTY_HARD = 2,
	)

	/// Assoc list of all active bounties.
	var/list/list/bounties = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

	/// Assoc list of all possible bounties for each difficulty.
	/// This is static, no bounty types are removed from this list.
	var/list/list/bounty_types = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

	/// List of all uplink items possible to be given as bounties.
	/// This is not static, as bounties are complete uplink items will be removed from this list.
	var/list/possible_uplink_items = list()

/datum/spy_bounty_handler/New()
	for(var/datum/spy_bounty/bounty as anything in subtypesof(/datum/spy_bounty))
		var/difficulty = bounty::difficulty
		if(!islist(bounty_types[difficulty]))
			continue
		bounty_types[difficulty] += bounty

	for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
		if(isnull(item.item) || istype(item.item, DUMMY_UPLINK_ITEM))
			continue
		if(!(item.purchasable_from & UPLINK_SPY))
			continue
		possible_uplink_items += item

	refresh_bounty_list()

/// Helper that returns a list of all active bounties in a single list, regardless of difficulty.
/datum/spy_bounty_handler/proc/get_all_bounties() as /list
	var/list/all_bounties = list()
	for(var/difficulty in bounties)
		all_bounties += bounties[difficulty]

	return all_bounties

/// Refreshes all active bounties for each difficulty, no matter if they were complete or not.
/// Then recursively calls itself via a timer.
/datum/spy_bounty_handler/proc/refresh_bounty_list()
	PRIVATE_PROC(TRUE)

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
