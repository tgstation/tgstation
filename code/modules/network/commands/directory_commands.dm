/*
//////////////////////////////
///// Directory Commands /////
//////////////////////////////

{encryption_key}
	Must be a string with no spaces. If you are currently connected to a network, leaving this blank will use the current networks encryption key.
	-b can be passed in place of a string using an upgraded net-tool to brute-force the encryption key. This may trigger security systems, and take some time.
	If the network does not require an encryption key, any arguments placed here will be ignored.

== info {query)
	Lists the available commands. If a query is provided, attempts to explain how the command is used.

== get_root
	Returns the id of the root network.

== get_id
	Returns the id of the current network.

== get_sub
	Returns the id of the subnetwork. Will return an error if there is more than one.

== get_sublist
	Lists the id's of all this networks subnetworks.

== rootnet {encryption_key}
	Attempts to connect to the rootnetwork, using the provided encryption key.

== subnet {target_id}
	Attempts to connect to the target subnetwork. If target is not provided, and there is only one subnet, then it will connect to that network.

== set_id {target_id} {encryption_key}
	Attempts to change the current networks id. Will return an error if the id is already taken.

== set_root {target_id} {encryption_key}
	Attempts to change the current networks root to the target network. Requires the current root encryption key.

== connect {target_id} {encryption_key}
	Attempts to connect to the target network. If you are already connected to a network, will attempt to connect through this one.
	If no target is specified it will return an error.

== disconnect
	Disconnects from the current network.

== probe {scope} {query}
	Searches through the connected network for networks matching the provided query. If no query is provided, it will list all networks within the scope.
		{scope} Arguments: "-w:wide, -l:local, -a:all"
			w:wide: Will search through wireless station-wide networks. If it is currently connected to a network, will only return networks that are connected.
			l:local: Will search for networks located within the same area. If it is currently connected to a network, will only return networks that are directly connected.
			a:all: Will search through station-wide, and local networks. If is is currently connected to a network, it will also search through any unencrypted connected networks.
		{query} Arguments: "-string"
			string: Will limit the search to networks containing the queried string within their id.

*/

/datum/net_command/info
	trigger = "info"
	info = "Usage: \"info -{query}\". Gives you some information about the commands available on this network. If a query is provided, will explain the usage of that command."

/datum/net_command/info/execute(datum/network/N, list/params)
	..()
	if(isnull(params["args"][1]))
		feedback = "<span class='notice'>Available Network Commands: </span>"
		for(var/datum/net_command/NC in N.commands)
			if(!NC.stealth || params["upgraded"] == 1)
				feedback += "\n <span class='notice'>[NC.trigger]</span>"
		return list(feedback)
	for(var/datum/net_command/NC in N.commands)
		if(NC.trigger == params["args"][1])
			feedback = "<span class='notice'>info -[NC.trigger]\n [NC.info]</span>"
			return list(feedback)
	feedback = "<span class='notice'>info -[params["args"][1]]</span>\n <span class='warning'>Invalid Argument: \"[params["args"][1]]\"</span>"
	return list(feedback)


/datum/net_command/get_root
	trigger = "get_root"
	info = "Usage: \"get_root\". Returns the root id of this network, if it exists."

/datum/net_command/get_root/execute(datum/network/N, list/params)
	..()
	if(!N.root || (N.root.stealth && params["upgraded"] == 0))
		feedback = "<span class='notice'>No Root Network.</span>"
		return list(feedback)
	feedback = "<span class='notice'>Root: [N.root.id]</span>"
	return list(feedback, N.root.id)


/datum/net_command/get_sub
	trigger = "get_sub"
	info = "Usage: \"get_sub\". Returns a list of all connected subnetworks."

/datum/net_command/get_sub/execute(datum/network/N, list/params)
	..()
	if(N.sub.len)
		var/list/datum/network/SN = list()
		feedback = "<span class='notice'>Available Subnetworks: </span>\n "
		for(var/datum/network/sub in N.sub)
			if(!sub.stealth || params["upgraded"] == 1)
				SN += sub
				feedback += "<span class='notice'>| [sub.id] </span>"
		if(SN.len >= 1)
			feedback += "<span class='notice'>|</span>"
			return list(feedback)
	feedback = "<span class='notice'>No Subnetwork Available.</span>"
	return list(feedback)


/datum/net_command/get_id
	trigger = "get_id"
	info = "Usage: \"get_id\". Returns the id of this network."

/datum/net_command/get_id/execute(datum/network/N, list/params)
	..()
	feedback = "<span class='notice'>Network ID: [N.id]</span>"
	return list(feedback, N.id)


/datum/net_command/rootnet
	trigger = "rootnet"
	info = "Usage: \"rootnet -{encryption_key}\". Attempts to connect to the root network. If no encryption key is provided, current networks encryption key will be used."

/datum/net_command/rootnet/execute(datum/network/N, list/params)
	..()
	if(!N.root || (N.root.stealth && params["upgraded"] == 0))
		feedback = "<span class'notice'>No Root Network.</span>"
		return list(feedback)
	if(!N.root.password || N.root.password == N.password || N.root.password == params["args"][1])
		return list(feedback, N.root.id)
	if(N.root.password && params["upgraded"] == 1 && params["args"][1] == "b")
		feedback = "<span class='warning'>Performing bruteforce hack on [N.root.id].</span>"
		N.root.execute("security -brute", list("args" = list(), "upgraded" = 1, "source" = N)) // Trigger the roots security. Loudly.
		return list(feedback)
	feedback = "<span class='warning'>Encryption Key Mismatch.</span>"
	N.root.execute("security -alert", list("args" = list(), "upgraded" = params["upgraded"], "source" = N)) // Trigger the root's security. Quietly.
	return list(feedback)


/datum/net_command/subnet
	trigger = "subnet"
	info = "Usage: \"subnet -{target}\". Attempts to connect to the target subnetwork of this network if it exists."

/datum/net_command/subnet/execute(datum/network/N, list/params)
	..()
	var/datum/network/SN
	if(N.sub.len < 1)
		return list("feedback" = "<span class='warning'>No subnetworks available. Unable to complete request.</span>")
	if(N.sub.len > 1)
		var/non_stealthed = 0
		for(var/datum/network/S in N.sub)
			if(!S.stealth)
				non_stealthed++
				if(non_stealthed == 1)
					SN = S
		if(params["upgraded"] == 1 || non_stealthed > 1)
			return list("feedback" = "<span class='warning'>Multiple subnetworks available. Unable to complete request.</span>")
		if(non_stealthed == 0)
			return list("feedback" = "<span class='warning'>No subnetworks available. Unable to complete request.</span>")
	if(N.sub.len == 1)
		for(var/datum/network/S in N.sub)
			if(!S.stealth || params["upgraded"] == 1)
				SN = S
			else
				return list("feedback" = "<span class='warning'>No subnetworks available. Unable to complete request.</span>")
	if(!SN.password || SN.password == params["arguments"])
		return list("focus" = SN)
	return list("feedback" = "<span class='warning'>Encryption Key Mismatch.</span>")


/datum/net_command/to_net
	trigger = "net"
	info = "Usage: \"net -{target_id} -{encryption_key}\". Will attempt to focus on the target network."

/datum/net_command/to_net/execute(datum/network/N, list/params)
	..()