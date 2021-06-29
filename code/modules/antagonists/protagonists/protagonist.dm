/datum/antagonist/protagonist
	name = "Protagonist"
	roundend_category = "protagonists"
	antagpanel_category = "Protagonists"
	job_rank = ROLE_PROTAGONIST
	show_to_ghosts = TRUE
	///Some protagonists have min ages
	var/min_age = 16
	///Some protagonists have max ages
	var/max_age = 99
	///Outfit to put onto the character
	var/outfit_type = /datum/outfit/wizard


/datum/antagonist/protagonist/on_gain()
	. = ..()
	equip_protagonist()
	create_objectives()

/datum/antagonist/protagonist/proc/equip_protagonist()
	if(!owner)
		CRASH("Antag datum with no owner.")
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	H.delete_equipment()

	if(H.age > max_age)
		H.age = max_age
	else if (H.age < min_age)
		H.age = min_age

	H.equipOutfit(outfit_type)

/datum/antagonist/protagonist/proc/create_objectives()
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective
