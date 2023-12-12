/datum/disease/advanced/premade/decloning
	name = "Severe Anxiety"
	form = "Infection"
	origin = "Social Settings"
	category = DISEASE_ANXIETY

	symptoms = list(
		new /datum/symptom/anxiety
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 90
	strength = 100

	infectionchance = 0
	infectionchance_base = 0
