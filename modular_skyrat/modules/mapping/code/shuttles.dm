/datum/map_template/shuttle/arrival/outpost
	suffix = "outpost"
	name = "arrival shuttle (Outpost)"

/datum/map_template/shuttle/emergency/outpost
	suffix = "outpost"
	prefix = "_maps/shuttles/skyrat/"
	name = "Outpoststation Emergency Shuttle"
	description = "The perfect shuttle for rectangle enthuasiasts, this long and slender shuttle has been known for it's incredible(Citation Needed) safety rating."
	admin_notes = "Has airlocks on both sides of the shuttle and will probably ram deltastation's maint wing below medical. Oh well?"
	credit_cost = CARGO_CRATE_VALUE * 4
	occupancy_limit = 45

/*----- Black Market Shuttle Datum + related code -----*/
/datum/map_template/shuttle/ruin/blackmarket_chevvy
	prefix = "_maps/shuttles/skyrat/"
	suffix = "blackmarket_chevvy"
	name = "Black Market Chevvy"

/obj/machinery/computer/shuttle/caravan/blackmarket_chevvy
	name = "Chevvy Shuttle Console"
	desc = "Used to control the affectionately named 'Chevvy'."
	circuit = /obj/item/circuitboard/computer/blackmarket_chevvy
	shuttleId = "blackmarket_chevvy"
	possible_destinations = "blackmarket_chevvy_custom;blackmarket_chevvy_home;whiteship_home"

/obj/machinery/computer/camera_advanced/shuttle_docker/blackmarket_chevvy
	name = "Chevvy Navigation Computer"
	desc = "Used to designate a precise transit location for the affectionately named 'Chevvy'."
	shuttleId = "blackmarket_chevvy"
	lock_override = NONE
	shuttlePortId = "blackmarket_chevvy_custom"
	jump_to_ports = list("blackmarket_chevvy_home" = 1, "whiteship_home" = 1)
	view_range = 0
	x_offset = 2
	y_offset = 0

/obj/item/circuitboard/computer/blackmarket_chevvy
	name = "Chevvy Control Console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/caravan/blackmarket_chevvy
/*----- End of Black Market Shuttle Code -----*/

/datum/map_template/shuttle/prison_transport
	prefix = "_maps/shuttles/skyrat/"
	port_id = "prison_transport"
	suffix = "skyrat"
	name = "Prison Transporter NSS-74"


/obj/machinery/computer/camera_advanced/shuttle_docker/slaver
	name = "Ship Navigation Computer"
	desc = "Used to designate a precise custom destination to land."
	shuttleId = "slaver_syndie"
	lock_override = NONE
	shuttlePortId = "slaver"
	jump_to_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
	view_range = 10
	x_offset = 0
	y_offset = 0
	designate_time = 30

/obj/machinery/computer/shuttle/slaver
	name = "Ship Travel Terminal"
	desc = "Controls for moving the ship to a pre-programmed destination or a custom one marked out by the navigation computer."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = COLOR_SOFT_RED
	req_access = list(ACCESS_SYNDICATE)
	shuttleId = "slaver_syndie"
	possible_destinations = "syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = NODECONSTRUCT_1

/datum/map_template/shuttle/slaver_ship
	port_id = "slaver ship"
	prefix = "_maps/shuttles/skyrat/"
	port_id = "slaver"
	suffix = "syndie"
	name = "Slaver Ship"
	who_can_purchase = null

/obj/effect/mob_spawn/ghost_role/human/guild
	name = "Privateer Slaver"
	prompt_name = "a privateer slaver"
	you_are_text = "You're here to capture valuable hostages to sell into slavery."
	flavour_text = "You're part of a privateer crew that sometimes takes contracts from the illusive Guild, which offers bounties and contracts to independent crews. Raiding colonies of the many less technologically advanced species in the area is much easier than this. You've been told that your mission is to capture as many valuable hostages from the station as possible. Your anonymous employer insists on the importance of humiliating SolFed by snatching those under their protection from right under their noses."
	important_text = ""

/obj/effect/mob_spawn/ghost_role/human/guild/slaver
	name = "Privateer Slaver"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/guild/slaver

/obj/effect/mob_spawn/ghost_role/human/guild/slaver/captain
	name = "Privateer Slaver Captain"
	you_are_text = "You lead a small team focused on capturing hostages."
	flavour_text = "You're the captain of a privateer crew that sometimes takes contracts from the illusive Guild, which offers bounties and contracts to independent crews, like yours! Lead your crew to infiltrate the station and capture hostages and hold them till the station's emergency shuttle leaves. The higher ranking the hostages, the more you'll get paid out. You're free to (and encouraged to) beat and humiliate, but not kill. Your anonymous employer wants your victims as their personel slaves. They mentioned something about propaganda? Ah, who knows with the Guild... All sorts of types posts these bounties."
	important_text = "You are expected to roleplay heavily and lead effectively in this role."
	outfit = /datum/outfit/guild/slaver/captain

/obj/item/radio/headset/guild
	keyslot = new /obj/item/encryptionkey/headset_syndicate/guild

/obj/item/radio/headset/guild/command
	command = TRUE

/datum/outfit/guild
	name = "Guild Default Outfit"

/datum/outfit/guild/slaver
	name = "Privateer Slaver"
	head = /obj/item/clothing/head/helmet/alt
	suit = /obj/item/clothing/suit/armor/bulletproof
	uniform = /obj/item/clothing/under/syndicate/combat
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/guild
	glasses = /obj/item/clothing/glasses/hud/security/chameleon
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/weapons_auth)
	belt = /obj/item/storage/belt/military
	r_pocket = /obj/item/storage/pouch/ammo
	l_pocket = /obj/item/gun/energy/e_gun/mini
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	skillchips = list(/obj/item/skillchip/job/engineer)
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/radio,
		/obj/item/melee/baton/telescopic,
		/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/wespe,
		/obj/item/grenade/c4,
		/obj/item/grenade/smokebomb
	)

/datum/outfit/guild/slaver/captain
	name = "Privateer Slaver Captain"
	head = /obj/item/clothing/head/helmet/alt
	suit = /obj/item/clothing/suit/armor/bulletproof
	uniform = /obj/item/clothing/under/syndicate/combat
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/guild/command
	glasses = /obj/item/clothing/glasses/thermal/syndi
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/weapons_auth)
	belt = /obj/item/storage/belt/military
	r_pocket = /obj/item/storage/pouch/ammo
	l_pocket = /obj/item/gun/energy/e_gun/mini
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	skillchips = list(/obj/item/skillchip/job/engineer)
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/radio,
		/obj/item/melee/baton/telescopic,
		/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/skild,
		/obj/item/megaphone/command
	)

/*----- Tarkon Shuttle Datum + related code -----*/
/datum/map_template/shuttle/ruin/tarkon_driver
	prefix = "_maps/shuttles/skyrat/"
	suffix = "tarkon_driverdc54"
	name = "Tarkon Drill Driver"

/obj/machinery/computer/shuttle/tarkon_driver
	name = "Tarkon Driver Control"
	desc = "Used to control the Tarkon Driver."
	circuit = /obj/item/circuitboard/computer/tarkon_driver
	shuttleId = "tarkon_driver"
	possible_destinations = "tarkon_driver_custom;port_tarkon;whiteship_home"

/obj/machinery/computer/camera_advanced/shuttle_docker/tarkon_driver
	name = "Tarkon Driver Navigation Computer"
	desc = "The Navigation console for the Tarkon Driver. A broken \"Engage Drill\" button seems to dimly blink in a yellow colour"
	shuttleId = "tarkon_driver"
	lock_override = NONE
	shuttlePortId = "tarkon_driver_custom"
	jump_to_ports = list("port_tarkon" = 1, "whiteship_home" = 1)
	view_range = 0

/obj/item/circuitboard/computer/tarkon_driver
	name = "Tarkon Driver Control Console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/tarkon_driver

/datum/map_template/shuttle/ruin/tarkon_driver/defcon3
	suffix = "tarkon_driverdc3"

/datum/map_template/shuttle/ruin/tarkon_driver/defcon2
	suffix = "tarkon_driverdc2"
/*----- End of Tarkon Shuttle Code -----*/
