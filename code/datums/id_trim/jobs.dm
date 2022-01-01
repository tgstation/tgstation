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
	/// What config entry relates to this job. Should be a lowercase job name with underscores for spaces, eg "prisoner" "research_director" "head_of_security"
	var/config_job
	/// An ID card with an access in this list can apply this trim to IDs or use it as a job template when adding access to a card. If the list is null, cannot be used as a template. Should be Head of Staff or ID Console accesses or it may do nothing.
	var/list/template_access
	/// The typepath to the job datum from the id_trim. This is converted to one of the job singletons in New().
	var/datum/job/job = /datum/job/unassigned

/datum/id_trim/job/New()
	if(ispath(job))
		job = SSjob.GetJobType(job)

	if(isnull(job_changes))
		job_changes = SSmapping.config.job_changes

	if(!length(job_changes) || !config_job)
		refresh_trim_access()
		return

	var/list/access_changes = job_changes[config_job]

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
	assignment = "Assistant"
	trim_state = "trim_assistant"
	extra_access = list(ACCESS_MAINT_TUNNELS)
	minimal_access = list()
	config_job = "assistant"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/assistant

/datum/id_trim/job/assistant/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config has assistant maint access set.
	if(CONFIG_GET(flag/assistants_have_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/atmospheric_technician
	assignment = "Atmospheric Technician"
	trim_state = "trim_atmospherictechnician"
	extra_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)
	minimal_access = list(ACCESS_ATMOSPHERICS, ACCESS_AUX_BASE, ACCESS_CONSTRUCTION, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
					ACCESS_MINERAL_STOREROOM)
	config_job = "atmospheric_technician"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CE, ACCESS_CHANGE_IDS)
	job = /datum/job/atmospheric_technician

/datum/id_trim/job/bartender
	assignment = "Bartender"
	trim_state = "trim_bartender"
	extra_access = list(ACCESS_HYDROPONICS, ACCESS_KITCHEN, ACCESS_MORGUE)
	minimal_access = list(ACCESS_BAR, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE, ACCESS_WEAPONS, ACCESS_SERVICE)
	config_job = "bartender"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/bartender

/datum/id_trim/job/botanist
	assignment = "Botanist"
	trim_state = "trim_botanist"
	extra_access = list(ACCESS_BAR, ACCESS_KITCHEN)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_SERVICE)
	config_job = "botanist"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/botanist

/datum/id_trim/job/captain
	assignment = "Captain"
	trim_state = "trim_captain"
	config_job = "captain"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CHANGE_IDS)
	job = /datum/job/captain

/// Captain gets all station accesses hardcoded in because it's the Captain.
/datum/id_trim/job/captain/New()
	extra_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_COMMON) + SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND))
	extra_wildcard_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_PRV_COMMAND) + SSid_access.get_flag_access_list(ACCESS_FLAG_CAPTAIN))
	minimal_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_COMMON) + SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND))
	minimal_wildcard_access |= (SSid_access.get_flag_access_list(ACCESS_FLAG_PRV_COMMAND) + SSid_access.get_flag_access_list(ACCESS_FLAG_CAPTAIN))

	return ..()

/datum/id_trim/job/cargo_technician
	assignment = "Cargo Technician"
	trim_state = "trim_cargotechnician"
	extra_access = list(ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM)
	config_job = "cargo_technician"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/cargo_technician

/datum/id_trim/job/chaplain
	assignment = "Chaplain"
	trim_state = "trim_chaplain"
	extra_access = list()
	minimal_access = list(ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MORGUE, ACCESS_THEATRE, ACCESS_SERVICE)
	config_job = "chaplain"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/chaplain

/datum/id_trim/job/chemist
	assignment = "Chemist"
	trim_state = "trim_chemist"
	extra_access = list(ACCESS_SURGERY, ACCESS_VIROLOGY)
	minimal_access = list(ACCESS_CHEMISTRY, ACCESS_MECH_MEDICAL, ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_PHARMACY)
	config_job = "chemist"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CMO, ACCESS_CHANGE_IDS)
	job = /datum/job/chemist

/datum/id_trim/job/chief_engineer
	assignment = "Chief Engineer"
	trim_state = "trim_chiefengineer"
	extra_access = list(ACCESS_TELEPORTER)
	extra_wildcard_access = list()
	minimal_access = list(ACCESS_ATMOSPHERICS, ACCESS_AUX_BASE, ACCESS_CE, ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_EVA,
					ACCESS_EXTERNAL_AIRLOCKS, ACCESS_HEADS, ACCESS_KEYCARD_AUTH, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
					ACCESS_MINERAL_STOREROOM, ACCESS_MINISAT, ACCESS_RC_ANNOUNCE, ACCESS_SEC_DOORS, ACCESS_TCOMSAT, ACCESS_TECH_STORAGE)
	minimal_wildcard_access = list(ACCESS_CE)
	config_job = "chief_engineer"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CHANGE_IDS)
	job = /datum/job/chief_engineer

/datum/id_trim/job/chief_medical_officer
	assignment = "Chief Medical Officer"
	trim_state = "trim_chiefmedicalofficer"
	extra_access = list(ACCESS_TELEPORTER)
	extra_wildcard_access = list()
	minimal_access = list(ACCESS_CHEMISTRY, ACCESS_EVA, ACCESS_HEADS, ACCESS_KEYCARD_AUTH, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MEDICAL,
					ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_PHARMACY, ACCESS_PSYCHOLOGY, ACCESS_RC_ANNOUNCE,
					ACCESS_SEC_DOORS, ACCESS_SURGERY, ACCESS_VIROLOGY)
	minimal_wildcard_access = list(ACCESS_CMO)
	config_job = "chief_medical_officer"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CHANGE_IDS)
	job = /datum/job/chief_medical_officer

/datum/id_trim/job/clown
	assignment = "Clown"
	trim_state = "trim_clown"
	extra_access = list()
	minimal_access = list(ACCESS_THEATRE, ACCESS_SERVICE)
	config_job = "clown"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/clown

/datum/id_trim/job/cook
	assignment = "Cook"
	trim_state = "trim_cook"
	extra_access = list(ACCESS_BAR, ACCESS_HYDROPONICS)
	minimal_access = list(ACCESS_KITCHEN, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_SERVICE)
	config_job = "cook"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/cook

/datum/id_trim/job/curator
	assignment = "Curator"
	trim_state = "trim_curator"
	extra_access = list()
	minimal_access = list(ACCESS_AUX_BASE, ACCESS_LIBRARY, ACCESS_MINING_STATION, ACCESS_SERVICE)
	config_job = "curator"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/curator

/datum/id_trim/job/detective
	assignment = "Detective"
	trim_state = "trim_detective"
	extra_access = list()
	minimal_access = list(ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS, ACCESS_SEC_DOORS,ACCESS_MAINT_TUNNELS, ACCESS_MORGUE,
					ACCESS_MECH_SECURITY, ACCESS_MINERAL_STOREROOM, ACCESS_WEAPONS)
	config_job = "detective"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOS, ACCESS_CHANGE_IDS)
	job = /datum/job/detective

/datum/id_trim/job/detective/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/geneticist
	assignment = "Geneticist"
	trim_state = "trim_geneticist"
	extra_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_XENOBIOLOGY)
	minimal_access = list(ACCESS_GENETICS, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_RND)
	config_job = "geneticist"
	template_access = list(ACCESS_CAPTAIN, ACCESS_RD, ACCESS_CHANGE_IDS)
	job = /datum/job/geneticist

/datum/id_trim/job/head_of_personnel
	assignment = "Head of Personnel"
	trim_state = "trim_headofpersonnel"
	extra_access = list()
	extra_wildcard_access = list()
	minimal_access = list(ACCESS_AI_UPLOAD, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_AUX_BASE, ACCESS_BAR, ACCESS_CARGO, ACCESS_CHAPEL_OFFICE,
					ACCESS_CHANGE_IDS, ACCESS_CONSTRUCTION, ACCESS_COURT, ACCESS_CREMATORIUM, ACCESS_ENGINE, ACCESS_EVA, ACCESS_GATEWAY,
					ACCESS_HEADS, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_KEYCARD_AUTH, ACCESS_KITCHEN, ACCESS_LAWYER, ACCESS_LIBRARY,
					ACCESS_MAILSORTING, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MINING, ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM,
					ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MORGUE, ACCESS_PSYCHOLOGY, ACCESS_QM, ACCESS_RC_ANNOUNCE,
					ACCESS_RESEARCH, ACCESS_SEC_DOORS, ACCESS_TELEPORTER, ACCESS_THEATRE, ACCESS_VAULT, ACCESS_WEAPONS, ACCESS_SERVICE)
	minimal_wildcard_access = list(ACCESS_HOP)
	config_job = "head_of_personnel"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CHANGE_IDS)
	job = /datum/job/head_of_personnel

/datum/id_trim/job/head_of_security
	assignment = "Head of Security"
	trim_state = "trim_headofsecurity"
	extra_access = list(ACCESS_TELEPORTER)
	extra_wildcard_access = list()
	minimal_access = list(ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_ARMORY, ACCESS_AUX_BASE, ACCESS_BRIG, ACCESS_CONSTRUCTION, ACCESS_COURT,
					ACCESS_ENGINE, ACCESS_EVA, ACCESS_FORENSICS_LOCKERS, ACCESS_GATEWAY, ACCESS_HEADS, ACCESS_KEYCARD_AUTH,
					ACCESS_MAILSORTING, ACCESS_MAINT_TUNNELS, ACCESS_MECH_SECURITY, ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM,
					ACCESS_MINING, ACCESS_MORGUE, ACCESS_RC_ANNOUNCE, ACCESS_RESEARCH, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_WEAPONS)
	minimal_wildcard_access = list(ACCESS_HOS)
	config_job = "head_of_security"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CHANGE_IDS)
	job = /datum/job/head_of_security

/datum/id_trim/job/head_of_security/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/janitor
	assignment = "Janitor"
	trim_state = "trim_janitor"
	extra_access = list()
	minimal_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_SERVICE)
	config_job = "janitor"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/janitor

/datum/id_trim/job/lawyer
	assignment = "Lawyer"
	trim_state = "trim_lawyer"
	extra_access = list()
	minimal_access = list(ACCESS_COURT, ACCESS_LAWYER, ACCESS_SEC_DOORS, ACCESS_SERVICE)
	config_job = "lawyer"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_HOS, ACCESS_CHANGE_IDS)
	job = /datum/job/lawyer

/datum/id_trim/job/medical_doctor
	assignment = "Medical Doctor"
	trim_state = "trim_medicaldoctor"
	extra_access = list(ACCESS_CHEMISTRY, ACCESS_VIROLOGY)
	minimal_access = list(ACCESS_MECH_MEDICAL, ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_PHARMACY, ACCESS_SURGERY)
	config_job = "medical_doctor"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CMO, ACCESS_CHANGE_IDS)
	job = /datum/job/doctor

/datum/id_trim/job/mime
	assignment = "Mime"
	trim_state = "trim_mime"
	extra_access = list()
	minimal_access = list(ACCESS_THEATRE, ACCESS_SERVICE)
	config_job = "mime"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/mime

/datum/id_trim/job/paramedic
	assignment = "Paramedic"
	trim_state = "trim_paramedic"
	extra_access = list(ACCESS_SURGERY)
	minimal_access = list(ACCESS_AUX_BASE, ACCESS_CARGO, ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_EVA, ACCESS_HYDROPONICS,
					ACCESS_MAINT_TUNNELS, ACCESS_MECH_MEDICAL, ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_RESEARCH)
	config_job = "paramedic"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CMO, ACCESS_CHANGE_IDS)
	job = /datum/job/paramedic

/datum/id_trim/job/prisoner
	assignment = "Prisoner"
	trim_state = "trim_prisoner"
	config_job = "prisoner"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_HOS, ACCESS_CHANGE_IDS)
	job = /datum/job/prisoner

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
	assignment = "Psychologist"
	trim_state = "trim_psychologist"
	extra_access = list()
	minimal_access = list(ACCESS_MEDICAL, ACCESS_PSYCHOLOGY, ACCESS_SERVICE)
	config_job = "psychologist"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CMO, ACCESS_CHANGE_IDS)
	job = /datum/job/psychologist

/datum/id_trim/job/quartermaster
	assignment = "Quartermaster"
	trim_state = "trim_quartermaster"
	extra_access = list()
	minimal_access = list(ACCESS_AUX_BASE, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MINING, ACCESS_MINING_STATION,
					ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_QM, ACCESS_RC_ANNOUNCE, ACCESS_VAULT)
	config_job = "quartermaster"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/quartermaster

/datum/id_trim/job/research_director
	assignment = "Research Director"
	trim_state = "trim_researchdirector"
	extra_access = list()
	extra_wildcard_access = list()
	minimal_access = list(ACCESS_AI_UPLOAD, ACCESS_AUX_BASE, ACCESS_EVA, ACCESS_GATEWAY, ACCESS_GENETICS, ACCESS_HEADS, ACCESS_KEYCARD_AUTH,
					ACCESS_NETWORK, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_MECH_MINING, ACCESS_MECH_SECURITY, ACCESS_MECH_SCIENCE,
					ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINISAT, ACCESS_MORGUE,
					ACCESS_ORDNANCE, ACCESS_ORDNANCE_STORAGE, ACCESS_RC_ANNOUNCE, ACCESS_RESEARCH, ACCESS_RND, ACCESS_ROBOTICS,
					ACCESS_SEC_DOORS, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_XENOBIOLOGY)
	minimal_wildcard_access = list(ACCESS_RD)
	config_job = "research_director"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CHANGE_IDS)
	job = /datum/job/research_director

/datum/id_trim/job/roboticist
	assignment = "Roboticist"
	trim_state = "trim_roboticist"
	extra_access = list(ACCESS_GENETICS, ACCESS_ORDNANCE, ACCESS_ORDNANCE_STORAGE, ACCESS_XENOBIOLOGY)
	minimal_access = list(ACCESS_AUX_BASE, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_RND,
					ACCESS_ROBOTICS, ACCESS_TECH_STORAGE)
	config_job = "roboticist"
	template_access = list(ACCESS_CAPTAIN, ACCESS_RD, ACCESS_CHANGE_IDS)
	job = /datum/job/roboticist

/datum/id_trim/job/scientist
	assignment = "Scientist"
	trim_state = "trim_scientist"
	extra_access = list(ACCESS_GENETICS, ACCESS_ROBOTICS)
	minimal_access = list(ACCESS_AUX_BASE, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM, ACCESS_ORDNANCE, ACCESS_ORDNANCE_STORAGE,
					ACCESS_RESEARCH, ACCESS_RND, ACCESS_XENOBIOLOGY)
	config_job = "scientist"
	template_access = list(ACCESS_CAPTAIN, ACCESS_RD, ACCESS_CHANGE_IDS)
	job = /datum/job/scientist

/// Sec officers have departmental variants. They each have their own trims with bonus departmental accesses.
/datum/id_trim/job/security_officer
	assignment = "Security Officer"
	trim_state = "trim_securityofficer"
	extra_access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE)
	minimal_access = list(ACCESS_BRIG, ACCESS_COURT, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY,
					ACCESS_MINERAL_STOREROOM, ACCESS_WEAPONS)
	/// List of bonus departmental accesses that departmental sec officers get.
	var/department_access = list()
	config_job = "security_officer"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOS, ACCESS_CHANGE_IDS)
	job = /datum/job/security_officer

/datum/id_trim/job/security_officer/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

	access |= department_access

/datum/id_trim/job/security_officer/supply
	assignment = "Security Officer (Cargo)"
	trim_state = "trim_securityofficer_car"
	department_access = list(ACCESS_AUX_BASE, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION)

/datum/id_trim/job/security_officer/engineering
	assignment = "Security Officer (Engineering)"
	trim_state = "trim_securityofficer_engi"
	department_access = list(ACCESS_ATMOSPHERICS, ACCESS_AUX_BASE, ACCESS_CONSTRUCTION, ACCESS_ENGINE)

/datum/id_trim/job/security_officer/medical
	assignment = "Security Officer (Medical)"
	trim_state = "trim_securityofficer_med"
	department_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY)

/datum/id_trim/job/security_officer/science
	assignment = "Security Officer (Science)"
	trim_state = "trim_securityofficer_sci"
	department_access = list(ACCESS_AUX_BASE, ACCESS_RESEARCH, ACCESS_RND)

/datum/id_trim/job/shaft_miner
	assignment = "Shaft Miner"
	trim_state = "trim_shaftminer"
	extra_access = list(ACCESS_CARGO, ACCESS_MAINT_TUNNELS, ACCESS_QM)
	minimal_access = list(ACCESS_AUX_BASE, ACCESS_MAILSORTING, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_MINING,
					ACCESS_MINING_STATION)
	config_job = "shaft_miner"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/shaft_miner

/// ID card obtained from the mining Disney dollar points vending machine.
/datum/id_trim/job/shaft_miner/spare
	extra_access = list()
	minimal_access = list(ACCESS_MAILSORTING, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MINING_STATION)
	template_access = null

/datum/id_trim/job/station_engineer
	assignment = "Station Engineer"
	trim_state = "trim_stationengineer"
	extra_access = list(ACCESS_ATMOSPHERICS)
	minimal_access = list(ACCESS_AUX_BASE, ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_EXTERNAL_AIRLOCKS,
					ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_MINERAL_STOREROOM, ACCESS_TCOMSAT, ACCESS_TECH_STORAGE)
	config_job = "station_engineer"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CE, ACCESS_CHANGE_IDS)
	job = /datum/job/station_engineer

/datum/id_trim/job/virologist
	assignment = "Virologist"
	trim_state = "trim_virologist"
	extra_access = list(ACCESS_CHEMISTRY, ACCESS_MORGUE, ACCESS_SURGERY)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_VIROLOGY)
	config_job = "virologist"
	template_access = list(ACCESS_CAPTAIN, ACCESS_CMO, ACCESS_CHANGE_IDS)
	job = /datum/job/virologist

/datum/id_trim/job/warden
	assignment = "Warden"
	trim_state = "trim_warden"
	extra_access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE)
	minimal_access = list(ACCESS_ARMORY, ACCESS_BRIG, ACCESS_COURT, ACCESS_MECH_SECURITY, ACCESS_MINERAL_STOREROOM,
					ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_WEAPONS) // See /datum/job/warden/get_access()
	config_job = "warden"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOS, ACCESS_CHANGE_IDS)
	job = /datum/job/warden

/datum/id_trim/job/warden/refresh_trim_access()
	. = ..()

	if(!.)
		return

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/barber
	assignment = "Barber"
	trim_state = "trim_barber"
	extra_access = list(ACCESS_HYDROPONICS)
	minimal_access = list(ACCESS_BARBER)
	config_job = "barber"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/barber

/datum/id_trim/job/tailor
	assignment = "Tailor"
	trim_state = "trim_tailor"
	extra_access = list(ACCESS_HYDROPONICS)
	minimal_access = list(ACCESS_TAILOR)
	config_job = "tailor"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/tailor
