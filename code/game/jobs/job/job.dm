/datum/job
	var
		//The name of the job
		title = "NOPE"
		//Bitflags for the job
		flag = 0
		department_flag = 0
		//Players will be allowed to spawn in as jobs that are set to "Station"
		faction = "None"
		//How many players can be this job
		total_positions = 0
		//How many players can spawn in as this job
		spawn_positions = 0
		//How many players have this job
		current_positions = 0


	proc/equip(var/mob/living/carbon/human/H)
		return 1
