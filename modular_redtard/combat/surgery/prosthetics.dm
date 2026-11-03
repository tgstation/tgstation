/// Ratwood's prosthetics (roguejobs/engineer/prosthetic.dm) as real limbs. The porter brings them as plain things grafted on
/// /obj/item/rockhill - the wooden arms and legs, the bronze right arm - and the artificer's contraptions of bronze, iron,
/// steel and gold, which become a limb of their metal once the side and the limb are chosen in hand. Put on a stump - held to
/// the zone it replaces of one who lacks that limb, at once, as at Ratwood, or by surgery (combat/surgery/steps.dm) - such a
/// prosthetic becomes a real limb of TG's: of wood a peg limb (clumsy fingers, as Ratwood's wooden arms cannot swing a
/// weapon), of metal a prosthetic one, with Ratwood's toughness, the damage it shrugs off and, for legs, its slowness. It does
/// not bleed, hurt or take Ratwood's wounds. Sawn off, struck off or swapped, the limb turns back into the prosthetic it was
/// made from, and one struck off leaves no bleeding stump.

/// What a thing replaces as a prosthetic: the zone of the limb, or null for anything that is no prosthetic.
/obj/item/proc/rogue_prosthetic_zone()
	return null

/// What a prosthetic is made of.
/obj/item/proc/rogue_prosthetic_material()
	return rogue_prosthetic_material_of(type)

/// The real limb this prosthetic stands for, made from it (the prosthetic goes inside); null for no prosthetic.
/obj/item/proc/rogue_make_prosthetic_limb()
	var/limb_type = rogue_prosthetic_limb_type(rogue_prosthetic_zone(), rogue_prosthetic_material())
	if(!limb_type)
		return null
	var/obj/item/bodypart/limb = new limb_type()
	limb.rogue_prosthetic_from(src)
	return limb

/// Ratwood prosthetic_attachment(): held to the zone it replaces of one who lacks that limb, the prosthetic is put on at once;
/// held to another zone, it is no limb for it. A prosthetic is never swung at anyone (Ratwood's attack() does nothing else).
/obj/item/proc/rogue_prosthetic_attachment(atom/target, mob/living/user)
	var/zone = rogue_prosthetic_zone()
	if(!zone || !ishuman(target))
		return NONE
	var/mob/living/carbon/human/patient = target
	if(deprecise_zone(user.zone_selected) != zone)
		to_chat(user, span_warning("[src] isn't the right type for [parse_zone(user.zone_selected)]."))
		return ITEM_INTERACT_BLOCKING
	if(patient.get_bodypart(zone))
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarilyRemoveItemFromInventory(src))
		return ITEM_INTERACT_BLOCKING
	if(!rogue_attach_part(src, patient))
		user.put_in_hands(src)
		to_chat(user, span_warning("[patient]'s body rejects [src]!"))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] attaches [src] to [patient]."), span_notice("I attach [src] to [patient]."))
	return ITEM_INTERACT_SUCCESS

/// Ratwood attach_limb(): the severed limb or the prosthetic goes on the patient's stump; a limb of flesh is to be sewn on
/// (the replantation), and the stump on the chest closes. The limb put on, or null with the part left at the patient's feet.
/proc/rogue_attach_part(obj/item/part, mob/living/carbon/patient)
	var/obj/item/bodypart/new_limb = isbodypart(part) ? part : part.rogue_make_prosthetic_limb()
	if(!new_limb)
		part.forceMove(patient.drop_location())
		return null
	if(!new_limb.try_attach_limb(patient))
		part.forceMove(patient.drop_location())
		if(new_limb != part)
			qdel(new_limb)
		return null
	if(new_limb.check_for_frankenstein(patient))
		new_limb.bodypart_flags |= BODYPART_IMPLANTED
	if((new_limb.biological_state & (BIO_FLESH|BIO_BLOODED)) == (BIO_FLESH|BIO_BLOODED))
		new_limb.rogue_surgery_wound(/datum/wound/rogue/replantation, "replantation")
	patient.rogue_close_stump()
	return new_limb

/// The material of a prosthetic of the porter's, by its type: Ratwood names them bronzeleft, bronzeright, iron, steel, gold; the
/// rest are wooden.
/proc/rogue_prosthetic_material_of(path)
	var/path_text = "[path]"
	if(findtext(path_text, "bronze"))
		return ROGUE_PROSTHETIC_BRONZE
	if(findtext(path_text, "iron"))
		return ROGUE_PROSTHETIC_IRON
	if(findtext(path_text, "steel"))
		return ROGUE_PROSTHETIC_STEEL
	if(findtext(path_text, "gold"))
		return ROGUE_PROSTHETIC_GOLD
	return ROGUE_PROSTHETIC_WOOD

/// TG's limb a prosthetic becomes: a peg limb of wood, a prosthetic limb of metal.
/proc/rogue_prosthetic_limb_type(zone, material)
	var/wooden = material == ROGUE_PROSTHETIC_WOOD
	switch(zone)
		if(BODY_ZONE_L_ARM)
			return wooden ? /obj/item/bodypart/arm/left/ghetto/rogue_prosthetic : /obj/item/bodypart/arm/left/robot/surplus/rogue_prosthetic
		if(BODY_ZONE_R_ARM)
			return wooden ? /obj/item/bodypart/arm/right/ghetto/rogue_prosthetic : /obj/item/bodypart/arm/right/robot/surplus/rogue_prosthetic
		if(BODY_ZONE_L_LEG)
			return wooden ? /obj/item/bodypart/leg/left/ghetto/rogue_prosthetic : /obj/item/bodypart/leg/left/robot/surplus/rogue_prosthetic
		if(BODY_ZONE_R_LEG)
			return wooden ? /obj/item/bodypart/leg/right/ghetto/rogue_prosthetic : /obj/item/bodypart/leg/right/robot/surplus/rogue_prosthetic
	return null

/// Ratwood max_damage of a prosthetic: its material's; Ratwood's left arms of wood and bronze are the weaker.
/proc/rogue_prosthetic_max_damage(material, zone)
	switch(material)
		if(ROGUE_PROSTHETIC_BRONZE)
			return zone == BODY_ZONE_L_ARM ? rogue_value("surgery_prosthetic_bronze_left_arm_damage") : rogue_value("surgery_prosthetic_bronze_damage")
		if(ROGUE_PROSTHETIC_IRON)
			return rogue_value("surgery_prosthetic_iron_damage")
		if(ROGUE_PROSTHETIC_STEEL)
			return rogue_value("surgery_prosthetic_steel_damage")
		if(ROGUE_PROSTHETIC_GOLD)
			return rogue_value("surgery_prosthetic_gold_damage")
	return zone == BODY_ZONE_L_ARM ? rogue_value("surgery_prosthetic_wood_left_arm_damage") : rogue_value("surgery_prosthetic_wood_damage")

/// Ratwood brute_reduction and burn_reduction: the damage of each hit a prosthetic shrugs off.
/proc/rogue_prosthetic_reduction(material)
	switch(material)
		if(ROGUE_PROSTHETIC_IRON)
			return rogue_value("surgery_prosthetic_iron_reduction")
		if(ROGUE_PROSTHETIC_STEEL)
			return rogue_value("surgery_prosthetic_steel_reduction")
	return 0

/// Ratwood organ_slowdown: how much a prosthetic leg slows its wearer.
/proc/rogue_prosthetic_slowdown(material)
	switch(material)
		if(ROGUE_PROSTHETIC_IRON)
			return rogue_value("surgery_prosthetic_iron_slowdown")
		if(ROGUE_PROSTHETIC_STEEL)
			return rogue_value("surgery_prosthetic_steel_slowdown")
	return 0

/// The porter's prosthetics: each replaces the limb of its type.
/obj/item/bodypart/l_arm/prosthetic/rogue_prosthetic_zone()
	return BODY_ZONE_L_ARM

/obj/item/bodypart/l_arm/prosthetic/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return rogue_prosthetic_attachment(interacting_with, user) || ..()

/obj/item/bodypart/r_arm/prosthetic/rogue_prosthetic_zone()
	return BODY_ZONE_R_ARM

/obj/item/bodypart/r_arm/prosthetic/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return rogue_prosthetic_attachment(interacting_with, user) || ..()

/obj/item/bodypart/l_leg/prosthetic/rogue_prosthetic_zone()
	return BODY_ZONE_L_LEG

/obj/item/bodypart/l_leg/prosthetic/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return rogue_prosthetic_attachment(interacting_with, user) || ..()

/obj/item/bodypart/r_leg/prosthetic/rogue_prosthetic_zone()
	return BODY_ZONE_R_LEG

/obj/item/bodypart/r_leg/prosthetic/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return rogue_prosthetic_attachment(interacting_with, user) || ..()

/// Ratwood's prosthetic contraptions of the artificer: once the limb is chosen in hand, a prosthetic of their metal.
/obj/item/contraption
	/// The limb the contraption was shaped into (Ratwood attack_self()); null until it is chosen.
	var/rogue_limb_zone

/// The metal of a prosthetic contraption; null for the other contraptions.
/obj/item/contraption/proc/rogue_kit_material()
	return null

/obj/item/contraption/bronzeprosthetic/rogue_kit_material()
	return ROGUE_PROSTHETIC_BRONZE

/obj/item/contraption/ironprosthetic/rogue_kit_material()
	return ROGUE_PROSTHETIC_IRON

/obj/item/contraption/steelprosthetic/rogue_kit_material()
	return ROGUE_PROSTHETIC_STEEL

/obj/item/contraption/goldprosthetic/rogue_kit_material()
	return ROGUE_PROSTHETIC_GOLD

/obj/item/contraption/rogue_prosthetic_zone()
	return rogue_kit_material() ? rogue_limb_zone : null

/obj/item/contraption/rogue_prosthetic_material()
	return rogue_kit_material() || ..()

/obj/item/contraption/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return rogue_prosthetic_attachment(interacting_with, user) || ..()

/// Ratwood attack_self(): "Choose the side and the limb".
/obj/item/contraption/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !rogue_kit_material() || rogue_limb_zone)
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_choose_limb), user)
	return TRUE

/// The contraption becomes Ratwood's limb of its metal where the porter brings that limb; otherwise it is shaped into the limb
/// itself, with Ratwood's name, words and sprite for it.
/obj/item/contraption/proc/rogue_choose_limb(mob/user)
	var/static/list/choices = list("Left Arm" = BODY_ZONE_L_ARM, "Right Arm" = BODY_ZONE_R_ARM, "Left Leg" = BODY_ZONE_L_LEG, "Right Leg" = BODY_ZONE_R_LEG)
	var/choice = tgui_input_list(user, "Choose the side and the limb", name, choices)
	if(!choice || QDELETED(src) || rogue_limb_zone || !user.is_holding(src))
		return
	var/zone = choices[choice]
	var/material = rogue_kit_material()
	var/ratwood_type = text2path(rogue_ratwood_prosthetic_path(material, zone))
	if(ratwood_type)
		var/obj/item/made = new ratwood_type(drop_location())
		qdel(src)
		user.put_in_hands(made)
		return
	rogue_limb_zone = zone
	var/arm = zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_R_ARM
	var/side = (zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_L_LEG) ? "left" : "right"
	var/limb = arm ? "arm" : "leg"
	switch(material)
		if(ROGUE_PROSTHETIC_BRONZE)
			name = "bronze [side] [limb]"
			desc = "A replacement [side] [limb], engineered out of bronze."
			icon_state = "bp_[limb]"
		if(ROGUE_PROSTHETIC_IRON)
			name = "iron [side] [limb]"
			desc = "A [side] [limb] of iron."
			icon_state = "pri_[limb]"
		if(ROGUE_PROSTHETIC_STEEL)
			name = "steel [side] [limb]"
			desc = "A [side] [limb] of steel."
			icon_state = "prs_[limb]"
		if(ROGUE_PROSTHETIC_GOLD)
			name = "golden [side] [limb]"
			desc = "A [side] [limb] of cogs and gold."
			icon_state = "prc_[limb]"
	update_appearance()
	to_chat(user, span_notice("I shape [src]."))

/// Ratwood's path of the prosthetic of a metal for a zone (bronzeleft, bronzeright, iron, steel, gold).
/proc/rogue_ratwood_prosthetic_path(material, zone)
	var/static/list/limbs = list(BODY_ZONE_L_ARM = "l_arm", BODY_ZONE_R_ARM = "r_arm", BODY_ZONE_L_LEG = "l_leg", BODY_ZONE_R_LEG = "r_leg")
	var/kind = material
	if(material == ROGUE_PROSTHETIC_BRONZE)
		kind = (zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_L_LEG) ? "bronzeleft" : "bronzeright"
	return "/obj/item/bodypart/[limbs[zone]]/prosthetic/[kind]"

/obj/item/bodypart
	/// The prosthetic this limb was made from: it comes back when the limb comes off.
	var/datum/weakref/rogue_prosthetic_kit
	/// Ratwood brute_reduction and burn_reduction: the damage of each hit this limb shrugs off.
	var/rogue_brute_reduction = 0
	var/rogue_burn_reduction = 0

/// Made from a prosthetic: its name and words, Ratwood's toughness, reductions and slowness of its material; the prosthetic
/// waits inside until the limb comes off.
/obj/item/bodypart/proc/rogue_prosthetic_from(obj/item/kit)
	var/material = kit.rogue_prosthetic_material()
	name = kit.name
	desc = kit.desc
	max_damage = rogue_prosthetic_max_damage(material, body_zone)
	rogue_brute_reduction = rogue_prosthetic_reduction(material)
	rogue_burn_reduction = rogue_brute_reduction
	var/obj/item/bodypart/leg/leg = src
	if(istype(leg))
		leg.speed_modifier = rogue_prosthetic_slowdown(material)
	kit.forceMove(src)
	rogue_prosthetic_kit = WEAKREF(kit)
	RegisterSignal(src, COMSIG_BODYPART_REMOVED, PROC_REF(rogue_prosthetic_removed))

/// The limb came off: once it lies loose it is the prosthetic again. Struck off, it leaves no bleeding stump.
/obj/item/bodypart/proc/rogue_prosthetic_removed(datum/source, mob/living/carbon/old_owner, special, dismembered)
	SIGNAL_HANDLER
	if(dismembered && old_owner)
		old_owner.rogue_prosthetic_lost_at = world.time
	addtimer(CALLBACK(src, PROC_REF(rogue_revert_prosthetic)), 0, TIMER_DELETE_ME)

/// The prosthetic comes out where the limb lies, and the limb is gone; a limb put back on at once stays.
/obj/item/bodypart/proc/rogue_revert_prosthetic()
	if(QDELETED(src) || owner)
		return
	var/atom/spot = drop_location()
	if(!spot)
		return
	var/obj/item/kit = rogue_prosthetic_kit?.resolve()
	rogue_prosthetic_kit = null
	if(kit && kit.loc == src)
		kit.forceMove(spot)
	qdel(src)

/// The real limbs of the prosthetics. Of wood: TG's peg limbs - wood, no flesh, blood or bone, an arm's clumsy fingers - with no
/// weakness of TG's to blows and fire, as Ratwood's have none.
/obj/item/bodypart/arm/left/ghetto/rogue_prosthetic
	name = "wooden left arm"
	brute_modifier = 1
	burn_modifier = 1
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

/obj/item/bodypart/arm/right/ghetto/rogue_prosthetic
	name = "wooden right arm"
	brute_modifier = 1
	burn_modifier = 1
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

/obj/item/bodypart/leg/left/ghetto/rogue_prosthetic
	name = "wooden left leg"
	brute_modifier = 1
	burn_modifier = 1
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

/obj/item/bodypart/leg/right/ghetto/rogue_prosthetic
	name = "wooden right leg"
	brute_modifier = 1
	burn_modifier = 1
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

/// Of metal: TG's surplus prosthetics - metal, jointed, nothing living in them - that shrug off a share of each hit.
/obj/item/bodypart/arm/left/robot/surplus/rogue_prosthetic
	name = "metal left arm"

/obj/item/bodypart/arm/left/robot/surplus/rogue_prosthetic/receive_damage(brute = 0, burn = 0, blocked = 0, updating_health = TRUE, forced = FALSE, required_bodytype = null, wound_bonus = 0, exposed_wound_bonus = 0, sharpness = NONE, attack_direction = null, damage_source, wound_clothing = TRUE)
	return ..(max(brute - rogue_brute_reduction, 0), max(burn - rogue_burn_reduction, 0), blocked, updating_health, forced, required_bodytype, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, damage_source, wound_clothing)

/obj/item/bodypart/arm/right/robot/surplus/rogue_prosthetic
	name = "metal right arm"

/obj/item/bodypart/arm/right/robot/surplus/rogue_prosthetic/receive_damage(brute = 0, burn = 0, blocked = 0, updating_health = TRUE, forced = FALSE, required_bodytype = null, wound_bonus = 0, exposed_wound_bonus = 0, sharpness = NONE, attack_direction = null, damage_source, wound_clothing = TRUE)
	return ..(max(brute - rogue_brute_reduction, 0), max(burn - rogue_burn_reduction, 0), blocked, updating_health, forced, required_bodytype, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, damage_source, wound_clothing)

/obj/item/bodypart/leg/left/robot/surplus/rogue_prosthetic
	name = "metal left leg"

/obj/item/bodypart/leg/left/robot/surplus/rogue_prosthetic/receive_damage(brute = 0, burn = 0, blocked = 0, updating_health = TRUE, forced = FALSE, required_bodytype = null, wound_bonus = 0, exposed_wound_bonus = 0, sharpness = NONE, attack_direction = null, damage_source, wound_clothing = TRUE)
	return ..(max(brute - rogue_brute_reduction, 0), max(burn - rogue_burn_reduction, 0), blocked, updating_health, forced, required_bodytype, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, damage_source, wound_clothing)

/obj/item/bodypart/leg/right/robot/surplus/rogue_prosthetic
	name = "metal right leg"

/obj/item/bodypart/leg/right/robot/surplus/rogue_prosthetic/receive_damage(brute = 0, burn = 0, blocked = 0, updating_health = TRUE, forced = FALSE, required_bodytype = null, wound_bonus = 0, exposed_wound_bonus = 0, sharpness = NONE, attack_direction = null, damage_source, wound_clothing = TRUE)
	return ..(max(brute - rogue_brute_reduction, 0), max(burn - rogue_burn_reduction, 0), blocked, updating_health, forced, required_bodytype, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, damage_source, wound_clothing)
