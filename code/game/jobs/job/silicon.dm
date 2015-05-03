/*
AI
*/
/datum/job/ai
	title = "AI"
	flag = AI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = 1
	minimal_player_age = 30

/datum/job/ai/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0

/datum/job/ai/config_check()
	if(config && config.allow_ai)
		return 1
	return 0

/*
Cyborg
*/
/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 21

/datum/job/cyborg/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	return H.Robotize()


/datum/job/mommi
	title = "MoMMI"
	flag = MOMMI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 4 // to match the number of drone shells that spawned on the station, was 2 on /vg/
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		return H.Mommize()