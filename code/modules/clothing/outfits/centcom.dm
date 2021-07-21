
/datum/outfit/centcom/commander
	name = "CentCom Commander"

	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/centhat
	belt = /obj/item/gun/ballistic/revolver/mateba
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/ammo_box/a357
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/commander

/datum/outfit/centcom/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/datum/outfit/centcom/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)//hmm lets have centcom officials become revs
	L.implant(H, null, 1)

/datum/outfit/centcom/spec_ops
	name = "Special Ops Officer"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/officer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	ears = /obj/item/radio/headset/headset_cent/commander
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/helmet/space/beret
	belt = /obj/item/gun/energy/pulse/pistol/m1911
	r_pocket = /obj/item/lighter
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/specops_officer

/datum/outfit/centcom/spec_ops/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE
	..()

/datum/outfit/centcom/soviet
	name = "Soviet Admiral"

	uniform = /obj/item/clothing/under/costume/soviet
	head = /obj/item/clothing/head/pirate/captain
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	suit = /obj/item/clothing/suit/pirate/captain
	back = /obj/item/storage/backpack/satchel/leather
	belt = /obj/item/gun/ballistic/revolver/mateba

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/admiral

/datum/outfit/centcom/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id

	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/datum/outfit/centcom/death_commando
	name = "Death Commando"

	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/space/hardsuit/deathsquad
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	back = /obj/item/storage/backpack/security
	l_pocket = /obj/item/melee/transforming/energy/sword/saber
	r_pocket = /obj/item/shield/energy
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	belt = /obj/item/gun/ballistic/revolver/mateba
	l_hand = /obj/item/gun/energy/pulse/loyalpin
	id = /obj/item/card/id/advanced/black/deathsquad
	ears = /obj/item/radio/headset/headset_cent/alt

	skillchips = list(/obj/item/skillchip/disk_verifier)

	backpack_contents = list(/obj/item/storage/box/survival/engineer=1,\
		/obj/item/ammo_box/a357=1,\
		/obj/item/storage/firstaid/regular=1,\
		/obj/item/storage/box/flashbangs=1,\
		/obj/item/flashlight=1,\
		/obj/item/grenade/c4/x4=1)

	id_trim = /datum/id_trim/centcom/deathsquad

/datum/outfit/centcom/death_commando/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/datum/outfit/centcom/death_commando/officer
	name = "Death Commando Officer"
	head = /obj/item/clothing/head/helmet/space/beret

/datum/outfit/tournament
	name = "tournament standard red"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet/thunderdome
	l_hand = /obj/item/gun/energy/pulse/destroyer
	l_hand = /obj/item/kitchen/knife
	r_pocket = /obj/item/grenade/smokebomb

/datum/outfit/tournament/green
	name = "tournament standard green"

	uniform = /obj/item/clothing/under/color/green

/datum/outfit/tournament/gangster
	name = "tournament gangster"

	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/det_suit
	glasses = /obj/item/clothing/glasses/thermal/monocle
	head = /obj/item/clothing/head/fedora/det_hat
	l_hand = /obj/item/gun/ballistic
	l_hand = null
	r_pocket = /obj/item/ammo_box/c10mm

/datum/outfit/tournament/janitor
	name = "tournament janitor"

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	back = /obj/item/storage/backpack
	suit = null
	head = null
	r_hand = /obj/item/mop
	l_hand = /obj/item/reagent_containers/glass/bucket
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	backpack_contents = list(/obj/item/stack/tile/iron=6)

/datum/outfit/tournament/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/reagent_containers/glass/bucket/bucket = H.get_item_for_held_index(1)
	bucket.reagents.add_reagent(/datum/reagent/water,70)
