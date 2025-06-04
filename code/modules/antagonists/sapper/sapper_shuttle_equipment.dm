/area/shuttle/sapper
	name = "Sapper Shuttle"
	requires_power = TRUE
	flags_1 = NONE

/obj/docking_port/mobile/sapper
	name = "Sapper Shuttle"
	callTime = 30 SECONDS
	ignitionTime = 15 SECONDS
	rechargeTime = 2 MINUTES
	shuttle_id = "sapper"
	movement_force = list("KNOCKDOWN"=3,"THROW"=0)
	preferred_direction = NORTH
	port_direction = EAST

/obj/machinery/computer/shuttle/sapper
	name = "shuttle console"
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_SAPPER_SHIP)
	shuttleId = "sapper"
	possible_destinations = "sapper_hideout;sapper_custom;whiteship_home"

/obj/machinery/computer/camera_advanced/shuttle_docker/sapper
	name = "shuttle navigation computer"
	icon_screen = "tram"
	icon_keyboard = "atmos_key"
	desc = "Used to designate a precise transit location for the shuttle."
	shuttleId = "sapper"
	shuttlePortId = "sapper_custom"
	jump_to_ports = list("sapper_hideout" = 1, "whiteship_home" = 1)
	see_hidden = FALSE
	lock_override = CAMERA_LOCK_STATION
	view_range = 5.5
	x_offset = -5

/mob/living/basic/bot/medbot/sapper
	name = "Manón"
	desc = "A little Medibot, colored orange to portray her specialization in treating burn-wounds."
	gender = FEMALE //feminine named medibot
	medkit_type = /obj/item/storage/medkit/fire
	skin = "burn"
	health = 40
	maxHealth = 40
	req_one_access = list(ACCESS_SAPPER_SHIP)
	bot_mode_flags = parent_type::bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED
	radio_key = /obj/item/encryptionkey/syndicate
	radio_channel = RADIO_CHANNEL_SYNDICATE
	faction = list(ROLE_SPACE_SAPPER, FACTION_NEUTRAL)
	heal_threshold = 0
	heal_amount = 5

/mob/living/basic/bot/medbot/sapper/Initialize(mapload, new_skin)
	. = ..()
	internal_radio.set_frequency(FREQ_SYNDICATE)
	internal_radio.freqlock = RADIO_FREQENCY_LOCKED
