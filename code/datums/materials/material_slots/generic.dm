// Generic slots for weapons

/// Generic main/parent type for all weapon heads
/datum/material_slot/weapon_head
	requirement_type = /datum/material_requirement/solid_material

/datum/material_slot/weapon_head/on_applied(obj/item/target, datum/material/material, amount, multiplier)
	// Weapon head controls strength and conductivity
	if (!(target.material_flags & MATERIAL_EFFECTS))
		return FALSE

	// Effect signals
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(on_throw_impact_living))
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))
	RegisterSignal(target, COMSIG_ITEM_ATTACK_ATOM, PROC_REF(on_item_attack))
	RegisterSignal(target, COMSIG_ITEM_ATTACK_ZONE, PROC_REF(on_item_attack_living))

	if (!(target.material_flags & MATERIAL_AFFECT_STATISTICS))
		return FALSE

	// Damage
	target.change_material_strength(material, amount, multiplier)

	// Conductivity
	var/conductivity = material.get_property(MATERIAL_ELECTRICAL)
	var/siemens_modifier = round(max(0, conductivity - 1) ** 1.18 * 0.15, 0.01)
	var/siemens_mult = 1 + (siemens_modifier - 1) * multiplier
	target.siemens_coefficient *= max(0, siemens_mult)

	if (target.siemens_coefficient == 0)
		target.obj_flags &= ~CONDUCTS_ELECTRICITY

/datum/material_slot/weapon_head/on_removed(obj/item/target, datum/material/material, amount, multiplier)
	var/static/list/interaction_signals = list(
		COMSIG_MOVABLE_IMPACT,
		COMSIG_MOVABLE_IMPACT_ZONE,
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_ATOM,
		COMSIG_ITEM_ATTACK_ZONE,
	)
	UnregisterSignal(target, interaction_signals)

	if (!(target.material_flags & MATERIAL_AFFECT_STATISTICS) || !(target.material_flags & MATERIAL_EFFECTS))
		return FALSE

	// Damage
	target.change_material_strength(material, amount, multiplier, remove = TRUE)

	// Conductivity
	var/conductivity = material.get_property(MATERIAL_ELECTRICAL)
	var/siemens_modifier = round(max(0, conductivity - 1) ** 1.18 * 0.15, 0.01)
	var/siemens_mult = 1 + (siemens_modifier - 1) * multiplier
	if (siemens_mult > 0)
		target.siemens_coefficient /= siemens_mult

	if (target.siemens_coefficient > 0 && (initial(target.obj_flags) & CONDUCTS_ELECTRICITY) && !(target.obj_flags & CONDUCTS_ELECTRICITY))
		target.obj_flags |= CONDUCTS_ELECTRICITY

/datum/material_slot/weapon_head/proc/on_throw_impact(obj/item/source, atom/hit_atom, datum/thrownthing/throwing_datum, caught)
	SIGNAL_HANDLER
	if (!caught && !isliving(hit_atom))
		affect_throw_impact(source, hit_atom, astype(throwing_datum.thrower.resolve(), /mob/living))

/datum/material_slot/weapon_head/proc/on_item_attack(obj/item/source, atom/movable/target, mob/living/user)
	SIGNAL_HANDLER
	// Living mobs use a different signal
	if (!isliving(target))
		affect_target(source, target, user)

/datum/material_slot/weapon_head/proc/on_item_attack_living(obj/item/source, mob/living/target, mob/living/user, def_zone)
	SIGNAL_HANDLER

	var/has_contact = TRUE
	for (var/obj/item/worn_item in target.get_equipped_items(INCLUDE_ABSTRACT))
		if (worn_item.body_parts_covered & def_zone)
			has_contact = FALSE
			break

	affect_target(source, target, user, def_zone, has_contact)

/datum/material_slot/weapon_head/proc/on_throw_impact_living(obj/item/source, mob/living/target, def_zone, blocked, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER

	var/has_contact = TRUE
	for (var/obj/item/worn_item in target.get_equipped_items(INCLUDE_ABSTRACT))
		if (worn_item.body_parts_covered & def_zone)
			has_contact = FALSE
			break

	affect_throw_impact(source, target, astype(throwing_datum.thrower.resolve(), /mob/living), def_zone, has_contact)

/datum/material_slot/weapon_head/proc/affect_target(obj/item/source, atom/target, mob/living/user, def_zone, skin_contact = TRUE)
	var/datum/material/source_mat = SSmaterials.get_material(source.get_material_from_slot(type))
	SEND_SIGNAL(source_mat, COMSIG_MATERIAL_EFFECT_HIT, source, target, user, def_zone, skin_contact)

/datum/material_slot/weapon_head/proc/affect_throw_impact(obj/item/source, atom/target, mob/living/user, def_zone, skin_contact = TRUE)
	var/datum/material/source_mat = SSmaterials.get_material(source.get_material_from_slot(type))
	SEND_SIGNAL(source_mat, COMSIG_MATERIAL_EFFECT_THROW_IMPACT, source, target, user, def_zone, skin_contact)

/// Main type for all weapon handles
/datum/material_slot/handle
	requirement_type = /datum/material_requirement/solid_material

/datum/material_slot/handle/on_applied(obj/item/target, datum/material/material, amount, multiplier)
	// Handle controls integrity, armor, conductivity and wieldiness stats-wise
	if (!(target.material_flags & MATERIAL_EFFECTS))
		return FALSE

	// Effect signals
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))
	RegisterSignal(target, COMSIG_ITEM_ATTACK_ATOM, PROC_REF(on_item_attack))
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_item_attack_self))

	if (!(target.material_flags & MATERIAL_AFFECT_STATISTICS))
		return FALSE

	// Armor/integrity
	var/integrity_mod = material.get_property(MATERIAL_INTEGRITY)
	target.modify_max_integrity(ceil(target.max_integrity * integrity_mod))
	var/list/armor_mods = material.get_armor_modifiers(multiplier)
	target.set_armor(target.get_armor().generate_new_with_multipliers(armor_mods))

	// Conductivity
	var/conductivity = material.get_property(MATERIAL_ELECTRICAL)
	var/siemens_modifier = round(max(0, conductivity - 1) ** 1.18 * 0.15, 0.01)
	var/siemens_mult = 1 + (siemens_modifier - 1) * multiplier
	target.siemens_coefficient *= max(0, siemens_mult)

	if (target.siemens_coefficient == 0)
		target.obj_flags &= ~CONDUCTS_ELECTRICITY

	// Wielding
	var/density = material.get_property(MATERIAL_DENSITY)
	var/hardness = material.get_property(MATERIAL_HARDNESS)
	// Can be faster/slower by 2 dcs
	target.attack_speed += MATERIAL_PROPERTY_DIVERGENCE(density, 4, 6) * 0.5 * multiplier
	target.throw_range += ((hardness - 4) - (density - 4) * 2) * multiplier
	return FALSE

/datum/material_slot/handle/on_removed(obj/item/target, datum/material/material, amount, multiplier)
	UnregisterSignal(target, list(COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_ATOM, COMSIG_ITEM_ATTACK_SELF))

	if (!(target.material_flags & MATERIAL_AFFECT_STATISTICS) || !(target.material_flags & MATERIAL_EFFECTS))
		return FALSE

	// Armor/integrity
	var/integrity_mod = material.get_property(MATERIAL_INTEGRITY)

	target.modify_max_integrity(ceil(target.max_integrity * integrity_mod))
	var/list/armor_mods = material.get_armor_modifiers(multiplier)
	for (var/armor_type, value in armor_mods)
		if (value != 0) // Needs to be restored to initial values in finalize effects, sorry
			armor_mods[armor_type] = 1 / value
	target.set_armor(target.get_armor().generate_new_with_multipliers(armor_mods))

	// Conductivity
	var/conductivity = material.get_property(MATERIAL_ELECTRICAL)
	var/siemens_modifier = round(max(0, conductivity - 1) ** 1.18 * 0.15, 0.01)
	var/siemens_mult = 1 + (siemens_modifier - 1) * multiplier
	if (siemens_mult > 0)
		target.siemens_coefficient /= siemens_mult

	if (target.siemens_coefficient > 0 && (initial(target.obj_flags) & CONDUCTS_ELECTRICITY) && !(target.obj_flags & CONDUCTS_ELECTRICITY))
		target.obj_flags |= CONDUCTS_ELECTRICITY

	// Wielding
	var/density = material.get_property(MATERIAL_DENSITY)
	var/hardness = material.get_property(MATERIAL_HARDNESS)
	target.attack_speed -= MATERIAL_PROPERTY_DIVERGENCE(density, 4, 6) * 0.5 * multiplier
	target.throw_range -= ((hardness - 4) - (density - 4) * 2) * multiplier
	return FALSE

/datum/material_slot/handle/proc/on_item_attack(obj/item/source, atom/movable/target, mob/living/user)
	SIGNAL_HANDLER
	affect_user(source, user, user)

/datum/material_slot/handle/proc/on_item_attack_self(obj/item/source, mob/living/user)
	SIGNAL_HANDLER
	affect_user(source, user, user)

/datum/material_slot/handle/proc/on_throw_impact(obj/item/source, atom/hit_atom, datum/thrownthing/throwing_datum, caught)
	SIGNAL_HANDLER
	if (caught)
		affect_user(source, hit_atom, astype(throwing_datum.thrower.resolve(), /mob/living))

/datum/material_slot/handle/proc/affect_user(obj/item/source, mob/living/user, mob/living/initiator)
	var/datum/material/source_mat = SSmaterials.get_material(source.material_slots[type])
	var/arm_dir = IS_LEFT_INDEX(user.active_hand_index) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
	if (!ishuman(user))
		SEND_SIGNAL(source_mat, COMSIG_MATERIAL_EFFECT_TOUCH, source, user, initiator, arm_dir, TRUE)
		return

	var/mob/living/carbon/human/as_human = user
	var/obj/item/bodypart/hand = as_human.has_hand_for_held_index(as_human.get_held_index_of_item(source))
	if (!hand) // ???
		SEND_SIGNAL(source_mat, COMSIG_MATERIAL_EFFECT_TOUCH, source, user, initiator, arm_dir, FALSE) // ...no hand, no skin contact?
		return

	var/list/obj/item/hand_covers = as_human.get_clothing_on_part(hand)
	var/hand_covered = FALSE
	for (var/obj/item/worn_item in hand_covers)
		if (worn_item.body_parts_covered & HANDS)
			hand_covered = TRUE
			break

	SEND_SIGNAL(source_mat, COMSIG_MATERIAL_EFFECT_TOUCH, source, user, initiator, hand.body_zone, !hand_covered)
