/mob/living
	var/t_plasma = null
	var/t_oxygen = null
	var/t_sl_gas = null
	var/t_n2 = null
	var/now_pushing = null
	var/cameraFollow = null
	var/age = null


// lists used to cache overlays
/mob/living/var/list/body_overlays_standing	= list()
/mob/living/var/list/body_overlays_lying	= list()
/mob/living/var/list/clothing_overlays		= list()

// This var describes whether the mob visually appears to be lying.
// This will be used to only update lying status when necessary.
/mob/living/var/visual_lying 				= 0