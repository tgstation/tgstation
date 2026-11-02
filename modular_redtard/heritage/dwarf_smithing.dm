/// Ratwood's dwarves know dwarvish smithing from birth (TRAIT_DWARF_REPAIR, Dwarvish Knowledge: the anvil shows them the
/// dwarven armor and mauls). Vibelin's dwarf kin, whose Vibelin path is a dwarf's, know it too (owner, 2026-11-01).
/datum/species/New()
	. = ..()
	if(rogue_vibelin_type && findtext(rogue_vibelin_type, "/datum/species/dwarf") == 1)
		inherent_traits = inherent_traits + TRAIT_DWARF_REPAIR
