/datum/symptom/soda
	name = "Soda Intolerance"
	desc = "The virus consumes soda (if present) in the host's body, releasing toxins as a byproduct."
	illness = "Soda Intolerance"
	stealth = 1
	stage_speed = 2
	level = 6
	severity = 1
	base_message_chance = 20
	symptom_delay_min = 2
	symptom_delay_max = 3
	symptom_cure = null
	threshold_descs = list(
		"Stealth 4" = "This symptom no longer affects the severity of the virus",
	)

	var/list/required_reagents = list(/datum/reagent/consumable/space_cola, /datum/reagent/consumable/lemon_lime,
	/datum/reagent/consumable/pwr_game, /datum/reagent/consumable/dr_gibb, /datum/reagent/consumable/space_up, /datum/reagent/consumable/spacemountainwind,
	/datum/reagent/consumable/volt_energy, /datum/reagent/consumable/melon_soda, /datum/reagent/consumable/hakka_mate, /datum/reagent/consumable/ethanol/bitters_soda,
	/datum/reagent/consumable/cucumberlemonade, /datum/reagent/consumable/cream_soda, /datum/reagent/consumable/sodawater, /datum/reagent/consumable/grapejuice)

/datum/symptom/soda/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth()>= 4)
		severity = 0
	else
		severity = initial(severity)

/datum/symptom/soda/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	var/dealDamage = false
	for(var/datum/reagent in required_reagents)
		if(A.has_reagent(reagent))
			dealDamage = TRUE
			break
	if(dealDamage)
		A.adjust_tox_loss(power*2)
		if(prob(base_message_chance))
			to_chat(M, span_warning("You feel a sudden pain inside you!"))
