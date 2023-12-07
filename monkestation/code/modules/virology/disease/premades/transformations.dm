/datum/disease/advanced/premade/gondola
	name = "Gondola Transformation"
	form = "Gondola Cells"
	origin = "Gondola Meat"
	category = DISEASE_GONDOLA

	symptoms = list(
		new /datum/symptom/transformation/gondola
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0

/datum/disease/advanced/premade/gondola/digital
	category = DISEASE_GONDOLA_DIGITAL

	symptoms = list(
		new /datum/symptom/transformation/gondola/digital
	)
