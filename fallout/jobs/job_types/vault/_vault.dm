datum/job/f13/vault
	selection_color = "#447ab9"

//These are base jobs, we don't want them appearing at all
/datum/job/f13/vault/config_check()
	if(type == /datum/job/f13/vault)
		return FALSE
	return ..()

/datum/job/f13/vault/map_check()
	if(type == /datum/job/f13/vault)
		return FALSE
	return ..()
