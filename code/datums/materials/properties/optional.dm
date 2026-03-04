
// Optional properties, not guaranteed to be present on all materials

/// Minimum flammability value required to make an object made out of this material flammable
#define MINIMUM_FLAMMABILITY 4

/// If a material has this property, it is flammable and has reduced fire protection.
/datum/material_property/flammability
	name = "Flammability"
	id = MATERIAL_FLAMMABILITY

/datum/material_property/flammability/get_descriptor(value)
	switch(value)
		if (0)
			return "fireproof"
		if (0 to 1)
			return "nonflammable"
		if (1 to 2)
			return "mostly nonflammable"
		if (2 to 3)
			return "slightly fire-resistant"
		if (3 to 4)
			return "flammable"
		if (4 to 6)
			return "highly flammable"
		if (6 to 8)
			return "extremely flammable"
		if (8 to INFINITY)
			return "insanely flammable"

/datum/material_property/flammability/attach_to(datum/material/material)
	. = ..()
	RegisterSignal(material, COMSIG_MATERIAL_APPLIED, PROC_REF(on_applied))
	RegisterSignal(material, COMSIG_MATERIAL_REMOVED, PROC_REF(on_removed))

/datum/material_property/flammability/proc/on_applied(datum/material/source, atom/new_atom, mat_amount, multiplier, from_slot)
	SIGNAL_HANDLER

	if (isobj(new_atom) && (new_atom.material_flags & MATERIAL_AFFECT_STATISTICS) && source.get_property(id) >= MINIMUM_FLAMMABILITY)
		new_atom.resistance_flags |= FLAMMABLE

/datum/material_property/flammability/proc/on_removed(datum/material/source, atom/old_atom, mat_amount, multiplier, from_slot)
	SIGNAL_HANDLER

	if (isobj(old_atom) && (old_atom.material_flags & MATERIAL_AFFECT_STATISTICS) && source.get_property(id) >= MINIMUM_FLAMMABILITY && !(initial(old_atom.resistance_flags) & FLAMMABLE))
		old_atom.resistance_flags &= ~FLAMMABLE

#undef MINIMUM_FLAMMABILITY

// An average value of 4 would equate to URANIUM_IRRADIATION_CHANCE radioactivity
#define URANIUM_RADIOACTIVITY 4

/datum/material_property/radioactivity
	name = "Radioactivity"
	id = MATERIAL_RADIOACTIVITY

/datum/material_property/radioactivity/get_descriptor(value)
	switch(value)
		if (0)
			return null
		if (0 to 2)
			return "slightly radioactive"
		if (2 to 4)
			return "radioactive"
		if (4 to 6)
			return "highly radioactive"
		if (6 to 8)
			return "extremely radioactive"
		if (8 to INFINITY)
			return "insanely radioactive"

/datum/material_property/radioactivity/attach_to(datum/material/material)
	. = ..()
	RegisterSignal(material, COMSIG_MATERIAL_APPLIED, PROC_REF(on_applied))
	RegisterSignal(material, COMSIG_MATERIAL_REMOVED, PROC_REF(on_removed))

/datum/material_property/radioactivity/proc/on_applied(datum/material/source, atom/new_atom, mat_amount, multiplier, from_slot)
	SIGNAL_HANDLER
	// Uranium structures should irradiate, but not items, because item irradiation is a lot more annoying.
	if (!isitem(new_atom))
		new_atom.AddElement(/datum/element/radioactive, chance = source.get_property(id) / URANIUM_RADIOACTIVITY * URANIUM_IRRADIATION_CHANCE * multiplier)

/datum/material_property/radioactivity/proc/on_removed(datum/material/source, atom/old_atom, mat_amount, multiplier, from_slot)
	SIGNAL_HANDLER

	if (!isitem(old_atom))
		old_atom.RemoveElement(/datum/element/radioactive, chance = source.get_property(id) / URANIUM_RADIOACTIVITY * URANIUM_IRRADIATION_CHANCE * multiplier)

#undef URANIUM_RADIOACTIVITY

/// Applies firestacks to affected mobs
/datum/material_property/firestacker
	name = "Igniting"
	id = MATERIAL_FIRESTACKER

/datum/material_property/firestacker/get_descriptor(value)
	return "igniting"

/datum/material_property/firestacker/get_tooltip(value)
	return "Applies [value] firestacks to affected mobs"

/datum/material_property/firestacker/attach_to(datum/material/material)
	. = ..()
	material.track_flags |= MATERIAL_TRACK_CONTACT | MATERIAL_TRACK_IMPACT
	var/static/list/interaction_signals = list(
		COMSIG_MATERIAL_EFFECT_TOUCH,
		COMSIG_MATERIAL_EFFECT_STEP,
		COMSIG_MATERIAL_EFFECT_HIT,
		COMSIG_MATERIAL_EFFECT_THROW_IMPACT,
	)
	RegisterSignals(material, interaction_signals, PROC_REF(on_contact))

/datum/material_property/firestacker/proc/on_contact(datum/material/source, atom/object, mob/living/target, mob/living/user, def_zone, skin_contact)
	SIGNAL_HANDLER

	// Floors don't trigger if you're wearing shoes because it'd be too cancer
	if (isfloorturf(object) && !skin_contact && !source.get_property(MATERIAL_PENETRATING))
		return

	if (isliving(target))
		target.adjust_fire_stacks(source.get_property(id))

/// Deals additional burn damage to vampires, property value determines damage
/datum/material_property/vampires_bane
	name = "Vampires' Bane"
	id = MATERIAL_VAMPIRES_BANE

/datum/material_property/vampires_bane/get_descriptor(value)
	return "vampires' bane"

/datum/material_property/vampires_bane/get_tooltip(value)
	return "Deals [value] additional burn damage to vampires on contact"

/datum/material_property/vampires_bane/attach_to(datum/material/material)
	. = ..()
	material.track_flags |= MATERIAL_TRACK_CONTACT | MATERIAL_TRACK_IMPACT
	var/static/list/interaction_signals = list(
		COMSIG_MATERIAL_EFFECT_TOUCH,
		COMSIG_MATERIAL_EFFECT_STEP,
		COMSIG_MATERIAL_EFFECT_HIT,
		COMSIG_MATERIAL_EFFECT_THROW_IMPACT,
	)
	RegisterSignals(material, interaction_signals, PROC_REF(on_contact))

/datum/material_property/vampires_bane/proc/on_contact(datum/material/source, atom/object, mob/living/target, mob/living/user, def_zone, skin_contact)
	SIGNAL_HANDLER

	if (!isvampire(target) || (!skin_contact && !source.get_property(MATERIAL_PENETRATING)))
		return

	to_chat(target, span_userdanger("Contact with [object] sears your undead flesh!"))
	target.apply_damage(source.get_property(id), BURN, def_zone, wound_bonus = 10, wound_clothing = FALSE)

/// Teleports targets who come into active contact with the material around, property value determines teleport radius and damage taken per teleport
/datum/material_property/teleporting
	name = "Teleporting"
	id = MATERIAL_TELEPORTING

/datum/material_property/teleporting/get_descriptor(value)
	return "dimensionally unstable"

/datum/material_property/teleporting/get_tooltip(value)
	return "Randomly teleports whoever comes into contact with it in a [value] tile radius"

/datum/material_property/teleporting/attach_to(datum/material/material)
	. = ..()
	material.track_flags |= MATERIAL_TRACK_CONTACT | MATERIAL_TRACK_IMPACT
	var/static/list/interaction_signals = list(
		COMSIG_MATERIAL_EFFECT_TOUCH,
		COMSIG_MATERIAL_EFFECT_STEP,
		COMSIG_MATERIAL_EFFECT_HIT,
	)
	RegisterSignals(material, interaction_signals, PROC_REF(on_contact))
	RegisterSignal(material, COMSIG_MATERIAL_EFFECT_THROW_IMPACT, PROC_REF(on_impact))

/datum/material_property/teleporting/proc/on_contact(datum/material/source, atom/object, atom/target, mob/living/user, def_zone, skin_contact)
	SIGNAL_HANDLER

	if (!ismovable(target))
		return

	// Floors don't trigger if you're wearing shoes because it'd be too cancer
	if (isfloorturf(object) && !skin_contact && !source.get_property(MATERIAL_PENETRATING))
		return

	var/value = source.get_property(id)
	do_teleport(target, get_turf(target), value, channel = TELEPORT_CHANNEL_BLUESPACE)
	if (object.uses_integrity)
		object.take_damage(object.max_integrity * value * 0.025)

/datum/material_property/teleporting/proc/on_impact(datum/material/source, atom/object, atom/target, mob/living/user, def_zone, skin_contact)
	SIGNAL_HANDLER

	// Unless its a specialized weapon, don't teleport the target for balance reasons
	if (object.has_material_slots() || source.get_property(MATERIAL_PENETRATING))
		on_contact(source, object, target, user, def_zone, skin_contact)

/// Makes all contact count as skin contact
/datum/material_property/penetrating
	name = "Penetrating"
	id = MATERIAL_PENETRATING

/datum/material_property/penetrating/get_descriptor(value)
	return "dimensionally penetrating"

/datum/material_property/penetrating/get_tooltip(value)
	return "Ignores all means of skin protection when triggering other material effects"
