/obj/item/device/ship_caller
	name = "Engineering Ship Beacon"
	icon_state = "gangtool-yellow"
	item_state = "walkietalkie"
	var/obj/docking_port/mobile/calling
	var/shuttleId = "engi_ship"
	var/obj/machinery/computer/engi_nav/navcomp
	var/ship_name = null

/obj/item/device/ship_caller/attack_self(mob/living/user)
	if(!ship_name)
		ship_name = stripped_input(user, message="What do you want to name your new ship? Keep in mind particularly terrible names may result in disciplinary measures.", max_length=MAX_CHARTER_LEN)
		if(!ship_name)
			return
		priority_announce("In recognition of your engineering team's unsurpassed accomplishments, they have been selected to receive and command our newest construction ship, the NSS [ship_name]", "Nanotrasen Dockyards")
	say("Beacon signal will transmit in 5 seconds")
	sleep(50)
	calling = SSshuttle.getShuttle(shuttleId)
	for(var/obj/machinery/computer/engi_nav/EN in machines)
		navcomp = EN
		navcomp.SetLanding(user)
	say("The current dock status is ")
	if(calling.canDock(navcomp.landing_zone) == SHUTTLE_CAN_DOCK)
		say("Valid docking location detected, clear the area immediately")
		SSshuttle.moveShuttle(shuttleId, navcomp.landing_zone.id, 1)
	else
		say("Beacon error detected: Dock location is not valid")