/**
 * This file contains all the trims associated with station jobs.
 * It also contains special prisoner trims and the miner's spare ID trim.
 */

/// ID Trims for station jobs.
/datum/id_trim/job
	trim_state = "trim_assistant"

	/// The extra access the card should have when CONFIG_GET(flag/jobs_have_minimal_access) is FALSE.
	var/list/extra_access = list()
	/// The extra wildcard_access the card should have when CONFIG_GET(flag/jobs_have_minimal_access) is FALSE.
	var/list/extra_wildcard_access = list()
	/// The base access the card should have when CONFIG_GET(flag/jobs_have_minimal_access) is TRUE.
	var/list/minimal_access = list()
	/// The base wildcard_access the card should have when CONFIG_GET(flag/jobs_have_minimal_access) is TRUE.
	var/list/minimal_wildcard_access = list()
	/// Static list. Cache of any mapping config job changes.
	var/static/list/job_changes
	/// An ID card with an access in this list can apply this trim to IDs or use it as a job template when adding access to a card. If the list is null, cannot be used as a template. Should be Head of Staff or ID Console accesses or it may do nothing.
	var/list/template_access
	/// The typepath to the job datum from the id_trim. This is converted to one of the job singletons in New().
	var/datum/job/job = /datum/job/unassigned

/datum/id_trim/job/New()
	if(ispath(job))
		job = SSjob.GetJobType(job)

	if(isnull(job_changes))
		job_changes = SSmapping.config.job_changes

	if(!length(job_changes))
		refresh_trim_access()
		return

	var/list/access_changes = job_changes[job.title]

	if(!length(access_changes))
		refresh_trim_access()
		return

	if(islist(access_changes["additional_access"]))
		extra_access |= access_changes["additional_access"]
	if(islist(access_changes["additional_minimal_access"]))
		minimal_access |= access_changes["additional_minimal_access"]
	if(islist(access_changes["additional_wildcard_access"]))
		extra_wildcard_access |= access_changes["additional_wildcard_access"]
	if(islist(access_changes["additional_minimal_wildcard_access"]))
		minimal_wildcard_access |= access_changes["additional_minimal_wildcard_access"]

	refresh_trim_access()

/**
 * Goes through various non-map config settings and modifies the trim's access based on this.
 *
 * Returns TRUE if the config is loaded, FALSE otherwise.
 */
/datum/id_trim/job/proc/refresh_trim_access()
	// If there's no config loaded then assume minimal access.
	if(!config)
		access = minimal_access.Copy()
		wildcard_access = minimal_wildcard_access.Copy()
		return FALSE

	// There is a config loaded. Check for the jobs_have_minimal_access flag being set.
	if(CONFIG_GET(flag/jobs_have_minimal_access))
		access = minimal_access.Copy()
		wildcard_access = minimal_wildcard_access.Copy()
	else
		access = minimal_access | extra_access
		wildcard_access = minimal_wildcard_access | extra_wildcard_access

	// If the config has global maint access set, we always want to add maint access.
	if(CONFIG_GET(flag/everyone_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

	return TRUE

/datum/id_trim/job/assistant
	assignment = JOB_ASSISTANT
	trim_state = "trim_assistant"
	intern_alt_name = "Intern"
	sechud_icon_state = SECHUD_ASSISTANT
	minimal_access = list()
	extra_access = list(
		ACCESS_MAINT_TUNNELS,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/assistant

/datum/id_trim/job/assistant/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config has assistant maint access set.
	if(CONFIG_GET(flag/assistants_have_maint_access))
		access |= list(
			ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/atmospheric_technician
	assignment = JOB_ATMOSPHERIC_TECHNICIAN
	trim_state = "trim_atmospherictechnician"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_ATMOSPHERIC_TECHNICIAN
	minimal_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_AUX_BASE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		)
	extra_access = list(
		ACCESS_ENGINE_EQUIP,
		ACCESS_MINISAT,
		ACCESS_TCOMMS,
		ACCESS_TECH_STORAGE,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CE,
		)
	job = /datum/job/atmospheric_technician

/datum/id_trim/job/bartender
	assignment = JOB_BARTENDER
	trim_state = "trim_bartender"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_BARTENDER
	minimal_access = list(
		ACCESS_BAR,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
		)
	extra_access = list(
		ACCESS_HYDROPONICS,
		ACCESS_KITCHEN,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/bartender

/datum/id_trim/job/bitrunner
	assignment = JOB_BITRUNNER
	trim_state = "trim_bitrunner"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_CARGO_BROWN
	sechud_icon_state = SECHUD_BITRUNNER
	minimal_access = list(
		ACCESS_BIT_DEN,
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
	)
	extra_access = list(
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_QM,
	)
	job = /datum/job/bitrunner

/datum/id_trim/job/botanist
	assignment = JOB_BOTANIST
	trim_state = "trim_botanist"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_BOTANIST
	minimal_access = list(
		ACCESS_HYDROPONICS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		)
	extra_access = list(
		ACCESS_BAR,
		ACCESS_KITCHEN,
		ACCESS_MORGUE,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/botanist

/datum/id_trim/job/bridge_assistant
	assignment = JOB_BRIDGE_ASSISTANT
	trim_state = "trim_assistant"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_COMMAND_BLUE
	sechud_icon_state = SECHUD_BRIDGE_ASSISTANT
	minimal_access = list(
		ACCESS_COMMAND,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_MAINT_TUNNELS,
		ACCESS_RC_ANNOUNCE,
		ACCESS_TELEPORTER,
		ACCESS_WEAPONS,
	)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
	)
	job = /datum/job/bridge_assistant

/datum/id_trim/job/captain
	assignment = JOB_CAPTAIN
	intern_alt_name = "Captain-in-Training"
	trim_state = "trim_captain"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_COMMAND_BLUE
	department_state = "departmenthead"
	sechud_icon_state = SECHUD_CAPTAIN
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		)
	job = /datum/job/captain
	big_pointer = TRUE
	pointer_color = COLOR_COMMAND_BLUE

/// Captain gets all station accesses hardcoded in because it's the Captain.
/datum/id_trim/job/captain/New()
	extra_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_COMMON) + SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND))
	extra_wildcard_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_PRV_COMMAND) + SSid_access.get_flag_access_list(ACCESS_FLAG_CAPTAIN))
	minimal_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_COMMON) + SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND))
	minimal_wildcard_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_PRV_COMMAND) + SSid_access.get_flag_access_list(ACCESS_FLAG_CAPTAIN))

	return ..()

/datum/id_trim/job/cargo_technician
	assignment = JOB_CARGO_TECHNICIAN
	trim_state = "trim_cargotechnician"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_CARGO_BROWN
	sechud_icon_state = SECHUD_CARGO_TECHNICIAN
	minimal_access = list(
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SHIPPING,
		)
	extra_access = list(
		ACCESS_BIT_DEN,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_QM,
		)
	job = /datum/job/cargo_technician

/datum/id_trim/job/chaplain
	assignment = JOB_CHAPLAIN
	trim_state = "trim_chaplain"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_CHAPLAIN
	minimal_access = list(
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CREMATORIUM,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SERVICE,
		ACCESS_THEATRE,
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/chaplain

/datum/id_trim/job/chemist
	assignment = JOB_CHEMIST
	trim_state = "trim_chemist"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_CHEMIST
	minimal_access = list(
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_PHARMACY,
		ACCESS_PLUMBING,
		)
	extra_access = list(
		ACCESS_MORGUE,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CMO,
		)
	job = /datum/job/chemist

/datum/id_trim/job/chief_engineer
	assignment = JOB_CHIEF_ENGINEER
	intern_alt_name = "Chief Engineer-in-Training"
	trim_state = "trim_stationengineer"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	department_state = "departmenthead"
	sechud_icon_state = SECHUD_CHIEF_ENGINEER
	extra_wildcard_access = list()
	minimal_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_AUX_BASE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CE,
		ACCESS_COMMAND,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_RC_ANNOUNCE,
		ACCESS_TCOMMS,
		ACCESS_TECH_STORAGE,
		)
	minimal_wildcard_access = list(
		ACCESS_CE,
		)
	extra_access = list(
		ACCESS_TELEPORTER,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		)
	job = /datum/job/chief_engineer
	big_pointer = TRUE
	pointer_color = COLOR_ENGINEERING_ORANGE

/datum/id_trim/job/chief_medical_officer
	assignment = JOB_CHIEF_MEDICAL_OFFICER
	intern_alt_name = "Chief Medical Officer-in-Training"
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	department_state = "departmenthead"
	sechud_icon_state = SECHUD_CHIEF_MEDICAL_OFFICER
	extra_wildcard_access = list()
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COMMAND,
		ACCESS_KEYCARD_AUTH,
		ACCESS_PLUMBING,
		ACCESS_EVA,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
		ACCESS_PHARMACY,
		ACCESS_PSYCHOLOGY,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
	)
	minimal_wildcard_access = list(
		ACCESS_CMO,
	)
	extra_access = list(
		ACCESS_TELEPORTER,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
	)
	job = /datum/job/chief_medical_officer
	big_pointer = TRUE
	pointer_color = COLOR_MEDICAL_BLUE

/datum/id_trim/job/clown
	assignment = JOB_CLOWN
	trim_state = "trim_clown"
	department_color = COLOR_MAGENTA
	subdepartment_color = COLOR_MAGENTA
	sechud_icon_state = SECHUD_CLOWN
	minimal_access = list(
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		ACCESS_THEATRE,
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/clown

/datum/id_trim/job/cook
	assignment = JOB_COOK
	trim_state = "trim_cook"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_COOK
	minimal_access = list(
		ACCESS_KITCHEN,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SERVICE,
		)
	extra_access = list(
		ACCESS_BAR,
		ACCESS_HYDROPONICS,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/cook

/datum/id_trim/job/cook/chef
	assignment = JOB_CHEF
	sechud_icon_state = SECHUD_CHEF

/datum/id_trim/job/coroner
	assignment = JOB_CORONER
	trim_state = "trim_coroner"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_CORONER
	minimal_access = list(
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
		ACCESS_SERVICE,
		ACCESS_SURGERY,
	)
	extra_access = list(
		ACCESS_PSYCHOLOGY,
		ACCESS_PHARMACY,
		ACCESS_VIROLOGY,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CMO,
		ACCESS_HOP,
	)
	job = /datum/job/coroner

/datum/id_trim/job/curator
	assignment = JOB_CURATOR
	trim_state = "trim_curator"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_CURATOR
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_LIBRARY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING_STATION,
		ACCESS_SERVICE,
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/curator

/datum/id_trim/job/detective
	assignment = JOB_DETECTIVE
	trim_state = "trim_detective"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_DETECTIVE
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_DETECTIVE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
	)
	extra_access = list(
		ACCESS_BRIG,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOS,
	)
	job = /datum/job/detective

/datum/id_trim/job/detective/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/geneticist
	assignment = JOB_GENETICIST
	trim_state = "trim_geneticist"
	department_color = COLOR_SCIENCE_PINK
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_GENETICIST
	minimal_access = list(
		ACCESS_GENETICS,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_RESEARCH,
		ACCESS_SCIENCE,
		ACCESS_XENOBIOLOGY,
		)
	extra_access = list(
		ACCESS_ROBOTICS,
		ACCESS_TECH_STORAGE,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_RD,
		)
	job = /datum/job/geneticist

/datum/id_trim/job/head_of_personnel
	assignment = JOB_HEAD_OF_PERSONNEL
	intern_alt_name = "Head of Personnel-in-Training"
	trim_state = "trim_headofpersonnel"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_SERVICE_LIME
	department_state = "departmenthead"
	sechud_icon_state = SECHUD_HEAD_OF_PERSONNEL
	minimal_access = list(
		ACCESS_AI_UPLOAD,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_AUX_BASE,
		ACCESS_BAR,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CARGO,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CHANGE_IDS,
		ACCESS_CREMATORIUM,
		ACCESS_COMMAND,
		ACCESS_COURT,
		ACCESS_ENGINEERING,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_KEYCARD_AUTH,
		ACCESS_KITCHEN,
		ACCESS_LAWYER,
		ACCESS_LIBRARY,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
		ACCESS_PSYCHOLOGY,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SCIENCE,
		ACCESS_SERVICE,
		ACCESS_TELEPORTER,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
	)
	minimal_wildcard_access = list(
		ACCESS_HOP,
	)
	extra_access = list()
	extra_wildcard_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
	)
	job = /datum/job/head_of_personnel
	big_pointer = TRUE
	pointer_color = COLOR_SERVICE_LIME

/datum/id_trim/job/head_of_security
	assignment = JOB_HEAD_OF_SECURITY
	intern_alt_name = "Head of Security-in-Training"
	trim_state = "trim_securityofficer"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_SECURITY_RED
	department_state = "departmenthead"
	sechud_icon_state = SECHUD_HEAD_OF_SECURITY
	extra_access = list(ACCESS_TELEPORTER)
	extra_wildcard_access = list()
	minimal_access = list(
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_ARMORY,
		ACCESS_AUX_BASE,
		ACCESS_BIT_DEN,
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CARGO,
		ACCESS_COMMAND,
		ACCESS_CONSTRUCTION,
		ACCESS_COURT,
		ACCESS_DETECTIVE,
		ACCESS_ENGINEERING,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_SECURITY,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SCIENCE,
		ACCESS_SECURITY,
		ACCESS_SERVICE,
		ACCESS_SHIPPING,
		ACCESS_WEAPONS,
	)
	minimal_wildcard_access = list(
		ACCESS_HOS,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
	)
	job = /datum/job/head_of_security
	big_pointer = TRUE
	pointer_color = COLOR_SECURITY_RED

/datum/id_trim/job/head_of_security/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/janitor
	assignment = JOB_JANITOR
	trim_state = "trim_janitor"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_JANITOR
	minimal_access = list(
		ACCESS_JANITOR,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_HOP,
		ACCESS_CHANGE_IDS,
		)
	job = /datum/job/janitor

/datum/id_trim/job/lawyer
	assignment = JOB_LAWYER
	trim_state = "trim_lawyer"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_LAWYER
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_LAWYER,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/lawyer

/datum/id_trim/job/medical_doctor
	assignment = JOB_MEDICAL_DOCTOR
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_MEDICAL_DOCTOR
	extra_access = list(
		ACCESS_PLUMBING,
		)
	minimal_access = list(
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CMO,
		)
	job = /datum/job/doctor

/datum/id_trim/job/mime
	assignment = JOB_MIME
	trim_state = "trim_mime"
	department_color = COLOR_SILVER
	subdepartment_color = COLOR_WHITE
	sechud_icon_state = SECHUD_MIME
	minimal_access = list(
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		ACCESS_THEATRE,
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/mime

/datum/id_trim/job/paramedic
	assignment = JOB_PARAMEDIC
	trim_state = "trim_paramedic"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_PARAMEDIC
	minimal_access = list(
		ACCESS_BIT_DEN,
		ACCESS_CARGO,
		ACCESS_CONSTRUCTION,
		ACCESS_HYDROPONICS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MORGUE,
		ACCESS_SCIENCE,
		ACCESS_SERVICE,
		)
	extra_access = list(
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CMO,
		)
	job = /datum/job/paramedic

/datum/id_trim/job/prisoner
	assignment = JOB_PRISONER
	trim_state = "trim_warden"
	department_color = COLOR_PRISONER_BLACK
	subdepartment_color = COLOR_PRISONER_BLACK
	sechud_icon_state = SECHUD_PRISONER
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		ACCESS_HOS,
		)
	job = /datum/job/prisoner
	threat_modifier = 1 // I'm watching you

/datum/id_trim/job/prisoner/one
	trim_state = "trim_prisoner_1"
	template_access = null

/datum/id_trim/job/prisoner/two
	trim_state = "trim_prisoner_2"
	template_access = null

/datum/id_trim/job/prisoner/three
	trim_state = "trim_prisoner_3"
	template_access = null

/datum/id_trim/job/prisoner/four
	trim_state = "trim_prisoner_4"
	template_access = null

/datum/id_trim/job/prisoner/five
	trim_state = "trim_prisoner_5"
	template_access = null

/datum/id_trim/job/prisoner/six
	trim_state = "trim_prisoner_6"
	template_access = null

/datum/id_trim/job/prisoner/seven
	trim_state = "trim_prisoner_7"
	template_access = null

/datum/id_trim/job/psychologist
	assignment = JOB_PSYCHOLOGIST
	trim_state = "trim_psychologist"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_PSYCHOLOGIST
	minimal_access = list(
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_PSYCHOLOGY,
		ACCESS_SERVICE,
	)
	extra_access = list(
		ACCESS_MORGUE,
		ACCESS_MORGUE_SECURE,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CMO,
		ACCESS_HOP,
	)
	job = /datum/job/psychologist

/datum/id_trim/job/quartermaster
	assignment = JOB_QUARTERMASTER
	intern_alt_name = "Quartermaster-in-Training"
	trim_state = "trim_cargotechnician"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_CARGO_BROWN
	department_state = "departmenthead"
	sechud_icon_state = SECHUD_QUARTERMASTER
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_BIT_DEN,
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_QM,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SHIPPING,
		ACCESS_VAULT,
		ACCESS_KEYCARD_AUTH,
		ACCESS_COMMAND,
		ACCESS_EVA,
		ACCESS_BRIG_ENTRANCE,
		)
	extra_access = list(
		ACCESS_TELEPORTER,
		)
	minimal_wildcard_access = list(
		ACCESS_QM,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
	)
	job = /datum/job/quartermaster
	big_pointer = TRUE
	pointer_color = COLOR_CARGO_BROWN

/datum/id_trim/job/research_director
	assignment = JOB_RESEARCH_DIRECTOR
	intern_alt_name = "Research Director-in-Training"
	trim_state = "trim_scientist"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_SCIENCE_PINK
	department_state = "departmenthead"
	sechud_icon_state = SECHUD_RESEARCH_DIRECTOR
	minimal_access = list(
		ACCESS_AI_UPLOAD,
		ACCESS_AUX_BASE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COMMAND,
		ACCESS_CONSTRUCTION,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_GENETICS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_NETWORK,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MECH_MINING,
		ACCESS_MECH_SECURITY,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_MORGUE,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS,
		ACCESS_SCIENCE,
		ACCESS_TECH_STORAGE,
		ACCESS_TELEPORTER,
		ACCESS_XENOBIOLOGY,
		)
	minimal_wildcard_access = list(
		ACCESS_RD,
		)
	extra_access = list()
	extra_wildcard_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		)
	job = /datum/job/research_director
	big_pointer = TRUE
	pointer_color = COLOR_SCIENCE_PINK

/datum/id_trim/job/roboticist
	assignment = JOB_ROBOTICIST
	trim_state = "trim_roboticist"
	department_color = COLOR_SCIENCE_PINK
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_ROBOTICIST
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS,
		ACCESS_SCIENCE,
		ACCESS_TECH_STORAGE,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		)
	extra_access = list(
		ACCESS_GENETICS,
		ACCESS_XENOBIOLOGY,
		ACCESS_MORGUE_SECURE,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_RD,
		)
	job = /datum/job/roboticist

/datum/id_trim/job/scientist
	assignment = JOB_SCIENTIST
	trim_state = "trim_scientist"
	department_color = COLOR_SCIENCE_PINK
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_SCIENTIST
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		ACCESS_RESEARCH,
		ACCESS_SCIENCE,
		ACCESS_XENOBIOLOGY,
		)
	extra_access = list(
		ACCESS_GENETICS,
		ACCESS_ROBOTICS,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_RD,
		)
	job = /datum/job/scientist

/// Sec officers have departmental variants. They each have their own trims with bonus departmental accesses.
/datum/id_trim/job/security_officer
	assignment = JOB_SECURITY_OFFICER
	trim_state = "trim_securityofficer"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_SECURITY_OFFICER
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		)
	extra_access = list(
		ACCESS_DETECTIVE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MORGUE,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOS,
		)
	job = /datum/job/security_officer
	/// List of bonus departmental accesses that departmental sec officers get by default.
	var/department_access = list()
	/// List of bonus departmental accesses that departmental security officers can in relation to how many overall security officers there are if the scaling system is set up. These can otherwise be granted via config settings.
	var/elevated_access = list()

/datum/id_trim/job/security_officer/refresh_trim_access()
	. = ..()

	if(!.)
		return

	access |= department_access

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

	// Scaling access (POPULATION_SCALED_ACCESS) is a system directly tied into calculations derived via a config entered variable, as well as the amount of players in the shift.
	// Thus, it makes it possible to judge if departmental security officers should have more access to their department on a lower population shift.
	// Server operators can modify config to change it such that security officers can use this system, or alternatively either: A) always give the "elevated" access (ALWAYS_GETS_ACCESS) or B) never give this access (null value).

	#define POPULATION_SCALED_ACCESS 1
	#define ALWAYS_GETS_ACCESS 2

	// If null, then the departmental security officer will not get any elevated access.
	if(!CONFIG_GET(number/depsec_access_level))
		return

	if(CONFIG_GET(number/depsec_access_level) == POPULATION_SCALED_ACCESS)
		var/minimal_security_officers = 3 // We do not spawn in any more lockers if there are 5 or less security officers, so let's keep it lower than that number.
		var/datum/job/J = SSjob.GetJob(JOB_SECURITY_OFFICER)
		if((J.spawn_positions - minimal_security_officers) <= 0)
			access |= elevated_access

	if(CONFIG_GET(number/depsec_access_level) == ALWAYS_GETS_ACCESS)
		access |= elevated_access

/datum/id_trim/job/security_officer/supply
	assignment = JOB_SECURITY_OFFICER_SUPPLY
	subdepartment_color = COLOR_CARGO_BROWN
	department_access = list(
		ACCESS_BIT_DEN,
		ACCESS_CARGO,
		ACCESS_MINING,
		ACCESS_SHIPPING,
	)
	elevated_access = list(
		ACCESS_AUX_BASE,
		ACCESS_MINING_STATION,
	)

/datum/id_trim/job/security_officer/engineering
	assignment = JOB_SECURITY_OFFICER_ENGINEERING
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	department_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_ENGINEERING,
	)
	elevated_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINE_EQUIP,
		ACCESS_TCOMMS,
	)

/datum/id_trim/job/security_officer/medical
	assignment = JOB_SECURITY_OFFICER_MEDICAL
	subdepartment_color = COLOR_MEDICAL_BLUE
	department_access = list(
		ACCESS_MEDICAL,
		ACCESS_MORGUE,
	)
	elevated_access = list(
		ACCESS_PHARMACY,
		ACCESS_PLUMBING,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
	)

/datum/id_trim/job/security_officer/science
	assignment = JOB_SECURITY_OFFICER_SCIENCE
	subdepartment_color = COLOR_SCIENCE_PINK
	department_access = list(
		ACCESS_RESEARCH,
		ACCESS_SCIENCE,
	)
	elevated_access = list(
		ACCESS_AUX_BASE,
		ACCESS_GENETICS,
		ACCESS_ORDNANCE_STORAGE,
		ACCESS_ORDNANCE,
		ACCESS_ROBOTICS,
		ACCESS_XENOBIOLOGY,
	)

/datum/id_trim/job/shaft_miner
	assignment = JOB_SHAFT_MINER
	trim_state = "trim_shaftminer"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_SHAFT_MINER
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CARGO,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		)
	extra_access = list(
		ACCESS_BIT_DEN,
		ACCESS_MAINT_TUNNELS,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_QM,
		)
	job = /datum/job/shaft_miner

/// ID card obtained from the mining Disney dollar points vending machine.
/datum/id_trim/job/shaft_miner/spare
	minimal_access = list(
		ACCESS_CARGO,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		)
	extra_access = list()
	template_access = null

/datum/id_trim/job/station_engineer
	assignment = JOB_STATION_ENGINEER
	trim_state = "trim_stationengineer"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_STATION_ENGINEER
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_TCOMMS,
		ACCESS_TECH_STORAGE,
		)
	extra_access = list(
		ACCESS_ATMOSPHERICS,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CE,
		)
	job = /datum/job/station_engineer

/datum/id_trim/job/veteran_advisor
	assignment = JOB_VETERAN_ADVISOR
	trim_state = "trim_veteranadvisor"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_COMMAND_BLUE
	sechud_icon_state = SECHUD_VETERAN_ADVISOR
	minimal_access = list(
		ACCESS_COMMAND,
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
	)
	extra_access = list()
	template_access = list()
	job = /datum/job/veteran_advisor
	big_pointer = TRUE

/datum/id_trim/job/veteran_advisor/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)


/datum/id_trim/job/warden
	assignment = JOB_WARDEN
	trim_state = "trim_warden"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_WARDEN
	minimal_access = list(
		ACCESS_ARMORY,
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		) // See /datum/job/warden/get_access()
	extra_access = list(
		ACCESS_DETECTIVE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MORGUE,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOS,
		)
	job = /datum/job/warden

/datum/id_trim/job/warden/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

#undef POPULATION_SCALED_ACCESS
#undef ALWAYS_GETS_ACCESS

/datum/id_trim/job/human_ai
	assignment = JOB_HUMAN_AI
	trim_state = "trim_recluse"
	department_color = COLOR_BLUE_GRAY
	subdepartment_color = COLOR_MODERATE_BLUE
	sechud_icon_state = SECHUD_HUMAN_AI
	minimal_access = list(
		ACCESS_ROBOTICS, // to access robotic controls
		ACCESS_NETWORK, //to access NTOS
		ACCESS_KEYCARD_AUTH, //to access holopads
		ACCESS_MINISAT,
		ACCESS_AI_UPLOAD,
	)
	extra_access = list()
	template_access = list()
	job = /datum/job/human_ai
	big_pointer = TRUE
	pointer_color = COLOR_MODERATE_BLUE
