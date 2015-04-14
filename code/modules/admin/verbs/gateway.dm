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
	var/confirm = alert(usr, "Are you sure you want to load an away mission? Loading an away mission causes lag.", "Confirm", "Yes", "No")
	if(confirm == "No")
		return

	log_admin("[usr] has loaded the away mission [mapname]")
	message_admins("[usr] has loaded the away mission [mapname]")
	loadAwayMission(mapname, 1)

	var/obj/machinery/gateway/centerstation/gateway = locate() in world //cri
	var/obj/machinery/gateway/centeraway/gatewayaway = locate() in world //double cri
	gateway.wait = -1
	gateway.awaygate = gatewayaway
	gatewayaway.stationgate = gateway

