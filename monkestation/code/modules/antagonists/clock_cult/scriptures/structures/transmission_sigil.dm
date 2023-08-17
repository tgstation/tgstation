/datum/scripture/create_structure/sigil_transmission
	name = "Sigil of Transmission"
	desc = "Summons a sigil of transmission, required to power clockwork structures. Will also drain power from charged objects."
	tip = "Power structures using this."
	button_icon_state = "Sigil of Transmission"
	power_cost = 100
	invocation_time = 5 SECONDS
	invocation_text = list("Oh great holy one...", "your energy...", "the power of the holy light!")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/transmission
	category = SPELLTYPE_STRUCTURES
