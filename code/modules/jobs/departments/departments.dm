/// Singleton representing a category of jobs forming a department.
/datum/job_department
	/// Department as displayed on different menus.
	var/department_name = DEPARTMENT_UNASSIGNED
	/// Bitflags associated to the specific department.
	var/department_bitflags = NONE
	/// Typepath of the job datum leading this department.
	var/datum/job/department_head = null
	/// Experience granted by playing in a job of this department.
	var/department_experience_type = null
	/// The order in which this department appears on menus, in relation to other departments.
	var/display_order = 0
	/// The header color to be displayed in the ban panel, classes defined in banpanel.css
	var/label_class = "undefineddepartment"
	/// The color used in TGUI or similar menus.
	var/ui_color = "#9689db"
	/// Job singleton datums associated to this department. Populated on job initialization.
	var/list/department_jobs = list()
	/// For separatists, what independent name prefix does their nation get named?
	var/list/nation_prefixes = list()
	/// List of /area types that are considered part of this department's "delivery" area.
	/// Acts as a priority system, where first items are picked first.
	var/list/department_delivery_areas = list()
	/// List of categories in the cargo console that are associated with this department.
	var/list/associated_cargo_groups = list()
	/// The single access associated with the head of staff of this department.
	var/head_of_staff_access
	/// A list of generic access flags people in this department generally have.
	var/list/department_access = list()

/// Handles adding jobs to the department and setting up the job bitflags.
/datum/job_department/proc/add_job(datum/job/job)
	department_jobs += job
	job.departments_bitflags |= department_bitflags

/// Handles removing jobs from the department and removing job bitflags.
/datum/job_department/proc/remove_job(datum/job/job_type)
	for(var/datum/job/job_datum as anything in department_jobs)
		if(job_datum.type == job_type)
			department_jobs -= job_datum
			job_datum.departments_bitflags -= department_bitflags
			job_datum.job_flags &= ~JOB_NEW_PLAYER_JOINABLE
			job_datum.spawn_positions = 0
			job_datum.total_positions = 0

/// Returns all jobs that are in this category for jobbans
/datum/job_department/proc/get_jobban_jobs()
	return department_jobs.Copy()

/// Returns a nation name for this department.
/datum/job_department/proc/generate_nation_name()
	var/static/list/nation_suffixes = list("stan", "topia", "land", "nia", "ca", "tova", "dor", "ador", "tia", "sia", "ano", "tica", "tide", "cis", "marea", "co", "taoide", "slavia", "stotzka")
	return pick(nation_prefixes) + pick(nation_suffixes)

/// A special assistant only department, primarily for use by the preferences menu
/datum/job_department/assistant
	department_name = DEPARTMENT_ASSISTANT
	department_bitflags = DEPARTMENT_BITFLAG_ASSISTANT
	nation_prefixes = list("Assa", "Mainte", "Tunnel", "Gris", "Grey", "Liath", "Grigio", "Ass", "Assi")
	// Don't add department_head! Assistants names should not be in bold.

/datum/job_department/assistant/generate_nation_name()
	var/nomadic_name = pick("roving clans", "barbaric tribes", "tides", "bandit kingdom", "tribal society", "marauder clans", "horde")
	return "The [nomadic_name] of [..()]"

/// A special captain only department, for use by the preferences menu
/datum/job_department/captain
	department_name = DEPARTMENT_CAPTAIN
	department_bitflags = DEPARTMENT_BITFLAG_CAPTAIN
	department_head = /datum/job/captain

/datum/job_department/command
	department_name = DEPARTMENT_COMMAND
	department_bitflags = DEPARTMENT_BITFLAG_COMMAND
	department_head = /datum/job/captain
	department_experience_type = EXP_TYPE_COMMAND
	display_order = 1
	label_class = "command"
	ui_color = "#6681a5"


/datum/job_department/security
	department_name = DEPARTMENT_SECURITY
	department_bitflags = DEPARTMENT_BITFLAG_SECURITY
	department_head = /datum/job/head_of_security
	department_experience_type = EXP_TYPE_SECURITY
	display_order = 2
	label_class = "security"
	ui_color = "#d46a78"
	nation_prefixes = list("Securi", "Beepski", "Shitcuri", "Red", "Stunba", "Flashbango", "Flasha", "Stanfordi")
	department_delivery_areas = list(
		/area/station/security/office,
		/area/station/security/brig,
		/area/station/security/brig/upper,
	)
	associated_cargo_groups = list("Security", "Armory")
	head_of_staff_access = ACCESS_HOS
	department_access = REGION_ACCESS_SECURITY

/datum/job_department/security/get_jobban_jobs()
	// Captains often fulfill security duties so they are considered part of the security department for jobbans
	return ..() | SSjob.get_job_type(/datum/job/captain)

/datum/job_department/engineering
	department_name = DEPARTMENT_ENGINEERING
	department_bitflags = DEPARTMENT_BITFLAG_ENGINEERING
	department_head = /datum/job/chief_engineer
	department_experience_type = EXP_TYPE_ENGINEERING
	display_order = 3
	label_class = "engineering"
	ui_color = "#dfb567"
	nation_prefixes = list("Atomo", "Engino", "Power", "Teleco")
	department_delivery_areas = list(
		/area/station/engineering/main,
		/area/station/engineering/lobby,
	)
	associated_cargo_groups = list("Engineering", "Engine Construction", "Canisters & Materials")
	head_of_staff_access = ACCESS_CE
	department_access = REGION_ACCESS_ENGINEERING

/datum/job_department/medical
	department_name = DEPARTMENT_MEDICAL
	department_bitflags = DEPARTMENT_BITFLAG_MEDICAL
	department_head = /datum/job/chief_medical_officer
	department_experience_type = EXP_TYPE_MEDICAL
	display_order = 4
	label_class = "medical"
	ui_color = "#65b2bd"
	nation_prefixes = list("Mede", "Healtha", "Recova", "Chemi", "Viro", "Psych")
	department_delivery_areas = list(
		/area/station/medical/medbay/central,
		/area/station/medical/medbay,
		/area/station/medical/treatment_center,
		/area/station/medical/storage,
	)
	associated_cargo_groups = list("Medical")
	head_of_staff_access = ACCESS_CMO
	department_access = REGION_ACCESS_MEDBAY

/datum/job_department/science
	department_name = DEPARTMENT_SCIENCE
	department_bitflags = DEPARTMENT_BITFLAG_SCIENCE
	department_head = /datum/job/research_director
	department_experience_type = EXP_TYPE_SCIENCE
	display_order = 5
	label_class = "science"
	ui_color = "#c973c9"
	nation_prefixes = list("Sci", "Griffa", "Geneti", "Explosi", "Mecha", "Xeno", "Nani", "Cyto")
	department_delivery_areas = list(
		/area/station/science/research,
		/area/station/science/lobby,
		/area/station/science/lab,
	)
	associated_cargo_groups = list("Science", "Livestock", "Canisters & Materials")
	head_of_staff_access = ACCESS_RD
	department_access = REGION_ACCESS_RESEARCH


/datum/job_department/cargo
	department_name = DEPARTMENT_CARGO
	department_bitflags = DEPARTMENT_BITFLAG_CARGO
	department_head = /datum/job/quartermaster
	department_experience_type = EXP_TYPE_SUPPLY
	display_order = 6
	label_class = "supply"
	ui_color = "#cf9c6c"
	nation_prefixes = list("Cargo", "Guna", "Suppli", "Mule", "Crate", "Ore", "Mini", "Shaf")
	head_of_staff_access = ACCESS_QM
	department_access = REGION_ACCESS_SUPPLY

/datum/job_department/service
	department_name = DEPARTMENT_SERVICE
	department_bitflags = DEPARTMENT_BITFLAG_SERVICE
	department_head = /datum/job/head_of_personnel
	department_experience_type = EXP_TYPE_SERVICE
	display_order = 7
	label_class = "service"
	ui_color = "#7cc46a"
	nation_prefixes = list("Honka", "Boozo", "Fatu", "Danka", "Mimi", "Libra", "Jani", "Religi")
	department_delivery_areas = list(/area/station/hallway/secondary/service, /area/station/service/bar/atrium)
	associated_cargo_groups = list("Service", "Food & Hydroponics", "Livestock", "Costumes & Toys")
	head_of_staff_access = ACCESS_HOP
	department_access = list(ACCESS_SERVICE)

/datum/job_department/silicon
	department_name = DEPARTMENT_SILICON
	department_bitflags = DEPARTMENT_BITFLAG_SILICON
	department_head = /datum/job/ai
	department_experience_type = EXP_TYPE_SILICON
	display_order = 8
	label_class = "silicon"
	ui_color = "#5dbda0"

/datum/job_department/silicon/generate_nation_name()
	return "United Nations" //For nations ruleset specifically, because all other sources of nation creation cannot choose silicons

/// Catch-all department for undefined jobs.
/datum/job_department/undefined
	display_order = 10
