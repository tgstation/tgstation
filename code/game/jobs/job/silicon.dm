/datum/job/ai
	title = "AI"
	flag = AI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	wiki_guide = "http://wiki.nanotrasen.com/index.php?title=AI"
	req_admin_notify = 1
	minimal_player_age = 30

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		return 1



/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	wiki_guide = "http://wiki.nanotrasen.com/index.php?title=Cyborg"
	minimal_player_age = 21

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		return 1