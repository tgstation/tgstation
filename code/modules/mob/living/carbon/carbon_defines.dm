/mob/living/carbon/
	gender = MALE
	var/list/stomach_contents = list()
	var/brain_op_stage = 0.0
/*
	var/eye_op_stage = 0.0
	var/appendix_op_stage = 0.0
*/
	var/datum/disease2/disease/virus2 = null
	var/list/datum/disease2/disease/resistances2 = list()

	var/antibodies = 0

	var/silent = null 		//Can't talk. Value goes down every life proc.
	var/last_eating = 0 	//Not sure what this does... I found it hidden in food.dm

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick
	// total amount of wounds on mob, used to spread out healing and the like over all wounds
	var/number_wounds = 0