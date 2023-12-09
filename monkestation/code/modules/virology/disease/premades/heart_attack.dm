/datum/disease/advanced/premade/heart_failure
	name = "Heart Eating Worms"
	form = "Worms"
	origin = "Heart Worms"
	category = DISEASE_HEART

	symptoms = list(
		new /datum/symptom/heart_failure
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
