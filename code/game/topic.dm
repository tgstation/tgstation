/world/Topic(T, addr, master, key)
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["admins"] = 0
		var/admins = 0
		var/n = 0

		for(var/client/C)

			n++
			if(C.holder && C.holder.level >= 0) //not retired admin
				if(!C.stealth) //stealthmins dont count as admins
					s["admins"] = 1
					s["player[n]"] = "[C.key]"
				else
					s["player[n]"] = "[C.fakekey]"
			else
				s["player[n]"] = "[C.key]"
		s["players"] = n
		s["end"] = "#end"

		// 7 + s["players"] + 1 = index of s["revinfo"]
		s["admins"] = admins

		return list2params(s)
