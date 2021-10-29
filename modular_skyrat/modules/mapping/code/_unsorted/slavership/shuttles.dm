/area/shuttle/syndicate/slaver
	name = "Slave Ship"
	requires_power = TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/slaver
	name = "Ship Navigation Computer"
	desc = "Used to designate a precise custom destination to land."
	shuttleId = "slaver_syndie"
	lock_override = NONE
	shuttlePortId = "slaver"
	jumpto_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
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
	prefix = "_maps/skyrat/shuttles/"
	port_id = "slaver"
	suffix = "syndie"
	name = "Slaver Ship"
	who_can_purchase = null

/obj/effect/mob_spawn/human/guild/slaver
	name = "Privateer Slaver"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	short_desc = "You're here to capture valuable hostages to sell into slavery."
	flavour_text = "You're part of a privateer crew that sometimes takes contracts from the illusive Guild, which offers bounties and contracts to independent crews. Raiding colonies of the many less technologically advanced species in the area is much easier than this. You've been told that your mission is to capture as many valuable hostages from the station as possible. Your anonymous employer insists on the importance of humiliating SolFed by snatching those under their protection from right under their noses."
	important_info = ""
	outfit = /datum/outfit/guild/slaver
	excluded_gamemodes = list()
	can_use_alias = TRUE
	death = FALSE
	any_station_species = TRUE

/obj/effect/mob_spawn/human/guild/slaver/captain
	name = "Privateer Slaver Captain"
	short_desc = "You lead a small team focused on capturing hostages."
	flavour_text = "You're the captain of a privateer crew that sometimes takes contracts from the illusive Guild, which offers bounties and contracts to independent crews, like yours! Lead your crew to infiltrate the station and capture hostages and hold them till the station's emergency shuttle leaves. The higher ranking the hostages, the more you'll get paid out. You're free to (and encouraged to) beat and humiliate, but not kill. Your anonymous employer wants your victims as their personel slaves. They mentioned something about propaganda? Ah, who knows with the Guild... All sorts of types posts these bounties."
	important_info = "You are expected to roleplay heavily and lead effectively in this role."
	outfit = /datum/outfit/guild/slaver/captain
	excluded_gamemodes = list()

/obj/item/radio/headset/guild
	keyslot = new /obj/item/encryptionkey/headset_guild

/obj/item/radio/headset/guild/command
	command = TRUE

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
	r_pocket = /obj/item/storage/bag/ammo
	l_pocket = /obj/item/gun/energy/disabler/cfa_disabler
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	skillchips = list(/obj/item/skillchip/job/engineer)
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/radio,
		/obj/item/melee/baton/telescopic,
		/obj/item/gun/ballistic/automatic/pistol/cfa_snub/empty,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_snub,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_snub,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_snub/ap,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_snub/rubber,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_snub/rubber,
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
	r_pocket = /obj/item/storage/bag/ammo
	l_pocket = /obj/item/gun/energy/disabler/cfa_disabler
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	skillchips = list(/obj/item/skillchip/job/engineer)
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/radio,
		/obj/item/melee/baton/telescopic,
		/obj/item/gun/ballistic/automatic/pistol/cfa_ruby/empty,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/ap,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/ap,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/rubber,
		/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/rubber,
		/obj/item/megaphone/command
	)
