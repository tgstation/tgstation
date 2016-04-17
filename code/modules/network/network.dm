/*
	For one-off or niche commands which will only ever apply to one specific machine, feel free to hard code it. Otherwise, for commands which might see use
	in another machine, please make a new net_command instead.

	Upgraded devices, such as borgs, the AI, or "Hacktools" have several notable features:
	they are able to see stealthed networks.
	they are able to pass "-b" as an argument in place of an encryption key to make an attempt at brute-forcing the network. This will take some time, and may trigger the networks security system, but will eventually get you in.

*/

proc/butcher_net_command(command = "")
	var/list/butchered = explode_text(command, " -") // allows for arguments like {text1 = "hello "} {text2 = "world"} to be caused when executing something like {print -text1 = "hello " -text2 = "world"}
	command = butchered[1]
	var/list/arguments = list()
	for(var/i=2, i<=butchered.len, i++)
		arguments[i-1] = butchered[i]
	return list(command, arguments)

/datum/network
	var/atom/holder = null							// The holder (atom that contains this network datum).
	var/id = null									// A unique id
	var/password = null								// A password to prevent unauthorized access to the network.
	var/stealth = 0									// Whether the network should be hidden from standard probing and prying.
	var/wireless = 0								// Whether the network can be accessed remotely.
	var/datum/network/root 							// The root network, if this is a subnetwork.
	var/list/datum/network/sub = list() 			// A list of networks that are a subnetwork of this one.
	var/list/datum/net_command/commands = list()	// A list of commands this network has access to. Works kinda like virus symptoms.

/datum/network/New(atom/holder)
	..()
	src.holder = holder

/datum/network/Destroy()
	holder = null
	for(var/datum/network/S in sub)
		S.del_root()
	sub = list()
	if(root)
		root.del_sub(src)
	root = list()
	for(var/datum/net_command/NC in commands)
		qdel(NC)
	commands = list()
	return ..()

/datum/network/proc/del_root() // Called when the root is destroyed.
	root = null

/datum/network/proc/del_sub(datum/network/S) // Called when the subdirectory is destroyed.
	if(S in sub)
		sub -= S

/datum/network/proc/execute(var/command, var/list/params = list("args" = list(), "upgraded" = 0)) // Used to pass commands to the network.
	if(!command)
		return
	var/list/butch = butcher_net_command(command)
	command = butch[1]
	params["args"] = butch[2]

	var/list/data = list()
	for(var/datum/net_command/NC in commands) // allows for adding 'universal' commands, which can be attached to any network object.
		if(NC.trigger == command)
			data = NC.execute(src, params) // Commands can be hard-coded to the network object, or made into a 'universal' command, which can be called by any network object.
			return data


/*
	Intended to increase code-modularity and reuseability.
	Execute should always return either null, or a list.
*/

/datum/net_command
	var/trigger = "" 	// The trigger word for this command to be executed.
	var/stealth = 0		// Whether this command can be identified using info.
	var/feedback = ""	// The message sent back to the device calling this command.
	var/info = ""		// A feedback message that explains the usage of this command. For the noobs.

/datum/net_command/proc/execute(datum/network/N, list/params)
	if(!N)
		return