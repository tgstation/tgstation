
// Optional properties, not guaranteed to be present on all materials
/// If a material has this property, it is flammable and has reduced fire protection.
/datum/material_property/flammability
	name = "Flammability"
	id = MATERIAL_FLAMMABILITY

/datum/material_property/flammability/get_descriptor(value)
	switch(value)
		if (0)
			return "nonflammable"
		if (0 to 1)
			return "mostly nonflammable"
		if (1 to 2)
			return "mildly nonflammable"
		if (2 to 3)
			return "somewhat flammable"
		if (3 to 4)
			return "flammable"
		if (4 to 6)
			return "highly flammable"
		if (6 to 8)
			return "extremely flammable"
		if (8 to INFINITY)
			return "insanely flammable"

// Average value of 4 would equate to URANIUM_IRRADIATION_CHANCE radioactivity
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

/datum/material_property/radioactivity/proc/on_applied(datum/material/source, atom/new_atom, mat_amount, multiplier)
	SIGNAL_HANDLER
	// Uranium structures should irradiate, but not items, because item irradiation is a lot more annoying.
	if (!isitem(new_atom))
		new_atom.AddElement(/datum/element/radioactive, chance = source.get_property(id) / URANIUM_RADIOACTIVITY * URANIUM_IRRADIATION_CHANCE * multiplier)

/datum/material_property/radioactivity/proc/on_removed(datum/material/source, atom/old_atom, mat_amount, multiplier)
	SIGNAL_HANDLER

	if (!isitem(old_aotm))
		old_atom.RemoveElement(/datum/element/radioactive, chance = source.get_property(id) / URANIUM_RADIOACTIVITY * URANIUM_IRRADIATION_CHANCE * multiplier)

#undef URANIUM_RADIOACTIVITY
