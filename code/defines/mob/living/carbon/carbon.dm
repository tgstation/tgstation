/mob/living/carbon/
	gender = MALE
	var/list/stomach_contents = list()

	var/brain_op_stage = 0.0
	var/eye_op_stage = 0.0
	var/appendix_op_stage = 0.0
	var/embryo_op_stage = 0.0
	var/face_op_stage = 0.0

	var/datum/disease2/disease/virus2 = null
	var/list/datum/disease2/disease/resistances2 = list()
	var/antibodies = 0

	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick

mob
	var/list/disease_symptoms = 0 // a list of disease-incurred symptoms