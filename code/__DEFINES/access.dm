// Security equipment, security records, gulag item storage, secbots
#define ACCESS_SECURITY 1
/// Brig cells+timers, permabrig, gulag+gulag shuttle, prisoner management console
#define ACCESS_BRIG 2
/// Armory, gulag teleporter, execution chamber
#define ACCESS_ARMORY 3
///Detective's office, forensics lockers, security+medical records
#define ACCESS_FORENSICS_LOCKERS 4
/// Medical general access
#define ACCESS_MEDICAL 5
/// Morgue access
#define ACCESS_MORGUE 6
/// R&D department and R&D console
#define ACCESS_RND 7
/// Toxins lab and burn chamber
#define ACCESS_TOXINS 8
/// Genetics access
#define ACCESS_GENETICS 9
/// Engineering area, power monitor, power flow control console
#define ACCESS_ENGINE 10
///APCs, EngiVend/YouTool, engineering equipment lockers
#define ACCESS_ENGINE_EQUIP 11
#define ACCESS_MAINT_TUNNELS 12
#define ACCESS_EXTERNAL_AIRLOCKS 13
#define ACCESS_CHANGE_IDS 15
#define ACCESS_AI_UPLOAD 16
#define ACCESS_TELEPORTER 17
#define ACCESS_EVA 18
/// Bridge, EVA storage windoors, gateway shutters, AI integrity restorer, comms console
#define ACCESS_HEADS 19
#define ACCESS_CAPTAIN 20
#define ACCESS_ALL_PERSONAL_LOCKERS 21
#define ACCESS_CHAPEL_OFFICE 22
#define ACCESS_TECH_STORAGE 23
#define ACCESS_ATMOSPHERICS 24
#define ACCESS_BAR 25
#define ACCESS_JANITOR 26
#define ACCESS_CREMATORIUM 27
#define ACCESS_KITCHEN 28
#define ACCESS_ROBOTICS 29
#define ACCESS_RD 30
#define ACCESS_CARGO 31
#define ACCESS_CONSTRUCTION 32
///Allows access to chemistry factory areas on compatible maps
#define ACCESS_CHEMISTRY 33
#define ACCESS_HYDROPONICS 35
#define ACCESS_LIBRARY 37
#define ACCESS_LAWYER 38
#define ACCESS_VIROLOGY 39
#define ACCESS_CMO 40
#define ACCESS_QM 41
#define ACCESS_COURT 42
#define ACCESS_SURGERY 45
#define ACCESS_THEATRE 46
#define ACCESS_RESEARCH 47
#define ACCESS_MINING 48
#define ACCESS_MAILSORTING 50
#define ACCESS_VAULT 53
#define ACCESS_MINING_STATION 54
#define ACCESS_XENOBIOLOGY 55
#define ACCESS_CE 56
#define ACCESS_HOP 57
#define ACCESS_HOS 58
/// Request console announcements
#define ACCESS_RC_ANNOUNCE 59
/// Used for events which require at least two people to confirm them
#define ACCESS_KEYCARD_AUTH 60
/// has access to the entire telecomms satellite / machinery
#define ACCESS_TCOMSAT 61
#define ACCESS_GATEWAY 62
/// Outer brig doors, department security posts
#define ACCESS_SEC_DOORS 63
/// For releasing minerals from the ORM
#define ACCESS_MINERAL_STOREROOM 64
#define ACCESS_MINISAT 65
/// Weapon authorization for secbots
#define ACCESS_WEAPONS 66
/// NTnet diagnostics/monitoring software
#define ACCESS_NETWORK 67
/// Pharmacy access (Chemistry room in Medbay)
#define ACCESS_PHARMACY 69 ///Nice.
#define ACCESS_PSYCHOLOGY 70
/// Toxins tank storage room access
#define ACCESS_TOXINS_STORAGE 71
/// Room and launching.
#define ACCESS_AUX_BASE 72

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
	Mostly for admin fun times.*/
/// General facilities. CentCom ferry.
#define ACCESS_CENT_GENERAL 101
/// Thunderdome.
#define ACCESS_CENT_THUNDER 102
/// Special Ops. Captain's display case, Marauder and Seraph mechs.
#define ACCESS_CENT_SPECOPS 103
/// Medical/Research
#define ACCESS_CENT_MEDICAL 104
/// Living quarters.
#define ACCESS_CENT_LIVING 105
/// Generic storage areas.
#define ACCESS_CENT_STORAGE 106
/// Teleporter.
#define ACCESS_CENT_TELEPORTER 107
/// Captain's office/ID comp/AI.
#define ACCESS_CENT_CAPTAIN 109
/// The non-existent CentCom Bar
#define ACCESS_CENT_BAR 110

	//The Syndicate
/// General Syndicate Access. Includes Syndicate mechs and ruins.
#define ACCESS_SYNDICATE 150
/// Nuke Op Leader Access
#define ACCESS_SYNDICATE_LEADER 151

	//Away Missions or Ruins
	/*For generic away-mission/ruin access. Why would normal crew have access to a long-abandoned derelict
	or a 2000 year-old temple? */
/// Away general facilities.
#define ACCESS_AWAY_GENERAL 200
/// Away maintenance
#define ACCESS_AWAY_MAINT 201
/// Away medical
#define ACCESS_AWAY_MED 202
/// Away security
#define ACCESS_AWAY_SEC 203
/// Away engineering
#define ACCESS_AWAY_ENGINE 204
///Away generic access
#define ACCESS_AWAY_GENERIC1 205
#define ACCESS_AWAY_GENERIC2 206
#define ACCESS_AWAY_GENERIC3 207
#define ACCESS_AWAY_GENERIC4 208

	//Special, for anything that's basically internal
#define ACCESS_BLOODCULT 250

	// Mech Access, allows maintanenace of internal components and altering keycard requirements.
#define ACCESS_MECH_MINING 300
#define ACCESS_MECH_MEDICAL 301
#define ACCESS_MECH_SECURITY 302
#define ACCESS_MECH_SCIENCE 303
#define ACCESS_MECH_ENGINE 304

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
	ACCESS_SEC_DOORS, \
	ACCESS_XENOBIOLOGY, \
	ACCESS_MINING_STATION, \
	ACCESS_MAILSORTING, \
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
	ACCESS_CHEMISTRY, \
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
	ACCESS_ENGINE, \
	ACCESS_GENETICS, \
	ACCESS_RND, \
	ACCESS_MORGUE, \
	ACCESS_MEDICAL, \
	ACCESS_FORENSICS_LOCKERS, \
	ACCESS_BRIG, \
	ACCESS_SECURITY, \
)

/// Command staff/secure accesses, think bridge/armoury, AI upload, notably access to modify ID cards themselves. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND)
#define COMMAND_ACCESS list( \
	ACCESS_TOXINS_STORAGE, \
	ACCESS_MINISAT, \
	ACCESS_TCOMSAT, \
	ACCESS_KEYCARD_AUTH, \
	ACCESS_RC_ANNOUNCE, \
	ACCESS_VAULT, \
	ACCESS_ATMOSPHERICS, \
	ACCESS_TECH_STORAGE, \
	ACCESS_HEADS, \
	ACCESS_TELEPORTER, \
	ACCESS_ARMORY, \
	ACCESS_AI_UPLOAD, \
	ACCESS_CHANGE_IDS, \
	ACCESS_TOXINS, \
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
	ACCESS_AWAY_MAINT, \
	ACCESS_AWAY_MED, \
	ACCESS_AWAY_SEC, \
	ACCESS_AWAY_ENGINE, \
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
)
/// Name for the Security region.
#define REGION_SECURITY "Security"
/// Used to seed the accesses_by_region list in SSid_access. A list of all security regional accesses that are overseen by the HoS.
#define REGION_ACCESS_SECURITY list( \
	ACCESS_SEC_DOORS, \
	ACCESS_WEAPONS, \
	ACCESS_SECURITY, \
	ACCESS_BRIG, \
	ACCESS_ARMORY, \
	ACCESS_FORENSICS_LOCKERS, \
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
	ACCESS_CHEMISTRY, \
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
	ACCESS_RND, \
	ACCESS_TOXINS, \
	ACCESS_TOXINS_STORAGE, \
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
	ACCESS_ENGINE, \
	ACCESS_ENGINE_EQUIP, \
	ACCESS_EXTERNAL_AIRLOCKS, \
	ACCESS_TECH_STORAGE, \
	ACCESS_ATMOSPHERICS, \
	ACCESS_MECH_ENGINE, \
	ACCESS_TCOMSAT, \
	ACCESS_MINISAT, \
	ACCESS_CE, \
)
/// Name for the Supply region.
#define REGION_SUPPLY "Supply"
/// Used to seed the accesses_by_region list in SSid_access. A list of all cargo regional accesses that are overseen by the HoP.
#define REGION_ACCESS_SUPPLY list( \
	ACCESS_MAILSORTING, \
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
	ACCESS_HEADS, \
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
	/obj/item/pda = list(REGION_GENERAL), \
	/obj/item/pda/clown = list(REGION_GENERAL), \
	/obj/item/pda/mime = list(REGION_GENERAL), \
	/obj/item/pda/medical = list(REGION_MEDBAY), \
	/obj/item/pda/viro = list(REGION_MEDBAY), \
	/obj/item/pda/engineering = list(REGION_ENGINEERING), \
	/obj/item/pda/security = list(REGION_SECURITY), \
	/obj/item/pda/detective = list(REGION_SECURITY), \
	/obj/item/pda/warden = list(REGION_SECURITY), \
	/obj/item/pda/janitor = list(REGION_GENERAL), \
	/obj/item/pda/toxins = list(REGION_RESEARCH), \
	/obj/item/pda/heads/hop = list(REGION_COMMAND), \
	/obj/item/pda/heads/hos = list(REGION_COMMAND), \
	/obj/item/pda/heads/cmo = list(REGION_COMMAND), \
	/obj/item/pda/heads/ce = list(REGION_COMMAND), \
	/obj/item/pda/heads/rd = list(REGION_COMMAND), \
	/obj/item/pda/captain = list(REGION_COMMAND), \
	/obj/item/pda/cargo = list(REGION_SUPPLY), \
	/obj/item/pda/quartermaster = list(REGION_SUPPLY), \
	/obj/item/pda/shaftminer = list(REGION_SUPPLY), \
	/obj/item/pda/chaplain = list(REGION_GENERAL), \
	/obj/item/pda/lawyer = list(REGION_GENERAL, REGION_SECURITY), \
	/obj/item/pda/botanist = list(REGION_GENERAL), \
	/obj/item/pda/roboticist = list(REGION_RESEARCH), \
	/obj/item/pda/curator = list(REGION_GENERAL), \
	/obj/item/pda/cook = list(REGION_GENERAL), \
	/obj/item/pda/bar = list(REGION_GENERAL), \
	/obj/item/pda/atmos = list(REGION_ENGINEERING), \
	/obj/item/pda/chemist = list(REGION_MEDBAY), \
	/obj/item/pda/geneticist = list(REGION_RESEARCH), \
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
