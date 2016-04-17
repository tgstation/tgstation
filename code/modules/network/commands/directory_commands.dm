
//////////////////////////////
///// Directory Commands /////
//////////////////////////////

/datum/network_command/info
	trigger = "info"
	info = "Usage: \"info -{query}\". Gives you some information about the commands available on this network. If a query is provided, will explain the usage of that command."

/datum/network_command/info/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(A.args.len == 0)
		feedback = "<span class='notice'>Available Network Commands: </span>"
		for(var/datum/network_command/NC in N.commands)
			if(!NC.stealth || ishacktool(H))
				feedback += "\n <span class='notice'>[NC.trigger]</span>"
		return feed(H)
	for(var/datum/network_command/NC in N.commands)
		if(NC.trigger == A.args[1])
			feedback = "<span class='notice'>info -[NC.trigger]\n [NC.info]</span>"
			return feed(H)
	feedback = "<span class='notice'>info -[A.args[1]]</span>\n <span class='warning'>Invalid Argument: \"[A.args[1]]\"</span>"
	return feed(H)


/datum/network_command/get_root
	trigger = "get_root"
	info = "Usage: \"get_root\". Returns the root id of this network, if it exists."

/datum/network_command/get_root/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(!N.root || (N.root.stealth && !ishacktool(H)))
		feedback = "<span class='notice'>No Root Network.</span>"
		return feed(H)
	feedback = "<span class='notice'>Root: [N.root.id]</span>"
	return feed(H)


/datum/network_command/get_sub
	trigger = "get_sub"
	info = "Usage: \"get_sub\". Returns a list of all connected subnetworks."

/datum/network_command/get_sub/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(N.sub.len)
		var/list/datum/network/SN = list()
		feedback = "<span class='notice'>Available Subnetworks: </span>\n "
		for(var/datum/network/sub in N.sub)
			if(!sub.stealth || ishacktool(H))
				SN += sub
				feedback += "<span class='notice'>| [sub.id] </span>"
		if(SN.len >= 1)
			feedback += "<span class='notice'>|</span>"
			return feed(H)
	feedback = "<span class='notice'>No Subnetwork Available.</span>"
	return feed(H)


/datum/network_command/get_id
	trigger = "get_id"
	info = "Usage: \"get_id\". Returns the id of this network."

/datum/network_command/get_id/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	feedback = "<span class='notice'>Network ID: [N.id]</span>"
	return feed(H)


/datum/network_command/get_key
	trigger = "get_key"
	info = "Usage: \"get_key\". Returns the network encryption key."

/datum/network_command/get_key/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	feedback = "<span_class='notice'>Encryption Key: [N.password]</span>"
	return feed(H)


/datum/network_command/get_hidden
	trigger = "get_hidden"
	info = "Usage: \"get_hidden\". Returns whether or not this network is protected from probing."

/datum/network_command/get_hidden/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	feedback = "<span class='notice'>Network Stealthed: [N.stealth ? "TRUE" : "FALSE"]</span>"
	return feed(H)


/datum/network_command/get_local
	trigger = "get_local"
	info = "Usage: \"get_local\". Returns whether or not this network can be accessed from anywhere on the station."

/datum/network_command/get_wireless/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	feedback = "<span class='notice'>Local Network: [N.wireless ? "FALSE" : "TRUE"]</span>"
	return feed(H)


/datum/network_command/rootnet
	trigger = "rootnet"
	info = "Usage: \"rootnet -{encryption_key}\". Attempts to connect to the root network. If no encryption key is provided, current networks encryption key will be used."

/datum/network_command/rootnet/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(!N.root || (N.root.stealth && !ishacktool(H)))
		feedback = "<span class'notice'>No Root Network.</span>"
		return feed(H)
	if(!N.root.password || N.root.password == N.password || N.root.password == A.args[1])
		connect(N.root, H)
		return feed(H)
	if(N.root.password && ishacktool(H) && A.args[1] == "b")
		feedback = "<span class='warning'>Performing bruteforce hack on [N.root.id].</span>"
		N.root.execute("security -brute -[N.id]", H) // Trigger the root's security. Loudly.
		connect(N.root, H)
		return feed(H)
	feedback = "<span class='warning'>Encryption Key Mismatch.</span>"
	N.root.execute("security -alert -[N.id]", H) // Trigger the root's security. Quietly.
	return feed(H)


/datum/network_command/subnet
	trigger = "subnet"
	info = "Usage: \"subnet -{target}\". Attempts to connect to the target subnetwork of this network if it exists. If there is only one subnetwork, the target is implicit."

/datum/network_command/subnet/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	var/datum/network/SN
	if(A.args[1] && N.sub.len >= 1)
		for(var/datum/network/S in N.sub)
			if(S.id == A.args[1])
				connect(S, H)
				return feed(H)
	if(N.sub.len > 1 && !A.args[1])
		var/not_stealthed = 0
		for(var/datum/network/S in N.sub)
			if(!S.stealth)
				not_stealthed++
				SN = S
		if(!ishacktool(H) && not_stealthed == 0)
			feedback = "<span class='notice'>No subnetworks available. Unable to complete request.</span>"
			return feed(H)
		if(ishacktool(H) || not_stealthed > 1)
			feedback = "<span class='notice'>Multiple subnetworks available. Unable to complete request.</span>"
			return feed(H)
		if(!ishacktool(H) && not_stealthed == 1)
			connect(SN, H)
			return feed(H)
	if(N.sub.len == 1)
		for(var/datum/network/S in N.sub)
			SN = S
		if(!SN.stealth || ishacktool(H))
			connect(SN, H)
			return feed(H)
	feedback = "<span class='notice'>No subnetworks available. Unable to complete request.</span>"
	return feed(H)


/datum/network_command/connect
	trigger = "connect"
	info = "Usage: \"connect -{target_id} -{encryption_key}\". Will attempt to connect to the target network."

/datum/network_command/connect/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(N.root.id == A.args[1])
		if(!N.root.password || N.root.password == N.password || N.root.password == A.args[2])
			connect(N.root, H)
			return feed(H)
		if(N.root.password && ishacktool(H) && A.args[2] == "b")
			feedback = "<span class='warning'>Performing bruteforce hack on [N.root.id].</span>"
			N.root.execute("security -brute -[N.id]", H) // Trigger the root's security. Loudly.
			connect(N.root, H)
			return feed(H)
		feedback = "<span class='warning'>Encryption Key Mismatch.</span>"
		N.root.execute("security -alert -[N.id]", H) // Trigger the root's security. Quietly.
		return feed(H)
	for(var/datum/network/S in N.sub)
		if(S.id == A.args[1])
			connect(S, H)
			return feed(H)
	feedback = "<span class='warning'>Unable to connect.</span>"
	return feed(H)


datum/network_command/disconnect
	trigger = "disconnect"
	info = "Usage: \"disconnect\". Will attempt to disconnect from the current network."

datum/network_command/disconnect/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	feedback = "<span class='notice'>Attempting to disconnect from network.</span>"
	N.execute("security -disconnect", H)
	disconnect(H)
	return feed(H)


/datum/network_command/set_root
	trigger = "set_root"
	info = "Usage: \"set_root -{target_id} -{encryption_key}\". Will attempt to reassign the root network."

/datum/network_command/set_root/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(!A.args[1])
		feedback = "<span class='warning'>Invalid Arguments</span>"
		return feed(H)
	if(!A.args[1] in active_network_ids || N.root.id == A.args[1] || A.args[1] == N.id)
		feedback = "<span class='warning'>Target Root is Invalid.</span>"
		return feed(H)
	if(!N.root.password || N.root.password == N.password || N.root.password == A.args[2])
		var/datum/network/newroot = networks_by_id[A.args[1]]
		newroot.sub += N
		N.root.sub -= N
		N.root = newroot
		return feed(H)
	if(N.root.password && ishacktool(H) && A.args[2] == "b")
		feedback = "<span class='warning'>Performing bruteforce hack on [N.root.id].</span>"
		N.root.execute("security -brute -[N.id]", H) // Trigger the root's security. Loudly.
		var/datum/network/newroot = networks_by_id[A.args[1]]
		newroot.sub += N
		N.root.sub -= N
		N.root = newroot
		return feed(H)
	feedback = "<span class='warning'>Encryption Key Mismatch.</span>"
	N.root.execute("security -alert -[N.id]", H) // Trigger the root's security. Quietly.
	return feed(H)


/datum/network_command/set_key
	trigger = "set_key"
	info = "Usage: \"set_key -{encryption_key}\". If an encryption key is provided, will set this networks encryption key. Otherwise, will remove it."

/datum/network_command/set_key/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(A.args[1])
		N.password = A.args[1]
		feedback = "<span class='notice'>Encryption Key Changed.</span>"
		return feed(H)
	N.password = null
	feedback = "<span class='notice'>Encryption Key Removed.</span>"
	return feed(H)


/datum/network_command/set_id
	trigger = "set_id"
	info = "Usage: \"set_id -{target_id}\". Will attempt to rename this network's ID to the ID provided."

/datum/network_command/set_id/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	if(!A.args[1])
		feedback = "<span class='warning'>Invalid Argument.</span>"
		return feed(H)
	if(A.args[1] in active_network_ids)
		feedback = "<span class='warning'>Failed to set Network ID.</span>"
		return feed(H)
	active_network_ids -= N.id
	networks_by_id[N.id] = null
	networks_by_id -= N.id
	N.id = A.args[1]
	networks_by_id[N.id] = N
	active_network_ids += N.id
	feedback = "<span class='notice'>Successfully set Network ID.</span>"
	return feed(H)


/datum/network_command/set_hidden
	trigger = "set_hidden"
	info = "Usage: \"set_hidden -{boolean}\". Will set hidden status."

/datum/network_command/set_hidden/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	switch(A.args[1])
		if("true" || "1")
			N.stealth = 1
			return feed(H)
		if("false"|| "0")
			N.stealth = 0
			return feed(H)
	feedback = "<span class='warning'>Invalid Argument.</span>"
	return feed(H)


/datum/network_command/set_local
	trigger = "set_local"
	info = "Usage: \"set_local -{boolean}\". Will set local|wide network status."

/datum/network_command/set_local/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	switch(A.args[1])
		if("true" || "1")
			N.wireless = 0
			if(N in networks_by_wide)
				networks_by_wide -= N
			return feed(H)
		if("false" || "0")
			N.wireless = 1
			if(!(N in networks_by_wide))
				networks_by_wide += N
			return feed(H)
	feedback = "<span class='warning'>Invalid Argument.</span>"
	return feed(H)


/datum/network_command/probe
	trigger = "probe"
	info = "Usage: \"probe -{scope}\". Will search within the provided scope for network id's containing the target id. Allowed scopes are: w:wide, l:local."

/datum/network_command/probe/execute(datum/network/N, datum/network_argument/A, obj/item/device/hacktool/H)
	..()
	var/list/datum/network/found = list()
	if(A.args[1] == "w" || A.args[1] == "wide")
		if(!ishacktool(H))
			for(var/datum/network/S in networks_by_wide)
				if(!S.stealth)
					found += S
		else
			found = networks_by_wide
	else if(A.args[1] == "l" || A.args[1] == "local")
		if(isnull(N.holder))
			feedback = "<span class='notice'>No Networks found within scope provided.</span>"
			return feed(H)
		var/area/AR = get_area(N.holder)
		for(var/obj/O in AR)
			if(O.netwrk && !O.netwrk.wireless)
				if(!O.netwrk.stealth || ishacktool(H))
					found += O.netwrk
	if(!found.len)
		feedback = "<span class='notice'>No Networks found within scope provided.</span>"
		return feed(H)
	feedback = "<span class='notice'>Probed Networks: </span>\n "
	for(var/datum/network/S in found)
		feedback += "<span class='notice'>| [S.id] </span>"
	feedback += "<span class='notice'>|</span>"
	return feed(H)