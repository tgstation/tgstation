/area/shuttle/sapper
	name = "Sapper Shuttle"

/area/sapper_hideout
	name = "Hide-out"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT
	flags_1 = NONE

/obj/docking_port/mobile/pirate/sapper
	name = "Sapper Shuttle"
	callTime = 1 MINUTES
	ignitionTime = 30 SECONDS
	rechargeTime = 3 MINUTES
	shuttle_id = "sapper"
	movement_force = list("KNOCKDOWN"=3,"THROW"=0)
	preferred_direction = NORTH
	port_direction = WEST

/obj/machinery/computer/shuttle/pirate/sapper
	name = "shuttle console"
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_SAPPER_SHIP)
	shuttleId = "sapper"
	possible_destinations = "sapper;"

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/pirate/sapper
	name = "shuttle navigation computer"
	icon_screen = "tram"
	icon_keyboard = "atmos_key"
	desc = "Used to designate a precise transit location for the shuttle."
	shuttleId = "sapper"
	shuttlePortId = "sapper"

/mob/living/basic/bot/medbot/sapper
	name = "Manon"
	medkit_type = /obj/item/storage/medkit/fire
	skin = "burn"
	health = 40
	maxHealth = 40
	req_one_access = list(ACCESS_SAPPER_SHIP)
	bot_mode_flags = parent_type::bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED
	radio_key = /obj/item/encryptionkey/syndicate
	radio_channel = RADIO_CHANNEL_SYNDICATE
	damage_type_healer = HEAL_ALL_DAMAGE
	faction = list(FACTION_NEUTRAL, ROLE_SPACE_SAPPER)
	heal_threshold = 0
	heal_amount = 5

/mob/living/basic/bot/medbot/sapper/Initialize(mapload, new_skin)
	. = ..()
	internal_radio.set_frequency(FREQ_SYNDICATE)
	internal_radio.freqlock = RADIO_FREQENCY_LOCKED
