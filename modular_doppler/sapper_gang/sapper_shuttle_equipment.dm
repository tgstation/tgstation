/datum/map_template/shuttle/pirate/sapper
	prefix = "_maps/shuttles/~doppler_shuttles/"
	suffix = "sapper"
	name = "Sapper ship (Default)"

/area/shuttle/pirate/sapper
	name = "Sapper Shuttle"

/obj/docking_port/mobile/pirate/sapper
	name = "Sapper Shuttle"
	callTime = 1 MINUTES
	ignitionTime = 1 MINUTES
	rechargeTime = 5 MINUTES
	shuttle_id = "pirate_sapper"
	movement_force = list("KNOCKDOWN"=3,"THROW"=0)
	preferred_direction = NORTH
	port_direction = WEST

/obj/machinery/computer/shuttle/pirate/sapper
	name = "shuttle console"
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_SAPPER_SHIP)
	shuttleId = "pirate_sapper"
	possible_destinations = "sapper_custom;"

/obj/machinery/computer/shuttle/pirate/sapper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "[get_area_name(get_turf(src))]")

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/pirate/sapper
	name = "shuttle navigation computer"
	icon_screen = "tram"
	icon_keyboard = "atmos_key"
	desc = "Used to designate a precise transit location for the shuttle."
	shuttleId = "pirate_sapper"
	shuttlePortId = "sapper_custom"

/mob/living/basic/bot/medbot/sapper
	name = "Manon"
	medkit_type = /obj/item/storage/medkit/fire
	skin = "ointment"
	health = 40
	maxHealth = 40
	req_one_access = list(ACCESS_SAPPER_SHIP)
	bot_mode_flags = parent_type::bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED
	radio_key = /obj/item/encryptionkey/syndicate
	radio_channel = RADIO_CHANNEL_SYNDICATE
	damage_type_healer = HEAL_ALL_DAMAGE
	faction = list(FACTION_SAPPER)
	heal_threshold = 0
	heal_amount = 5

/mob/living/basic/bot/medbot/sapper/Initialize(mapload, new_skin)
	. = ..()
	internal_radio.set_frequency(FREQ_SYNDICATE)
	internal_radio.freqlock = RADIO_FREQENCY_LOCKED
