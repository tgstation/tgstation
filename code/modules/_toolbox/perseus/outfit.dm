//Perseus Outfit
/datum/outfit/perseus
	name = "Perseus Security Enforcer"
	uniform = /obj/item/clothing/under/space/skinsuit
	suit = /obj/item/clothing/suit/armor/lightarmor
	back = /obj/item/storage/backpack/blackpack
	gloves = /obj/item/clothing/gloves/specops
	shoes = /obj/item/clothing/shoes/perseus
	head = /obj/item/clothing/head/helmet/space/pershelmet
	mask = /obj/item/clothing/mask/gas/perseus_voice
	ears = /obj/item/device/radio/headset/perseus
	var/title = "Enforcer"
	var/list/items_for_belt = list()
	var/list/items_for_box = list()

/datum/outfit/perseus/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/storage/box/box = new()
	box.handle_item_insertion(new /obj/item/tank/perseus(), 1, H)
	H.equip_to_slot_or_del(box, slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/book/manual/sop(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/gun/energy/ep90(H), slot_s_store)
	var/theckey = H.ckey
	if(!theckey)
		for(var/mob/dead/new_player/N in world)
			if(N.new_character == H)
				theckey = N.ckey
				break

	var/datum/extra_role/perseus/E = H.give_extra_role(/datum/extra_role/perseus,0)
	E.give_identifier(theckey)

	var/obj/item/device/pda/perseus/P = new (H)
	var/obj/item/card/id/perseus/id = new /obj/item/card/id/perseus(P)
	id.assignment = "Perseus Security [title]"
	id.registered_name = "Perseus Security [title] #[E.perc_identifier]"
	id.name = "[id.registered_name]'s ID Card ([id.assignment])"

	P.id = id
	P.owner = "Perseus Security [title] #[E.perc_identifier]"
	P.ownjob = "Perseus Security [title]"
	P.name = "PDA-[P.owner] ([P.ownjob])"
	H.equip_to_slot_or_del(P, slot_wear_id)
	E.announce()

//Commander outfit
/datum/outfit/perseus/commander
	name = "Perseus Security Commander"
	title = "Commander"
	head = /obj/item/clothing/head/helmet/space/persberet

/datum/outfit/perseus/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if (visualsOnly)
		return
	var/datum/extra_role/perseus/P = check_perseus(H)
	if(P)
		P.give_commander()

//Advanced enforcer and commander outfits
/datum/outfit/perseus/fullkit
	name = "Perseus Security Enforcer - Full Kit"
	items_for_belt = list(
		/obj/item/c4_ex/breach,
		/obj/item/c4_ex/breach,
		/obj/item/ammo_box/magazine/fiveseven,
		/obj/item/ammo_box/magazine/fiveseven)
	items_for_box = list()

/datum/outfit/perseus/fullkit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	extra_equipment(H)

/datum/outfit/perseus/commander/fullkit
	name = "Perseus Security Commander - Full Kit"
	items_for_belt = list(
		/obj/item/c4_ex/breach,
		/obj/item/c4_ex/breach,
		/obj/item/ammo_box/magazine/fiveseven,
		/obj/item/ammo_box/magazine/fiveseven)
	items_for_box = list()

/datum/outfit/perseus/commander/fullkit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	extra_equipment(H)

//Adding additional items.
/datum/outfit/perseus/proc/extra_equipment(mob/living/carbon/human/H)
	if(istype(H.belt,/obj/item/storage/belt))
		var/obj/item/storage/belt/B = H.belt
		for(var/type in items_for_belt)
			B.handle_item_insertion(new type(), 1, H)
	if(istype(H.back,/obj/item/storage/backpack))
		for(var/obj/item/storage/box/box in H.back)
			for(var/type in items_for_box)
				box.handle_item_insertion(new type(), 1, H)
			break

	//adding knife to boots
	if(istype(H.shoes, /obj/item/clothing/shoes/perseus))
		var/obj/item/clothing/shoes/perseus/shoes = H.shoes
		if(!shoes.knife)
			var/obj/item/stun_knife/stunknife = new(shoes)
			shoes.knife = stunknife
			shoes.update_icon()

	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/perseus, slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/security/perseus, slot_belt)
	H.equip_to_slot_or_del(new /obj/item/restraints/handcuffs, slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/gun/ballistic/fiveseven(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/tank/jetpack/oxygen/perctech(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), slot_in_backpack)
	H.put_in_l_hand(new /obj/item/shield/riot/perc(H))
