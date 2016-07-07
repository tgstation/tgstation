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
	//sanitize the sticky ban
	for (var/bannedkey in bannedkeys)
		var/ckey = ckey(bannedkey)
		var/list/ban = stickyban2list(world.GetConfig("ban", bannedkey))

		//byond stores sticky bans by key, that can end up confusing things
		world.SetConfig("ban", bannedkey, null)

		if (!ban["ckey"])
			ban["ckey"] = ckey

		//there are matches, lets convert them from keys to ckeys
		if (ban["keys"])
			var/list/keys = list()
			for (var/matchedkey in ban["keys"])
				keys += ckey(matchedkey)
			ban["keys"] = keys

		//storing these can break things and isn't needed for sticky ban tracking
		ban -= "IP"
		ban -= "computer_id"

		world.SetConfig("ban", ckey, list2stickyban(ban))

		ban["matches_this_round"] = list()
		ban["existing_user_matches_this_round"] = list()
		ban["admin_matches_this_round"] = list()
		cache[ckey] = ban
