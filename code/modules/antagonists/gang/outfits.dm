/datum/outfit/families_police/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.access = get_all_accesses() // I have a warrant.
	W.assignment = "Space Police"
	W.registered_name = H.real_name
	W.update_label()
	..()

/datum/outfit/families_police/beatcop
	name = "Families: Beat Cop"

	uniform = /obj/item/clothing/under/rank/security/officer/beatcop
	suit = null
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = null
	glasses = /obj/item/clothing/glasses/hud/spacecop
	ears = /obj/item/radio/headset/headset_sec
	mask = null
	head = /obj/item/clothing/head/spacepolice
	belt = /obj/item/gun/energy/e_gun/mini
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/restraints/handcuffs
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id


/datum/outfit/families_police/beatcop/armored
	name = "Families: Armored Beat Cop"
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	belt = /obj/item/gun/energy/e_gun

/datum/outfit/families_police/beatcop/swat
	name = "Families: SWAT Beat Cop"
	suit = /obj/item/clothing/suit/armor/riot
	head = /obj/item/clothing/head/helmet/riot
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/gun/energy/e_gun

/datum/outfit/families_police/beatcop/fbi
	name = "Families: Space FBI Officer"
	suit = /obj/item/clothing/suit/armor/laserproof
	head = /obj/item/clothing/head/helmet/riot
	belt = /obj/item/gun/energy/laser/scatter
	gloves = /obj/item/clothing/gloves/combat

/datum/outfit/families_police/beatcop/military
	name = "Families: Space Military"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/laserproof
	head = /obj/item/clothing/head/beret/durathread
	belt = /obj/item/gun/energy/laser/scatter
	gloves = /obj/item/clothing/gloves/combat
