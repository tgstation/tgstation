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

#define ACCESS_FLAG_COMMON 		(1 << 0)
#define ACCESS_FLAG_COMMAND		((1 << 1) | ACCESS_FLAG_COMMON)
#define ACCESS_FLAG_PRV_COMMAND	((1 << 2) | ACCESS_FLAG_COMMAND)
#define ACCESS_FLAG_CAPTAIN		((1 << 3) | ACCESS_FLAG_PRV_COMMAND)
#define ACCESS_FLAG_CENTCOM		((1 << 4) | ACCESS_FLAG_CAPTAIN)
/// Flag for syndicate wildcard accesses
#define ACCESS_FLAG_SYNDICATE	((1 << 5) | ACCESS_FLAG_CAPTAIN)
/// Flag for away mission wildcard accesses.
#define ACCESS_FLAG_AWAY		(1 << 6)
/// Flag for special accesses that should not ordinarily go on ID cards.
#define ACCESS_FLAG_SPECIAL		(1 << 7)

/// Departmental/general/common area accesses
#define COMMON_ACCESS 			list(ACCESS_MECH_MINING, ACCESS_MECH_MEDICAL, ACCESS_MECH_SECURITY, ACCESS_MECH_SCIENCE, \
								ACCESS_MECH_ENGINE, ACCESS_AUX_BASE, ACCESS_PSYCHOLOGY, ACCESS_PHARMACY, ACCESS_NETWORK, \
								ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_SEC_DOORS, ACCESS_XENOBIOLOGY, \
								ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_RESEARCH, ACCESS_THEATRE, \
								ACCESS_SURGERY, ACCESS_COURT, ACCESS_QM, ACCESS_VIROLOGY, ACCESS_LAWYER, ACCESS_LIBRARY, \
								ACCESS_HYDROPONICS, ACCESS_CHEMISTRY, ACCESS_CONSTRUCTION, ACCESS_CARGO, ACCESS_ROBOTICS, \
								ACCESS_KITCHEN, ACCESS_CREMATORIUM, ACCESS_JANITOR, ACCESS_BAR, ACCESS_CHAPEL_OFFICE, \
								ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE_EQUIP, ACCESS_ENGINE, \
								ACCESS_GENETICS, ACCESS_RND, ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_FORENSICS_LOCKERS, \
								ACCESS_BRIG, ACCESS_SECURITY)
/// Command staff/secure accesses, think bridge/armoury, AI upload, notably access to modify ID cards themselves.
#define COMMAND_ACCESS 			list(ACCESS_TOXINS_STORAGE, ACCESS_MINISAT, ACCESS_TCOMSAT, ACCESS_KEYCARD_AUTH, \
								ACCESS_RC_ANNOUNCE, ACCESS_VAULT, ACCESS_ATMOSPHERICS, ACCESS_TECH_STORAGE, ACCESS_HEADS, \
								ACCESS_TELEPORTER, ACCESS_ARMORY, ACCESS_AI_UPLOAD, ACCESS_CHANGE_IDS, ACCESS_TOXINS, \
								ACCESS_EVA, ACCESS_GATEWAY, ACCESS_ALL_PERSONAL_LOCKERS)
/// Private head of staff offices, usually only granted to most cards by trimming
#define PRIVATE_COMMAND_ACCESS 	list(ACCESS_HOS, ACCESS_HOP, ACCESS_CE, ACCESS_CMO, ACCESS_RD)
/// Captains private rooms.
#define CAPTAIN_ACCESS 			list(ACCESS_CAPTAIN)
/// Centcomm area stuff
#define CENTCOM_ACCESS 			list(ACCESS_CENT_BAR, ACCESS_CENT_CAPTAIN, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE,\
								ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_THUNDER, \
								ACCESS_CENT_GENERAL)
/// Syndicate areas off station
#define SYNDICATE_ACCESS 		list(ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE)
/// Away missions/gateway/space ruins
#define AWAY_ACCESS 			list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_MED, ACCESS_AWAY_SEC, ACCESS_AWAY_ENGINE, \
								ACCESS_AWAY_GENERIC1, ACCESS_AWAY_GENERIC2, ACCESS_AWAY_GENERIC3, ACCESS_AWAY_GENERIC4)
/// Special
#define CULT_ACCESS 			list(ACCESS_BLOODCULT)

#define ALL_ACCESS_STATION		COMMON_ACCESS + COMMAND_ACCESS + PRIVATE_COMMAND_ACCESS + CAPTAIN_ACCESS

#define ACCESS_REGION_ALL				0
#define ACCESS_REGION_GENERAL			1
#define ACCESS_REGION_SECURITY			2
#define ACCESS_REGION_MEDBAY			3
#define ACCESS_REGION_RESEARCH			4
#define ACCESS_REGION_ENGINEERING		5
#define ACCESS_REGION_SUPPLY			6
#define ACCESS_REGION_COMMAND			7
