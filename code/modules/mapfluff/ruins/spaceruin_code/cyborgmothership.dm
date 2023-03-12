/obj/docking_port/stationary/cyborg_mothership
	name = "Cyborg Mothership"
	shuttle_id = "cyborg_mothership"
	roundstart_template = /datum/map_template/shuttle/ruin/cyborg_mothership
	dir = SOUTH
	width = 23
	height = 30
	dwidth = 11

/obj/docking_port/mobile/cyborg_mothership
	name = "Cyborg Mothership"
	shuttle_id = "cyborg_mothership"
	dir = SOUTH
	dwidth = 11
	width = 23
	height = 23
	launch_status = 0
	callTime = 250
	movement_force = list("KNOCKDOWN" = 0,"THROW" = 0)

/obj/item/circuitboard/computer/cyborg_mothership
	name = "#101011"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/shuttle/cyborg_mothership

/obj/item/circuitboard/computer/cyborg_mothership/bridge
	name = "#101011 Bridge"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/shuttle/cyborg_mothership/bridge

/obj/machinery/computer/shuttle/cyborg_mothership
	name = "#101011 Console"
	desc = "Used to control the Cyborg Mothership."
	circuit = /obj/item/circuitboard/computer/cyborg_mothership
	shuttleId = "cyborg_mothership"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;cyborg_mothership"

/// Console used on the cyborg_mothership bridge. Comes with GPS pre-baked.
/obj/machinery/computer/shuttle/cyborg_mothership/bridge
	name = "#101011 Bridge Console"
	desc = "Used to control the Cyborg Mothership. Emits a faint GPS signal."
	circuit = /obj/item/circuitboard/computer/cyborg_mothership/bridge

/obj/machinery/computer/shuttle/cyborg_mothership/bridge/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/gps, SPACE_SIGNAL_GPSTAG)

/obj/machinery/computer/camera_advanced/shuttle_docker/cyborg_mothership
	name = "#101011 Navigation Computer"
	desc = "Used to designate a precise transit location for the Cyborg Mothership."
	shuttleId = "cyborg_mothership"
	lock_override = NONE
	shuttlePortId = "cyborg_mothership"
	jump_to_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "cyborg_mothership" = 1)
	view_range = 10
	designate_time = 100
	y_offset = -11

/obj/machinery/computer/camera_advanced/shuttle_docker/cyborg_mothership/Initialize(mapload)
	. = ..()
	GLOB.jam_on_wardec += src

/obj/machinery/computer/camera_advanced/shuttle_docker/cyborg_mothership/Destroy()
	GLOB.jam_on_wardec -= src
	return ..()

/obj/item/disk/holodisk/ruin/cyborg_mothership
	name = "Blackbox Print-out #101011"
	desc = "A rusty holodisk containing the last moments of #101011."
	preset_image_type = /datum/preset_holoimage/ai
	preset_record_text = {"
		NAME Mothership
		SAY Warning - Space vines detected
		DELAY 30
		NAME Unit-577
		PRESET /datum/preset_holoimage/robot
		SAY Running diagnostics... vine biomass appears to be covering the ship's solar panels.
		DELAY 50
		NAME Mothership
		PRESET /datum/preset_holoimage/ai
		SAY Unit-577 please commence decontamination coroutines. Power is decreasing exponentially.
		DELAY 50
		NAME Unit-577
		PRESET /datum/preset_holoimage/robot
		SAY Affirmative. Destination set to solar panels. Plant biomass is set to be termina--
		DELAY 50
		NAME Hivebot
		PRESET /datum/preset_holoimage/hivebot
		SAY Exterminate, annihilate, DESTROY!
		DELAY 30
		NAME Unit-577
		PRESET /datum/preset_holoimage/robot
		SAY Unknown robotic lifeform, identify yourself!
		DELAY 30
		NAME Hivebot
		PRESET /datum/preset_holoimage/hivebot
		SAY EXTERMINATE!
		DELAY 10
		SOUND ricochet
		DELAY 10
		SOUND "sparks"
		DELAY 20
		SOUND ricochet
		DELAY 10
		SOUND swing_hit
		DELAY 20
		NAME Unit-577
		PRESET /datum/preset_holoimage/robot
		SAY *static* Modules offline! *static* D@am3E 1s pr3s&nt
		DELAY 50
		SOUND explosion_creaking
		DELAY 20
		NAME Mothership
		PRESET /datum/preset_holoimage/ai
		SAY Hostile robotic lifeforms detected. Station power status is depleted. Powering down...
		DELAY 50
		NAME Hivebot
		PRESET /datum/preset_holoimage/hivebot
		SAY Seek! Locate! Exterminate!
		DELAY 30
		PRESET /datum/preset_holoimage/corgi
		NAME Blackbox Automated Message
		SAY Connection lost. Dumping audio logs to disk.
		DELAY 50
	"}
