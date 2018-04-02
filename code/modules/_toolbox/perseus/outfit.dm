/datum/outfit/perseus
	name = "Perseus Security Enforcer"
	uniform = /obj/item/clothing/under/space/skinsuit
	suit = /obj/item/clothing/suit/armor/lightarmor
	back = /obj/item/storage/backpack/blackpack
	gloves = /obj/item/clothing/gloves/specops
	shoes = /obj/item/clothing/shoes/perseus
	head = /obj/item/clothing/head/helmet/space/pershelmet
	mask = /obj/item/clothing/mask/gas/voice/perseus_voice
	ears = /obj/item/device/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/perseus
	belt = /obj/item/tank/perseus
	var/title = "Enforcer"

/datum/outfit/perseus/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	H.equip_to_slot_or_del(new /obj/item/storage/box(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/book/manual/sop(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/gun/energy/ep90(H), slot_s_store)
	var/obj/item/implant/enforcer/implant = new /obj/item/implant/enforcer(H)
	implant.implant(H)
	implant.perc_identifier = generate_perc_identifier()

	var/obj/item/device/pda/perseus/P = new (H)
	var/obj/item/card/id/perseus/id = new /obj/item/card/id/perseus(P)
	id.assignment = "Perseus Security [title]"
	id.registered_name = "Perseus Security [title] #[implant.perc_identifier]"
	id.name = name

	P.id = id
	P.owner = "Perseus Security [title] #[implant.perc_identifier]"
	P.ownjob = "Perseus Security [title]"
	P.name = "PDA-[P.owner] ([P.ownjob])"
	H.equip_to_slot_or_del(P, slot_wear_id)


/datum/outfit/perseus/fullkit
	name = "Perseus Security Enforcer - Full Kit"

/datum/outfit/perseus/fullkit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	H.equip_to_slot_or_del(new /obj/item/stun_knife, slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/c4_ex/breach(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/gun/ballistic/fiveseven(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/fiveseven(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/fiveseven(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/tank/jetpack/oxygen/perctech(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), slot_in_backpack)
	H.put_in_l_hand(new /obj/item/shield/riot/perc(H))


/datum/outfit/perseus/commander
	name = "Perseus Security Commander"
	title = "Commander"
	head = /obj/item/clothing/head/helmet/space/persberet

/datum/outfit/perseus/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if (visualsOnly)
		return
	var/obj/item/implant/commander/implant = new /obj/item/implant/commander(H)
	implant.implant(H)


/datum/outfit/perseus/commander/fullkit
	name = "Perseus Security Commander - Full Kit"
	title = "Commander"

/datum/outfit/perseus/commander/fullkit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	H.equip_to_slot_or_del(new /obj/item/stun_knife, slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/c4_ex/breach(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/gun/ballistic/fiveseven(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/fiveseven(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/fiveseven(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/tank/jetpack/oxygen/perctech(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), slot_in_backpack)
	H.put_in_l_hand(new /obj/item/shield/riot/perc(H))
