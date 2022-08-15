/datum/outfit/syndicate
	name = "Syndicate Operative - Basic"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/modular_computer/tablet/nukeops
	r_pocket = /obj/item/pen/edagger
	id = /obj/item/card/id/advanced/chameleon
	belt = /obj/item/gun/ballistic/automatic/pistol/clandestine

	skillchips = list(/obj/item/skillchip/disk_verifier)
	box = /obj/item/storage/box/survival/syndie
	var/tc = 25
	var/command_radio = FALSE
	var/uplink_type = /obj/item/uplink/nuclear

	id_trim = /datum/id_trim/chameleon/operative

/datum/outfit/syndicate/leader
	name = "Syndicate Leader - Basic"
	command_radio = TRUE

	id_trim = /datum/id_trim/chameleon/operative/nuke_leader

/datum/outfit/syndicate/no_crystals
	name = "Syndicate Operative - Reinforcement"
	tc = 0

/datum/outfit/syndicate/post_equip(mob/living/carbon/human/H)
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE
	if(command_radio)
		R.command = TRUE

	if(ispath(uplink_type, /obj/item/uplink/nuclear) || tc) // /obj/item/uplink/nuclear understands 0 tc
		var/obj/item/U = new uplink_type(H, H.key, tc)
		H.equip_to_slot_or_del(U, ITEM_SLOT_BACKPACK)

	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	H.faction |= ROLE_SYNDICATE
	H.update_icons()

/datum/outfit/syndicate/full
	name = "Syndicate Operative - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/mod/control/pre_equipped/nuclear
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/storage/belt/military
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog
	backpack_contents = list(
		/obj/item/gun/ballistic/automatic/pistol/clandestine,
		/obj/item/pen/edagger,
	)
