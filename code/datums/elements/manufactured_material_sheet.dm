/datum/element/manufactured_material_sheet

/datum/element/manufactured_material_sheet/Attach(datum/target)
	. = ..()
	if (!istype(target, /obj/item/stack/sheet))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_SHEET_SMELTED, REF(src))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	
/datum/element/manufactured_material_sheet/Detach(datum/source)
	REMOVE_TRAIT(source, TRAIT_SHEET_SMELTED, REF(src))
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	return ..()

/// Assure your customers that this alloy is 100% pure and ~30% free of enforced labour
/datum/element/manufactured_material_sheet/proc/on_examined(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It has been embossed with a manufacturer's mark of guaranteed quality.")
