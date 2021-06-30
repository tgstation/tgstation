/datum/antagonist/protagonist
	name = "Protagonist"
	roundend_category = "protagonists"
	antagpanel_category = "Protagonists"
	job_rank = ROLE_PROTAGONIST
	show_to_ghosts = TRUE
	///Some protagonists have min ages
	var/min_age = 17
	///Some protagonists have max ages
	var/max_age = 99
	///Outfit to put onto the character
	var/outfit_type = /datum/outfit


/datum/antagonist/protagonist/on_gain()
	. = ..()
	equip_protagonist()
	create_objectives()

/datum/antagonist/protagonist/proc/equip_protagonist()
	if(!owner)
		CRASH("Antag datum with no owner.")
	var/mob/living/carbon/human/protagonist_human = owner.current
	if(!istype(protagonist_human))
		return

	protagonist_human.delete_equipment()

	if(protagonist_human.age > max_age)
		protagonist_human.age = max_age
	else if (protagonist_human.age < min_age)
		protagonist_human.age = min_age

	protagonist_human.equipOutfit(outfit_type)

/datum/antagonist/protagonist/proc/create_objectives()
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective
