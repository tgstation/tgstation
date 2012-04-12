/world/Topic(T, addr, master, key)
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in world)
			if(M.client)
				n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		var/n = 0
		var/admins = 0

		for(var/mob/M in world)

			if(M.client)
				if(M.client.holder)
					if(!M.client.stealth)
						admins++

				s["player[n]"] = M.client.key
				n++
		s["players"] = n

		// 7 + s["players"] + 1 = index of s["revinfo"]
		s["revision"] = revdata.revision
		s["admins"] = admins

		return list2params(s)
