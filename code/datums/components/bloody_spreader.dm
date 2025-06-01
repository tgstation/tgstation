/datum/component/bloody_spreader
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	// How many bloodening instances are left. Deleted on zero.
	var/blood_left
	// We will spread this blood DNA to targets!
	var/list/blood_dna
	// Blood splashed around everywhere will carry these diseases. Oh no...
	var/list/diseases

/datum/component/bloody_spreader/Initialize(blood_left = INFINITY, list/blood_dna = list(get_blood_type(BLOOD_TYPE_MEAT).dna_string = get_blood_type(BLOOD_TYPE_MEAT)), list/diseases = null)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/static/list/hand_signals = list(
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_ATTACK_SELF_SECONDARY,
		COMSIG_ITEM_DROPPED,
	)
	RegisterSignals(parent, hand_signals, PROC_REF(spread_to_hands))

	if (isstructure(parent))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(spread_to_hands))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(spread_to_hands))

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(spread_to_atom))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_ATOM, PROC_REF(spread_to_atom))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(spread_to_atom))
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(spread_to_atom))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(spread_to_atom))
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(spread_to_atom))
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(spread_to_atom))

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(spread_on_equip))
	RegisterSignal(parent, COMSIG_ATOM_STORED_ITEM, PROC_REF(spread_on_stored))

	if(isclothing(parent))
		parent.AddComponent(/datum/component/bloodysoles)

	src.blood_left = blood_left
	src.blood_dna = blood_dna
	src.diseases = diseases

/datum/component/bloody_spreader/InheritComponent(/datum/component/new_comp, i_am_original, blood_left = 0, list/blood_dna = null, list/diseases = null)
	src.blood_dna |= blood_dna
	src.diseases |= diseases
	if(src.blood_left >= INFINITY)
		return
	src.blood_left += blood_left

/// Apply blood to the mob who interacted with us
/datum/component/bloody_spreader/proc/spread_to_hands(atom/parent, mob/bloody_fool)
	SIGNAL_HANDLER

	if(ishuman(bloody_fool))
		var/mob/living/carbon/human/as_human = bloody_fool
		as_human.add_blood_DNA_to_items(blood_dna, ITEM_SLOT_GLOVES)
		blood_left -= 3
	else
		bloody_fool.add_blood_DNA(blood_dna, diseases)
		blood_left -= 1

	if(blood_left <= 0)
		qdel(src)

/// Apply blood to the atom that interacted with us, ignoring that they may be human
/datum/component/bloody_spreader/proc/spread_to_atom(atom/parent, atom/bloody_fool)
	SIGNAL_HANDLER

	bloody_fool.add_blood_DNA(blood_dna, diseases)
	blood_left -= 1

	if(blood_left <= 0)
		qdel(src)

/// Apply blood to both the item put into us, and the mob who put it there
/datum/component/bloody_spreader/proc/spread_on_stored(atom/parent, obj/item/stored, mob/user)
	SIGNAL_HANDLER

	spread_to_atom(parent, stored)
	if (blood_left > 0)
		spread_to_hands(parent, user)

/// Apply blood to the slots that our item covers when equipped
/datum/component/bloody_spreader/proc/spread_on_equip(obj/item/parent, mob/equipper, slot)
	SIGNAL_HANDLER

	if (!ishuman(equipper))
		equipper.add_blood_DNA(blood_dna, diseases)
		blood_left -= 1
		if(blood_left <= 0)
			qdel(src)
		return

	var/mob/living/carbon/human/as_human = equipper

	var/blood_slots = ITEM_SLOT_GLOVES
	var/blood_lost = 3
	if (slot & (ITEM_SLOT_LPOCKET | ITEM_SLOT_RPOCKET | ITEM_SLOT_ID))
		blood_slots |= ITEM_SLOT_ICLOTHING
		blood_lost += 1
	else if (slot & (ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT | ITEM_SLOT_BACK | ITEM_SLOT_NECK))
		blood_slots |= ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING // Will only actually bloody one of these, thus blood_lost is increased by one instead of two
		blood_lost += 1

	if (!(slot & ITEM_SLOT_HANDS))
		var/list/equipment = as_human.get_equipped_items()
		for (var/obj/item/equipped as anything in equipment)
			var/item_slot = as_human.get_slot_by_item(equipped)
			if ((item_slot & equipped.slot_flags) && (parent.body_parts_covered & equipped.body_parts_covered))
				if (!(blood_slots & item_slot))
					blood_lost += 1
				blood_slots |= item_slot

	if (blood_slots != ITEM_SLOT_GLOVES)
		blood_lost -= 1

	as_human.add_blood_DNA_to_items(blood_dna, blood_slots)
	blood_left -= blood_lost

	if(blood_left <= 0)
		qdel(src)
