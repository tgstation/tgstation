/datum/scripture/create_structure/interdiction
	name = "Interdiction Lens"
	desc = "Creates a device that will slow non servants in the area and damage mechanised exosuits. Requires power from a sigil of transmission."
	tip = "Construct interdiction lens to slow down a hostile assault."
	button_icon_state = "Interdiction Lens"
	power_cost = 500
	invocation_time = 8 SECONDS
	invocation_text = list("Oh great lord...", "may your divinity block the outsiders.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES
