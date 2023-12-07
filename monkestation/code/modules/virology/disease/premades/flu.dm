/datum/disease/advanced/premade/cold
	name = "Common Cold"
	form = "Virus"
	category = DISEASE_COLD

	symptoms = list(
		new /datum/symptom/cough,
		new /datum/symptom/sneeze,
		new /datum/symptom/fridge,
	)
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	robustness = 45
	
	infectionchance = 70
	infectionchance_base = 86
	can_kill = list("Bacteria")
