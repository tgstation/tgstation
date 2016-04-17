/*
//////////////////////////////
///// Directory Commands /////
//////////////////////////////

== probe {scope} {query}
	Searches through the connected network for networks matching the provided query. If no query is provided, it will list all networks within the scope.
		{scope} Arguments: "-w:wide, -l:local, -a:all"
			w:wide: Will search through wireless station-wide networks. If it is currently connected to a network, will only return networks that are connected.
			l:local: Will search for networks located within the same area. If it is currently connected to a network, will only return networks that are directly connected.
			a:all: Will search through station-wide, and local networks. If is is currently connected to a network, it will also search through any unencrypted connected networks.
		{query} Arguments: "-string"
			string: Will limit the search to networks containing the queried string within their id.

*/

/datum/network_command/info
	trigger = "info"
	info = "Usage: \"info -{query}\". Gives you some information about the commands available on this network. If a query is provided, will explain the usage of that command."

/datum/network_command/info/execute(datum/network/N, datum/network_argument/A)
	..()
	if(A.args.len == 0)
		feedback = "<span class='notice'>Available Network Commands: </span>"
		for(var/datum/network_command/NC in N.commands)
			if(!NC.stealth || A.is_hacktool)
				feedback += "\n <span class='notice'>[NC.trigger]</span>"
		return list(feedback)
	for(var/datum/network_command/NC in N.commands)
		if(NC.trigger == A.args[1])
			feedback = "<span class='notice'>info -[NC.trigger]\n [NC.info]</span>"
			return list(feedback)
	feedback = "<span class='notice'>info -[A.args[1]]</span>\n <span class='warning'>Invalid Argument: \"[A.args[1]]\"</span>"
	return list(feedback)


/datum/network_command/get_root
	trigger = "get_root"
	info = "Usage: \"get_root\". Returns the root id of this network, if it exists."

/datum/network_command/get_root/execute(datum/network/N, datum/network_argument/A)
	..()
	if(!N.root || (N.root.stealth && !A.is_hacktool))
		feedback = "<span class='notice'>No Root Network.</span>"
		return list(feedback)
	feedback = "<span class='notice'>Root: [N.root.id]</span>"
	return list(feedback, N.root.id)


/datum/network_command/get_sub
	trigger = "get_sub"
	info = "Usage: \"get_sub\". Returns a list of all connected subnetworks."

/datum/network_command/get_sub/execute(datum/network/N, datum/network_argument/A)
	..()
	if(N.sub.len)
		var/list/datum/network/SN = list()
		feedback = "<span class='notice'>Available Subnetworks: </span>\n "
		for(var/datum/network/sub in N.sub)
			if(!sub.stealth || A.is_hacktool)
				SN += sub
				feedback += "<span class='notice'>| [sub.id] </span>"
		if(SN.len >= 1)
			feedback += "<span class='notice'>|</span>"
			return list(feedback)
	feedback = "<span class='notice'>No Subnetwork Available.</span>"
	return list(feedback)


/datum/network_command/get_id
	trigger = "get_id"
	info = "Usage: \"get_id\". Returns the id of this network."

/datum/network_command/get_id/execute(datum/network/N, datum/network_argument/A)
	..()
	feedback = "<span class='notice'>Network ID: [N.id]</span>"
	return list(feedback, N.id)


/datum/network_command/get_key
	trigger = "get_key"
	info = "Usage: \"get_key\". Returns the network encryption key."

/datum/network_command/get_key/execute(datum/network/N, datum/network_argument/A)
	..()
	feedback = "<span_class='notice'>Encryption Key: [N.password]</span>"
	return list(feedback, N.password)


/datum/network_command/get_hidden
	trigger = "get_hidden"
	info = "Usage: \"get_hidden\". Returns whether or not this network is protected from probing."

/datum/network_command/get_hidden/execute(datum/network/N, datum/network_argument/A)
	..()
	feedback = "<span class='notice'>Network Stealthed: [N.stealth ? "TRUE" : "FALSE"]</span>"
	return list(feedback, N.stealth)


/datum/network_command/get_local
	trigger = "get_local"
	info = "Usage: \"get_local\". Returns whether or not this network can be accessed from anywhere on the station."

/datum/network_command/get_wireless/execute(datum/network/N, datum/network_argument/A)
	..()
	feedback = "<span class='notice'>Local Network: [N.wireless ? "FALSE" : "TRUE"]</span>"
	return list(feedback, !N.wireless)


/datum/network_command/rootnet
	trigger = "rootnet"
	info = "Usage: \"rootnet -{encryption_key}\". Attempts to connect to the root network. If no encryption key is provided, current networks encryption key will be used."

/datum/network_command/rootnet/execute(datum/network/N, datum/network_argument/A)
	..()
	if(!N.root || (N.root.stealth && !A.is_hacktool))
		feedback = "<span class'notice'>No Root Network.</span>"
		return list(feedback)
	if(!N.root.password || N.root.password == N.password || N.root.password == A.args[1])
		return list(feedback, N.root.id)
	if(N.root.password && A.is_hacktool && A.args[1] == "b")
		feedback = "<span class='warning'>Performing bruteforce hack on [N.root.id].</span>"
		N.root.execute("security -brute -[N.id]", A.is_hacktool) // Trigger the root's security. Loudly.
		return list(feedback)
	feedback = "<span class='warning'>Encryption Key Mismatch.</span>"
	N.root.execute("security -alert -[N.id]", A.is_hacktool) // Trigger the root's security. Quietly.
	return list(feedback)


/datum/network_command/subnet
	trigger = "subnet"
	info = "Usage: \"subnet -{target}\". Attempts to connect to the target subnetwork of this network if it exists. If there is only one subnetwork, the target is implicit."

/datum/network_command/subnet/execute(datum/network/N, datum/network_argument/A)
	..()
	var/datum/network/SN
	if(A.args[1] && N.sub.len >= 1)
		for(var/datum/network/S in N.sub)
			if(S.id == A.args[1])
				return list(feedback, S.id)
	if(N.sub.len > 1 && !A.args[1])
		var/not_stealthed = 0
		for(var/datum/network/S in N.sub)
			if(!S.stealth)
				not_stealthed++
				SN = S
		if(!A.is_hacktool && not_stealthed == 0)
			feedback = "<span class='notice'>No subnetworks available. Unable to complete request.</span>"
			return list(feedback)
		if(A.is_hacktool || not_stealthed > 1)
			feedback = "<span class='notice'>Multiple subnetworks available. Unable to complete request.</span>"
			return list(feedback)
		if(!A.is_hacktool && not_stealthed == 1)
			return list(feedback, SN.id)
	if(N.sub.len == 1)
		for(var/datum/network/S in N.sub)
			SN = S
		if(!SN.stealth || A.is_hacktool)
			return list(feedback, SN)
	feedback = "<span class='notice'>No subnetworks available. Unable to complete request.</span>"
	return list(feedback)


/datum/network_command/connect
	trigger = "connect"
	info = "Usage: \"connect -{target_id} -{encryption_key}\". Will attempt to connect to the target network."

/datum/network_command/connect/execute(datum/network/N, datum/network_argument/A)
	..()
	if(N.root.id == A.args[1])
		if(!N.root.password || N.root.password == N.password || N.root.password == A.args[2])
			return list(feedback, N.root.id)
		if(N.root.password && A.is_hacktool && A.args[2] == "b")
			feedback = "<span class='warning'>Performing bruteforce hack on [N.root.id].</span>"
			N.root.execute("security -brute -[N.id]", A.is_hacktool) // Trigger the root's security. Loudly.
			return list(feedback, N.root.id)
		feedback = "<span class='warning'>Encryption Key Mismatch.</span>"
		N.root.execute("security -alert -[N.id]", A.is_hacktool) // Trigger the root's security. Quietly.
		return list(feedback)
	for(var/datum/network/S in N.sub)
		if(S.id == A.args[1])
			return list(feedback, S.id)
	feedback = "<span class='warning'>Unable to connect.</span>"
	return list(feedback)


/datum/network_command/set_root
	trigger = "set_root"
	info = "Usage: \"set_root -{target_id} -{encryption_key}\". Will attempt to reassign the root network."

/datum/network_command/set_root/execute(datum/network/N, datum/network_argument/A)
	..()
	if(!A.args[1])
		feedback = "<span class='warning'>Invalid Arguments</span>"
		return list(feedback)
	if(!A.args[1] in active_network_ids || N.root.id == A.args[1] || A.args[1] == N.id)
		feedback = "<span class='warning'>Target Root is Invalid.</span>"
		return list(feedback)
	if(!N.root.password || N.root.password == N.password || N.root.password == A.args[2])
		var/datum/network/newroot = networks_by_id[A.args[1]]
		newroot.sub += N
		N.root.sub -= N
		N.root = newroot
		return list(feedback, N.root.id)
	if(N.root.password && A.is_hacktool && A.args[2] == "b")
		feedback = "<span class='warning'>Performing bruteforce hack on [N.root.id].</span>"
		N.root.execute("security -brute -[N.id]", A.is_hacktool) // Trigger the root's security. Loudly.
		var/datum/network/newroot = networks_by_id[A.args[1]]
		newroot.sub += N
		N.root.sub -= N
		N.root = newroot
		return list(feedback, N.root.id)
	feedback = "<span class='warning'>Encryption Key Mismatch.</span>"
	N.root.execute("security -alert -[N.id]", A.is_hacktool) // Trigger the root's security. Quietly.
	return list(feedback)


/datum/network_command/set_key
	trigger = "set_key"
	info = "Usage: \"set_key -{encryption_key}\". If an encryption key is provided, will set this networks encryption key. Otherwise, will remove it."

/datum/network_command/set_key/execute(datum/network/N, datum/network_argument/A)
	..()
	if(A.args[1])
		N.password = A.args[1]
		feedback = "<span class='notice'>Encryption Key Changed.</span>"
		return list(feedback, N.password)
	N.password = null
	feedback = "<span class='notice'>Encryption Key Removed.</span>"
	return list(feedback)


/datum/network_command/set_id
	trigger = "set_id"
	info = "Usage: \"set_id -{target_id}\". Will attempt to rename this network's ID to the ID provided."

/datum/network_command/set_id/execute(datum/network/N, datum/network_argument/A)
	..()
	if(!A.args[1])
		feedback = "<span class='warning'>Invalid Argument.</span>"
		return list(feedback)
	if(A.args[1] in active_network_ids)
		feedback = "<span class='warning'>Failed to set Network ID.</span>"
		return list(feedback)
	active_network_ids -= N.id
	networks_by_id[N.id] = null
	networks_by_id -= N.id
	N.id = A.args[1]
	networks_by_id[N.id] = N
	active_network_ids += N.id
	feedback = "<span class='notice'>Successfully set Network ID.</span>"
	return list(feedback)


/datum/network_command/set_hidden
	trigger = "set_hidden"
	info = "Usage: \"set_hidden -{boolean}\". Will set hidden status."

/datum/network_command/set_hidden/execute(datum/network/N, datum/network_argument/A)
	..()
	switch(A.args[1])
		if("true" || "1")
			N.stealth = 1
			return list(feedback)
		if("false"|| "0")
			N.stealth = 0
			return list(feedback)
	feedback = "<span class='warning'>Invalid Argument.</span>"
	return list(feedback)


/datum/network_command/set_local
	trigger = "set_local"
	info = "Usage: \"set_local -{boolean}\". Will set local|wide network status."

/datum/network_command/set_local/execute(datum/network/N, datum/network_argument/A)
	..()
	switch(A.args[1])
		if("true" || "1")
			N.wireless = 0
			if(N in networks_by_wide)
				networks_by_wide -= N
			return list(feedback)
		if("false" || "0")
			N.wireless = 1
			if(!(N in networks_by_wide))
				networks_by_wide += N
			return list(feedback)
	feedback = "<span class='warning'>Invalid Argument.</span>"
	return list(feedback)


/datum/network_command/probe
	trigger = "probe"
	info = "Usage: \"probe -{scope}\". Will search within the provided scope for network id's containing the target id. Allowed scopes are: w:wide, l:local."

/datum/network_command/probe/execute(datum/network/N, datum/network_argument/A)
	..()
	var/list/datum/network/found = list()
	if(A.args[1] == "w" || A.args[1] == "wide")
		if(!A.is_hacktool)
			for(var/datum/network/S in networks_by_wide)
				if(!S.stealth)
					found += S
		else
			found = networks_by_wide
	else if(A.args[1] == "l" || A.args[1] == "local")
		if(isnull(N.holder))
			feedback = "<span class='notice'>No Networks found within scope provided.</span>"
			return list(feedback)
		var/area/AR = get_area(N.holder)
		for(var/obj/O in AR)
			if(O.netwrk && !O.netwrk.wireless)
				if(!O.netwrk.stealth || A.is_hacktool)
					found += O.netwrk
	if(!found.len)
		feedback = "<span class='notice'>No Networks found within scope provided.</span>"
		return list(feedback)
	feedback = "<span class='notice'>Probed Networks: </span>\n "
	for(var/datum/network/S in found)
		feedback += "<span class='notice'>| [S.id] </span>"
	feedback += "<span class='notice'>|</span>"
	return list(feedback)