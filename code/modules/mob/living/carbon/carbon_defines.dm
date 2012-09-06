/mob/living/carbon/
	gender = MALE
	var/list/stomach_contents = list()

	var/brain_op_stage = 0.0
	var/eye_op_stage = 0.0
	var/appendix_op_stage = 0.0

	var/antibodies = 0

	var/silent = null 		//Can't talk. Value goes down every life proc.
	var/last_eating = 0 	//Not sure what this does... I found it hidden in food.dm

	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick
