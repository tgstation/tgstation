/obj/item/device/ship_caller
	name = "Engineering Ship Beacon"
	icon_state = "gangtool-yellow"
	item_state = "walkietalkie"
	var/obj/docking_port/mobile/calling
	var/shuttleId = "engi_ship"
	var/obj/machinery/computer/engi_nav/navcomp

/obj/item/device/ship_caller/attack_self(mob/living/user)
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