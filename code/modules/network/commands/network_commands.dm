// List of generic commands which are used by most if not all networks.


// INFO COMMAND //

/datum/network_command/info
	trigger = "help"
	info = "Usage: \"help -{query}\". Gives you some information about the queried command. You can use \"help -info\" for information about this network, or \"get -commands\" for a list of available commands."

/datum/network_command/info/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(!A)
		if (security(N, "noob", H)) return
		feedback(H, info)
		return
	if(A[1] == "info")
		if (security(N, "noob", H)) return
		feedback(H, N.info)
		return
	for(var/datum/network_command/C in N.commands)
		if(C.trigger == A[1])
			if (security(N, "noob", H)) return
			feedback(H, C.info)
			return
	badarg(A[1], H)
	return

// CONNECT COMMAND //

/datum/network_command/connect
	trigger = "connect"
	info = "Usage: \"connect -{network} -{encryption key}\". Attempts to connect to the specified linked network. If no encryption key is provided, current encryption key will be used."

/datum/network_command/connect/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	if(!A[1])
		if (security(N, "noob", H)) return
		feedback(H, info)
		return
	if(A[1] in N.connected)
		var/datum/network/L = N.connected[A[1]]
		if(!L.invisible && (!L.stealth || H.software & HACK_PROBE))
			if(!L.password || L.password == N.password || L.password == A[2])
				if(security(L, "connect", H)) return
				H.connect(L)
				return
			if(L.password && H.software & HACK_BRUTE && A[2] == "b")
				security(L, "bruteforce", H)
				H.bruteforce(N, "connect -[A[1]] -[L.password]", 10)
				return
			security(L, "badkey", H)
			badkey(A[2], H)
			return
	if(A[1] != N.id)
		if(!N.invisible && (N.stealth || H.software & HACK_PROBE))
			if(!N.password || N.password == A[1])
				if(security(N, "connect", H)) return
				H.connect(N)
				return
			if(N.password && H.software & HACK_BRUTE && A[1] == "b")
				security(N, "bruteforce", H)
				H.bruteforce(N, "connect -[N.password]", 10)
				return
			security(N, "badkey", H)
			badkey(A[1], H)
			return
	badnet(A[1], H)
	return

// DISCONNECT COMMAND //

/datum/network_command/disconnect
	trigger = "disconnect"
	info = "Usage: \"disconnect\". Will disconnect from this network."

/datum/network_command/disconnect/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	security(N, "disconnect", H)
	H.disconnect()

// GET COMMAND //

/datum/network_command/get
	trigger = "get"
	info = "Usage: \"get -{query}\". Asks the network to return the value of query. Acceptable arguments are -c:commands, -i:id, -k:key, -h:hidden, -r:remote"

/datum/network_command/get/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	switch(A[1])
		if("c"||"commands")
			if (security(N, "probe", H)) return
			var/feed = "Network Commands:"
			for(var/datum/network_command/C in N.commands)
				if(!C.stealth || H.software & HACK_PROBE)
					feed += " | [C.trigger] |"
			feedback(H, feed)
			return
		if("i"||"id")
			if (security(N, "get", H)) return
			feedback(H, N.id)
			return
		if("k"||"key")
			if (security(N, "getsecure", H)) return
			feedback(H, isnull(N.password) ? "NULL" : N.password)
			return
		if("h"||"hidden")
			if (security(N, "get", H)) return
			feedback(H, "Network Hidden: [N.stealth ? "TRUE" : "FALSE"]")
			return
		if("l"||"locked") // Kind of redundant.
			if (security(N, "get", H)) return
			feedback(H, "Network Locked: [N.locked ? "TRUE" : "FALSE"]")
			return
		if("r"||"remote")
			if (security(N, "get", H)) return
			switch(N.remote)
				if(REMOTE_NETWORK_NONE)
					feedback(H, "Remote Access: NONE")
				if(REMOTE_NETWORK_AREA)
					feedback(H, "Remote Access: LOCAL")
				if(REMOTE_NETWORK_HALF)
					feedback(H, "Remote Access: SHORT")
				if(REMOTE_NETWORK_FULL)
					feedback(H, "Remote Access: BROAD")
				else
					feedback(H, "Remote Access: ERROR")
			return
		if(null)
			if (security(N, "noob", H)) return
			feedback(H, info)
			return
	badarg(A[1], H)
	return

// SET COMMAND //

/*

/datum/network_command/setkey
	trigger = "set_key"
	info = "Usage: \"set_key -{encryption_key}\". If an encryption key is provided, will set this networks encryption key. Otherwise, will remove it."

/datum/network_command/setkey/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	N.password = A[1]
	feedback = "Encryption Key Set"
	feed(H)
	return

*/

// LINK COMMAND //

/datum/network_command/link
	trigger = "link"
	info = "Usage: \"link -{network} -{connection} -{encryption key}\". Links the specified network to this one. Connection parameters can be: 0, 1, or 2. Setting the connection controls whether or not these networks can be traversed easily using 'connect'. Setting of 1 causes a one-way connection, allowing connection to the linked network, but no return."

/datum/network_command/link/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	if(!A[1])
		if (security(N, "noob", H)) return
		feedback(H, info)
		return
	if(A[1] in networks_by_id)
		var/datum/network/L = networks_by_id[A[1]]
		if(!L.invisible && (!L.stealth || H.software & HACK_PROBE))
			if(L.can_remote(H)) // Can only link networks by being within range, or if they're already connected. You might have to connect to a network, then cross the station, then link to the new network.
				if(!L.password || L.password == N.password || L.password == A[3])
					switch(A[2])
						if(0)
							N.add_link(L)
							security(N, "linked", H)
							security(L, "linked", H)
							feedback("LINKED: {[N.id]}:{[L.id]}")
						if(1)
							N.add_connection(L, FALSE)
							security(N, "linked", H)
							security(L, "linked", H)
							feedback("LINKED: {[N.id]}>{[L.id]}")
						if(2)
							N.add_connection(L)
							security(N, "linked", H)
							security(L, "linked", H)
							feedback("LINKED: {[N.id]}-{[L.id]}")
						else
							badarg(A[2], H)
					return
				if(L.password && H.software & HACK_BRUTE && A[3] == "b")
					security(L, "bruteforce", H)
					H.bruteforce(N, "link -[A[1]] -[A[2]] -[L.password]", 10)
					return
				security(L, "badkey", H)
				badkey(A[3], H)
				return
	badnet(A[1], H)
	return

// UNLINK COMMAND //

/datum/network_command/unlink
	trigger = "unlink"
	info = "Usage: \"unlink -{network} -{encryption key}\". Functional opposite of link. Disconnects the specified network from this one."

/datum/network_command/unlink/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	if(!A[1])
		if (security(N, "noob", H)) return
		feedback(H, info)
		return
	if(A[1] in N.linked)
		var/datum/network/L = N.linked[A[1]]
		if(!L.password || L.password == N.password || L.password == A[2])
			N.del_link(L, TRUE)
			security(N, "unlinked", H)
			security(L, "unlinked", H)
			feedback("UNLINKED: {[N.id]} {[L.id]}")
			return
		if(L.password && H.software & HACK_BRUTE && A[2] == "b")
			security(L, "bruteforce", H)
			H.bruteforce(N, "link -[A[1]] -[L.password]", 10)
			return
		security(L, "badkey", H)
		badkey(A[2], H)
		return
	badnet(A[1], H)
	return

// PROBE COMMAND //

/datum/network_command/probe
	trigger = "probe"
	info = "Usage: \"probe -{query}\" or \"probe -{network} -{query}\". Acceptable query arguments are: l:linked, c:connected, i:info, s:security. Network may be any linked network id."

/datum/network_command/probe/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	if(!A[1])
		if (security(N, "noob", H)) return
		feedback(H, info)
		return
	if(!A[2])
		switch(A[1])
			if("l"||"linked")
				if (security(N, "probe", H)) return
				var/feed = "Linked Networks:"
				for(var/I in N.linked)
					var/datum/network/L = N.linked[I]
					if(!L.invisible && (!L.stealth || H.software & HACK_PROBE))
						feed += " | [I] |"
				feedback(H, feed)
				return
			if("c"||"connected")
				if (security(N, "probe", H)) return
				var/feed = "Connected Networks:"
				for(var/I in N.connected)
					var/datum/network/L = N.connected[I]
					if(!L.invisible && (!L.stealth || H.software & HACK_PROBE))
						feed += " | [I] |"
				feedback(H, feed)
				return
			if("i"||"info")
				if (security(N, "get", H)) return
				feedback(H, "[N.info]\n Linked Networks: [N.linked.len]\n Connected Networks: [N.connected.len]\n Encrypted: [N.password ? "TRUE" : "FALSE"]")
				return
			if("s"||"security") // Alternate method of calling "help -security"
				if (security(N, "probe", H)) return
				security(N, "info", H)
				return
		badarg(A[1], H)
		return
	if(A[1] in N.linked)
		var/datum/network/L = N.linked[A[1]]
		if(!L.invisible && (!L.stealth || H.software & HACK_PROBE))
			switch(A[2])
				if("l"||"linked")
					if (security(L, "probe", H)) return
					var/feed = "Linked Networks:"
					for(var/I in L.linked)
						var/datum/network/LL = L.linked[I]
						if(!LL.invisible && (!LL.stealth || H.software & HACK_PROBE))
							feed += " | [I] |"
					feedback(H, feed)
					return
				if("c"||"connected")
					if (security(L, "probe", H)) return
					var/feed = "Connected Networks:"
					for(var/I in L.connected)
						var/datum/network/LL = L.connected[I]
						if(!LL.invisible && (!LL.stealth || H.software & HACK_PROBE))
							feed += " | [I] |"
					feedback(H, feed)
					return
				if("i"||"info")
					if (L.stealth && security(L, "probe", H)) return
					else if (!L.stealth && security(L, "get", H)) return
					feedback(H, "[L.info]\n Linked Networks: [L.linked.len]\n Connected Networks: [L.connected.len]\n Encrypted: [L.password ? "TRUE" : "FALSE"]")
					return
				if("s"||"security") // Very useful. Gets info on a networks security system from afar, before connecting to it.
					if (security(L, "probe", H)) return
					security(L, "info", H)
					return
			badarg(A[2], H)
			return
	badnet(A[1], H)
	return
