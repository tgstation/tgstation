/** Auto crew transfer vote SS
  *
  * Tracks information about auto crew transfer votes and calls transfer votes.area
  *
  * calls a vote [minimum_transfer_time] into the round, and every [minimum_time_between_votes] after that
  * stops calling votes automatically afer [auto_votes_allowed] attemps. all of these values are set in the config.
  *
  */
SUBSYSTEM_DEF(autocrewtransfer)
	name = "Automatic Crew Transfer Vote"
	wait = 600
	priority = FIRE_PRIORITY_CREW_TRANSFER
	runlevels = RUNLEVEL_GAME
	init_order = INIT_ORDER_AUTOTRANSFER
	/// Number of attempted auto transfer votes.
	var/auto_votes_attempted = 0
	/// Number of auto votes the system attemps before stopping - from config.
	var/auto_votes_allowed = 0
	/// Minimum shift length before the votes begin - from config.
	var/minimum_transfer_time = 0
	/// Minimum length of time between auto votes - from config.
	var/minimum_time_between_votes = 0
	/// We stop calling votes if a vote passed
	var/transfer_vote_successful = FALSE

/datum/controller/subsystem/autocrewtransfer/Initialize(timeofday)

	if(!CONFIG_GET(flag/transfer_auto_vote_enabled))
		can_fire = FALSE
		return ..()

	auto_votes_allowed = CONFIG_GET(number/transfer_auto_vote_limit)
	minimum_transfer_time = CONFIG_GET(number/transfer_time_min_allowed)
	minimum_time_between_votes = CONFIG_GET(number/transfer_time_between_auto_votes)
	wait = minimum_transfer_time //first vote will fire at [minimum_transfer_time]

	return ..()

/datum/controller/subsystem/autocrewtransfer/fire()
	//we can't vote if we don't have a functioning democracy
	if(!SSvote)
		disable_vote()
		CRASH("Voting subsystem not found, but the crew transfer vote subsystem is!")

	//if it fires before it's supposed to be allowed, cut it out
	if(world.time - SSticker.round_start_time < minimum_transfer_time)
		return

	//if the shuttle is docked or beyond, stop firing
	if(!SSshuttle.canRecall() || EMERGENCY_AT_LEAST_DOCKED)
		disable_vote()
		return

	//a vote passed, we're done here
	if(transfer_vote_successful)
		disable_vote()
		return

	//time to actually call the transfer vote.
	//if the transfer vote is unable to be called, try again in 2 minutes.
	//if the transfer vote begins successfully, then we'll come back in [minimum_time_between_votes]
	wait = SSvote.auto_transfer_vote() ? minimum_time_between_votes : 2 MINUTES

	//lastly, if we're over our attempt limit, stop firing
	if(auto_votes_allowed != -1 && auto_votes_attempted++ >= auto_votes_allowed)
		disable_vote()
		return

/datum/controller/subsystem/autocrewtransfer/proc/disable_vote()
	can_fire = FALSE
	message_admins("[name] system has been disabled and automatic votes will not be called.")
	return TRUE
