/datum/disease/advanced/premade/decloning
	name = "Cellular Degeneration"
	form = "Virus"
	origin = "Instability"
	category = DISEASE_DECLONING

	symptoms = list(
		new /datum/symptom/mutation
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 90
	strength = 100

	infectionchance = 0
	infectionchance_base = 0
	can_kill = list("Bacteria")
