/datum/scripture/create_structure/sigil_vitality
	name = "Vitality Matrix"
	desc = "Summons a vitality matrix, which drains the life force of non servants. Much less vitality is gained from simpler entities."
	tip = "If a fellow servant who is dead or mindless is placed on a rune, they will be restored. Bringing back the dead will cost Vitality."
	button_icon_state = "Sigil of Vitality"
	power_cost = 300
	invocation_time = 5 SECONDS
	invocation_text = list("My life in your hands.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/vitality
	cogs_required = 2
	category = SPELLTYPE_SERVITUDE
