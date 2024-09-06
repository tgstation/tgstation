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

/obj/machinery/porta_turret/syndicate/energy/sapper
	stun_projectile = /obj/projectile/beam/weak
	stun_projectile_sound = 'sound/weapons/laser.ogg'
	faction = list(FACTION_SAPPER)
	req_access = list(ACCESS_SAPPER_SHIP)
	on = FALSE

/obj/item/storage/toolbox/emergency/turret/mag_fed/spider/sapper
	name = "offensive turret capsule"
	desc = "A deployable turret used for aggressive expansion and zone defense. It is chambered to fire <i>4.6x30mm</i> auto-rifle ammunition."
	icon_state = "sapper_toolbox"
	inhand_icon_state = null
	setting_change = FALSE
	turret_safety = FALSE
	flags_on = TRUE
	faction = list(FACTION_SAPPER)
	turret_type = /obj/machinery/porta_turret/syndicate/toolbox/mag_fed/spider/sapper
	mag_types_allowed = list(/obj/item/ammo_box/magazine/wt550m9)

/obj/item/storage/toolbox/emergency/turret/mag_fed/spider/sapper/pre_filled/PopulateContents()
	new /obj/item/ammo_box/magazine/wt550m9(src)

/obj/machinery/porta_turret/syndicate/toolbox/mag_fed/spider/sapper
	name = "\improper Sapper Spider Turret"
	desc = "A deployable turret used for aggressive expansion and zone defense. It is chambered to fire .35 Sol ammunition."
	base_icon_state = "sapper"
	max_integrity = 115
	shot_delay = 2 SECONDS
	faction = list(FACTION_SAPPER)
	mag_box_type = /obj/item/storage/toolbox/emergency/turret/mag_fed/spider/pre_filled

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
