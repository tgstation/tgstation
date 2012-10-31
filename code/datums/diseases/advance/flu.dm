/datum/disease/advance/flu/New(var/process = 1, var/datum/disease/advance/D)
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	..(process, D)
