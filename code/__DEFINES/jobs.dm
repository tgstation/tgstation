#define JOB_AVAILABLE 0
#define JOB_UNAVAILABLE_GENERIC 1
#define JOB_UNAVAILABLE_BANNED 2
#define JOB_UNAVAILABLE_PLAYTIME 3
#define JOB_UNAVAILABLE_ACCOUNTAGE 4
#define JOB_UNAVAILABLE_SLOTFULL 5
/// Job unavailable due to incompatibility with an antag role.
#define JOB_UNAVAILABLE_ANTAG_INCOMPAT 6
/// Checks for character age.
#define JOB_UNAVAILABLE_AGE 7

/// Used when the `get_job_unavailable_error_message` proc can't make sense of a given code.
#define GENERIC_JOB_UNAVAILABLE_ERROR "Error: Unknown job availability."

// Human authority settings
// If you want to add another setting, make sure to also add it to the if chain in /datum/job_config_type/human_authority/validate_value()
#define JOB_AUTHORITY_HUMANS_ONLY "HUMANS_ONLY"
#define JOB_AUTHORITY_NON_HUMANS_ALLOWED "NON_HUMANS_ALLOWED"

#define DEFAULT_RELIGION "Christianity"
#define DEFAULT_DEITY "Space Jesus"
#define DEFAULT_BIBLE "Default Bible Name"
#define DEFAULT_BIBLE_REPLACE(religion) "The Holy Book of [religion]"

#define JOB_DISPLAY_ORDER_DEFAULT 0

// Keys for jobconfig.toml
#define JOB_CONFIG_PLAYTIME_REQUIREMENTS "Playtime Requirements"
#define JOB_CONFIG_REQUIRED_ACCOUNT_AGE "Required Account Age"
#define JOB_CONFIG_REQUIRED_CHARACTER_AGE "Required Character Age"
#define JOB_CONFIG_SPAWN_POSITIONS "Spawn Positions"
#define JOB_CONFIG_TOTAL_POSITIONS "Total Positions"
#define JOB_CONFIG_HUMAN_AUTHORITY "Human Authority Whitelist Setting"

/**
 * =======================
 * WARNING WARNING WARNING
 * WARNING WARNING WARNING
 * WARNING WARNING WARNING
 * =======================
 * These names are used as keys in many locations in the database
 * you cannot change them trivially without breaking job bans and
 * role time tracking, if you do this and get it wrong you will die
 * and it will hurt the entire time
 */

//No department
#define JOB_ASSISTANT "Assistant"
#define JOB_PRISONER "Prisoner"
//Command
#define JOB_CAPTAIN "Captain"
#define JOB_HEAD_OF_PERSONNEL "Head of Personnel"
#define JOB_HEAD_OF_SECURITY "Head of Security"
#define JOB_RESEARCH_DIRECTOR "Research Director"
#define JOB_CHIEF_ENGINEER "Chief Engineer"
#define JOB_CHIEF_MEDICAL_OFFICER "Chief Medical Officer"
#define JOB_BRIDGE_ASSISTANT "Bridge Assistant"
#define JOB_VETERAN_ADVISOR "Veteran Security Advisor"
//Silicon
#define JOB_AI "AI"
#define JOB_CYBORG "Cyborg"
#define JOB_PERSONAL_AI "Personal AI"
#define JOB_HUMAN_AI "Big Brother"
//Security
#define JOB_WARDEN "Warden"
#define JOB_DETECTIVE "Detective"
#define JOB_SECURITY_OFFICER "Security Officer"
#define JOB_SECURITY_OFFICER_MEDICAL "Security Officer (Medical)"
#define JOB_SECURITY_OFFICER_ENGINEERING "Security Officer (Engineering)"
#define JOB_SECURITY_OFFICER_SCIENCE "Security Officer (Science)"
#define JOB_SECURITY_OFFICER_SUPPLY "Security Officer (Cargo)"
//Engineering
#define JOB_STATION_ENGINEER "Station Engineer"
#define JOB_ATMOSPHERIC_TECHNICIAN "Atmospheric Technician"
//Medical
#define JOB_CORONER "Coroner"
#define JOB_MEDICAL_DOCTOR "Medical Doctor"
#define JOB_PARAMEDIC "Paramedic"
#define JOB_CHEMIST "Chemist"
//Science
#define JOB_SCIENTIST "Scientist"
#define JOB_ROBOTICIST "Roboticist"
#define JOB_GENETICIST "Geneticist"
//Supply
#define JOB_QUARTERMASTER "Quartermaster"
#define JOB_CARGO_TECHNICIAN "Cargo Technician"
#define JOB_CARGO_GORILLA "Cargo Gorilla"
#define JOB_SHAFT_MINER "Shaft Miner"
#define JOB_BITRUNNER "Bitrunner"
//Service
#define JOB_BARTENDER "Bartender"
#define JOB_BOTANIST "Botanist"
#define JOB_COOK "Cook"
#define JOB_CHEF "Chef" // Alternate cook title.
#define JOB_JANITOR "Janitor"
#define JOB_CLOWN "Clown"
#define JOB_MIME "Mime"
#define JOB_CURATOR "Curator"
#define JOB_LAWYER "Lawyer"
#define JOB_CHAPLAIN "Chaplain"
#define JOB_PSYCHOLOGIST "Psychologist"
#define JOB_PUN_PUN "Pun Pun"
//ERTs
#define JOB_ERT_DEATHSQUAD "Death Commando"
#define JOB_ERT_COMMANDER "Emergency Response Team Commander"
#define JOB_ERT_OFFICER "Security Response Officer"
#define JOB_ERT_ENGINEER "Engineering Response Officer"
#define JOB_ERT_MEDICAL_DOCTOR "Medical Response Officer"
#define JOB_ERT_CHAPLAIN "Religious Response Officer"
#define JOB_ERT_JANITOR "Janitorial Response Officer"
#define JOB_ERT_CLOWN "Entertainment Response Officer"
//CentCom
#define JOB_CENTCOM "Central Command"
#define JOB_CENTCOM_OFFICIAL "CentCom Official"
#define JOB_CENTCOM_ADMIRAL "Admiral"
#define JOB_CENTCOM_COMMANDER "CentCom Commander"
#define JOB_CENTCOM_VIP "VIP Guest"
#define JOB_CENTCOM_BARTENDER "CentCom Bartender"
#define JOB_CENTCOM_CUSTODIAN "Custodian"
#define JOB_CENTCOM_THUNDERDOME_OVERSEER "Thunderdome Overseer"
#define JOB_CENTCOM_MEDICAL_DOCTOR "Medical Officer"
#define JOB_CENTCOM_RESEARCH_OFFICER "Research Officer"
#define JOB_CENTCOM_SPECIAL_OFFICER "Special Ops Officer"
#define JOB_CENTCOM_PRIVATE_SECURITY "Private Security Force"

//Lost crew
#define JOB_LOSTCREW_ENGINEER "Visiting Engineer"
#define JOB_LOSTCREW_MEDICAL "Visiting Doctor"
#define JOB_LOSTCREW_SECURITY "Visiting Officer"
#define JOB_LOSTCREW_SCIENCE "Visiting Scientist"
#define JOB_LOSTCREW_CARGO "Visiting Technician"
#define JOB_LOSTCREW_CIVILLIAN "Visiting Civillian"

#define JOB_GROUP_ENGINEERS list( \
	JOB_STATION_ENGINEER, \
	JOB_ATMOSPHERIC_TECHNICIAN, \
)

//Bots
#define JOB_MEDIBOT "Medibot"

#define JOB_DISPLAY_ORDER_ASSISTANT 1
#define JOB_DISPLAY_ORDER_CAPTAIN 2
#define JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL 3
#define JOB_DISPLAY_ORDER_BRIDGE_ASSISTANT 4
#define JOB_DISPLAY_ORDER_BARTENDER 5
#define JOB_DISPLAY_ORDER_BOTANIST 6
#define JOB_DISPLAY_ORDER_COOK 7
#define JOB_DISPLAY_ORDER_JANITOR 8
#define JOB_DISPLAY_ORDER_CLOWN 9
#define JOB_DISPLAY_ORDER_MIME 10
#define JOB_DISPLAY_ORDER_CURATOR 11
#define JOB_DISPLAY_ORDER_LAWYER 12
#define JOB_DISPLAY_ORDER_CHAPLAIN 13
#define JOB_DISPLAY_ORDER_PSYCHOLOGIST 14
#define JOB_DISPLAY_ORDER_PUN_PUN 15
#define JOB_DISPLAY_ORDER_AI 16
#define JOB_DISPLAY_ORDER_CYBORG 17
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER 18
#define JOB_DISPLAY_ORDER_STATION_ENGINEER 19
#define JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN 20
#define JOB_DISPLAY_ORDER_QUARTERMASTER 21
#define JOB_DISPLAY_ORDER_CARGO_TECHNICIAN 22
#define JOB_DISPLAY_ORDER_SHAFT_MINER 23
#define JOB_DISPLAY_ORDER_BITRUNNER 24
#define JOB_DISPLAY_ORDER_CARGO_GORILLA 25
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER 26
#define JOB_DISPLAY_ORDER_MEDICAL_DOCTOR 27
#define JOB_DISPLAY_ORDER_PARAMEDIC 28
#define JOB_DISPLAY_ORDER_CHEMIST 29
#define JOB_DISPLAY_ORDER_CORONER 30
#define JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR 31
#define JOB_DISPLAY_ORDER_SCIENTIST 32
#define JOB_DISPLAY_ORDER_ROBOTICIST 33
#define JOB_DISPLAY_ORDER_GENETICIST 34
#define JOB_DISPLAY_ORDER_HEAD_OF_SECURITY 35
#define JOB_DISPLAY_ORDER_VETERAN_ADVISOR 36
#define JOB_DISPLAY_ORDER_WARDEN 37
#define JOB_DISPLAY_ORDER_DETECTIVE 38
#define JOB_DISPLAY_ORDER_SECURITY_OFFICER 39
#define JOB_DISPLAY_ORDER_PRISONER 40

#define DEPARTMENT_UNASSIGNED "No Department"

#define DEPARTMENT_BITFLAG_SECURITY (1<<0)
#define DEPARTMENT_SECURITY "Security"
#define DEPARTMENT_BITFLAG_COMMAND (1<<1)
#define DEPARTMENT_COMMAND "Command"
#define DEPARTMENT_BITFLAG_SERVICE (1<<2)
#define DEPARTMENT_SERVICE "Service"
#define DEPARTMENT_BITFLAG_CARGO (1<<3)
#define DEPARTMENT_CARGO "Cargo"
#define DEPARTMENT_BITFLAG_ENGINEERING (1<<4)
#define DEPARTMENT_ENGINEERING "Engineering"
#define DEPARTMENT_BITFLAG_SCIENCE (1<<5)
#define DEPARTMENT_SCIENCE "Science"
#define DEPARTMENT_BITFLAG_MEDICAL (1<<6)
#define DEPARTMENT_MEDICAL "Medical"
#define DEPARTMENT_BITFLAG_SILICON (1<<7)
#define DEPARTMENT_SILICON "Silicon"
#define DEPARTMENT_BITFLAG_ASSISTANT (1<<8)
#define DEPARTMENT_ASSISTANT "Assistant"
#define DEPARTMENT_BITFLAG_CAPTAIN (1<<9)
#define DEPARTMENT_CAPTAIN "Captain"

DEFINE_BITFIELD(departments_bitflags, list(
	"SECURITY" = DEPARTMENT_BITFLAG_SECURITY,
	"COMMAND" = DEPARTMENT_BITFLAG_COMMAND,
	"SERVICE" = DEPARTMENT_BITFLAG_SERVICE,
	"CARGO" = DEPARTMENT_BITFLAG_CARGO,
	"ENGINEERING" = DEPARTMENT_BITFLAG_ENGINEERING,
	"SCIENCE" = DEPARTMENT_BITFLAG_SCIENCE,
	"MEDICAL" = DEPARTMENT_BITFLAG_MEDICAL,
	"SILICON" = DEPARTMENT_BITFLAG_SILICON,
	"ASSISTANT" = DEPARTMENT_BITFLAG_ASSISTANT,
	"CAPTAIN" = DEPARTMENT_BITFLAG_CAPTAIN,
))

/* Job datum job_flags */
/// Whether the mob is announced on arrival.
#define JOB_ANNOUNCE_ARRIVAL (1<<0)
/// Whether the mob is added to the crew manifest.
#define JOB_CREW_MANIFEST (1<<1)
/// Whether the mob is equipped through SSjob.equip_rank() on spawn.
#define JOB_EQUIP_RANK (1<<2)
/// Whether the job is considered a regular crew member of the station. Equipment such as AI and cyborgs not included.
#define JOB_CREW_MEMBER (1<<3)
/// Whether this job can be joined through the new_player menu.
#define JOB_NEW_PLAYER_JOINABLE (1<<4)
/// Whether this job appears in bold in the job menu.
#define JOB_BOLD_SELECT_TEXT (1<<5)
/// Reopens this position if we lose the player at roundstart.
#define JOB_REOPEN_ON_ROUNDSTART_LOSS (1<<6)
/// If the player with this job can have quirks assigned to him or not. Relevant for new player joinable jobs and roundstart antags.
#define JOB_ASSIGN_QUIRKS (1<<7)
/// Whether this job can be an intern.
#define JOB_CAN_BE_INTERN (1<<8)
/// This job cannot have more slots opened by the Head of Personnel (but admins or other random events can still do this).
#define JOB_CANNOT_OPEN_SLOTS (1<<9)
/// This job will not display on the job menu when there are no slots available, instead of appearing greyed out
#define JOB_HIDE_WHEN_EMPTY (1<<10)
/// This job cannot be signed up for at round start or recorded in your preferences
#define JOB_LATEJOIN_ONLY (1<<11)
/// This job is a head of staff.
#define JOB_HEAD_OF_STAFF (1<<12)
/// This job will NEVER be selected as an antag role
#define JOB_ANTAG_BLACKLISTED (1<<13)
/// This job will never be selected as an antag role IF config `protect_roles_from_antagonist` is set
#define JOB_ANTAG_PROTECTED (1<<14)

DEFINE_BITFIELD(job_flags, list(
	"JOB_ANNOUNCE_ARRIVAL" = JOB_ANNOUNCE_ARRIVAL,
	"JOB_CREW_MANIFEST" = JOB_CREW_MANIFEST,
	"JOB_EQUIP_RANK" = JOB_EQUIP_RANK,
	"JOB_CREW_MEMBER" = JOB_CREW_MEMBER,
	"JOB_NEW_PLAYER_JOINABLE" = JOB_NEW_PLAYER_JOINABLE,
	"JOB_BOLD_SELECT_TEXT" = JOB_BOLD_SELECT_TEXT,
	"JOB_REOPEN_ON_ROUNDSTART_LOSS" = JOB_REOPEN_ON_ROUNDSTART_LOSS,
	"JOB_ASSIGN_QUIRKS" = JOB_ASSIGN_QUIRKS,
	"JOB_CAN_BE_INTERN" = JOB_CAN_BE_INTERN,
	"JOB_CANNOT_OPEN_SLOTS" = JOB_CANNOT_OPEN_SLOTS,
	"JOB_HIDE_WHEN_EMPTY" = JOB_HIDE_WHEN_EMPTY,
	"JOB_LATEJOIN_ONLY" = JOB_LATEJOIN_ONLY,
	"JOB_HEAD_OF_STAFF" = JOB_HEAD_OF_STAFF,
))

/// Combination flag for jobs which are considered regular crew members of the station.
#define STATION_JOB_FLAGS (JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS|JOB_CAN_BE_INTERN)
/// Combination flag for jobs which are considered heads of staff.
#define HEAD_OF_STAFF_JOB_FLAGS (JOB_BOLD_SELECT_TEXT|JOB_CANNOT_OPEN_SLOTS|JOB_HEAD_OF_STAFF)
/// Combination flag for jobs which are enabled by station traits.
#define STATION_TRAIT_JOB_FLAGS (JOB_CANNOT_OPEN_SLOTS|JOB_HIDE_WHEN_EMPTY|JOB_LATEJOIN_ONLY&~JOB_REOPEN_ON_ROUNDSTART_LOSS)

#define FACTION_NONE "None"
#define FACTION_STATION "Station"

// Variable macros used to declare who is the supervisor for a given job, announced to the player when they join as any given job.
#define SUPERVISOR_CAPTAIN "the Captain"
#define SUPERVISOR_CE "the Chief Engineer"
#define SUPERVISOR_CMO "the Chief Medical Officer"
#define SUPERVISOR_HOP "the Head of Personnel"
#define SUPERVISOR_HOS "the Head of Security"
#define SUPERVISOR_QM "the Quartermaster"
#define SUPERVISOR_RD "the Research Director"

/// Mind traits that should be shared by every head of staff. has to be this way cause byond lists lol
#define HEAD_OF_STAFF_MIND_TRAITS TRAIT_FAST_TYING, TRAIT_HIGH_VALUE_RANSOM
