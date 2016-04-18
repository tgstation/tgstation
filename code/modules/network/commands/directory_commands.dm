
//////////////////////////////
///// Directory Commands /////
//////////////////////////////

// An obvious starting point for clueless players. Hints to the next useful command."

/datum/network_command/info
	trigger = "help"
	info = "Usage: \"help -{query}\". Gives you some information about the queried command. You can use \"probe -c\" for a list of available commands."

/datum/network_command/info/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	if(!A)
		feedback = "[info]"
		feed(H)
		security(N, "noob", H)
		return
	for(var/datum/network_command/C in N.commands)
		if(C.trigger == A[1])
			feedback = "[C.info]"
			security(N, "noob", H)
			feed(H)
			return
	feedback = "Invalid Argument: \"[A[1]]\""
	feed(H)
	return


/datum/network_command/getroot
	trigger = "getroot"
	info = "Usage: \"getroot\". Returns the root id of this network, if it exists."

/datum/network_command/get_root/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	if(N.root && (!N.root.stealth || H.software & HACK_PROBE))
		feedback = "Root Network: [N.root.id]"
		security(N.root, "bruteprobe", H)
		feed(H)
		return
	feedback = "Root Network: NULL"
	feed(H)
	return


/datum/network_command/getsubnet
	trigger = "getsubnet"
	info = "Usage: \"getsubnet\". Returns a list of all connected subnetworks."

/datum/network_command/getsubnet/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	if(N.subnetwork.len)
		var/list/datum/network/SN = list()
		feedback = "Available Subnetworks: "
		for(var/datum/network/sub in N.subnetwork)
			if(!sub.stealth || H.software & HACK_PROBE)
				SN += sub
				feedback += "| [sub.id] "
		if(SN.len >= 1)
			feedback += "|"
			security(N, "bruteprobe", H)
			feed(H)
			return
	feedback = "Available Subnetworks: NULL"
	feed(H)
	return


/datum/network_command/getid
	trigger = "getid"
	info = "Usage: \"getid\". Returns the id of this network."

/datum/network_command/get_id/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	feedback = "Network ID: [N.id]"
	feed(H)
	return


/datum/network_command/getkey
	trigger = "getkey"
	info = "Usage: \"getkey\". Returns the network encryption key."

/datum/network_command/getkey/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	if(!N.password)
		feedback = "Encryption Key: NULL"
		feed(H)
		return
	feedback = "Encryption Key: [N.password]"
	feed(H)
	security(N, "probe", H)
	return


/datum/network_command/gethidden
	trigger = "gethidden"
	info = "Usage: \"gethidden\". Returns whether or not this network is protected from probing."

/datum/network_command/gethidden/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	feedback = "Network Stealthed: [N.stealth ? "TRUE" : "FALSE"]"
	feed(H)
	return


/datum/network_command/getlocal
	trigger = "getlocal"
	info = "Usage: \"getlocal\". Returns whether or not this network can be accessed from anywhere on the station."

/datum/network_command/getlocal/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	feedback = "Local Network: [N.wireless ? "FALSE" : "TRUE"]"
	feed(H)
	return


/datum/network_command/root
	trigger = "root"
	info = "Usage: \"root -{encryption_key}\". Attempts to connect to the root network. If no encryption key is provided, current networks encryption key will be used."

/datum/network_command/rootnet/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	if(N.root && (!N.root.stealth || H.software & HACK_PROBE))
		if(!N.root.password || N.root.password == N.password || N.root.password == A[1])
			connect(N.root, H)
			return
		if(N.root.password && H.software & HACK_BRUTE && A[1] == "b")
			security(N.root, "brutealert", H)
			H.bruteforce(N.root)
			return
		feedback = "Encryption Key Mismatch"
		security(N.root, "alert", H)
		feed(H)
		return
	feedback = "Connection failed. Target is NULL"
	feed(H)
	return


/datum/network_command/subnet
	trigger = "subnet"
	info = "Usage: \"subnet -{target}\". Attempts to connect to subnetwork. If there is more than one subnetwork, a target must be specified."

/datum/network_command/subnet/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	if(N.subnetwork.len)
		var/list/datum/network/found
		for(var/datum/network/S in N.subnetwork)
			if(S.id == A[1] || (!A[1] && (!S.stealth || H.software & HACK_PROBE)))
				found += S
		if(found.len==1)
			security(found[1], "connect", H)
			connect(found[1], H)
			return
		if(found.len>=1) // There is more than one.
			feedback = "Connection failed. Multiple targets."
			feed(H)
			return
	feedback = "Connection failed. Target is NULL"
	feed(H)
	return


datum/network_command/disconnect
	trigger = "disconnect"
	info = "Usage: \"disconnect\". Will attempt to disconnect from the current network."

datum/network_command/disconnect/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	disconnect(H)
	return


/datum/network_command/setkey
	trigger = "set_key"
	info = "Usage: \"set_key -{encryption_key}\". If an encryption key is provided, will set this networks encryption key. Otherwise, will remove it."

/datum/network_command/setkey/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	N.password = A[1]
	feedback = "Encryption Key Set"
	feed(H)
	return


/datum/network_command/setid
	trigger = "setid"
	info = "Usage: \"setid -{target_id}\". Will attempt to rename this network's ID to the ID provided."

/datum/network_command/setid/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	if(A[1])
		N.updateid(A[1])
		feedback = "Network ID: [N.id]"
		feed(H)
		return
	feedback = "Command failed. Required argument is NULL"
	feed(H)
	return


/datum/network_command/togglehidden
	trigger = "togglehidden"
	info = "Usage: \"togglehidden\". Will toggle hidden status."

/datum/network_command/togglehidden/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	N.stealth = !N.stealth
	feedback = "Network Hidden: [N.stealth ? "TRUE" : "FALSE"]"
	feed(H)
	return


/datum/network_command/togglebroad
	trigger = "togglebroad"
	info = "Usage: \"togglebroad\". Will toggle local|wide network broadcasting."

/datum/network_command/togglebroad/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	..()
	N.wireless = !N.wireless
	feedback = "Network Broadcasting: [N.wireless ? "TRUE" : "FALSE"]"
	feed(H)
	return

/*
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
*/