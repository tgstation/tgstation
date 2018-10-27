/datum/outfit
	var/name = "Naked"

	var/list/uniform
	var/list/suit
	var/toggle_helmet = TRUE
	var/list/back
	var/list/belt
	var/list/gloves
	var/list/shoes
	var/list/head
	var/list/mask
	var/list/neck
	var/list/ears
	var/list/glasses
	var/list/id
	var/list/l_pocket
	var/list/r_pocket
	var/list/suit_store
	var/list/r_hand
	var/list/l_hand
	var/internals_slot //ID of slot containing a gas tank
	var/list/backpack_contents // In the list(path=count,otherpath=count) format
	var/list/implants
	var/accessory

	var/can_be_admin_equipped = TRUE // Set to FALSE if your outfit requires runtime parameters
	var/list/chameleon_extras //extra types for chameleon outfit changes, mostly guns

/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for customization depending on client prefs,species etc
	return

/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for toggling internals, id binding, access etc
	return

#define TRY_EQUIP_ITEM(mob, item_to_equip, slot)\
	var/item = (islist(item_to_equip) && item_to_equip.len > 1) ? pickweight(item_to_equip) : item_to_equip;\
	if(ispath(item)){\
		mob.equip_to_slot_or_del(new item(mob), slot)}

#define RIGHT_HAND 0
#define LEFT_HAND 1
#define TRY_EQUIP_HAND(mob, item_to_equip, slot)\
	var/item = (islist(item_to_equip) && item_to_equip.len > 1) ? pickweight(item_to_equip) : item_to_equip;\
	if(ispath(item)){\
		if(slot){\
			mob.put_in_l_hand(new item(mob))}\
		else{\
			mob.put_in_r_hand(new item(mob))}}

/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		TRY_EQUIP_ITEM(H, uniform, SLOT_W_UNIFORM)

	if(suit)
		TRY_EQUIP_ITEM(H, suit, SLOT_WEAR_SUIT)

	if(back)
		TRY_EQUIP_ITEM(H, back, SLOT_BACK)

	if(belt)
		TRY_EQUIP_ITEM(H, belt, SLOT_BELT)

	if(gloves)
		TRY_EQUIP_ITEM(H, gloves, SLOT_GLOVES)

	if(shoes)
		TRY_EQUIP_ITEM(H, shoes, SLOT_SHOES)

	if(head)
		TRY_EQUIP_ITEM(H, head, SLOT_HEAD)

	if(mask)
		TRY_EQUIP_ITEM(H, mask, SLOT_WEAR_MASK)

	if(neck)
		TRY_EQUIP_ITEM(H, neck, SLOT_NECK)

	if(ears)
		TRY_EQUIP_ITEM(H, ears, SLOT_EARS)

	if(glasses)
		TRY_EQUIP_ITEM(H, glasses, SLOT_GLASSES)

	if(id)
		TRY_EQUIP_ITEM(H, id, SLOT_WEAR_ID)

	if(suit_store)
		TRY_EQUIP_ITEM(H, suit_store, SLOT_S_STORE)

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		if(U)
			U.attach_accessory(new accessory(H))
		else
			WARNING("Unable to equip accessory [accessory] in outfit [name]. No uniform present!")

	if(l_hand)
		TRY_EQUIP_HAND(H, l_hand, LEFT_HAND)
	if(r_hand)
		TRY_EQUIP_HAND(H, r_hand, RIGHT_HAND)

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			TRY_EQUIP_ITEM(H, l_pocket, SLOT_L_STORE)

		if(r_pocket)
			TRY_EQUIP_ITEM(H, r_pocket, SLOT_R_STORE)

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					H.equip_to_slot_or_del(new path(H),SLOT_IN_BACKPACK)

	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons_icon()
		if(implants)
			for(var/implant_type in implants)
				var/obj/item/implant/I = new implant_type(H)
				I.implant(H, null, TRUE)

	H.update_body()
	return TRUE

#undef LEFT_HAND
#undef RIGHT_HAND
#undef TRY_EQUIP_HAND
#undef TRY_EQUIP_ITEM

/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.back)
		H.back.add_fingerprint(H,1)	//The 1 sets a flag to ignore gloves
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H,1)
	if(H.wear_id)
		H.wear_id.add_fingerprint(H,1)
	if(H.w_uniform)
		H.w_uniform.add_fingerprint(H,1)
	if(H.wear_suit)
		H.wear_suit.add_fingerprint(H,1)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H,1)
	if(H.wear_neck)
		H.wear_neck.add_fingerprint(H,1)
	if(H.head)
		H.head.add_fingerprint(H,1)
	if(H.shoes)
		H.shoes.add_fingerprint(H,1)
	if(H.gloves)
		H.gloves.add_fingerprint(H,1)
	if(H.ears)
		H.ears.add_fingerprint(H,1)
	if(H.glasses)
		H.glasses.add_fingerprint(H,1)
	if(H.belt)
		H.belt.add_fingerprint(H,1)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H,1)
	if(H.s_store)
		H.s_store.add_fingerprint(H,1)
	if(H.l_store)
		H.l_store.add_fingerprint(H,1)
	if(H.r_store)
		H.r_store.add_fingerprint(H,1)
	for(var/obj/item/I in H.held_items)
		I.add_fingerprint(H,1)
	return 1

/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, ears, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand)
	types += chameleon_extras
	listclearnulls(types)
	return types
