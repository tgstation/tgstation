/datum/disease/advanced/premade/gondola
	name = "Gondola Transformation"
	form = "Gondola Cells"
	origin = "Gondola Toxins"
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

/datum/disease/advanced/premade/xeno
	name = "Xenomorph Transformation"
	form = "Foreign Cells"
	origin = "UNKNOWN"
	category = DISEASE_XENO

	symptoms = list(
		new /datum/symptom/transformation/xeno
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0

/datum/disease/advanced/premade/corgi
	name = "Puppification"
	form = "Puppy Cells"
	origin = "Ian"
	category = DISEASE_CORGI

	symptoms = list(
		new /datum/symptom/transformation/corgi
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0

/datum/disease/advanced/premade/slime
	name = "Slime Syndrome"
	form = "Simplified Cells"
	origin = "Slime Colonies"
	category = DISEASE_SLIME

	symptoms = list(
		new /datum/symptom/transformation/slime
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0

/datum/disease/advanced/premade/morph
	name = "Gluttony"
	form = "Hungering Cells"
	origin = "The Hivemind"
	category = DISEASE_MORPH

	symptoms = list(
		new /datum/symptom/transformation/morph
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0

/datum/disease/advanced/premade/robot
	name = "Nanite Conversion"
	form = "Nanites"
	origin = "Swarmers"
	category = DISEASE_ROBOT

	symptoms = list(
		new /datum/symptom/transformation/robot
	)
	spread_flags = DISEASE_SPREAD_BLOOD
	robustness = 75
	
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
