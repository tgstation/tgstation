//WORK IN PROGRESS CONTENT

//Project coder: Errorage

//Readme: As part of the UI upgrade project, the intention here is for each job to have
//somewhat customizable loadouts. Players will be able to pick between jumpsuits, shoes,
//and other items. This datum will be used for all jobs and code will reference it.
//adding new jobs will be a matter of adding this datum.to a list of jobs.

#define VITAL_PRIORITY_JOB 5
#define HIGH_PRIORITY_JOB 4
#define PRIORITY_JOB 3
#define LOW_PRIORITY_JOB 2
#define ASSISTANT_PRIORITY_JOB 1
#define NO_PRIORITY_JOB 0

/datum/job
	//Basic information
	var/title = "Untitled"					//The main (default) job title/name
	var/list/alternative_titles = list()	//Alternative job titles/names (alias)
	var/job_number_at_round_start = 0		//Number of jobs that can be assigned at round start
	var/job_number_total = 0				//Number of jobs that can be assigned total
	var/list/bosses = list()				//List of jobs which have authority over this job by default.
	var/admin_only = 0						//If this is set to 1, the job is not available on the spawn screen
	var/description = ""					//A description of the job to be displayed when requested on the spawn screen
	var/guides = ""							//A string with links to relevent guides (likely the wiki)
	var/department = ""						//This is used to group jobs into departments, which means that if you don't get your desired jobs, you get another job from the same department
	var/job_type = "SS13"					//SS13, NT or ANTAGONIST
	var/can_be_traitor = 1
	var/can_be_changeling = 1
	var/can_be_wizard = 1
	var/can_be_cultist = 1
	var/can_be_rev_head = 1
	var/is_head_position = 0

	//Job conditions
	var/change_to_mob = "Human"				//The type of mob which this job will change you to (alien,cyborg,human...)
	var/change_to_mutantrace = ""			//What mutantrace you will be once you get this job

	//Random job assignment priority
	var/assignment_priority = NO_PRIORITY_JOB		//This variable determins the priority of assignment
		//VITAL_PRIORITY_JOB = Absolutely vital (Someone will get assigned every round) - Use VERY, VERY lightly
		//HIGH_PRIORITY_JOB = High priority - Assibned before the other jobs, candidates compete on equal terms
		//PRIORITY_JOB = Priorized (Standard priority) - Candidates compete by virtue of priority (choice 1 > choice 2 > choice 3...)
		//LOW_PRIORITY_JOB = Low priority (Low-priority (librarian))
		//ASSISTANT_PRIORITY_JOB = Assistant-level (Only filled when all the other jobs have been assigned)
		//NO_PRIORITY_JOB = Skipped om assignment (Admin-only jobs should have this level)



	//Available equipment - The first thing listed is understood as the default setup.
	var/list/equipment_ears = list()		//list of possible ear-wear items
	var/list/equipment_glasses = list()		//list of possible glasses
	var/list/equipment_gloves = list()		//list of possible gloves
	var/list/equipment_head = list()		//list of possible headgear/helmets/hats
	var/list/equipment_mask = list()		//list of possible masks
	var/list/equipment_shoes = list()		//list of possible shoes
	var/list/equipment_suit = list()		//list of possible suits
	var/list/equipment_under = list()		//list of possible jumpsuits
	var/list/equipment_belt = list()		//list of possible belt-slot items
	var/list/equipment_back = list()		//list of possible back-slot items
	var/obj/equipment_pda					//default pda type
	var/obj/equipment_id					//default id type

	New(var/param_title, var/list/param_alternative_titles = list(), var/param_jobs_at_round_start = 0, var/param_global_max = 0, var/list/param_bosses = list(), var/param_admin_only = 0)
		title = param_title
		alternative_titles = param_alternative_titles
		job_number_at_round_start = param_jobs_at_round_start
		job_number_total = param_global_max
		bosses = param_bosses
		admin_only = param_admin_only

	//This proc tests to see if the given alias (job title/alternative job title) corresponds to this job.
	//Returns 1 if it is, else returns 0
	proc/is_job_alias(var/alias)
		if(alias == title)
			return 1
		if(alias in alternative_titles)
			return 1
		return 0

/datum/jobs
	var/list/datum/job/all_jobs = list()

	proc/get_all_jobs()
		return all_jobs

	//This proc returns all the jobs which are NOT admin only
	proc/get_normal_jobs()
		var/list/datum/job/normal_jobs = list()
		for(var/datum/job/J in all_jobs)
			if(!J.admin_only)
				normal_jobs += J
		return normal_jobs

	//This proc returns all the jobs which are admin only
	proc/get_admin_jobs()
		var/list/datum/job/admin_jobs = list()
		for(var/datum/job/J in all_jobs)
			if(J.admin_only)
				admin_jobs += J
		return admin_jobs

	//This proc returns the job datum of the job with the alias or job title given as the argument. Returns an empty string otherwise.
	proc/get_job(var/alias)
		for(var/datum/job/J in all_jobs)
			if(J.is_job_alias(alias))
				return J
		return ""

	//This proc returns a string with the default job title for the job with the given alias. Returns an empty string otherwise.
	proc/get_job_title(var/alias)
		for(var/datum/job/J in all_jobs)
			if(J.is_job_alias(alias))
				return J.title
		return ""

	//This proc returns all the job datums of the workers whose boss has the alias provided. (IE Engineer under Chief Engineer, etc.)
	proc/get_jobs_under(var/boss_alias)
		var/boss_title = get_job_title(boss_alias)
		var/list/datum/job/employees = list()
		for(var/datum/job/J in all_jobs)
			if(boss_title in J.bosses)
				employees += J
		return employees

	//This proc returns the chosen vital and high priority jobs that the person selected. It goes from top to bottom of the list, until it finds a job which does not have such priority.
	//Example: Choosing (in this order): CE, Captain, Engineer, RD will only return CE and Captain, as RD is assumed as being an unwanted choice.
	//This proc is used in the allocation algorithm when deciding vital and high priority jobs.
	proc/get_prefered_high_priority_jobs()
		var/list/datum/job/hp_jobs = list()
		for(var/datum/job/J in all_jobs)
			if(J.assignment_priority == HIGH_PRIORITY_JOB || J.assignment_priority == VITAL_PRIORITY_JOB)
				hp_jobs += J
			else
				break
		return hp_jobs

	//If only priority is given, it will return the jobs of only that priority, if end_priority is set it will return the jobs with their priority higher or equal to var/priority and lower or equal to end_priority. end_priority must be higher than 0.
	proc/get_jobs_by_priority(var/priority, var/end_priority = 0)
		var/list/datum/job/priority_jobs = list()
		if(end_priority)
			if(end_priority < priority)
				return
			for(var/datum/job/J in all_jobs)
				if(J.assignment_priority >= priority && J.assignment_priority <= end_priority)
					priority_jobs += J
		else
			for(var/datum/job/J in all_jobs)
				if(J.assignment_priority == priority)
					priority_jobs += J
		return priority_jobs

//This datum is used in the plb allocation algorithm to make life easier, not used anywhere else.
/datum/player_jobs
	var/mob/new_player/player
	var/datum/jobs/selected_jobs

var/datum/jobs/jobs = new/datum/jobs()

proc/setup_jobs()
	var/datum/job/JOB

	JOB = new/datum/job("Station Engineer")
	JOB.alternative_titles = list("Structural Engineer","Engineer","Student of Engineering")
	JOB.job_number_at_round_start = 5
	JOB.job_number_total = 5
	JOB.bosses = list("Chief Engineer")
	JOB.admin_only = 0
	JOB.description = "Engineers are tasked with the maintenance of the station. Be it maintaining the power grid or rebuilding damaged sections."
	JOB.guides = ""
	JOB.equipment_ears = list(/obj/item/device/radio/headset/headset_eng)
	JOB.equipment_glasses = list()
	JOB.equipment_gloves = list()
	JOB.equipment_head = list(/obj/item/clothing/head/helmet/hardhat)
	JOB.equipment_mask = list()
	JOB.equipment_shoes = list(/obj/item/clothing/shoes/orange,/obj/item/clothing/shoes/brown,/obj/item/clothing/shoes/black)
	JOB.equipment_suit = list(/obj/item/clothing/suit/storage/hazardvest)
	JOB.equipment_under = list(/obj/item/clothing/under/rank/engineer,/obj/item/clothing/under/color/yellow)
	JOB.equipment_belt = list(/obj/item/weapon/storage/belt/utility/full)
	JOB.equipment_back = list(/obj/item/weapon/storage/backpack/industrial,/obj/item/weapon/storage/backpack)
	JOB.equipment_pda = /obj/item/device/pda/engineering
	JOB.equipment_id = /obj/item/weapon/card/id

	jobs.all_jobs += JOB

//This proc will dress the mob (employee) in the default way for the specified job title/job alias
proc/dress_for_job_default(var/mob/living/carbon/human/employee as mob, var/job_alias)
	if(!ishuman(employee))
		return

	//TODO ERRORAGE - UNFINISHED
	var/datum/job/JOB = jobs.get_job(job_alias)
	if(JOB)
		var/item = JOB.equipment_ears[1]
		employee.equip_to_slot_or_del(new item(employee), employee.slot_ears)
		item = JOB.equipment_under[1]
		employee.equip_to_slot_or_del(new item(employee), employee.slot_w_uniform)


		/*
	src.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial (src), slot_back)
	src.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(src), slot_in_backpack)
	src.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
	src.equip_to_slot_or_del(new /obj/item/device/pda/engineering(src), slot_belt)
	src.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(src), slot_w_uniform)
	src.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(src), slot_shoes)
	src.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/hardhat(src), slot_head)
	src.equip_to_slot_or_del(new /obj/item/weapon/storage/utilitybelt/full(src), slot_l_hand) //currently spawns in hand due to traitor assignment requiring a PDA to be on the belt. --Errorage
	//src.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(src), slot_gloves) removed as part of Dangercon 2011, approved by Urist_McDorf --Errorage
	src.equip_to_slot_or_del(new /obj/item/device/t_scanner(src), slot_r_store)
	*/


//This algorithm works in 5 steps:
//1: Assignment of wizard / nuke members (if appropriate game mode)
//2: Assignment of jobs based on preferenes
//   2.1: Assignment of vital and high priority jobs. Candidates compete on equal terms. If the vital jobs are not filled, a random candidate is chosen to fill them,
//   2.2: Assignment of the rest of the jobs based on player preference,
//3: Assignment of remaining jobs for remaining players based on chosen departments
//4: Random assignment of remaining jobs for remaining players based on assignment priority
//5: Assignment of traitor / changeling to assigned roles (if appropriate game mode)
proc/assignment_algorithm(var/list/mob/new_player/players)
	for(var/mob/new_player/PLAYER in players)
		if(!PLAYER.client)
			players -= PLAYER
			continue
		if(!PLAYER.ready)
			players -= PLAYER
			continue

	var/list/datum/job/vital_jobs = list()
	var/list/datum/job/high_priority_jobs = list()
	var/list/datum/job/priority_jobs = list()
	var/list/datum/job/low_priority_jobs = list()
	var/list/datum/job/assistant_jobs = list()
	var/list/datum/job/not_assigned_jobs = list()

	for(var/datum/job/J in jobs)
		switch(J.assignment_priority)
			if(5)
				vital_jobs += J
			if(4)
				high_priority_jobs += J
			if(3)
				priority_jobs += J
			if(2)
				low_priority_jobs += J
			if(1)
				assistant_jobs += J
			if(0)
				not_assigned_jobs += J

	var/list/datum/player_jobs/player_jobs = list() //This datum only holds a mob/new_player and a datum/jobs. The first is the player, the 2nd is the player's selected jobs, from the preferences datum.

	for(var/mob/new_player/NP in players)
		var/datum/player_jobs/PJ = new/datum/player_jobs
		PJ.player = NP
		PJ.selected_jobs = NP.preferences.wanted_jobs
		player_jobs += PJ

	//At this point we have the player_jobs list filled. Next up we have to assign all vital and high priority positions.

	var/list/datum/job/hp_jobs = jobs.get_jobs_by_priority( HIGH_PRIORITY_JOB, VITAL_PRIORITY_JOB )

	for(var/datum/job/J in hp_jobs)
		var/list/mob/new_player/candidates = list()
		for(var/datum/player_jobs/PJ in player_jobs)
			if(J in PJ.selected_jobs)
				candidates += PJ.player
		var/mob/new_player/chosen_player
		if(candidates)
			chosen_player = pick(candidates)
		else
			if(J.assignment_priority == VITAL_PRIORITY_JOB)
				if(players) 			//Just in case there are more vital jobs than there are players.
					chosen_player = pick(players)
		if(chosen_player)
			chosen_player.mind.assigned_job = J
			players -= chosen_player
		//TODO ERRORAGE - add capability for hp jobs with more than one slots.




	//1: vital and high priority jobs, assigned on equal terms

	//TODO ERRORAGE - UNFINISHED


//END OF WORK IN PROGRESS CONTENT
