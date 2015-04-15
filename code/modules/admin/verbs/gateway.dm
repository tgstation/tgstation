/client/proc/admin_activate_gateway()
	set name = "Activate Gateway"
	set category = "Special Verbs"

	if(!holder)
		usr << "<span class='warning'>Only administrators may use this command.</span>"
		return

	if(away_loaded)
		alert(usr, "An away mission is already loaded. You cannot load another away mission.", "Already Loaded")
		return
	
	if(!potentialRandomZlevels.len)
		usr << "<span class='warning'>There are no enabled away missions.</span>"

	var/mapname = input("Select the away mission you want to load", "Away Mission") in potentialRandomZlevels //This list is built at roundstart by createRandomZlevel()
	var/confirm = alert(usr, "Are you sure you want to load an away mission? Loading an away mission will freeze the server for a short period of time.", "Confirm", "Yes", "No")
	if(confirm == "No")
		return

	log_admin("[usr] has loaded the away mission [mapname]")
	message_admins("[usr] has loaded the away mission [mapname]")
	var/z_level = world.maxz + 1
	loadAwayMission(mapname, 1)

	for(var/atom/movable/AM in world)
		if(AM.z == z_level)
			AM.initialize()

	SSlighting.Initialize(world.timeofday, z_level)
	SSpower.Initialize(world.timeofday, z_level)
	SSair.Initialize(world.timeofday, z_level)
	SSpipe.Initialize(world.timeofday, z_level)

	var/obj/machinery/gateway/centerstation/gateway = locate() in world //oh no locate in world is bad! except we just initialized four subsystems and looped through every atom/movable in the world to initialize them too.
	var/obj/machinery/gateway/centeraway/gatewayaway = locate() in world
	gateway.wait = -1
	gateway.awaygate = gatewayaway
	gatewayaway.stationgate = gateway
