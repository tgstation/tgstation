///////////////////////////CSV Bearcat////////////////////////////

/datum/map_template/ruin/space/bearcat
	id = "bearcat"
	prefix = "code/white/hule/bearcat/"
	suffix = "bearcat2.dmm"
	name = "CSV Bearcat"
	cost = -1

///////////////////////////Areas//////////////////////////////////


/area/shuttle/bearcat
	name = "CSV Bearcat"
	blob_allowed = FALSE
	requires_power = TRUE

/area/shuttle/bearcat/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/shuttle/bearcat/captain
	name = "Captain's Quarters"
	icon_state = "captain"

/area/shuttle/bearcat/dockingbay
	name = "Docking Bay"

/area/shuttle/bearcat/hallway
	name = "Hallway"
	icon_state = "hallC"

/area/shuttle/bearcat/saloon
	name = "Saloon"
	icon_state = "bar"

/area/shuttle/bearcat/bathroom
	name = "Bathroom"
	icon_state = "toilet"

/area/shuttle/bearcat/dorms
	name = "Dorms"
	icon_state = "Sleep"

/area/shuttle/bearcat/engines
	name = "Engine"

/area/shuttle/bearcat/cargo
	name = "Cargo Hold"
	icon_state = "cargo_bay"

/area/shuttle/bearcat/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/shuttle/bearcat/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/shuttle/bearcat/washroom
	name = "Washroom"
	icon_state = "locker"

/area/shuttle/bearcat/toolstorage
	name = "Tool Storage"
	icon_state = "engi_storage"

/area/shuttle/bearcat/engineering
	name = "Engineering"
	icon_state = "engine"

/area/shuttle/bearcat/maint1
	name = "Maintenance"
	icon_state = "maintcentral"

/area/shuttle/bearcat/maint2
	name = "Maintenance"
	icon_state = "maintcentral"

///////////////////////////Nav Console///////////////////////////

/obj/machinery/computer/camera_advanced/shuttle_docker/coordinate/bearcat
	name = "CSV Bearcat navigation computer"
	desc = "Used to designate a precise transit location for the ship."
	shuttleId = "bearcat"
	shuttlePortId = "bearcat_custom"
	shuttlePortName = "custom location"
	view_range = 20
	x_offset = 8
	y_offset = -7
	z_lock = list(3,4,7,8,9,10,12,13)
	networks = list("bearcat")

/obj/machinery/computer/shuttle/bearcat
	name = "CSV Bearcat console"
	shuttleId = "bearcat"
	possible_destinations = "bearcat_away;bearcat_home;bearcat_custom"

/obj/docking_port/mobile/bearcat
	name = "CSV Bearcat"
	id = "bearcat"
	width = 29
	dwidth = 6
	height = 44
	dheight = 30
	port_direction = SOUTH
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	engine_coeff = 30 //5 mins to move from one point to another

///////////////////////////Spawners//////////////////////////////
/obj/effect/mob_spawn/human/bearcatcrew
	name = "CSV Bearcat cryogenics pod"
	desc = "An old cryogenics pod. Looks like it has not been touched for decades."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<font size=3>You are a member of CSV Bearcat crew."

/obj/effect/mob_spawn/human/bearcatcrew/eng
	mob_name = "an engineer"
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id
	gloves = /obj/item/clothing/gloves/color/yellow
	assignedrole = "CSV Bearcat Crew"
	id_access_list = list(205,204)

/obj/effect/mob_spawn/human/bearcat/eng/Destroy()
	return ..()

/obj/effect/mob_spawn/human/bearcatcrew/atmos
	mob_name = "an atmostech"
	uniform = /obj/item/clothing/under/rank/atmospheric_technician
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id
	gloves = /obj/item/clothing/gloves/color/black
	id_access_list = list(205,204)

/obj/effect/mob_spawn/human/bearcat/atmos/Destroy()
	return ..()

/obj/effect/mob_spawn/human/bearcatcrew/pilot
	mob_name = "a pilot"
	uniform = /obj/item/clothing/under/syndicate/camo
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id
	id_access_list = list(205,204,203)

/obj/effect/mob_spawn/human/bearcat/pilot/Destroy()
	return ..()
