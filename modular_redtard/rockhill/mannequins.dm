/// Ratwood's mannequin (structures/mannequin.dm): a figure that wears clothes on twelve places of its body. Aim at the place
/// and click with the garment to dress it, with an empty hand to take the garment back; drag the mannequin onto oneself for a
/// fitting panel that also reaches the cloak and the ring and turns the figure. A punch or a blow in combat tips it over and
/// everything it wears falls off; a hand stands it up again. Ratwood's base display stand shares its path with TG's
/// mannequin, so only the mannequins under /male (the man and the woman) are Ratwood's here.

#define MANNEQUIN_SLOT_SHIRT "shirt"
#define MANNEQUIN_SLOT_FEET "feet"
#define MANNEQUIN_SLOT_GLOVES "gloves"
#define MANNEQUIN_SLOT_WRISTS "wrists"
#define MANNEQUIN_SLOT_ARMOR "armor"
#define MANNEQUIN_SLOT_NECK "neck"
#define MANNEQUIN_SLOT_BELT "belt"
#define MANNEQUIN_SLOT_MASK "mask"
#define MANNEQUIN_SLOT_HEAD "head"
#define MANNEQUIN_SLOT_PANTS "pants"
#define MANNEQUIN_SLOT_CLOAK "cloak"
#define MANNEQUIN_SLOT_RING "ring"
/// Ratwood draws the figure's arms over its clothes and under its sleeves (HANDS_PART_LAYER).
#define MANNEQUIN_ARMS_LAYER (BELT_LAYER - 0.15)

/obj/structure/mannequin/male
	anchored = FALSE
	gender = MALE
	/// A decorative one keeps what it wears.
	var/unchangeable = FALSE
	/// Lying on the floor after a blow.
	var/tipped_over = FALSE
	/// What it wears, by its place (MANNEQUIN_SLOT_*).
	var/list/obj/item/outfit = list()

/obj/structure/mannequin/male/female
	gender = FEMALE

/obj/structure/mannequin/male/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	for(var/slot in list(MANNEQUIN_SLOT_ARMOR, MANNEQUIN_SLOT_SHIRT, MANNEQUIN_SLOT_BELT, MANNEQUIN_SLOT_MASK, MANNEQUIN_SLOT_PANTS, MANNEQUIN_SLOT_FEET, MANNEQUIN_SLOT_HEAD, MANNEQUIN_SLOT_CLOAK, MANNEQUIN_SLOT_NECK, MANNEQUIN_SLOT_GLOVES, MANNEQUIN_SLOT_WRISTS, MANNEQUIN_SLOT_RING))
		outfit[slot] = null
	update_appearance(UPDATE_OVERLAYS)
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/// Ratwood: the clothes the map laid on the mannequin's tile are what it wears.
/obj/structure/mannequin/male/LateInitialize()
	for(var/obj/item/clothing/garment in loc)
		var/slot = slot_of_flags(garment.slot_flags)
		if(slot && !outfit[slot])
			wear(garment, slot)

/obj/structure/mannequin/male/Destroy()
	drop_all()
	return ..()

/obj/structure/mannequin/male/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/slot in outfit)
		if(outfit[slot] == gone)
			outfit[slot] = null
			if(!QDELETED(src))
				update_appearance(UPDATE_OVERLAYS)

/obj/structure/mannequin/male/examine(mob/user)
	. = ..()
	for(var/slot in outfit)
		var/obj/item/garment = outfit[slot]
		if(garment)
			. += "Wearing [garment][slot_words(slot)]"
	. += "This mannequin has a [gender == FEMALE ? "feminine" : "masculine"] body."
	. += "Aim for the place where the clothing fits, or drag the mannequin onto yourself for a less immersive panel."

/obj/structure/mannequin/male/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	var/datum/intent/unarmed/fist = user.rogue_active_intent()
	if(istype(fist) && fist.unarmed_action == ROGUE_UNARMED_HARM)
		if(!tipped_over)
			tip_over()
			return TRUE
		return
	if(tipped_over)
		stand_up(user)
		return TRUE
	take_off(user, slot_of_zone(user.rogue_precise_zone()))
	return TRUE

/obj/structure/mannequin/male/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(tipped_over)
		return ITEM_INTERACT_BLOCKING
	try_dress(user, tool, user.rogue_precise_zone())
	return ITEM_INTERACT_SUCCESS

/obj/structure/mannequin/male/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	var/mob/living/striker = user
	if(isliving(striker) && striker.combat_mode && !tipped_over)
		tip_over()
		return TRUE
	return ..()

/obj/structure/mannequin/male/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(over != user || !iscarbon(user) || unchangeable || user.incapacitated || !Adjacent(user))
		return
	show_inventory(user)

/obj/structure/mannequin/male/update_overlays()
	. = ..()
	underlays.Cut()
	for(var/slot in outfit)
		var/obj/item/garment = outfit[slot]
		if(!garment)
			continue
		var/mutable_appearance/look = garment.build_worn_icon(default_layer = slot_layer(slot), default_icon_file = garment.worn_icon || get_default_icon_by_slot(slot_flag(slot)))
		// What is worn behind the body cannot go under the figure as an overlay (Ratwood puts cloaks in the underlays).
		if(look && -look.layer >= BODY_BEHIND_LAYER)
			underlays += look
		else if(look)
			. += look
		if(slot in list(MANNEQUIN_SLOT_GLOVES, MANNEQUIN_SLOT_WRISTS, MANNEQUIN_SLOT_ARMOR, MANNEQUIN_SLOT_SHIRT, MANNEQUIN_SLOT_CLOAK))
			. += sleeve_looks(garment, slot)
	. += mutable_appearance(icon, "mannequin_arms[gender == FEMALE ? "f" : "m"]", -MANNEQUIN_ARMS_LAYER)

/// Ratwood MakeSleeveLayer(): the garment's sleeves, as on a body, drawn over the figure's arms unless torn off or rolled up.
/obj/structure/mannequin/male/proc/sleeve_looks(obj/item/garment, slot)
	. = list()
	if(!garment.rogue_sleeved)
		return
	var/sleeve_layer = ROGUE_ARMOR_SLEEVE_LAYER
	switch(slot)
		if(MANNEQUIN_SLOT_WRISTS)
			sleeve_layer = ROGUE_WRISTS_SLEEVE_LAYER
		if(MANNEQUIN_SLOT_GLOVES)
			sleeve_layer = ROGUE_GLOVES_SLEEVE_LAYER
		if(MANNEQUIN_SLOT_SHIRT)
			sleeve_layer = ROGUE_SHIRT_SLEEVE_LAYER
		if(MANNEQUIN_SLOT_CLOAK)
			sleeve_layer = ROGUE_CLOAK_LAYER
	for(var/side in list("r", "l"))
		if(!garment.nodismemsleeves && garment.rogue_sleeve_bare(side))
			continue
		var/state = "[side]_[garment.icon_state]"
		if(gender == FEMALE && icon_exists(garment.rogue_sleeved, "[state][ROGUE_FEMALE_SUFFIX]"))
			state += ROGUE_FEMALE_SUFFIX
		if(!icon_exists(garment.rogue_sleeved, state))
			continue
		var/mutable_appearance/sleeve = mutable_appearance(garment.rogue_sleeved, state, -sleeve_layer)
		sleeve.color = garment.color
		sleeve.alpha = garment.alpha
		var/obj/item/clothing/cloth = garment
		if(istype(cloth) && cloth.sleeved_detail)
			sleeve.overlays += cloth.rogue_detail_layers(garment.rogue_sleeved, state, "[side]_[garment.icon_state]")
		. += sleeve

/// Ratwood tryEquip(): with a garment in hand it goes on the aimed place, with an empty hand what is there comes off.
/obj/structure/mannequin/male/proc/try_dress(mob/living/user, obj/item/garment, zone)
	if(unchangeable)
		return
	var/slot = slot_of_zone(zone)
	if(!slot)
		return
	if(!(garment.slot_flags & slot_flag(slot)))
		to_chat(user, span_warning("\The [garment] doesn't fit on the mannequins [slot_place(slot)]."))
		return
	if(!user.transferItemToLoc(garment, src))
		to_chat(user, span_warning("You can't drop that!"))
		return
	var/obj/item/previous = outfit[slot]
	if(previous)
		to_chat(user, span_info("You switch \the [garment] and \the [previous] on the [src]."))
	else
		to_chat(user, span_info("You place \the [garment] on \the [src]."))
	wear(garment, slot)
	add_fingerprint(user)

/obj/structure/mannequin/male/proc/take_off(mob/living/user, slot)
	if(unchangeable || !slot)
		return
	var/obj/item/garment = outfit[slot]
	if(!garment)
		return
	remove(slot)
	user.put_in_hands(garment)
	add_fingerprint(user)
	to_chat(user, span_info("You pick up \the [garment] from \the [src]."))

/// Ratwood MannequinEquip(): what was there before falls off.
/obj/structure/mannequin/male/proc/wear(obj/item/garment, slot)
	if(outfit[slot] && outfit[slot] != garment)
		remove(slot)
	if(garment.loc != src)
		garment.forceMove(src)
	outfit[slot] = garment
	update_appearance(UPDATE_OVERLAYS)

/// Ratwood MannequinUnequip(): the garment drops to the floor.
/obj/structure/mannequin/male/proc/remove(slot)
	var/obj/item/garment = outfit[slot]
	if(!garment)
		return
	outfit[slot] = null
	garment.forceMove(drop_location())
	if(!QDELETED(src))
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/mannequin/male/proc/drop_all()
	if(unchangeable)
		return
	for(var/slot in outfit)
		remove(slot)

/// Ratwood TipOver(): knocked to the floor it drops everything.
/obj/structure/mannequin/male/proc/tip_over()
	playsound(src, 'modular_redtard/rockhill/sound/foley/dropsound/wooden_drop.ogg', 50, TRUE)
	set_density(FALSE)
	tipped_over = TRUE
	drop_all()
	transform = transform.Turn(90)

/// Ratwood StandUp(): not onto another standing one.
/obj/structure/mannequin/male/proc/stand_up(mob/living/user)
	for(var/obj/structure/mannequin/male/other in loc)
		if(other != src && other.density && !other.tipped_over)
			return
	playsound(src, 'modular_redtard/rockhill/sound/foley/woodclimb.ogg', 50, TRUE)
	set_density(TRUE)
	tipped_over = FALSE
	transform = transform.Turn(-90)
	to_chat(user, span_notice("You pull [src] off the ground."))

/// Ratwood ShowInventory(): the fitting panel, every place and what is on it, and a button that turns the figure.
/obj/structure/mannequin/male/proc/show_inventory(mob/user)
	var/list/rows = list()
	for(var/list/place in list(
		list("Head", MANNEQUIN_SLOT_HEAD), list("Mask", MANNEQUIN_SLOT_MASK), list("Neck", MANNEQUIN_SLOT_NECK),
		list("Cloak", MANNEQUIN_SLOT_CLOAK), list("Armor", MANNEQUIN_SLOT_ARMOR), list("Shirt", MANNEQUIN_SLOT_SHIRT),
		list("Belt", MANNEQUIN_SLOT_BELT), list("Ring", MANNEQUIN_SLOT_RING), list("Wrists", MANNEQUIN_SLOT_WRISTS),
		list("Gloves", MANNEQUIN_SLOT_GLOVES), list("Pants", MANNEQUIN_SLOT_PANTS), list("Shoes", MANNEQUIN_SLOT_FEET),
	))
		var/obj/item/garment = outfit[place[2]]
		rows += "<B>[place[1]]:</B> <A href='byond://?src=[REF(src)];command=item_placement;item_slot=[place[2]]'>[garment ? garment : "<font color=grey>Empty</font>"]</A>"
	var/content = "[jointext(rows, "<BR>")]<HR>Turn Mannequin: <B><A href='byond://?src=[REF(src)];command=turn_mannequin'>[dir2text(dir)]</A></B>"
	var/datum/browser/popup = new(user, "mannequin[REF(src)]", "Mannequin Fitting", 275, 425)
	popup.set_content(content)
	popup.open()

/obj/structure/mannequin/male/Topic(href, list/href_list)
	. = ..()
	var/mob/living/carbon/user = usr
	if(tipped_over || unchangeable || !istype(user) || user.incapacitated || !Adjacent(user))
		return
	switch(href_list["command"])
		if("item_placement")
			var/slot = href_list["item_slot"]
			if(!(slot in outfit))
				return
			var/obj/item/held = user.get_active_held_item()
			if(held)
				dress_slot(user, held, slot)
			else
				take_off(user, slot)
		if("turn_mannequin")
			switch(dir)
				if(NORTH)
					setDir(EAST)
				if(SOUTH)
					setDir(WEST)
				if(WEST)
					setDir(NORTH)
				else
					setDir(SOUTH)
		else
			return
	update_appearance(UPDATE_OVERLAYS)
	show_inventory(user)

/// The fitting panel puts a garment on a place directly, the cloak and the ring too.
/obj/structure/mannequin/male/proc/dress_slot(mob/living/user, obj/item/garment, slot)
	if(!(garment.slot_flags & slot_flag(slot)))
		to_chat(user, span_warning("\The [garment] doesn't fit on the mannequins [slot_place(slot)]."))
		return
	if(!user.transferItemToLoc(garment, src))
		to_chat(user, span_warning("You can't drop that!"))
		return
	to_chat(user, span_info("You place \the [garment] on \the [src]."))
	wear(garment, slot)
	add_fingerprint(user)

/// Ratwood MannequinEquipHelper(): the place an aimed part of the body stands for; the cloak and the ring have none.
/obj/structure/mannequin/male/proc/slot_of_zone(zone)
	switch(zone)
		if(BODY_ZONE_HEAD, "ears", "skull")
			return MANNEQUIN_SLOT_HEAD
		if("neck")
			return MANNEQUIN_SLOT_NECK
		if("l_eye", "r_eye", "nose", BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
			return MANNEQUIN_SLOT_MASK
		if(BODY_ZONE_CHEST)
			return MANNEQUIN_SLOT_ARMOR
		if("stomach")
			return MANNEQUIN_SLOT_SHIRT
		if(BODY_ZONE_PRECISE_GROIN)
			return MANNEQUIN_SLOT_BELT
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return MANNEQUIN_SLOT_PANTS
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return MANNEQUIN_SLOT_WRISTS
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return MANNEQUIN_SLOT_GLOVES
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return MANNEQUIN_SLOT_FEET

/// The item slot a place takes (Ratwood EquipHelper()).
/obj/structure/mannequin/male/proc/slot_flag(slot)
	switch(slot)
		if(MANNEQUIN_SLOT_HEAD)
			return ITEM_SLOT_HEAD
		if(MANNEQUIN_SLOT_NECK)
			return ITEM_SLOT_NECK
		if(MANNEQUIN_SLOT_MASK)
			return ITEM_SLOT_MASK
		if(MANNEQUIN_SLOT_CLOAK)
			return ITEM_SLOT_ROGUE_CLOAK
		if(MANNEQUIN_SLOT_ARMOR)
			return ITEM_SLOT_OCLOTHING
		if(MANNEQUIN_SLOT_SHIRT)
			return ITEM_SLOT_ROGUE_SHIRT
		if(MANNEQUIN_SLOT_BELT)
			return ITEM_SLOT_BELT
		if(MANNEQUIN_SLOT_RING)
			return ITEM_SLOT_ROGUE_RING
		if(MANNEQUIN_SLOT_PANTS)
			return ITEM_SLOT_ICLOTHING
		if(MANNEQUIN_SLOT_GLOVES)
			return ITEM_SLOT_GLOVES
		if(MANNEQUIN_SLOT_WRISTS)
			return ITEM_SLOT_ROGUE_WRISTS
		if(MANNEQUIN_SLOT_FEET)
			return ITEM_SLOT_FEET
	return NONE

/// The place a mapped garment goes to by its slots (Ratwood MannequinSlotHelper()).
/obj/structure/mannequin/male/proc/slot_of_flags(flags)
	for(var/slot in list(MANNEQUIN_SLOT_HEAD, MANNEQUIN_SLOT_NECK, MANNEQUIN_SLOT_MASK, MANNEQUIN_SLOT_ARMOR, MANNEQUIN_SLOT_SHIRT, MANNEQUIN_SLOT_BELT, MANNEQUIN_SLOT_PANTS, MANNEQUIN_SLOT_GLOVES, MANNEQUIN_SLOT_FEET, MANNEQUIN_SLOT_CLOAK, MANNEQUIN_SLOT_WRISTS, MANNEQUIN_SLOT_RING))
		if(flags & slot_flag(slot))
			return slot

/// The layer a place is drawn on, as on a body of the module.
/obj/structure/mannequin/male/proc/slot_layer(slot)
	switch(slot)
		if(MANNEQUIN_SLOT_HEAD)
			return HEAD_LAYER
		if(MANNEQUIN_SLOT_MASK)
			return FACEMASK_LAYER
		if(MANNEQUIN_SLOT_NECK)
			return NECK_LAYER
		if(MANNEQUIN_SLOT_CLOAK)
			return ROGUE_CLOAK_LAYER
		if(MANNEQUIN_SLOT_ARMOR)
			return SUIT_LAYER
		if(MANNEQUIN_SLOT_SHIRT)
			return ROGUE_SHIRT_LAYER
		if(MANNEQUIN_SLOT_BELT)
			return BELT_LAYER
		if(MANNEQUIN_SLOT_RING)
			return ROGUE_RING_LAYER
		if(MANNEQUIN_SLOT_WRISTS)
			return ROGUE_WRISTS_LAYER
		if(MANNEQUIN_SLOT_GLOVES)
			return GLOVES_LAYER
		if(MANNEQUIN_SLOT_PANTS)
			return UNIFORM_LAYER
		if(MANNEQUIN_SLOT_FEET)
			return SHOES_LAYER

/// Ratwood PlacementDescriber(): the place in words.
/obj/structure/mannequin/male/proc/slot_place(slot)
	switch(slot)
		if(MANNEQUIN_SLOT_HEAD)
			return "head"
		if(MANNEQUIN_SLOT_CLOAK)
			return "shoulders"
		if(MANNEQUIN_SLOT_NECK)
			return "neck"
		if(MANNEQUIN_SLOT_MASK)
			return "face"
		if(MANNEQUIN_SLOT_ARMOR)
			return "chest"
		if(MANNEQUIN_SLOT_SHIRT)
			return "belly"
		if(MANNEQUIN_SLOT_BELT)
			return "crotch"
		if(MANNEQUIN_SLOT_RING)
			return "finger"
		if(MANNEQUIN_SLOT_PANTS)
			return "legs"
		if(MANNEQUIN_SLOT_GLOVES)
			return "hands"
		if(MANNEQUIN_SLOT_WRISTS)
			return "wrists"
		if(MANNEQUIN_SLOT_FEET)
			return "feet"
	return "thing"

/// Where a garment sits, for the examine (Ratwood examine()).
/obj/structure/mannequin/male/proc/slot_words(slot)
	switch(slot)
		if(MANNEQUIN_SLOT_HEAD)
			return " on its head."
		if(MANNEQUIN_SLOT_NECK)
			return " on its neck."
		if(MANNEQUIN_SLOT_GLOVES)
			return " on its hands."
		if(MANNEQUIN_SLOT_WRISTS)
			return " around its arms."
		if(MANNEQUIN_SLOT_BELT)
			return " about its waist."
		if(MANNEQUIN_SLOT_SHIRT)
			return " close to its skin."
		if(MANNEQUIN_SLOT_ARMOR)
			return " over its body."
		if(MANNEQUIN_SLOT_PANTS)
			return " on its legs."
		if(MANNEQUIN_SLOT_FEET)
			return " on its feet."
		if(MANNEQUIN_SLOT_MASK)
			return " on its face."
		if(MANNEQUIN_SLOT_CLOAK)
			return " over its shoulders."
		if(MANNEQUIN_SLOT_RING)
			return " around its finger."

/// Clothes on a woman's mannequin take Ratwood's women's sprites, as on a woman.
/obj/item/rogue_worn_by_female()
	var/obj/structure/mannequin/male/stand = loc
	if(istype(stand))
		return stand.gender == FEMALE
	return ..()

#undef MANNEQUIN_SLOT_SHIRT
#undef MANNEQUIN_SLOT_FEET
#undef MANNEQUIN_SLOT_GLOVES
#undef MANNEQUIN_SLOT_WRISTS
#undef MANNEQUIN_SLOT_ARMOR
#undef MANNEQUIN_SLOT_NECK
#undef MANNEQUIN_SLOT_BELT
#undef MANNEQUIN_SLOT_MASK
#undef MANNEQUIN_SLOT_HEAD
#undef MANNEQUIN_SLOT_PANTS
#undef MANNEQUIN_SLOT_CLOAK
#undef MANNEQUIN_SLOT_RING
#undef MANNEQUIN_ARMS_LAYER
