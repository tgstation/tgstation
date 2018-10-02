/datum/outfit/ert
	name = "ERT Common"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt

/datum/outfit/ert/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
	L.implant(H, null, 1)

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)

/datum/outfit/ert/commander
	name = "ERT Commander"

	id = /obj/item/card/id/ert
	suit = /obj/item/clothing/suit/space/hardsuit/ert
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert
	belt = /obj/item/storage/belt/security/full
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/melee/baton/loaded=1,\
		/obj/item/clothing/mask/gas/sechailer=1,\
		/obj/item/gun/energy/e_gun=1)
	l_pocket = /obj/item/switchblade

/datum/outfit/ert/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return
	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/captain
	R.recalculateChannels()

/datum/outfit/ert/commander/alert
	name = "ERT Commander - High Alert"

	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/melee/baton/loaded=1,\
		/obj/item/clothing/mask/gas/sechailer/swat=1,\
		/obj/item/gun/energy/pulse/pistol/loyalpin=1)
	l_pocket = /obj/item/melee/transforming/energy/sword/saber

/datum/outfit/ert/security
	name = "ERT Security"

	id = /obj/item/card/id/ert/Security
	suit = /obj/item/clothing/suit/space/hardsuit/ert/sec
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/storage/belt/security/full
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/storage/box/handcuffs=1,\
		/obj/item/clothing/mask/gas/sechailer=1,\
		/obj/item/gun/energy/e_gun/stun=1,\
		/obj/item/melee/baton/loaded=1)

/datum/outfit/ert/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hos
	R.recalculateChannels()

/datum/outfit/ert/security/alert
	name = "ERT Security - High Alert"

	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/storage/box/handcuffs=1,\
		/obj/item/clothing/mask/gas/sechailer/swat=1,\
		/obj/item/melee/baton/loaded=1,\
		/obj/item/gun/energy/pulse/carbine/loyalpin=1)


/datum/outfit/ert/medic
	name = "ERT Medic"

	id = /obj/item/card/id/ert/Medical
	suit = /obj/item/clothing/suit/space/hardsuit/ert/med
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/ert/medical
	belt = /obj/item/storage/belt/medical
	r_hand = /obj/item/storage/firstaid/regular
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/melee/baton/loaded=1,\
		/obj/item/clothing/mask/gas/sechailer=1,\
		/obj/item/gun/energy/e_gun=1,\
		/obj/item/reagent_containers/hypospray/combat=1,\
		/obj/item/gun/medbeam=1)

/datum/outfit/ert/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/cmo
	R.recalculateChannels()

/datum/outfit/ert/medic/alert
	name = "ERT Medic - High Alert"

	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/melee/baton/loaded=1,\
		/obj/item/clothing/mask/gas/sechailer/swat=1,\
		/obj/item/gun/energy/pulse/pistol/loyalpin=1,\
		/obj/item/reagent_containers/hypospray/combat/nanites=1,\
		/obj/item/gun/medbeam=1)

/datum/outfit/ert/engineer
	name = "ERT Engineer"

	id = /obj/item/card/id/ert/Engineer
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engi
	glasses =  /obj/item/clothing/glasses/meson/engine
	back = /obj/item/storage/backpack/ert/engineer
	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/rcd_ammo/large
	r_hand = /obj/item/storage/firstaid/regular
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/melee/baton/loaded=1,\
		/obj/item/clothing/mask/gas/sechailer=1,\
		/obj/item/gun/energy/e_gun=1,\
		/obj/item/construction/rcd/loaded=1)

/datum/outfit/ert/engineer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/ce
	R.recalculateChannels()

/datum/outfit/ert/engineer/alert
	name = "ERT Engineer - High Alert"

	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/melee/baton/loaded=1,\
		/obj/item/clothing/mask/gas/sechailer/swat=1,\
		/obj/item/gun/energy/pulse/pistol/loyalpin=1,\
		/obj/item/construction/rcd/combat=1)


/datum/outfit/centcom_official
	name = "CentCom Official"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/pen
	back = /obj/item/storage/backpack/satchel
	r_pocket = /obj/item/pda/heads
	l_hand = /obj/item/clipboard
	id = /obj/item/card/id

/datum/outfit/centcom_official/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/pda/heads/pda = H.r_store
	pda.owner = H.real_name
	pda.ownjob = "CentCom Official"
	pda.update_label()

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_centcom_access("CentCom Official")
	W.access += ACCESS_WEAPONS
	W.assignment = "CentCom Official"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/ert/commander/inquisitor
	name = "Inquisition Commander"
	r_hand = /obj/item/nullrod/scythe/talking/chainsword
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/clothing/mask/gas/sechailer=1,
		/obj/item/gun/energy/e_gun=1)

/datum/outfit/ert/security/inquisitor
	name = "Inquisition Security"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor

	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/clothing/mask/gas/sechailer=1,
		/obj/item/gun/energy/e_gun/stun=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/construction/rcd/loaded=1)

/datum/outfit/ert/medic/inquisitor
	name = "Inquisition Medic"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor

	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/clothing/mask/gas/sechailer=1,
		/obj/item/gun/energy/e_gun=1,
		/obj/item/reagent_containers/hypospray/combat=1,
		/obj/item/reagent_containers/hypospray/combat/heresypurge=1,
		/obj/item/gun/medbeam=1)

/datum/outfit/ert/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hop
	R.recalculateChannels()

/datum/outfit/ert/chaplain
	name = "ERT Chaplain"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor // Chap role always gets this suit
	id = /obj/item/card/id/ert/chaplain
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/cultpack
	belt = /obj/item/storage/belt/soulstone
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/nullrod=1,
		/obj/item/clothing/mask/gas/sechailer=1,
		/obj/item/gun/energy/e_gun=1,
		)

/datum/outfit/ert/chaplain/inquisitor
	name = "Inquisition Chaplain"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor

	belt = /obj/item/storage/belt/soulstone/full/chappy
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/grenade/chem_grenade/holy=1,
		/obj/item/nullrod=1,
		/obj/item/clothing/mask/gas/sechailer=1,
		/obj/item/gun/energy/e_gun=1,
		)
