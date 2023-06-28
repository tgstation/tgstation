//spider webs
/datum/mutation/human/webbing
	name = "Webbing Production"
	desc = "Allows the user to lay webbing, and travel through it."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your skin feels webby.</span>"
	instability = 15
	power_path = /datum/action/cooldown/lay_web/genetic
	energy_coeff = 1

/datum/mutation/human/webbing/modify()
	. = ..()
	var/datum/action/cooldown/lay_web/genetic/to_modify = .

	if(!istype(to_modify)) // null or invalid
		return

	if(GET_MUTATION_ENERGY(src) == 1) // Energetic chromosome outputs a value less than 1 when present, 1 by default
		to_modify.webbing_time = initial(to_modify.webbing_time)
		return
	to_modify.webbing_time = 2 SECONDS // Spin webs faster but not more often

/datum/mutation/human/webbing/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_WEB_WEAVER, GENETIC_MUTATION)

/datum/mutation/human/webbing/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_WEB_WEAVER, GENETIC_MUTATION)
