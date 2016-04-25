////////////
// CAMERA //
////////////

/datum/network/camera
	id = "camera"
	info = "Security Camera BIOS. A simple internal network used by cameras to connect and transmit data to a camera network."
	linked = list()
	connected = list()
	var/list/camera_networks = list()		// A list of camera network id's this camera is connected to.
	var/datum/network/apc/apc = null		// The apc connected to this network, if any.

	// A list of commands this network has access to. Works kinda like virus symptoms.
	var/list/datum/network_command/commands = list(/datum/network_command/info, \
												/datum/network_command/connect, \
												/datum/network_command/disconnect, \
												/datum/network_command/get/camera, \
												/datum/network_command/cnet, \
												/datum/network_command/link, \
												/datum/network_command/unlink, \
												/datum/network_command/probe)

/datum/network/camera/New()
	..()
	addtimer(src, "update_network", 5) // Updates the connected camera networks to include this camera.

/datum/network/camera/Destroy()
	camera_networks = list()
	update_network()
	apc.remove(src)
	..()

/datum/network/camera/update_network()
	// Connects to registered camera networks.
	for(var/I in camera_networks)
		var/datum/network/cameranet/N = networks_by_id[I]
		if(istype(N))
			N.add_camera(src)
			new_net += I
	// Removes links between unregistered camera networks.
	for(var/I in linked)
		if(istype(linked[I], /datum/network/cameranet))
			if(I in camera_networks)
				continue
			else
				var/datum/network/cameranet/N = linked[I]
				N.del_camera(src)

/////////////////////
// CAMERA COMMANDS //
/////////////////////

/datum/network_command/get/camera
	trigger = "get"
	info = "Usage: \"get -{query}\" Used to get information about this network. Uses standard network queries, as well as: cnet:cameranet and apc:powernet."

/datum/network_command/get/camera/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	switch(A[1])
		if("cnet"||"cameranet")
			if (security(N, "get", H)) return
			var/feed = "Camera Network(s):"
			for(var/I in camera_networks)
				if(istype(networks_by_id[I], /datum/network/cameranet))
					feed += " [I],"
			feedback(H, feed)
			return
	..()

/datum/network_command/cnet
	trigger = "cnet"
	info = "Usage: \"cnet -{option} -{value}\" Used to set options related to the camera network. Options can be: add, del, ref:refresh."

/datum/network_command/cnet/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	switch(A[1])
		if("add")
			if(A[2])
				if (security(N, "set", H)) return
				N.camera_networks += A[2]
				feedback(H, "[A[2]] network added.")
				return
		if("del")
			if(A[2])
				if (security(N, "set", H)) return
				N.camera_networks -= A[2]
				feedback(H, "[A[2]] network deleted.")
				return
		if("ref"||"refresh")
			if (security(N, "set", H)) return
			N.update_network()
			feedback(H, "Camera networks refreshed.")
			return

/datum/network_command/camera
	trigger = "camera"
	info = "Usage: \"camera -{option} -{value}\" Accessing the BIOS, granting access to camera specific commands."

/*
	Take A Picture
	Disable Camera
	Disable Camera for 30 Seconds
	Reset Camera Power
	Adjust Camera Focus
	Toggle Camera Upgrade
	Add Camera Network
	Del Camera Network
	Refresh Camera Networks
	Trigger Camera Ping/Alert

	CAMERA UPGRADES:
		plasteel // Whack it with a chunk of plasteel to use 1 plasteel sheet, making it immune to emp's and more durable
		motion // Whack it with prox or infra sensors to enable a motion alarm. Infra sensor is more effective than prox sensor.
		lights // Whack it with a flashlight to enable a light which can be toggled on and off.
		mesons // Whack it with meson scanners to enable meson view.
		sunglasses // Whack it with sunglasses or welding goggles to reduce flash effect duration, or provide immunity to flash effects entirely.
		medhud // Whack it with medhud to enable medical HUD
		sechud // Whack it with sechud to enable security HUD
		diahud // Whack it with diagnostichud to enable diagnostic HUD
		infravis // Whack it with night vision goggles to enable night vision.
		thermal // Whack it with thermals to enable thermal vision.
		xrayhud // Whack it with xray scanners to enable xray vision, makes thermals/mesons obsolete.
		voice // Whack it with a voice recorder/bounced radio/voice sensor to allow hearing sound and chatter through the camera.
*/

/datum/network_command/camera/execute(datum/network/N, list/A, obj/item/device/hacktool/H)
	if(badargs(N, H)) return
	if(lockout(N, H)) return
	switch(A[1])

////////////////////
// CAMERA NETWORK //
////////////////////

//////////////////////
// NETWORK COMMANDS //
//////////////////////

/datum/network/cameranet
	id = "id_camera_network"
	info = "Secure Camera Network. A network with basic security features that can be connected to with specialized consoles in order to roam and observe using linked security cameras."
