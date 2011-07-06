//WORK IN PROGRESS CONTENT

//Project coder: Errorage

//Readme: As part of the UI upgrade project, the intention here is for each job to have
//somewhat customizable loadouts. Players will be able to pick between jumpsuits, shoes,
//and other items. This datum will be used for all jobs and code will reference it.
//adding new jobs will be a matter of adding this datum.to a list of jobs.

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
	JOB.equipment_suit = list(/obj/item/clothing/suit/hazardvest)
	JOB.equipment_under = list(/obj/item/clothing/under/rank/engineer,/obj/item/clothing/under/color/yellow)
	JOB.equipment_belt = list(/obj/item/weapon/storage/utilitybelt/full)
	JOB.equipment_back = list(/obj/item/weapon/storage/backpack/industrial,/obj/item/weapon/storage/backpack)
	JOB.equipment_pda = /obj/item/device/pda/engineering
	JOB.equipment_id = /obj/item/weapon/card/id

	jobs.all_jobs += JOB

//This proc will dress the mob (employee) in the default way for the specified job title/job alias
proc/dress_for_job_default(var/mob/living/carbon/human/employee as mob, var/job_alias)
	if(!ishuman(employee))
		return

	//UNFINISHED
	var/datum/job/JOB = jobs.get_job(job_alias)
	if(JOB)
		var/item = JOB.equipment_ears[1]
		employee.equip_if_possible(new item(employee), employee.slot_ears)
		item = JOB.equipment_under[1]
		employee.equip_if_possible(new item(employee), employee.slot_w_uniform)


		/*
	src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (src), slot_back)
	src.equip_if_possible(new /obj/item/weapon/storage/survival_kit/engineer(src), slot_in_backpack)
	src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
	src.equip_if_possible(new /obj/item/device/pda/engineering(src), slot_belt)
	src.equip_if_possible(new /obj/item/clothing/under/rank/engineer(src), slot_w_uniform)
	src.equip_if_possible(new /obj/item/clothing/shoes/orange(src), slot_shoes)
	src.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(src), slot_head)
	src.equip_if_possible(new /obj/item/weapon/storage/utilitybelt/full(src), slot_l_hand) //currently spawns in hand due to traitor assignment requiring a PDA to be on the belt. --Errorage
	//src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves) removed as part of Dangercon 2011, approved by Urist_McDorf --Errorage
	src.equip_if_possible(new /obj/item/device/t_scanner(src), slot_r_store)
	*/

//END OF WORK IN PROGRESS CONTENT



var/list/occupations = list(
	//Civilian jobs
	"Head of Personnel"      = 1,
	//soul
	"Clown"                  = 1,
	"Mime"                   = 1,
	"Chaplain"               = 1,
	"Librarian"              = 1,
	"Lawyer"                 = 1,
	//body
	"Bartender"              = 1,
	"Chef"                   = 1,
	"Janitor"                = 1,
	"Quartermaster"          = 1,
	"Cargo Technician"       = 3,
	"Shaft Miner"            = 3,

	//engineering
	"Chief Engineer"         = 1,
	"Station Engineer"       = 5,
	"Atmospheric Technician" = 4,
	"Roboticist"             = 1,

	//red shirts
	"Head of Security"       = 1,
	"Warden"                 = 1,
	"Detective"              = 1,
	"Security Officer"       = 5,

	//medbay
	"Chief Medical Officer"  = 1,
	"Medical Doctor"         = 5,
	"Chemist"                = 2,

	//science dept
	"Research Director"      = 1,
	"Geneticist"             = 2,
	"Scientist"              = 3,
	"Botanist"               = 2,
	"Virologist"             = 1,

	//I afraid I can't do that, Dave
	"AI" = 1,
	"Cyborg" = 1,

)

var/list/assistant_occupations = list(
	"Assistant",
	//"Tourist", //I am not going to implement these jobs at the moment. Just listed it as examples. --rastaf0
	//"Monkey",
	//"Prisoneer",
	//"Lizard",
)

var/list/head_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
)

var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	//"Monkey",
	//"Lizard",
)

/proc/is_important_job(var/job)
	return (job in head_positions) || (job in list("AI", "Cyborg", "Warden", "Detective"))
