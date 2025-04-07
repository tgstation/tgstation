/obj/item/storage/belt/secsword
	name = "security weapons sheath"
	desc = "A large block of metal made for safely holding on to a shortblade and matching electro baton, \
		along with the rest of an officer's security equipment."
	icon = 'modular_doppler/modular_weapons/icons/obj/sec_swords.dmi'
	icon_state = "swordcase"
	base_icon_state = "swordcase"
	worn_icon = 'modular_doppler/modular_weapons/icons/mob/worn/cases.dmi'
	worn_icon_state = "swordcase"
	w_class = WEIGHT_CLASS_BULKY
	interaction_flags_click = parent_type::interaction_flags_click | NEED_DEXTERITY | NEED_HANDS
	obj_flags = UNIQUE_RENAME
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK

/obj/item/storage/belt/secsword/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

	atom_storage.max_slots = 5
	atom_storage.do_rustle = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = (WEIGHT_CLASS_BULKY + (WEIGHT_CLASS_NORMAL * 4)) // One sword four other things
	atom_storage.set_holdable(list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing/shotgun,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/flashlight/seclite,
		/obj/item/food/donut,
		/obj/item/grenade,
		/obj/item/holosign_creator/security,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/radio,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/melee/secblade,
	))
	atom_storage.open_sound = 'sound/items/handling/holster_open.ogg'
	atom_storage.open_sound_vary = TRUE

/obj/item/storage/belt/secsword/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("<b>Left Click</b> to draw a stored blade, <b>Right Click</b> to draw a stored baton while wearing.")

/obj/item/storage/belt/secsword/attack_hand_secondary(mob/user, list/modifiers)
	if(!(user.get_slot_by_item(src) & ITEM_SLOT_BELT) && !(user.get_slot_by_item(src) & ITEM_SLOT_BACK) && !(user.get_slot_by_item(src) & ITEM_SLOT_SUITSTORE))
		return ..()
	for(var/obj/item/melee/secblade/blade_runner in contents)
		user.visible_message(span_notice("[user] draws [blade_runner] from [src]."), span_notice("You draw [blade_runner] from [src]."))
		user.put_in_hands(blade_runner)
		playsound(user, 'sound/items/sheath.ogg', 50, TRUE)
		update_appearance()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/storage/belt/secsword/attack_hand(mob/user, list/modifiers)
	if(!(user.get_slot_by_item(src) & ITEM_SLOT_BELT) && !(user.get_slot_by_item(src) & ITEM_SLOT_BACK) && !(user.get_slot_by_item(src) & ITEM_SLOT_SUITSTORE))
		return ..()
	for(var/obj/item/melee/baton/doppler_security/simply_shocking in contents)
		user.visible_message(span_notice("[user] draws [simply_shocking] from [src]."), span_notice("You draw [simply_shocking] from [src]."))
		user.put_in_hands(simply_shocking)
		playsound(user, 'sound/items/sheath.ogg', 50, TRUE)
		update_appearance()
		return
	return ..()

/obj/item/storage/belt/secsword/update_icon_state()
	var/has_sword = FALSE
	var/has_baton = FALSE
	for(var/obj/thing in contents)
		if(has_baton && has_sword)
			break
		if(istype(thing, /obj/item/melee/baton/doppler_security))
			has_baton = TRUE
		if(istype(thing, /obj/item/melee/secblade))
			has_sword = TRUE

	icon_state = initial(icon_state)
	worn_icon_state = initial(worn_icon_state)

	var/next_appendage
	if(has_sword && has_baton)
		next_appendage = "-full"
	else if(has_sword)
		next_appendage = "-blayde"
	else if(has_baton)
		next_appendage = "-stun"

	if(next_appendage)
		icon_state += next_appendage
		worn_icon_state += next_appendage
	return ..()

/obj/item/storage/belt/secsword/full/PopulateContents()
	new /obj/item/melee/secblade(src)
	new /obj/item/melee/baton/doppler_security/loaded(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/assembly/flash/handheld(src)
	update_appearance()

/obj/item/storage/belt/secsword/training/PopulateContents()
	new /obj/item/melee/secblade/training(src) // No way attack on titan
	new /obj/item/melee/secblade/training(src)
	new /obj/item/melee/baton/doppler_security/loaded(src)
	update_appearance()

/obj/item/storage/belt/secsword/deathmatch/PopulateContents()
	new /obj/item/melee/secblade(src) // No way attack on titan
	new /obj/item/melee/secblade(src)
