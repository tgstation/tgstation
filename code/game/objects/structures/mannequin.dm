/obj/structure/mannequin
	name = "mannequin"
	desc = "Oh, so this is a dress-up game now."
	icon = 'icons/mob/species/human/mannequin.dmi'
	icon_state = "mannequin_male"
	density = TRUE
	anchored = TRUE
	resistance_flags = FLAMMABLE
	var/body_type
	var/static/list/slot_flags = list(
		ITEM_SLOT_HEAD,
		ITEM_SLOT_EYES,
		ITEM_SLOT_EARS,
		ITEM_SLOT_MASK,
		ITEM_SLOT_NECK,
		ITEM_SLOT_BACK,
		ITEM_SLOT_BELT,
		ITEM_SLOT_ID,
		ITEM_SLOT_ICLOTHING,
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_FEET,
	)
	var/list/worn_items = list()

/obj/structure/mannequin/Initialize(mapload)
	. = ..()
	for(var/slot_flag in slot_flags)
		worn_items["[slot_flag]"] = null
	if(!body_type)
		body_type = pick(MALE, FEMALE)
	if(body_type == FEMALE)
		icon_state = "mannequin_female"
	AddElement(/datum/element/strippable, GLOB.strippable_mannequin_items)

/obj/structure/mannequin/Destroy()
	QDEL_LIST_ASSOC_VAL(worn_items)
	return ..()

/obj/structure/mannequin/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/slot_flag in worn_items)
		if(worn_items[slot_flag] == gone)
			worn_items[slot_flag] = null
	update_appearance()

/obj/structure/mannequin/atom_destruction(damage_flag)
	for(var/slot_flag in worn_items)
		var/obj/item/worn_item = worn_items[slot_flag]
		if(worn_item)
			worn_item.forceMove(drop_location())
	return ..()

/obj/structure/mannequin/update_overlays()
	. = ..()
	var/default_layer = 0
	var/default_icon = null
	var/female_icon = NO_FEMALE_UNIFORM
	for(var/slot_flag in worn_items)
		var/obj/item/worn_item = worn_items[slot_flag]
		if(!worn_item)
			continue
		switch(text2num(slot_flag)) //this kinda sucks because build worn icon kinda sucks
			if(ITEM_SLOT_HEAD)
				default_layer = HEAD_LAYER
				default_icon = 'icons/mob/clothing/head/default.dmi'
			if(ITEM_SLOT_EYES)
				default_layer = GLASSES_LAYER
				default_icon = 'icons/mob/clothing/eyes.dmi'
			if(ITEM_SLOT_EARS)
				default_layer = EARS_LAYER
				default_icon = 'icons/mob/clothing/ears.dmi'
			if(ITEM_SLOT_MASK)
				default_layer = FACEMASK_LAYER
				default_icon = 'icons/mob/clothing/mask.dmi'
			if(ITEM_SLOT_NECK)
				default_layer = NECK_LAYER
				default_icon = 'icons/mob/clothing/neck.dmi'
			if(ITEM_SLOT_BACK)
				default_layer = BACK_LAYER
				default_icon = 'icons/mob/clothing/back.dmi'
			if(ITEM_SLOT_BELT)
				default_layer = BELT_LAYER
				default_icon = 'icons/mob/clothing/belt.dmi'
			if(ITEM_SLOT_ID)
				default_layer = ID_LAYER
				default_icon = 'icons/mob/clothing/id.dmi'
			if(ITEM_SLOT_ICLOTHING)
				default_layer = UNIFORM_LAYER
				default_icon = DEFAULT_UNIFORM_FILE
				if(body_type == FEMALE && istype(worn_item, /obj/item/clothing/under))
					var/obj/item/clothing/under/worn_jumpsuit = worn_item
					female_icon = worn_jumpsuit.female_sprite_flags
			if(ITEM_SLOT_OCLOTHING)
				default_layer = SUIT_LAYER
				default_icon = DEFAULT_SUIT_FILE
			if(ITEM_SLOT_SUITSTORE)
				default_layer = SUIT_STORE_LAYER
				default_icon = 'icons/mob/clothing/belt_mirror.dmi'
			if(ITEM_SLOT_GLOVES)
				default_layer = GLOVES_LAYER
				default_icon = 'icons/mob/clothing/hands.dmi'
			if(ITEM_SLOT_FEET)
				default_layer = SHOES_LAYER
				default_icon = DEFAULT_SHOES_FILE
		. += worn_item.build_worn_icon(default_layer, default_icon, female_uniform = female_icon)

GLOBAL_LIST_INIT(strippable_mannequin_items, create_strippable_list(list(
	/datum/strippable_item/mannequin_slot/head,
	/datum/strippable_item/mannequin_slot/suit,
)))

/datum/strippable_item/mannequin_slot
	/// The ITEM_SLOT_* to equip to.
	var/item_slot

/datum/strippable_item/mannequin_slot/get_item(atom/source)
	var/obj/structure/mannequin/mannequin_source = source
	return istype(mannequin_source) ? mannequin_source.worn_items["[item_slot]"] : null

/datum/strippable_item/mannequin_slot/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!(equipping.item_flags & item_slot))
		to_chat(user, span_warning("[equipping] won't fit!"))
		return FALSE
	return TRUE

/datum/strippable_item/mannequin_slot/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/obj/structure/mannequin/mannequin_source = source
	if(!istype(mannequin_source))
		return
	if(!user.transferItemToLoc(equipping, mannequin_source) || QDELETED(equipping))
		return
	mannequin_source.worn_items["[item_slot]"] = equipping
	mannequin_source.update_appearance()

/datum/strippable_item/mannequin_slot/finish_unequip(atom/source, mob/user)
	var/obj/structure/mannequin/mannequin_source = source
	if(!istype(mannequin_source))
		return
	var/obj/item/unequipped = mannequin_source.worn_items["[item_slot]"]
	unequipped.forceMove(mannequin_source.drop_location())

/datum/strippable_item/mannequin_slot/head
	key = STRIPPABLE_ITEM_HEAD
	item_slot = ITEM_SLOT_HEAD

/datum/strippable_item/mannequin_slot/suit
	key = STRIPPABLE_ITEM_SUIT
	item_slot = ITEM_SLOT_OCLOTHING
