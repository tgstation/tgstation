/*				CARGO OBJECTIVES				*/

/datum/objective/crew/petsplosion
	explanation_text = "Ensure there are at least (If you see this, yell on citadels discord in the development discussion channel) pets on the station by the end of the shift. Interpret this as you wish."
	jobs = "quartermaster,cargotechnician"

/datum/objective/crew/petsplosion/New()
	. = ..()
	target_amount = rand(10,30)
	update_explanation_text()

/datum/objective/crew/petsplosion/update_explanation_text()
	. = ..()
	explanation_text = "Ensure there are at least [target_amount] pets on the station by the end of the shift. Interpret this as you wish."

/datum/objective/crew/petsplosion/check_completion()
	var/petcount = target_amount
	for(var/mob/living/simple_animal/pet/P in GLOB.mob_list)
		if(!(P.stat == DEAD))
			if(P.z == SSmapping.station_start || SSshuttle.emergency.shuttle_areas[get_area(P)])
				petcount--
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(!(H.stat == DEAD))
			if(H.z == SSmapping.station_start || SSshuttle.emergency.shuttle_areas[get_area(H)])
				if(istype(H.wear_neck, /obj/item/clothing/neck/petcollar))
					petcount--
	if(petcount <= 0)
		return TRUE
	else
		return FALSE

/datum/objective/crew/points //ported from old hippie
	explanation_text = "Make sure the station has at least (Something broke, report this to the development discussion channel of citadels discord) supply points at the end of the shift."
	jobs = "quartermaster,cargotechnician"

/datum/objective/crew/points/New()
	. = ..()
	target_amount = rand(25000,100000)
	update_explanation_text()

/datum/objective/crew/points/update_explanation_text()
	. = ..()
	explanation_text = "Make sure the station has at least [target_amount] supply points at the end of the shift."

/datum/objective/crew/points/check_completion()
	if(SSshuttle.points >= target_amount)
		return TRUE
	else
		return FALSE

/datum/objective/crew/bubblegum
	explanation_text = "Ensure Bubblegum is dead at the end of the shift."
	jobs = "shaftminer"

/datum/objective/crew/bubblegum/check_completion()
	for(var/mob/living/simple_animal/hostile/megafauna/bubblegum/B in GLOB.mob_list)
		if(!(B.stat == DEAD))
			return FALSE
	return TRUE

/datum/objective/crew/fatstacks //ported from old hippie
	explanation_text = "Have at least (something broke, report this to the development discussion channel of citadels discord) mining points on your ID at the end of the shift."
	jobs = "shaftminer"

/datum/objective/crew/fatstacks/New()
	. = ..()
	target_amount = rand(15000,50000)
	update_explanation_text()

/datum/objective/crew/fatstacks/update_explanation_text()
	. = ..()
	explanation_text = "Have at least [target_amount] mining points on your ID at the end of the shift."

/datum/objective/crew/fatstacks/check_completion()
	if(owner && owner.current)
		var/mob/living/carbon/human/H = owner.current
		var/obj/item/card/id/theID = H.get_idcard()
		if(istype(theID))
			if(theID.mining_points >= target_amount)
				return TRUE
	return FALSE
