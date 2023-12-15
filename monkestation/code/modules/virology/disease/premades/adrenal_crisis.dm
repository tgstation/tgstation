/datum/disease/advanced/premade/adrenal_crisis
	name = "Adrenal Crisis"
	origin = "Trauma"
	category = DISEASE_TRAUMA

	symptoms = list(
		new /datum/symptom/bad_adrenaline
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 90
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0

