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
	ignore_special_events = 1
	var/title = "Enforcer"
	var/list/items_for_belt = list()
	var/list/items_for_box = list()

/datum/outfit/perseus/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/storage/box/box = new()
	if(!istype(H.dna.species, /datum/species/plasmaman))
		if(!visualsOnly)
			box.handle_item_insertion(new /obj/item/tank/perseus(), 1, H)
	else
		//plasmaman compatibility
		qdel(H.head)
		qdel(H.wear_mask)
		H.equip_to_slot_if_possible(new head(),slot_head, 1, 1, 1, 0)
		H.equip_to_slot_if_possible(new mask(),slot_wear_mask, 1, 1, 1, 0)
		if(!visualsOnly)
			//since we deleted the mask, we have to turn internals back on, we look for the first tank added by parent code.
			for(var/obj/item/tank/internals/plasmaman/belt/full/F in H.contents)
				H.internal = F
				break
			H.update_internals_hud_icon(1)
			//adding an extra plasmaman tank to the box
			box.handle_item_insertion(new /obj/item/tank/internals/plasmaman/belt/full(), 1, H)
		//transforming the plasmaman uniform to look and function like a skinsuit. We do not actually remove the plasmaman suit
		if(istype(H.w_uniform,/obj/item/clothing/under/plasmaman))
			var/obj/item/clothing/under/plasmaman/P = H.w_uniform
			P.name = "Modified Perseus skin suit"
			P.icon_state = "pers_skinsuit"
			P.icon = 'icons/oldschool/perseus.dmi'
			P.alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
			P.item_state = "perc"
			P.item_color = "pers_skinsuit"
			P.desc = "Standard issue to Perseus Security personnel in space assignments. Maintains a safe internal atmosphere for the user. This particular item has been adapted to fit the users unique physiology."
			P.flags_1 = STOPSPRESSUREDMAGE_1
			P.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
			P.w_class = 3
			P.has_sensor = 0
			P.resistance_flags = FIRE_PROOF | ACID_PROOF
			H.regenerate_icons()
	if(visualsOnly)
		return
	box.handle_item_insertion(new /obj/item/stimpack/perseus(), 1, H)
	H.equip_to_slot_or_del(box, slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/book/manual/sop(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/gun/energy/ep90(H), slot_s_store)
	var/theckey = H.ckey
	if(!theckey)
		for(var/mob/dead/new_player/N in GLOB.player_list)
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
	var/list/thecontents = H.get_contents()
	if(istype(thecontents) && GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
		for(var/obj/machinery/computer/percsecuritysystem/C in GLOB.Perseus_Data["Perseus_Security_Systems"])
			C.gather_equipment(thecontents)

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
	var/list/thecontents = extra_equipment(H)
	if(istype(thecontents) && GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
		for(var/obj/machinery/computer/percsecuritysystem/C in GLOB.Perseus_Data["Perseus_Security_Systems"])
			C.gather_equipment(thecontents)

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
	var/list/thecontents = extra_equipment(H)
	if(istype(thecontents) && GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
		for(var/obj/machinery/computer/percsecuritysystem/C in GLOB.Perseus_Data["Perseus_Security_Systems"])
			C.gather_equipment(thecontents)

//Adding additional items.
/datum/outfit/perseus/proc/extra_equipment(mob/living/carbon/human/H)
	. = list()
	var/list/to_be_equipped = list(
		/obj/item/clothing/glasses/perseus = slot_glasses,
		/obj/item/storage/belt/security/perseus = slot_belt,
		/obj/item/restraints/handcuffs = slot_l_store,
		/obj/item/gun/ballistic/fiveseven = slot_in_backpack,
		/obj/item/tank/jetpack/oxygen/perctech = slot_in_backpack,
		/obj/item/storage/belt/utility/full = slot_in_backpack)
	for(var/t in to_be_equipped)
		if(!to_be_equipped[t])
			continue
		var/obj/item/I = new t(H)
		H.equip_to_slot_or_del(I, to_be_equipped[t])
		. += I
	var/obj/item/shield/riot/perc/shield = new(H)
	H.put_in_l_hand(shield)
	. += shield

	if(istype(H.belt,/obj/item/storage/belt))
		var/obj/item/storage/belt/B = H.belt
		for(var/t in items_for_belt)
			var/obj/item/I = new t(H)
			B.handle_item_insertion(I, 1, H)
			. += I
	if(istype(H.back,/obj/item/storage/backpack))
		for(var/obj/item/storage/box/box in H.back)
			for(var/t in items_for_box)
				var/obj/item/I = new t(H)
				box.handle_item_insertion(I, 1, H)
				. += I
			break

	//adding knife to boots
	if(istype(H.shoes, /obj/item/clothing/shoes/perseus))
		var/obj/item/clothing/shoes/perseus/shoes = H.shoes
		if(!shoes.knife)
			var/obj/item/stun_knife/stunknife = new(shoes)
			shoes.knife = stunknife
			shoes.update_icon()
			. += stunknife
