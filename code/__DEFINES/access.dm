
/* Access is broken down by department, department special functions/rooms, and departmental roles
	The first access for the department will always be its general access function
	Access for departmental roles will start with the head and go down in level of succession
	If we ever get to a point where we have more departmental roles than the five (four) available slots, we should be looking to make some job access more generic
	Access goes from Command, Security, Engineering, Medical, Supply, Science, Service, Away Missions, Mech Access, Admin, then Antag
	Please try to make the strings for any new accesses as close to the name of the define as possible
	If you are going to add an access to the list, make sure to also add it to its respective region further below
	If you're varediting on the map, it uses the string. If you're editing the object directly, use the define name*/

/// Command general access, EVA storage windoors, gateway shuters, AI integrity restorer, comms console
#define ACCESS_COMMAND "command"
#define ACCESS_AI_UPLOAD "ai_upload"
#define ACCESS_TELEPORTER "teleporter"
#define ACCESS_EVA "eva"
///Request console announcements
#define ACCESS_RC_ANNOUNCE "rc_announce"
/// Used for events which require at least two people to confirm them
#define ACCESS_KEYCARD_AUTH "keycard_auth"
#define ACCESS_MINISAT "minisat"
/// NTnet diagnostics/monitoring software
#define ACCESS_NETWORK "network"
#define ACCESS_GATEWAY "gateway"
#define ACCESS_ALL_PERSONAL_LOCKERS "all_personal_lockers"
#define ACCESS_CHANGE_IDS "change_ids"
#define ACCESS_CAPTAIN "captain"
#define ACCESS_HOP "hop"

/// Security general access, security records, gulag item storage, secbots
#define ACCESS_SECURITY "security"
/// Outer brig doors
#define ACCESS_BRIG_ENTRANCE "brig_entrance"
/// Brig cells+timers, permabrig, gulag+gulag shuttle, prisoner management console, security equipment
#define ACCESS_BRIG "brig"
/// Armory, gulag teleporter, execution chamber
#define ACCESS_ARMORY "armory"
#define ACCESS_COURT "court"
/// Weapon authorization for secbots
#define ACCESS_WEAPONS "weapons"
#define ACCESS_HOS "hos"
///Detective's office, forensics lockers, security+medical records
#define ACCESS_DETECTIVE "detective"

/// Engineering general access, power monitor, power flow control console
#define ACCESS_ENGINEERING "engineering"
#define ACCESS_ATMOSPHERICS "atmospherics"
#define ACCESS_MAINT_TUNNELS "maint_tunnels"
///APCs, EngiVend/YouTool, engineering equipment lockers
#define ACCESS_ENGINE_EQUIP "engine_equip"
#define ACCESS_CONSTRUCTION "construction"
#define ACCESS_TECH_STORAGE "tech_storage"
/// has access to the entire telecomms satellite / machinery
#define ACCESS_TCOMMS "tcomms"
/// Room and launching.
#define ACCESS_AUX_BASE "aux_base"
#define ACCESS_EXTERNAL_AIRLOCKS "external airlocks"
#define ACCESS_CE "ce"

/// Medical general access
#define ACCESS_MEDICAL "medical"
#define ACCESS_MORGUE "morgue"
/// Pharmacy access (Chemistry room in Medbay)
#define ACCESS_PHARMACY "pharmacy"
#define ACCESS_SURGERY "surgery"
///Allows access to chemistry factory areas on compatible maps
#define ACCESS_PLUMBING "plumbing"

#define ACCESS_CMO "cmo"
#define ACCESS_VIROLOGY "virology"
#define ACCESS_PSYCHOLOGY "psychology"

///Cargo general access
#define ACCESS_CARGO "cargo"
#define ACCESS_MAIL_SORTING "mail_sorting"
/// For releasing minerals from the ORM
#define ACCESS_MINERAL_STOREROOM "mineral_storeroom"
#define ACCESS_MINING_STATION "mining_station"
#define ACCESS_VAULT "vault"
#define ACCESS_QM "qm"
#define ACCESS_MINING "mining"

///Science general access
#define ACCESS_SCIENCE "science"
#define ACCESS_RESEARCH "research"
#define ACCESS_ORDNANCE_STORAGE "ordnance_storage"
#define ACCESS_RD "rd"
#define ACCESS_GENETICS "genetics"
#define ACCESS_ROBOTICS "robotics"
#define ACCESS_ORDNANCE "ordnance"
#define ACCESS_XENOBIOLOGY "xenobiology"

///Service general access
#define ACCESS_SERVICE "service"
#define ACCESS_THEATRE "theatre"
#define ACCESS_CHAPEL_OFFICE "chapel_office"
#define ACCESS_CREMATORIUM "crematorium"
#define ACCESS_LIBRARY "library"
#define ACCESS_BAR "bar"
#define ACCESS_KITCHEN "kitchen"
#define ACCESS_HYDROPONICS "hydroponics"
#define ACCESS_JANITOR "janitor"
#define ACCESS_LAWYER "lawyer"

/// - - - AWAY MISSIONS - - -
/*For generic away-mission/ruin access. Why would normal crew have access to a long-abandoned derelict
	or a 2000 year-old temple? */
#define ACCESS_AWAY_GENERAL "away_general"
#define ACCESS_AWAY_COMMAND "away_command"
#define ACCESS_AWAY_SEC "away_sec"
#define ACCESS_AWAY_ENGINEERING "away_engineering"
#define ACCESS_AWAY_MEDICAL "away_medical"
#define ACCESS_AWAY_SUPPLY "away_supply"
#define ACCESS_AWAY_SCIENCE "away_science"
#define ACCESS_AWAY_MAINTENANCE "away_maintenance"
#define ACCESS_AWAY_GENERIC1 "away_generic1"
#define ACCESS_AWAY_GENERIC2 "away_generic2"
#define ACCESS_AWAY_GENERIC3 "away_generic3"
#define ACCESS_AWAY_GENERIC4 "away_generic4"

/// - - - MECH - - -
	// Mech Access, allows maintanenace of internal components and altering keycard requirements.
#define ACCESS_MECH_MINING "mech_mining"
#define ACCESS_MECH_MEDICAL "mech_medical"
#define ACCESS_MECH_SECURITY "mech_security"
#define ACCESS_MECH_SCIENCE "mech_science"
#define ACCESS_MECH_ENGINE "mech_engine"

/// - - - ADMIN - - -
	// Used for admin events and things of the like. Lots of extra space for more admin tools in the future
/// General facilities. Centcom ferry.
#define ACCESS_CENT_GENERAL "cent_general"
#define ACCESS_CENT_THUNDER "cent_thunder"
#define ACCESS_CENT_MEDICAL "cent_medical"
#define ACCESS_CENT_LIVING "cent_living"
#define ACCESS_CENT_STORAGE "cent_storage"
#define ACCESS_CENT_TELEPORTER "cent_teleporter"
#define ACCESS_CENT_CAPTAIN "cent_captain"
#define ACCESS_CENT_BAR "cent_bar"
/// Special Ops. Captain's display case, Marauder and Seraph mechs.
#define ACCESS_CENT_SPECOPS 188 ///Remind me to separate to captain, centcom, and syndicate mech access later -SonofSpace

/// - - - ANTAGONIST - - -
/// SYNDICATE
#define ACCESS_SYNDICATE "syndicate"
#define ACCESS_SYNDICATE_LEADER "syndicate_leader"
/// BLOODCULT
	//Special, for anything that's basically internal
#define ACCESS_BLOODCULT "bloodcult"

/// - - - END ACCESS IDS - - -

/// A list of access levels that, when added to an ID card, will warn admins.
#define ACCESS_ALERT_ADMINS list(ACCESS_CHANGE_IDS)

/// Logging define for ID card access changes
#define LOG_ID_ACCESS_CHANGE(user, id_card, change_description) \
	log_game("[key_name(user)] [change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]"); \
	user.investigate_log("([key_name(user)]) [change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]", INVESTIGATE_ACCESSCHANGES); \
	user.log_message("[change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]", LOG_GAME); \

/// Displayed name for Common ID card accesses.
#define ACCESS_FLAG_COMMON_NAME "Common"
/// Bitflag for Common ID card accesses. See COMMON_ACCESS.
#define ACCESS_FLAG_COMMON (1 << 0)
/// Displayed name for Command ID card accesses.
#define ACCESS_FLAG_COMMAND_NAME "Command"
/// Bitflag for Command ID card accesses. See COMMAND_ACCESS.
#define ACCESS_FLAG_COMMAND (1 << 1)
/// Displayed name for Private Command ID card accesses.
#define ACCESS_FLAG_PRV_COMMAND_NAME "Private Command"
/// Bitflag for Private Command ID card accesses. See PRIVATE_COMMAND_ACCESS.
#define ACCESS_FLAG_PRV_COMMAND (1 << 2)
/// Displayed name for Captain ID card accesses.
#define ACCESS_FLAG_CAPTAIN_NAME "Captain"
/// Bitflag for Captain ID card accesses. See CAPTAIN_ACCESS.
#define ACCESS_FLAG_CAPTAIN (1 << 3)
/// Displayed name for Centcom ID card accesses.
#define ACCESS_FLAG_CENTCOM_NAME "Centcom"
/// Bitflag for Centcom ID card accesses. See CENTCOM_ACCESS.
#define ACCESS_FLAG_CENTCOM (1 << 4)
/// Displayed name for Syndicate ID card accesses.
#define ACCESS_FLAG_SYNDICATE_NAME "Syndicate"
/// Bitflag for Syndicate ID card accesses. See SYNDICATE_ACCESS.
#define ACCESS_FLAG_SYNDICATE (1 << 5)
/// Displayed name for Offstation/Ruin/Away Mission ID card accesses.
#define ACCESS_FLAG_AWAY_NAME "Away"
/// Bitflag for Offstation/Ruin/Away Mission ID card accesses. See AWAY_ACCESS.
#define ACCESS_FLAG_AWAY (1 << 6)
/// Displayed name for Special accesses that ordinaryily shouldn't be on ID cards.
#define ACCESS_FLAG_SPECIAL_NAME "Special"
/// Bitflag for Special accesses that ordinaryily shouldn't be on ID cards. See CULT_ACCESS.
#define ACCESS_FLAG_SPECIAL (1 << 7)

/// This wildcraft flag accepts any access level.
#define WILDCARD_FLAG_ALL ALL
/// Name associated with the all wildcard bitflag.
#define WILDCARD_NAME_ALL "All"
/// Access flags that can be applied to common wildcard slots.
#define WILDCARD_FLAG_COMMON ACCESS_FLAG_COMMON
/// Name associated with the common wildcard bitflag.
#define WILDCARD_NAME_COMMON ACCESS_FLAG_COMMON_NAME
/// Access flags that can be applied to command wildcard slots.
#define WILDCARD_FLAG_COMMAND ACCESS_FLAG_COMMON | ACCESS_FLAG_COMMAND
/// Name associated with the command wildcard bitflag.
#define WILDCARD_NAME_COMMAND ACCESS_FLAG_COMMAND_NAME
/// Access flags that can be applied to private command wildcard slots.
#define WILDCARD_FLAG_PRV_COMMAND ACCESS_FLAG_COMMON | ACCESS_FLAG_COMMAND | ACCESS_FLAG_PRV_COMMAND
/// Name associated with the private command wildcard bitflag.
#define WILDCARD_NAME_PRV_COMMAND ACCESS_FLAG_PRV_COMMAND_NAME
/// Access flags that can be applied to captain wildcard slots.
#define WILDCARD_FLAG_CAPTAIN ACCESS_FLAG_COMMON | ACCESS_FLAG_COMMAND | ACCESS_FLAG_PRV_COMMAND | ACCESS_FLAG_CAPTAIN
/// Name associated with the captain wildcard bitflag.
#define WILDCARD_NAME_CAPTAIN ACCESS_FLAG_CAPTAIN_NAME
/// Access flags that can be applied to centcom wildcard slots.
#define WILDCARD_FLAG_CENTCOM ACCESS_FLAG_COMMON | ACCESS_FLAG_COMMAND | ACCESS_FLAG_PRV_COMMAND | ACCESS_FLAG_CAPTAIN | ACCESS_FLAG_CENTCOM
/// Name associated with the centcom wildcard bitflag.
#define WILDCARD_NAME_CENTCOM ACCESS_FLAG_CENTCOM_NAME
/// Access flags that can be applied to syndicate wildcard slots.
#define WILDCARD_FLAG_SYNDICATE ACCESS_FLAG_COMMON | ACCESS_FLAG_COMMAND | ACCESS_FLAG_PRV_COMMAND | ACCESS_FLAG_CAPTAIN | ACCESS_FLAG_SYNDICATE
/// Name associated with the syndicate wildcard bitflag.
#define WILDCARD_NAME_SYNDICATE ACCESS_FLAG_SYNDICATE_NAME
/// Access flags that can be applied to offstation wildcard slots.
#define WILDCARD_FLAG_AWAY ACCESS_FLAG_AWAY
/// Name associated with the offstation wildcard bitflag.
#define WILDCARD_NAME_AWAY ACCESS_FLAG_AWAY_NAME
/// Access flags that can be applied to super special weird wildcard slots.
#define WILDCARD_FLAG_SPECIAL ACCESS_FLAG_SPECIAL
/// Name associated with the super special weird wildcard bitflag.
#define WILDCARD_NAME_SPECIAL ACCESS_FLAG_SPECIAL_NAME
/// Access flag that indicates a wildcard was forced onto an ID card.
#define WILDCARD_FLAG_FORCED ALL
/// Name associated with the wildcard bitflag that covers wildcards that have been forced onto an ID card that could not accept them.
#define WILDCARD_NAME_FORCED "Hacked"

/// Departmental/general/common area accesses. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_COMMON)
#define COMMON_ACCESS list( \
	ACCESS_MECH_MINING, \
	ACCESS_MECH_MEDICAL, \
	ACCESS_MECH_SECURITY, \
	ACCESS_MECH_SCIENCE, \
	ACCESS_MECH_ENGINE, \
	ACCESS_AUX_BASE, \
	ACCESS_PSYCHOLOGY, \
	ACCESS_PHARMACY, \
	ACCESS_NETWORK, \
	ACCESS_WEAPONS, \
	ACCESS_MINERAL_STOREROOM, \
	ACCESS_BRIG_ENTRANCE, \
	ACCESS_XENOBIOLOGY, \
	ACCESS_MINING_STATION, \
	ACCESS_MAIL_SORTING, \
	ACCESS_MINING, \
	ACCESS_RESEARCH, \
	ACCESS_THEATRE, \
	ACCESS_SURGERY, \
	ACCESS_COURT, \
	ACCESS_QM, \
	ACCESS_VIROLOGY, \
	ACCESS_LAWYER, \
	ACCESS_LIBRARY, \
	ACCESS_HYDROPONICS, \
	ACCESS_PLUMBING, \
	ACCESS_CONSTRUCTION, \
	ACCESS_CARGO, \
	ACCESS_ROBOTICS, \
	ACCESS_KITCHEN, \
	ACCESS_CREMATORIUM, \
	ACCESS_JANITOR, \
	ACCESS_BAR, \
	ACCESS_CHAPEL_OFFICE, \
	ACCESS_EXTERNAL_AIRLOCKS, \
	ACCESS_MAINT_TUNNELS, \
	ACCESS_ENGINE_EQUIP, \
	ACCESS_ENGINEERING, \
	ACCESS_GENETICS, \
	ACCESS_SCIENCE, \
	ACCESS_MORGUE, \
	ACCESS_MEDICAL, \
	ACCESS_DETECTIVE, \
	ACCESS_BRIG, \
	ACCESS_SECURITY, \
	ACCESS_ATMOSPHERICS, \
	ACCESS_ORDNANCE_STORAGE, \
	ACCESS_ORDNANCE, \
	ACCESS_SERVICE, \
)

/// Command staff/secure accesses, think bridge/armoury, ai_upload, notably access to modify ID cards themselves. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND)
#define COMMAND_ACCESS list( \
	ACCESS_MINISAT, \
	ACCESS_TCOMMS, \
	ACCESS_KEYCARD_AUTH, \
	ACCESS_RC_ANNOUNCE, \
	ACCESS_VAULT, \
	ACCESS_TECH_STORAGE, \
	ACCESS_COMMAND, \
	ACCESS_TELEPORTER, \
	ACCESS_ARMORY, \
	ACCESS_AI_UPLOAD, \
	ACCESS_CHANGE_IDS, \
	ACCESS_EVA, \
	ACCESS_GATEWAY, \
	ACCESS_ALL_PERSONAL_LOCKERS, \
)

/// Private head of staff offices, usually only granted to most cards by trimming. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_PRV_COMMAND)
#define PRIVATE_COMMAND_ACCESS list( \
	ACCESS_HOS, \
	ACCESS_HOP, \
	ACCESS_CE, \
	ACCESS_CMO, \
	ACCESS_RD, \
)

/// Captains private rooms. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_CAPTAIN)
#define CAPTAIN_ACCESS list( \
	ACCESS_CAPTAIN, \
)
/// Centcom area stuff. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_CENTCOM)
#define CENTCOM_ACCESS list( \
	ACCESS_CENT_BAR, \
	ACCESS_CENT_CAPTAIN, \
	ACCESS_CENT_TELEPORTER, \
	ACCESS_CENT_STORAGE, \
	ACCESS_CENT_LIVING, \
	ACCESS_CENT_MEDICAL, \
	ACCESS_CENT_SPECOPS, \
	ACCESS_CENT_THUNDER, \
	ACCESS_CENT_GENERAL, \
)

/// Syndicate areas off station. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_SYNDICATE)
#define SYNDICATE_ACCESS list( \
	ACCESS_SYNDICATE_LEADER, \
	ACCESS_SYNDICATE, \
)

/// Away missions/gateway/space ruins.  Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_AWAY)
#define AWAY_ACCESS list( \
	ACCESS_AWAY_GENERAL, \
	ACCESS_AWAY_COMMAND, \
	ACCESS_AWAY_MAINTENANCE, \
	ACCESS_AWAY_MEDICAL, \
	ACCESS_AWAY_SEC, \
	ACCESS_AWAY_ENGINEERING, \
	ACCESS_AWAY_GENERIC1, \
	ACCESS_AWAY_GENERIC2, \
	ACCESS_AWAY_GENERIC3, \
	ACCESS_AWAY_GENERIC4, \
)

/// Weird internal Cult access that prevents non-cult from using their doors.  Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_SPECIAL)
#define CULT_ACCESS list( \
	ACCESS_BLOODCULT, \
)

/// Name for the Global region.
#define REGION_ALL_GLOBAL "All"
/// Used to seed the accesses_by_region list in SSid_access. A list of every single access in the game.
#define REGION_ACCESS_ALL_GLOBAL REGION_ACCESS_ALL_STATION + CENTCOM_ACCESS + SYNDICATE_ACCESS + AWAY_ACCESS + CULT_ACCESS
/// Name for the Station All Access region.
#define REGION_ALL_STATION "Station"
/// Used to seed the accesses_by_region list in SSid_access. A list of all station accesses.
#define REGION_ACCESS_ALL_STATION COMMON_ACCESS + COMMAND_ACCESS + PRIVATE_COMMAND_ACCESS + CAPTAIN_ACCESS
/// Name for the General region.
#define REGION_GENERAL "General"
/// Used to seed the accesses_by_region list in SSid_access. A list of general service accesses that are overseen by the HoP.
#define REGION_ACCESS_GENERAL list( \
	ACCESS_KITCHEN, \
	ACCESS_BAR, \
	ACCESS_HYDROPONICS, \
	ACCESS_JANITOR, \
	ACCESS_CHAPEL_OFFICE, \
	ACCESS_CREMATORIUM, \
	ACCESS_LIBRARY, \
	ACCESS_THEATRE, \
	ACCESS_LAWYER, \
	ACCESS_SERVICE, \
)
/// Name for the Security region.
#define REGION_SECURITY "Security"
/// Used to seed the accesses_by_region list in SSid_access. A list of all security regional accesses that are overseen by the HoS.
#define REGION_ACCESS_SECURITY list( \
	ACCESS_BRIG_ENTRANCE, \
	ACCESS_WEAPONS, \
	ACCESS_SECURITY, \
	ACCESS_BRIG, \
	ACCESS_ARMORY, \
	ACCESS_DETECTIVE, \
	ACCESS_COURT, \
	ACCESS_MECH_SECURITY, \
	ACCESS_HOS, \
)
/// Name for the Medbay region.
#define REGION_MEDBAY "Medbay"
/// Used to seed the accesses_by_region list in SSid_access. A list of all medbay regional accesses that are overseen by the CMO.
#define REGION_ACCESS_MEDBAY list( \
	ACCESS_MEDICAL, \
	ACCESS_MORGUE, \
	ACCESS_PLUMBING, \
	ACCESS_VIROLOGY, \
	ACCESS_SURGERY, \
	ACCESS_MECH_MEDICAL, \
	ACCESS_CMO, \
	ACCESS_PHARMACY, \
	ACCESS_PSYCHOLOGY, \
)
/// Name for the Research region.
#define REGION_RESEARCH "Research"
/// Used to seed the accesses_by_region list in SSid_access. A list of all research regional accesses that are overseen by the RD.
#define REGION_ACCESS_RESEARCH list( \
	ACCESS_RESEARCH, \
	ACCESS_SCIENCE, \
	ACCESS_ORDNANCE, \
	ACCESS_ORDNANCE_STORAGE, \
	ACCESS_GENETICS, \
	ACCESS_ROBOTICS, \
	ACCESS_XENOBIOLOGY, \
	ACCESS_MECH_SCIENCE, \
	ACCESS_MINISAT, \
	ACCESS_RD, \
	ACCESS_NETWORK, \
)
/// Name for the Engineering region.
#define REGION_ENGINEERING "Engineering"
/// Used to seed the accesses_by_region list in SSid_access. A list of all engineering regional accesses that are overseen by the CE.
#define REGION_ACCESS_ENGINEERING list( \
	ACCESS_CONSTRUCTION, \
	ACCESS_AUX_BASE, \
	ACCESS_MAINT_TUNNELS, \
	ACCESS_ENGINEERING, \
	ACCESS_ENGINE_EQUIP, \
	ACCESS_EXTERNAL_AIRLOCKS, \
	ACCESS_TECH_STORAGE, \
	ACCESS_ATMOSPHERICS, \
	ACCESS_MECH_ENGINE, \
	ACCESS_TCOMMS, \
	ACCESS_MINISAT, \
	ACCESS_CE, \
)
/// Name for the Supply region.
#define REGION_SUPPLY "Supply"
/// Used to seed the accesses_by_region list in SSid_access. A list of all cargo regional accesses that are overseen by the HoP.
#define REGION_ACCESS_SUPPLY list( \
	ACCESS_MAIL_SORTING, \
	ACCESS_MINING, \
	ACCESS_MINING_STATION, \
	ACCESS_MECH_MINING, \
	ACCESS_MINERAL_STOREROOM, \
	ACCESS_CARGO, \
	ACCESS_QM, \
	ACCESS_VAULT, \
)
/// Name for the Command region.
#define REGION_COMMAND "Command"
/// Used to seed the accesses_by_region list in SSid_access. A list of all command regional accesses that are overseen by the Captain.
#define REGION_ACCESS_COMMAND list( \
	ACCESS_COMMAND, \
	ACCESS_RC_ANNOUNCE, \
	ACCESS_KEYCARD_AUTH, \
	ACCESS_CHANGE_IDS, \
	ACCESS_AI_UPLOAD, \
	ACCESS_TELEPORTER, \
	ACCESS_EVA, \
	ACCESS_GATEWAY, \
	ACCESS_ALL_PERSONAL_LOCKERS, \
	ACCESS_HOP, \
	ACCESS_CAPTAIN, \
	ACCESS_VAULT, \
)
/// Name for the Centcom region.
#define REGION_CENTCOM "Central Command"
/// Used to seed the accesses_by_region list in SSid_access. A list of all CENTCOM_ACCESS regional accesses.
#define REGION_ACCESS_CENTCOM CENTCOM_ACCESS

/**
 * A list of PDA paths that can be painted as well as the regional heads which should be able to paint them.
 * If a PDA is not in this list, it cannot be painted using the PDA & ID Painter.
 * If a PDA is in this list, it can always be painted with ACCESS_CHANGE_IDS.
 * Used to see pda_region in [/datum/controller/subsystem/id_access/proc/setup_tgui_lists]
 */
#define PDA_PAINTING_REGIONS list( \
	/obj/item/modular_computer/tablet/pda = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/clown = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/mime = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/medical = list(REGION_MEDBAY), \
	/obj/item/modular_computer/tablet/pda/viro = list(REGION_MEDBAY), \
	/obj/item/modular_computer/tablet/pda/engineering = list(REGION_ENGINEERING), \
	/obj/item/modular_computer/tablet/pda/security = list(REGION_SECURITY), \
	/obj/item/modular_computer/tablet/pda/detective = list(REGION_SECURITY), \
	/obj/item/modular_computer/tablet/pda/warden = list(REGION_SECURITY), \
	/obj/item/modular_computer/tablet/pda/janitor = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/science = list(REGION_RESEARCH), \
	/obj/item/modular_computer/tablet/pda/heads/hop = list(REGION_COMMAND), \
	/obj/item/modular_computer/tablet/pda/heads/hos = list(REGION_COMMAND), \
	/obj/item/modular_computer/tablet/pda/heads/cmo = list(REGION_COMMAND), \
	/obj/item/modular_computer/tablet/pda/heads/ce = list(REGION_COMMAND), \
	/obj/item/modular_computer/tablet/pda/heads/rd = list(REGION_COMMAND), \
	/obj/item/modular_computer/tablet/pda/heads/captain = list(REGION_COMMAND), \
	/obj/item/modular_computer/tablet/pda/cargo = list(REGION_SUPPLY), \
	/obj/item/modular_computer/tablet/pda/quartermaster = list(REGION_SUPPLY), \
	/obj/item/modular_computer/tablet/pda/shaftminer = list(REGION_SUPPLY), \
	/obj/item/modular_computer/tablet/pda/chaplain = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/lawyer = list(REGION_GENERAL, REGION_SECURITY), \
	/obj/item/modular_computer/tablet/pda/botanist = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/roboticist = list(REGION_RESEARCH), \
	/obj/item/modular_computer/tablet/pda/curator = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/cook = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/bar = list(REGION_GENERAL), \
	/obj/item/modular_computer/tablet/pda/atmos = list(REGION_ENGINEERING), \
	/obj/item/modular_computer/tablet/pda/chemist = list(REGION_MEDBAY), \
	/obj/item/modular_computer/tablet/pda/geneticist = list(REGION_RESEARCH), \
)

/// All regions that make up the station area. Helper define to quickly designate a region as part of the station or not. Access via SSid_access.station_regions.
#define REGION_AREA_STATION list( \
	REGION_GENERAL, \
	REGION_SECURITY, \
	REGION_MEDBAY, \
	REGION_RESEARCH, \
	REGION_ENGINEERING, \
	REGION_SUPPLY, \
	REGION_COMMAND, \
)

/// Used in ID card access adding procs. Will try to add all accesses and utilises free wildcards, skipping over any accesses it can't add.
#define TRY_ADD_ALL 0
/// Used in ID card access adding procs. Will try to add all accesses and does not utilise wildcards, skipping anything requiring a wildcard.
#define TRY_ADD_ALL_NO_WILDCARD 1
/// Used in ID card access adding procs. Will forcefully add all accesses.
#define FORCE_ADD_ALL 2
/// Used in ID card access adding procs. Will stack trace on fail.
#define ERROR_ON_FAIL 3
