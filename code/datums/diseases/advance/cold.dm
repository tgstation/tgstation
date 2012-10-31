/datum/disease/advance/cold/New(var/process = 1, var/datum/disease/advance/D)
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	..(process, D)
