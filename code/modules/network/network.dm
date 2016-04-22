/*
	Upgraded devices, such as borgs, the AI, or "Hacktools" have several notable features:
	they are able to see stealthed networks.
	they are able to pass "-b" as an argument in place of an encryption key to make an attempt at brute-forcing the network. This will take some time, and may trigger the networks security system, but will eventually get you in.
*/

var/global/list/networks_by_id = list() // netid = network

#define REMOTE_NETWORK_NONE 0 // The network can only be connected to manually.
#define REMOTE_NETWORK_AREA 1 // The network can be connected to from the same area, except for space.
#define REMOTE_NETWORK_HALF 2 // The network can be connected to from anywhere on the same z-level.
#define REMOTE_NETWORK_FULL 3 // The network can be connected to from anywhere in the world. Good for TV shows/Thunderdome cameras/Cargo Consoles

proc/parse_network_command(command = "")
	var/list/butchered = splittext(command, " -") // allows for arguments like {text1 = "hello "} {text2 = "world"} to be caused when executing something like {print -text1 = "hello " -text2 = "world"}
	command = butchered[1]
	var/list/arguments = list()
	for(var/i=2, i<=butchered.len, i++)
		arguments[i-1] = butchered[i]
	return list(command, arguments)

/datum/network
	var/atom/holder = null							// The holder (atom that contains this network datum).
	var/id = null									// A unique id
	var/info										// Information about this network type. Used by help info
	var/password = null								// A password to prevent unauthorized access to the network.
	var/stealth = 0									// Whether the network should be hidden from standard probing and prying.
	var/remote = REMOTE_NETWORK_NONE				// Whether the network can be accessed remotely, and if so, from where.
	var/locked = 0									// Prevent hacktool from connecting to this network. Can be bypassed.
	var/invisible = 0								// This network doesnt exist, as far as players are concerned.
	var/list/linked = list()						// List of linked networks by id (netid = network).
	var/list/connected = list()						// List of traversable networks by id (netid = network)
	var/list/datum/network_command/commands = list(/datum/network_command/info, \
												/datum/network_command/connect, \
												/datum/network_command/disconnect, \
												/datum/network_command/get, \
												/datum/network_command/link, \
												/datum/network_command/unlink, \
												/datum/network_command/probe)	// A list of commands this network has access to. Works kinda like virus symptoms.

/datum/network/New(var/newid = null, atom/H, var/newpw = null)
	..()
	if(H)
		holder = H
	if(!holder)
		world.log << "[id]:[src] was created without a holder."
		qdel(src)
		return
	if(newpw)
		if(newpw == "generate")
			password = random_string(8, hex_characters)
		else
			password = newpw
	if(newid) // Can be called with new(null, H) without issues, or new("system", H) to set a preferred ID.
		id = newid
	if(!id)
		id = "[num2hex(world.time, -1)]"
	id = updateid()
	var/list/commandlist = commands.Copy()
	commands = list()
	for(var/datum/network_command/NC in commandlist)
		commands += new NC()

/datum/network/Destroy()
	holder = null
	for(var/I in linked)
		var/datum/network/N = linked[I]
		if(istype(N))
			N.del_link(src)
		linked -= I
	linked = list()
	connected = list()
	for(var/datum/network_command/NC in commands)
		qdel(NC)
	commands = list()
	networks_by_id -= id
	..()


/datum/network/proc/del_link(var/datum/network/N, var/callOnLinked = FALSE) // Called when the root is destroyed. Or it can be called to remove a link by setting callOnLinked to TRUE
	linked -= N.id
	connected -= N.id
	if(callOnLinked)
		N.del_link(src)


/datum/network/proc/del_connection(datum/network/N, var/callOnLinked = TRUE) // Called to remove the connection, but not the link. This can be create a one-way network diode by setting FALSE.
	connected -= N.id
	if(callOnLinked)
		N.del_connection(src, FALSE)


/datum/network/proc/add_link(var/datum/network/N, var/callOnLinked = TRUE) // Used to link networks together. callOnLinked should always be TRUE.
	if(!linked[N.id] == N)
		linked[N.id] = N
	if(callOnLinked)
		N.add_link(src, FALSE)


/datum/network/proc/add_connection(var/datum/network/N, var/callOnLinked = TRUE) // Used to connect linked networks together. Can create a network diode by setting FALSE.
	add_link(N)
	if(!connected[N.id] == N)
		connected[N.id] = N
	if(callOnLinked)
		N.add_connection(src, FALSE)


/datum/network/proc/execute(var/command, var/obj/item/device/hacktool/H) // Used to pass commands to the network.
	if(!command)
		return
	var/list/parsed = parse_network_command(command)

	for(var/datum/network_command/NC in commands) // allows for adding 'universal' commands, which can be attached to any network object.
		if(NC.trigger == parsed[1])
			NC.execute(src, parsed[2], H)
			return 1


/datum/network/proc/updateid() // Used when this id is changed.
	var/newid = id
	. = newid

	if(id in networks_by_id) // Checks if the current id already exists, and whether we're changing it, or it's just a conflict.
		newid += "_[num2hex(world.time, -1)]" // Will typically be 4 digits long.
		if(networks_by_id[id] == src)
			networks_by_id -= id
	networks_by_id[newid] = src

	for(var/I in linked) // Check through all the linked networks and update the reference.
		var/datum/network/N = linked[I]
		if(N.linked[id] == src)
			N.linked -= id
		N.linked[newid] = src
		if(N.connected[id] == src)
			N.connected -= id
		N.connected[newid] = src




/datum/network/proc/can_remote(var/obj/item/device/hacktool/H)
	if(!holder)
		return
	var/boost = H.software & HACK_BOOST
	var/turf/T = get_turf(holder)
	var/turf/R = get_turf(H)
	var/area/A = T.loc
	switch(remote + boost)
		if(REMOTE_NETWORK_NONE)
			if(R in range(1, T)) return 1
			return
		if(REMOTE_NETWORK_AREA)
			if(R.loc == A && R.z == T.z && !A.outdoors) return 1
			return
		if(REMOTE_NETWORK_HALF)
			if(R.z == T.z) return 1
			return
	return 1





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
	if(badargs(N, H)) return

/datum/network_command/proc/feedback(var/obj/item/device/hacktool/H, var/feed)
	if(feed && H && istype(H))
		H.add_feedback(feed)

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
	/*
	switch(params)
		if("noob")
			if(H.software & (HACK_STEALTH | HACK_PROBE))
				return
			N.execute("security -noob", H)
		if("probe")
			if(H.software & HACK_STEALTH)
				return
			N.execute("security -probe", H)
		if("alert")
			if(H.software & HACK_STEALTH)
				return
			N.execute("security -alert", H)
		if("bruteprobe")
			if(H.software & HACK_PROBE & ~HACK_STEALTH) // If probe software is installed, but stealth isn't, call bruteprobe.
				N.execute("security -bruteprobe", H)
			else if(H.software & HACK_STEALTH & ~HACK_PROBE) // If probe software is not installed, but stealth software is, don't trigger security.
				return
			else
				N.execute("security -probe", H)
		if("brutealert")
			if(H.software & HACK_STEALTH)
				N.execute("security -alert", H)
			else
				N.execute("security -brutealert", H)
		if("connect")
			if(H.software & HACK_STEALTH)
				return
			N.execute("security -connect", H)
		else
			N.execute("security -[params]", H) // Probably a rogue parameter, try it anyways.
	*/
	return lockout(N, H)

/datum/network_command/proc/lockout(var/datum/network/N, var/obj/item/device/hacktool/H)
	if(N.locked && !H.bypass)
		feedback(H, "<span class='warning'>ACCESS DENIED</span>")
		return 1

/datum/network_command/proc/badarg(var/A, var/obj/item/device/hacktool/H)
	feedback(H, "span class='warning'>BAD ARGUMENT: [A]</span>")

/datum/network_command/proc/badnet(var/A, var/obj/item/device/hacktool/H)
	feedback(H, "span class='warning'>BAD NETWORK: [A]</span>")

/datum/network_command/proc/badkey(var/A, var/obj/item/device/hacktool/H)
	feedback(H, "span class='warning'>BAD KEY: [A]</span>")

/datum/network_command/proc/badargs(var/datum/network/N, var/obj/item/device/hacktool/H)
	if(!N || !H)
		return 1
	if(!istype(N) || !istype(H))
		return 1