#define VOX_SHUTTLE_COOLDOWN 460
#define VOX_SHUTTLE_TRANSIT_DELAY 260

var/global/datum/shuttle/vox/vox_shuttle = new(starting_area=/area/shuttle/vox/station)

/datum/shuttle/vox
	name = "vox skipjack"

	cant_leave_zlevel = list()

	cooldown = VOX_SHUTTLE_COOLDOWN

	transit_delay = VOX_SHUTTLE_TRANSIT_DELAY - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30

	stable = 1 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

	var/returned_home = 0
	var/obj/structure/docking_port/destination/dock_home

/datum/shuttle/vox/is_special()
	return 1

/datum/shuttle/vox/initialize()
	.=..()
	dock_home = add_dock(/obj/structure/docking_port/destination/vox/station)
	add_dock(/obj/structure/docking_port/destination/vox/northeast_solars)
	add_dock(/obj/structure/docking_port/destination/vox/southeast_solars)
	add_dock(/obj/structure/docking_port/destination/vox/southwest_solars)
	add_dock(/obj/structure/docking_port/destination/vox/mining)

	set_transit_dock(/obj/structure/docking_port/destination/vox/transit)

/datum/shuttle/vox/travel_to(var/obj/structure/docking_port/D, var/obj/machinery/computer/shuttle_control/broadcast = null, var/mob/user)
	if(D == dock_home)
		if(ticker && istype(ticker.mode, /datum/game_mode/heist))
			switch(alert(usr,"Returning to the deep space will end your raid and report your success or failure. Are you sure?","Vox Skipjack","Yes","No"))
				if("Yes")
					var/location = get_turf(user)
					message_admins("[key_name_admin(user)] attempts to end the raid - [formatJumpTo(location)]")
					log_admin("[key_name(user)] attempts to end the raid - [formatLocation(location)]")
				if("No")
					return
	.=..()

/datum/shuttle/vox/after_flight()
	.=..()
	if(current_port == dock_home)
		returned_home = 1	//If the round type is heist, this will cause the round to end
							//See code/game/gamemodes/heist/heist.dm, 294

/obj/machinery/computer/shuttle_control/vox
	icon_state = "syndishuttle"

	req_access = list(access_syndicate)

	light_color = LIGHT_COLOR_RED
	machine_flags = EMAGGABLE //No screwtoggle because this computer can't be built

/obj/machinery/computer/shuttle_control/vox/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(vox_shuttle)
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/structure/docking_port/destination/vox/station
	areaname = "deep space"

/obj/structure/docking_port/destination/vox/northeast_solars
	areaname = "north east solars"

/obj/structure/docking_port/destination/vox/northwest_solars
	areaname = "north west solars"

/obj/structure/docking_port/destination/vox/southeast_solars
	areaname = "south east solars"

/obj/structure/docking_port/destination/vox/southwest_solars
	areaname = "south west solars"

/obj/structure/docking_port/destination/vox/mining
	areaname = "vox trading outpost"

/obj/structure/docking_port/destination/vox/transit
	areaname = "hyperspace (vox skipjack)"
