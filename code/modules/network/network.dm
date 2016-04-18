/*
	Upgraded devices, such as borgs, the AI, or "Hacktools" have several notable features:
	they are able to see stealthed networks.
	they are able to pass "-b" as an argument in place of an encryption key to make an attempt at brute-forcing the network. This will take some time, and may trigger the networks security system, but will eventually get you in.
*/

var/global/list/networks_by_id = list()
var/global/list/datum/network/networks_by_wide = list()
var/global/list/active_network_ids = list()

proc/clean_network_command(command = "")
	var/list/butchered = explode_text(command, " -") // allows for arguments like {text1 = "hello "} {text2 = "world"} to be caused when executing something like {print -text1 = "hello " -text2 = "world"}
	command = butchered[1]
	var/list/arguments = list()
	for(var/i=2, i<=butchered.len, i++)
		arguments[i-1] = butchered[i]
	return list(command, arguments)

proc/getuniqueid()
	return 1

/datum/network_argument
	var/main_command
	var/list/net_args = list()

/datum/network_argument/New(var/command)
	var/list/clean_command = clean_network_command(command)
	main_command = clean_command[1]
	args = clean_command[2]

/datum/network
	var/atom/holder = null							// The holder (atom that contains this network datum).
	var/id = null									// A unique id
	var/password = null								// A password to prevent unauthorized access to the network.
	var/stealth = 0									// Whether the network should be hidden from standard probing and prying.
	var/wireless = 0								// Whether the network can be accessed remotely.
	var/locked = 0									// Prevent hacktool from connecting to this network. Can be bypassed.
	var/lockout = 0									// Prevent hacktool from connecting to this network. Can't be bypassed.
	var/datum/network/root 							// The root network, if this is a subnetwork.
	var/list/datum/network/subnetwork = list() 			// A list of networks that are a subnetwork of this one.
	var/list/datum/network_command/commands = list()	// A list of commands this network has access to. Works kinda like virus symptoms.

/datum/network/New(atom/holder)
	..()
	src.holder = holder
	if(id)
		updateid(id)
	if(wireless)
		networks_by_wide += src
	var/list/commandlist = commands
	commands = list()
	for(var/C in commandlist)
		commands += new C()

/datum/network/Destroy()
	holder = null
	for(var/datum/network/S in subnetwork)
		S.del_root()
	subnetwork = list()
	if(root)
		root.del_sub(src)
	root = list()
	for(var/datum/network_command/NC in commands)
		qdel(NC)
	commands = list()
	if(id)
		networks_by_id[id] = null
		networks_by_id -= id
		active_network_ids -= id
	if(wireless)
		networks_by_wide -= src
	return ..()

/datum/network/proc/del_root() // Called when the root is destroyed.
	root = null

/datum/network/proc/del_sub(datum/network/S) // Called when the subdirectory is destroyed.
	if(S in subnetwork)
		subnetwork -= S

/datum/network/proc/execute(var/command, var/obj/item/device/hacktool/H) // Used to pass commands to the network.
	if(!command)
		return
	var/datum/network_argument/A = new(command)

	for(var/datum/network_command/NC in commands) // allows for adding 'universal' commands, which can be attached to any network object.
		if(NC.trigger == A.main_command)
			NC.execute(src, A.net_args, H) // Commands can be hard-coded to the network object, or made into a 'universal' command, which can be called by any network object.
			qdel(A)
			return 1

/datum/network/proc/updateid(var/newid)
	if(newid in active_network_ids)
		newid += getuniqueid()
	active_network_ids -= id
	active_network_ids += newid
	networks_by_id[id] = null
	networks_by_id[newid] = src
	id = newid



/datum/network_command/proc/feed(var/obj/item/device/hacktool/H)
	if(feedback && H)
		H.get_feedback(feedback)
		return 1

/datum/network_command/proc/disconnect(var/obj/item/device/hacktool/H)
	if(H)
		H.disconnect()

/datum/network_command/proc/connect(var/datum/network/N, var/obj/item/device/hacktool/H)
	if(H && N)
		H.connect(N)

// helper proc to trigger security systems, and step up/down depending on hacktool upgrades.
/*
	possible parameters:

	noob: calls security -noob, unless hacktool is stealthed OR has probe software installed.
		called by noobs. For being noobs.
	probe: calls security -probe unless hacktool is stealthed.
		should be used if there is no potential for stealthed commands or networks to be revealed.
	bruteprobe: calls security -probe unless hacktool is stealthed, or bruteprobe if hacktool has probe software installed.
		should be used whenever stealthed commands or networks are potentially revealed.
	alert: calls security -alert unless hacktool is stealthed.
		used often, this is the default 'alert' parameter.
	brutealert: calls security -brutealert unless hacktool is stealthed, in which case it will call security -alert instead.
		used when a hacktool with brute software bruteforces a network encryption key.
	connect: calls security -connect unless the hacktool is stealthed.
		used when a hacktool makes a valid attempt to connect to a network.

*/
/datum/network_command/proc/security(var/datum/network/N, var/params = "alert", var/obj/item/device/hacktool/H)
	if(!params || !N || !H)
		return
	switch(params)
		if("noob")
			if(H.software & (HACK_STEALTH | HACK_PROBE))
				return
			N.execute("security -noob", H)
			return
		if("probe")
			if(H.software & HACK_STEALTH)
				return
			N.execute("security -probe", H)
			return
		if("alert")
			if(H.software & HACK_STEALTH)
				return
			N.execute("security -alert", H)
			return
		if("bruteprobe")
			if(H.software & HACK_PROBE & ~HACK_STEALTH) // If probe software is installed, but stealth isn't, call bruteprobe.
				N.execute("security -bruteprobe", H)
				return
			else if(H.software & HACK_STEALTH & ~HACK_PROBE) // If probe software is not installed, but stealth software is, don't trigger security.
				return
			else
				N.execute("security -probe", H)
				return
		if("brutealert")
			if(H.software & HACK_STEALTH)
				N.execute("security -alert", H)
				return
			N.execute("security -brutealert", H)
			return
		if("connect")
			if(H.software & HACK_STEALTH)
				return
			N.execute("security -connect", H)
			return

	N.execute("security -[params]", H) // Probably a rogue parameter, try it anyways.


/*
	Intended to increase code-modularity and reuseability.
	Execute should always return either null, or a list.
*/

/datum/network_command
	var/trigger = "" 	// The trigger word for this command to be executed.
	var/stealth = 0		// Whether this command can be identified using info.
	var/feedback = ""	// The message sent back to the device calling this command.
	var/info = ""		// A feedback message that explains the usage of this command. For the noobs.

/datum/network_command/proc/execute(datum/network/N, list/A, obj/item/device/hacktool/H) // Network running command, Arguments passed, Hacktool
	if(!N || !H)
		return