var/datum/subsystem/stickyban/SSstickyban

/datum/subsystem/stickyban
	name = "Sticky Ban"
	init_order = -10
	flags = SS_NO_FIRE

	var/list/cache = list()

/datum/subsystem/stickyban/New()
	NEW_SS_GLOBAL(SSstickyban)

/datum/subsystem/stickyban/Initialize(timeofday)
	var/list/bannedkeys = world.GetConfig("ban")
	//sanitize the sticky ban list
	for (var/bannedkey in bannedkeys)
		var/ckey = ckey(bannedkey)
		var/list/ban = stickyban2list(world.GetConfig("ban", bannedkey))

		//byond stores sticky bans by key, that can end up confusing things
		//i also remove it here so that if any stickybans cause a runtime, they just stop existing
		world.SetConfig("ban", bannedkey, null)

		if (!ban["ckey"])
			ban["ckey"] = ckey

		//storing these can break things and isn't needed for sticky ban tracking
		ban -= "IP"
		ban -= "computer_id"

		ban["matches_this_round"] = list()
		ban["existing_user_matches_this_round"] = list()
		ban["admin_matches_this_round"] = list()
		cache[ckey] = ban
	
	for (var/bannedckey in cache)
		world.SetConfig("ban", bannedckey, list2stickyban(cache[bannedckey]))
