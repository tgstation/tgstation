/datum/scripture/create_structure/sigil_submission
	name = "Sigil of Submission"
	desc = "Summons a sigil of submission, which will convert anyone placed on top of it to the faith of Rat'var after 8 seconds."
	tip = "Simply wait after placing a convertee on top, do not interact with the sigil."
	button_icon_state = "Sigil of Submission"
	power_cost = 250
	invocation_time = 5 SECONDS
	invocation_text = list("Relax you animal...", "for I shall show you the truth.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/submission
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE
