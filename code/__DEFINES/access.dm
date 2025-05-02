
/*  Access is broken down by department, department special functions/rooms, and departmental roles
*	The first access for the department will always be its general access function
*	Please try to make the strings for any new accesses as close to the name of the define as possible
*	If you are going to add an access to the list, make sure to also add it to its respective region further below
*	If you're varediting on the map, it uses the string. If you're editing the object directly, use the define name
*/

/// Command General Access, typically used for accessing the doors to the bridge, as well as being the general access that Tablet/Computer Programs check for "heads".
#define ACCESS_COMMAND "command"
/// Access to the AI Upload Room Doors as well as the AI satellite. Also used for controlling the machinery in the AI Upload (turrets, foam dispensers)
#define ACCESS_AI_UPLOAD "ai_upload"
/// Access to the Teleporter Room, and some cargo crates.
#define ACCESS_TELEPORTER "teleporter"
/// Access to the EVA Storage Room, and some cargo crates.
#define ACCESS_EVA "eva"
/// Access to make an announcement through the Requests Console found in an office.
#define ACCESS_RC_ANNOUNCE "rc_announce"
/// Access used for events (Red Alert, BSA, Emergency Maintenance) which require at least two people to swipe at the same time to authorize it
#define ACCESS_KEYCARD_AUTH "keycard_auth"
/// Access for the "minisat", but is actually used for the small maintenance cubicle some AI satellites may have.
#define ACCESS_MINISAT "minisat"
/// Access used to run the NTNet Tablet Application WireCarp, which allows you to diagnose and view NTNet logging.
#define ACCESS_NETWORK "network"
/// Access used to access the Gateway Room, which will further lead you to get to Away Missions.
#define ACCESS_GATEWAY "gateway"
/// Access used to override "personal control" on a personal locker, meaning you are able to open any of those lockers/wardrobes.
#define ACCESS_ALL_PERSONAL_LOCKERS "all_personal_lockers"
/// Access used for Access-Changing Programs, this one will unlock all options that can be ever given via that program.
#define ACCESS_CHANGE_IDS "change_ids"
/// Access used for the Captain's personal quarters in mapping, as well as what allows one to order emergency shuttles.
#define ACCESS_CAPTAIN "captain"
/// Access used for the Head of Personnel's personal quarters in mapping, as well as the security console and other HoP-related things.
#define ACCESS_HOP "hop"

/// Security's General Access. In mapping, grants access to spaces such as to the "meeting room" or firing range, as well as being the general access that Tablet/Computer Programs check for "heads". Also unlocks other types of security equipment.
#define ACCESS_SECURITY "security"
/// Access that ONLY grants access to the front doors of the Brig. Never use this more for anything than that, please.
#define ACCESS_BRIG_ENTRANCE "brig_entrance"
/// Access to brig cells, brig timers, permabrig, gulag, gulag teleporter, gulag shuttle, prisoner management console, and some security cargo crates.
#define ACCESS_BRIG "brig"
/// Access to the armory, security incinerator (when present), and the execution/re-education chamber.
#define ACCESS_ARMORY "armory"
/// Access to the "secure" portion of the courtroom, like where the judge and everyone sits..
#define ACCESS_COURT "court"
/// The "Weapons Permit" Access, or the one that lets you walk past secbots without them charging at you as you hold your weaponry.
#define ACCESS_WEAPONS "weapons"
/// Access used for the Head of Security's personal quarters in mapping, as well as other HoS-related things.
#define ACCESS_HOS "hos"
/// Access for the detective to get into their office, the medical data console, and some other detective-related stuff.
#define ACCESS_DETECTIVE "detective"

/// Engineering General Access, grants access to the standard parts of engineering (as well as the Supermatter and related equipment).
#define ACCESS_ENGINEERING "engineering"
/// Access to Atmospherics Sections of the Engineering Department, as well as air alarms.
#define ACCESS_ATMOSPHERICS "atmospherics"
/// Access to all maintenance tunnels on the station. This overrides any "departmental maintenance" access, this has free roaming range everywhere.
#define ACCESS_MAINT_TUNNELS "maint_tunnels"
/// Access to get into APCs, engineering equipment lockers, typically mapped in for key power rooms across the station, engineering vending machines, emitters, and some other stuff.
#define ACCESS_ENGINE_EQUIP "engine_equip"
/// Access to "construction" areas of the station. However, in mapping, it's used to get access to the front door and lathe room of the engineering department.
#define ACCESS_CONSTRUCTION "construction"
/// Access to the technical storage room (contains all the boards and other miscellaneous engineering gear).
#define ACCESS_TECH_STORAGE "tech_storage"
/// Access to the telecomms satellite, machinery, and tablets.
#define ACCESS_TCOMMS "tcomms"
/// Access to the Auxiliary Base Room, as well as the ability over launching it.
#define ACCESS_AUX_BASE "aux_base"
/// Access to all external "space facing" airlocks on the station. Used such that people don't easily "jump ship", or restict free ingress/egress to only a few points on the station.
#define ACCESS_EXTERNAL_AIRLOCKS "external airlocks"
/// Access for the Chief Engineer's personal quarters in mapping, as well as some other CE-related things.
#define ACCESS_CE "ce"

/// General access to Medbay, like the front doors, the treatment center, the medical records console, defibrillator mounts, and more.
#define ACCESS_MEDICAL "medical"
/// Access to the Morgue.
#define ACCESS_MORGUE "morgue"
/// Access to the secure morgue area.
#define ACCESS_MORGUE_SECURE "morgue_secure"
/// Access to the Pharmacy, or the smaller room in medical with the multiple chem dispensers and pill pressers. The Chemist's main position.
#define ACCESS_PHARMACY "pharmacy"
/// Access to the surgery rooms.
#define ACCESS_SURGERY "surgery"
/// Allows access to the larger room for Chemistry plumbing machinery setups.
#define ACCESS_PLUMBING "plumbing"
/// Access to the Virology portion of the medical department, as well as the virology crate.
#define ACCESS_VIROLOGY "virology"
/// Access to the Psychologist's office.
#define ACCESS_PSYCHOLOGY "psychology"
/// Access for the Chief Medical Officer's personal quarters in mapping, as well as some other CMO-related things.
#define ACCESS_CMO "cmo"

/// General access for Cargo, allows for entry to Cargo Bay and Cargo's Office.
#define ACCESS_CARGO "cargo"
/// Access to the Shipping and Mailing Rooms on several maps.
#define ACCESS_SHIPPING "shipping"
/// Access for a room where the ORM may be kept, or to release materials from the ORM.
#define ACCESS_MINERAL_STOREROOM "mineral_storeroom"
/// Access to the "on-station" Mining Portion of the Cargo Department.
#define ACCESS_MINING "mining"
/// Access to the "off-station" Mining Station, which contains gear dedicated for miners to do their job best, as well as seek shelter from the inhospitable elements.
#define ACCESS_MINING_STATION "mining_station"
/// Access to the vault on the station, for accessing the station's budget, the nuke core, or the Ore Silo.
#define ACCESS_VAULT "vault"
/// Access for the Quartermaster's personal quarters in mapping, as well as some other QM-related things.
#define ACCESS_QM "qm"
/// Access for the bitrunning den
#define ACCESS_BIT_DEN "bit_den"

/// General access for Science, allows for entry to the general hallways of Science, as well as the main lathe room.
#define ACCESS_SCIENCE "science"
/// Access to the specialized research experimentation rooms within Science, as well as what gives access to lockers and access to TechWeb programs.
#define ACCESS_RESEARCH "research"
/// Access to the Ordnance Mixing Lab and the Ordnance Bomb Range.
#define ACCESS_ORDNANCE "ordnance"
/// Access to the Ordnance Storage Room, where all of the bomb-making gases are stored.
#define ACCESS_ORDNANCE_STORAGE "ordnance_storage"
/// Access to the Genetics division of Science.
#define ACCESS_GENETICS "genetics"
/// Access to the Robotics division of Science, as well as opening up silicon cyborgs and other simple robots.
#define ACCESS_ROBOTICS "robotics"
/// Access to the Xenobiology division of Science.
#define ACCESS_XENOBIOLOGY "xenobiology"
/// Access for the Research Director's personal quarters in mapping, as well as some other RD-related things.
#define ACCESS_RD "rd"

/// General access for Service, allows for entry to the Service Hallway.
#define ACCESS_SERVICE "service"
/// Access to the Theatre, as well as other vending machines related to the theatre. Sometimes also used as the "clown's" access in code.
#define ACCESS_THEATRE "theatre"
/// Access to the Chaplain's office.
#define ACCESS_CHAPEL_OFFICE "chapel_office"
/// Access to the chapel's crematorium.
#define ACCESS_CREMATORIUM "crematorium"
/// Access to the curator's private rooms in the Library and the trophy display cases, as well as access both into and out of the Library via Maintenance.
#define ACCESS_LIBRARY "library"
/// Access to the Bar, the Bar's Backroom, the bar sign, the bar robot portal, and the bar's vending machines. Some other bar-things too.
#define ACCESS_BAR "bar"
/// Access to the Kitchen, the Kitchen's Coldroom, the kitchen's vending machines, and the food robot portal. Some other chef-things too.
#define ACCESS_KITCHEN "kitchen"
/// Access to the Botany Division of the station and some other Botanist things.
#define ACCESS_HYDROPONICS "hydroponics"
/// Access to the Janitor's room, and some tablet apps for control of the station's janitorial equipment.
#define ACCESS_JANITOR "janitor"
/// Access to the Lawyer's office.
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
/// HUNTERS
#define ACCESS_HUNTER "hunter"

/// - - - MISC - - -
	// These don't really fit anywhere else
/// For things that aren't ever supposed to be accessed
#define ACCESS_INACCESSIBLE "inaccessible"

/// - - - END ACCESS IDS - - -

/// A list of access levels that, when added to an ID card, will warn admins.
#define ACCESS_ALERT_ADMINS list(ACCESS_CHANGE_IDS)

/// Logging define for ID card access changes
#define LOG_ID_ACCESS_CHANGE(user, id_card, change_description) \
	log_game("[key_name(user)] [change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]"); \
	user.investigate_log("[change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]", INVESTIGATE_ACCESSCHANGES); \
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
	ACCESS_ATMOSPHERICS, \
	ACCESS_AUX_BASE, \
	ACCESS_BAR, \
	ACCESS_BIT_DEN, \
	ACCESS_BRIG, \
	ACCESS_BRIG_ENTRANCE, \
	ACCESS_CARGO, \
	ACCESS_CHAPEL_OFFICE, \
	ACCESS_CONSTRUCTION, \
	ACCESS_COURT, \
	ACCESS_CREMATORIUM, \
	ACCESS_DETECTIVE, \
	ACCESS_ENGINE_EQUIP, \
	ACCESS_ENGINEERING, \
	ACCESS_EVA, \
	ACCESS_EXTERNAL_AIRLOCKS, \
	ACCESS_GATEWAY, \
	ACCESS_GENETICS, \
	ACCESS_HYDROPONICS, \
	ACCESS_JANITOR, \
	ACCESS_KITCHEN, \
	ACCESS_LAWYER, \
	ACCESS_LIBRARY, \
	ACCESS_MAINT_TUNNELS, \
	ACCESS_MECH_MINING, \
	ACCESS_MECH_MEDICAL, \
	ACCESS_MECH_SECURITY, \
	ACCESS_MECH_SCIENCE, \
	ACCESS_MECH_ENGINE, \
	ACCESS_MEDICAL, \
	ACCESS_MINERAL_STOREROOM, \
	ACCESS_MINING, \
	ACCESS_MINING_STATION, \
	ACCESS_MORGUE_SECURE, \
	ACCESS_MORGUE, \
	ACCESS_NETWORK, \
	ACCESS_ORDNANCE, \
	ACCESS_ORDNANCE_STORAGE, \
	ACCESS_PHARMACY, \
	ACCESS_PLUMBING, \
	ACCESS_PSYCHOLOGY, \
	ACCESS_RESEARCH, \
	ACCESS_ROBOTICS, \
	ACCESS_SCIENCE, \
	ACCESS_SECURITY, \
	ACCESS_SERVICE, \
	ACCESS_SHIPPING, \
	ACCESS_SURGERY, \
	ACCESS_THEATRE, \
	ACCESS_VIROLOGY, \
	ACCESS_WEAPONS, \
	ACCESS_XENOBIOLOGY, \
)

/// Command staff/secure accesses, think bridge/armoury, ai_upload, notably access to modify ID cards themselves. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND)
#define COMMAND_ACCESS list( \
	ACCESS_AI_UPLOAD, \
	ACCESS_ALL_PERSONAL_LOCKERS, \
	ACCESS_ARMORY, \
	ACCESS_CHANGE_IDS, \
	ACCESS_COMMAND, \
	ACCESS_EVA, \
	ACCESS_KEYCARD_AUTH, \
	ACCESS_MINISAT, \
	ACCESS_RC_ANNOUNCE, \
	ACCESS_TCOMMS, \
	ACCESS_TECH_STORAGE, \
	ACCESS_TELEPORTER, \
	ACCESS_VAULT, \
)

/// Private head of staff offices, usually only granted to most cards by trimming. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_PRV_COMMAND)
#define PRIVATE_COMMAND_ACCESS list( \
	ACCESS_CE, \
	ACCESS_CMO, \
	ACCESS_HOS, \
	ACCESS_HOP, \
	ACCESS_QM, \
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
	ACCESS_CENT_GENERAL, \
	ACCESS_CENT_LIVING, \
	ACCESS_CENT_MEDICAL, \
	ACCESS_CENT_SPECOPS, \
	ACCESS_CENT_STORAGE, \
	ACCESS_CENT_TELEPORTER, \
	ACCESS_CENT_THUNDER, \
)

/// Syndicate areas off station. Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_SYNDICATE)
#define SYNDICATE_ACCESS list( \
	ACCESS_SYNDICATE, \
	ACCESS_SYNDICATE_LEADER, \
)

/// Away missions/gateway/space ruins.  Do not use direct, access via SSid_access.get_flag_access_list(ACCESS_FLAG_AWAY)
#define AWAY_ACCESS list( \
	ACCESS_AWAY_COMMAND, \
	ACCESS_AWAY_ENGINEERING, \
	ACCESS_AWAY_GENERAL, \
	ACCESS_AWAY_GENERIC1, \
	ACCESS_AWAY_GENERIC2, \
	ACCESS_AWAY_GENERIC3, \
	ACCESS_AWAY_GENERIC4, \
	ACCESS_AWAY_MAINTENANCE, \
	ACCESS_AWAY_MEDICAL, \
	ACCESS_AWAY_SCIENCE, \
	ACCESS_AWAY_SEC, \
	ACCESS_AWAY_SUPPLY, \
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
	ACCESS_BAR, \
	ACCESS_CHAPEL_OFFICE, \
	ACCESS_CREMATORIUM, \
	ACCESS_HYDROPONICS, \
	ACCESS_JANITOR, \
	ACCESS_KITCHEN, \
	ACCESS_LAWYER, \
	ACCESS_LIBRARY, \
	ACCESS_SERVICE, \
	ACCESS_THEATRE, \
)
/// Name for the Security region.
#define REGION_SECURITY "Security"
/// Used to seed the accesses_by_region list in SSid_access. A list of all security regional accesses that are overseen by the HoS.
#define REGION_ACCESS_SECURITY list( \
	ACCESS_ARMORY, \
	ACCESS_BRIG, \
	ACCESS_BRIG_ENTRANCE, \
	ACCESS_COURT, \
	ACCESS_DETECTIVE, \
	ACCESS_HOS, \
	ACCESS_MECH_SECURITY, \
	ACCESS_SECURITY, \
	ACCESS_WEAPONS, \
)
/// Name for the Medbay region.
#define REGION_MEDBAY "Medbay"
/// Used to seed the accesses_by_region list in SSid_access. A list of all medbay regional accesses that are overseen by the CMO.
#define REGION_ACCESS_MEDBAY list( \
	ACCESS_CMO, \
	ACCESS_MECH_MEDICAL, \
	ACCESS_MEDICAL, \
	ACCESS_MORGUE, \
	ACCESS_MORGUE_SECURE, \
	ACCESS_PHARMACY, \
	ACCESS_PLUMBING, \
	ACCESS_PSYCHOLOGY, \
	ACCESS_SURGERY, \
	ACCESS_VIROLOGY, \
)
/// Name for the Research region.
#define REGION_RESEARCH "Research"
/// Used to seed the accesses_by_region list in SSid_access. A list of all research regional accesses that are overseen by the RD.
#define REGION_ACCESS_RESEARCH list( \
	ACCESS_AI_UPLOAD, \
	ACCESS_GENETICS, \
	ACCESS_MECH_SCIENCE, \
	ACCESS_MINISAT, \
	ACCESS_NETWORK, \
	ACCESS_ORDNANCE, \
	ACCESS_ORDNANCE_STORAGE, \
	ACCESS_RD, \
	ACCESS_RESEARCH, \
	ACCESS_ROBOTICS, \
	ACCESS_SCIENCE, \
	ACCESS_XENOBIOLOGY, \
)
/// Name for the Engineering region.
#define REGION_ENGINEERING "Engineering"
/// Used to seed the accesses_by_region list in SSid_access. A list of all engineering regional accesses that are overseen by the CE.
#define REGION_ACCESS_ENGINEERING list( \
	ACCESS_ATMOSPHERICS, \
	ACCESS_AUX_BASE, \
	ACCESS_CE, \
	ACCESS_CONSTRUCTION, \
	ACCESS_ENGINEERING, \
	ACCESS_ENGINE_EQUIP, \
	ACCESS_EXTERNAL_AIRLOCKS, \
	ACCESS_MAINT_TUNNELS, \
	ACCESS_MECH_ENGINE, \
	ACCESS_MINISAT, \
	ACCESS_TCOMMS, \
	ACCESS_TECH_STORAGE, \
)
/// Name for the Supply region.
#define REGION_SUPPLY "Supply"
/// Used to seed the accesses_by_region list in SSid_access. A list of all cargo regional accesses that are overseen by the HoP.
#define REGION_ACCESS_SUPPLY list( \
	ACCESS_BIT_DEN, \
	ACCESS_CARGO, \
	ACCESS_MECH_MINING, \
	ACCESS_MINERAL_STOREROOM, \
	ACCESS_MINING, \
	ACCESS_MINING_STATION, \
	ACCESS_QM, \
	ACCESS_SHIPPING, \
	ACCESS_VAULT, \
)
/// Name for the Command region.
#define REGION_COMMAND "Command"
/// Used to seed the accesses_by_region list in SSid_access. A list of all command regional accesses that are overseen by the Captain.
#define REGION_ACCESS_COMMAND list( \
	ACCESS_AI_UPLOAD, \
	ACCESS_ALL_PERSONAL_LOCKERS, \
	ACCESS_CAPTAIN, \
	ACCESS_CHANGE_IDS, \
	ACCESS_COMMAND, \
	ACCESS_EVA, \
	ACCESS_GATEWAY, \
	ACCESS_HOP, \
	ACCESS_KEYCARD_AUTH, \
	ACCESS_RC_ANNOUNCE, \
	ACCESS_TELEPORTER, \
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
	/obj/item/modular_computer/pda = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/clown = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/mime = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/medical = list(REGION_MEDBAY), \
	/obj/item/modular_computer/pda/coroner = list(REGION_MEDBAY), \
	/obj/item/modular_computer/pda/engineering = list(REGION_ENGINEERING), \
	/obj/item/modular_computer/pda/security = list(REGION_SECURITY), \
	/obj/item/modular_computer/pda/detective = list(REGION_SECURITY), \
	/obj/item/modular_computer/pda/warden = list(REGION_SECURITY), \
	/obj/item/modular_computer/pda/janitor = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/science = list(REGION_RESEARCH), \
	/obj/item/modular_computer/pda/heads/quartermaster = list(REGION_COMMAND), \
	/obj/item/modular_computer/pda/heads/hop = list(REGION_COMMAND), \
	/obj/item/modular_computer/pda/heads/hos = list(REGION_COMMAND), \
	/obj/item/modular_computer/pda/heads/cmo = list(REGION_COMMAND), \
	/obj/item/modular_computer/pda/heads/ce = list(REGION_COMMAND), \
	/obj/item/modular_computer/pda/heads/rd = list(REGION_COMMAND), \
	/obj/item/modular_computer/pda/heads/captain = list(REGION_COMMAND), \
	/obj/item/modular_computer/pda/cargo = list(REGION_SUPPLY), \
	/obj/item/modular_computer/pda/bitrunner = list(REGION_SUPPLY), \
	/obj/item/modular_computer/pda/shaftminer = list(REGION_SUPPLY), \
	/obj/item/modular_computer/pda/chaplain = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/lawyer = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/botanist = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/roboticist = list(REGION_RESEARCH), \
	/obj/item/modular_computer/pda/curator = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/cook = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/bar = list(REGION_GENERAL), \
	/obj/item/modular_computer/pda/atmos = list(REGION_ENGINEERING), \
	/obj/item/modular_computer/pda/chemist = list(REGION_MEDBAY), \
	/obj/item/modular_computer/pda/geneticist = list(REGION_RESEARCH), \
)

/// All regions that make up the station area. Helper define to quickly designate a region as part of the station or not. Access via SSid_access.station_regions.
#define REGION_AREA_STATION list( \
	REGION_COMMAND, \
	REGION_ENGINEERING, \
	REGION_GENERAL, \
	REGION_MEDBAY, \
	REGION_RESEARCH, \
	REGION_SECURITY, \
	REGION_SUPPLY, \
)

/// Used in ID card access adding procs. Will try to add all accesses and utilises free wildcards, skipping over any accesses it can't add.
#define TRY_ADD_ALL 0
/// Used in ID card access adding procs. Will try to add all accesses and does not utilise wildcards, skipping anything requiring a wildcard.
#define TRY_ADD_ALL_NO_WILDCARD 1
/// Used in ID card access adding procs. Will forcefully add all accesses.
#define FORCE_ADD_ALL 2
/// Used in ID card access adding procs. Will stack trace on fail.
#define ERROR_ON_FAIL 3
