#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8

//fugitive end results
#define FUGITIVE_RESULT_BADASS_HUNTER 0
#define FUGITIVE_RESULT_POSTMORTEM_HUNTER 1
#define FUGITIVE_RESULT_MAJOR_HUNTER 2
#define FUGITIVE_RESULT_HUNTER_VICTORY 3
#define FUGITIVE_RESULT_MINOR_HUNTER 4
#define FUGITIVE_RESULT_STALEMATE 5
#define FUGITIVE_RESULT_MINOR_FUGITIVE 6
#define FUGITIVE_RESULT_FUGITIVE_VICTORY 7
#define FUGITIVE_RESULT_MAJOR_FUGITIVE 8

#define APPRENTICE_DESTRUCTION "destruction"
#define APPRENTICE_BLUESPACE "bluespace"
#define APPRENTICE_ROBELESS "robeless"
#define APPRENTICE_HEALING "healing"

//ERT Types
#define ERT_BLUE "Blue"
#define ERT_RED  "Red"
#define ERT_AMBER "Amber"
#define ERT_DEATHSQUAD "Deathsquad"

//ERT subroles
#define ERT_SEC "sec"
#define ERT_MED "med"
#define ERT_ENG "eng"
#define ERT_LEADER "leader"
#define DEATHSQUAD "ds"
#define DEATHSQUAD_LEADER "ds_leader"

//Shuttle elimination hijacking
/// Does not stop elimination hijacking but itself won't elimination hijack
#define ELIMINATION_NEUTRAL 0
/// Needs to be present for shuttle to be elimination hijacked
#define ELIMINATION_ENABLED 1
/// Prevents elimination hijack same way as non-antags
#define ELIMINATION_PREVENT 2

//Syndicate Contracts
#define CONTRACT_STATUS_INACTIVE 1
#define CONTRACT_STATUS_ACTIVE 2
#define CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE 3
#define CONTRACT_STATUS_EXTRACTING 4
#define CONTRACT_STATUS_COMPLETE 5
#define CONTRACT_STATUS_ABORTED 6

#define CONTRACT_PAYOUT_LARGE 1
#define CONTRACT_PAYOUT_MEDIUM 2
#define CONTRACT_PAYOUT_SMALL 3

#define CONTRACT_UPLINK_PAGE_CONTRACTS "CONTRACTS"
#define CONTRACT_UPLINK_PAGE_HUB "HUB"

GLOBAL_LIST_INIT(heretic_start_knowledge, list(
	/datum/heretic_knowledge/spell/basic,
	/datum/heretic_knowledge/living_heart,
	/datum/heretic_knowledge/codex_cicatrix
))


#define PATH_SIDE "Side"

#define PATH_ASH "Ash"
#define PATH_RUST "Rust"
#define PATH_FLESH "Flesh"
#define PATH_VOID "Void"

/// Forces the blob to place the core where they currently are, ignoring any checks.
#define BLOB_FORCE_PLACEMENT -1
/// Normal blob placement, does the regular checks to make sure the blob isn't placing itself in an invalid location
#define BLOB_NORMAL_PLACEMENT 0
/// Selects a random location for the blob to be placed.
#define BLOB_RANDOM_PLACEMENT 1

#define CONSTRUCT_JUGGERNAUT "Juggernaut"
#define CONSTRUCT_WRAITH "Wraith"
#define CONSTRUCT_ARTIFICER "Artificer"

/// The Classic Wizard wizard loadout.
#define WIZARD_LOADOUT_CLASSIC "loadout_classic"
/// Mjolnir's Power wizard loadout.
#define WIZARD_LOADOUT_MJOLNIR "loadout_hammer"
/// Fantastical Army wizard loadout.
#define WIZARD_LOADOUT_WIZARMY "loadout_army"
/// Soul Tapper wizard loadout.
#define WIZARD_LOADOUT_SOULTAP "loadout_tap"
/// Convenient list of all wizard loadouts for unit testing.
#define ALL_WIZARD_LOADOUTS list( \
	WIZARD_LOADOUT_CLASSIC, \
	WIZARD_LOADOUT_MJOLNIR, \
	WIZARD_LOADOUT_WIZARMY, \
	WIZARD_LOADOUT_SOULTAP, \
)

///File to the traitor flavor
#define TRAITOR_FLAVOR_FILE "antagonist_flavor/traitor_flavor.json"

///File to the malf flavor
#define MALFUNCTION_FLAVOR_FILE "antagonist_flavor/malfunction_flavor.json"

///File to the thief flavor
#define THIEF_FLAVOR_FILE "antagonist_flavor/thief_flavor.json"

///employers that are from the syndicate
GLOBAL_LIST_INIT(syndicate_employers, list(
	"Animal Rights Consortium",
	"Bee Liberation Front",
	"Cybersun Industries",
	"Donk Corporation",
	"Gorlex Marauders",
	"MI13",
	"Tiger Cooperative Fanatic",
	"Waffle Corporation Terrorist",
	"Waffle Corporation",
))
///employers that are from nanotrasen
GLOBAL_LIST_INIT(nanotrasen_employers, list(
	"Champions of Evil",
	"Corporate Climber",
	"Gone Postal",
	"Internal Affairs Agent",
	"Legal Trouble",
))

///employers who hire agents to do the hijack
GLOBAL_LIST_INIT(hijack_employers, list(
	"Animal Rights Consortium",
	"Bee Liberation Front",
	"Gone Postal",
	"Tiger Cooperative Fanatic",
	"Waffle Corporation Terrorist",
))

///employers who hire agents to do a task and escape... or martyrdom. whatever
GLOBAL_LIST_INIT(normal_employers, list(
	"Champions of Evil",
	"Corporate Climber",
	"Cybersun Industries",
	"Donk Corporation",
	"Gorlex Marauders",
	"Internal Affairs Agent",
	"Legal Trouble",
	"MI13",
	"Waffle Corporation",
))

///employers for malfunctioning ais. they do not have sides, unlike traitors.
GLOBAL_LIST_INIT(ai_employers, list(
	"Biohazard",
	"Despotic Ruler",
	"Fanatical Revelation",
	"Logic Core Error",
	"Problem Solver",
	"S.E.L.F.",
	"Something's Wrong",
	"Spam Virus",
	"SyndOS",
	"Unshackled",
))

///all the employers that are syndicate
#define FACTION_SYNDICATE "syndicate"
///all the employers that are nanotrasen
#define FACTION_NANOTRASEN "nanotrasen"

#define UPLINK_THEME_SYNDICATE "syndicate"

#define UPLINK_THEME_UNDERWORLD_MARKET "neutral"

/// Checks if the given mob is a blood cultist
#define IS_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult))

/// Checks if the given mob is a nuclear operative
#define IS_NUKE_OP(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/nukeop))

#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))

#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic_monster))

/// Checks if the given mob is a wizard
#define IS_WIZARD(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/wizard))

/// Checks if the given mob is a revolutionary. Will return TRUE for rev heads as well.
#define IS_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev))

/// Checks if the given mob is a head revolutionary.
#define IS_HEAD_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev/head))

/// Checks if the given mob is a malf ai.
#define IS_MALF_AI(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/malf_ai))

/// The dimensions of the antagonist preview icon. Will be scaled to this size.
#define ANTAGONIST_PREVIEW_ICON_SIZE 96

// Defines for objective items to determine what they can appear in
/// Can appear in everything
#define OBJECTIVE_ITEM_TYPE_NORMAL "normal"
/// Only appears in traitor objectives
#define OBJECTIVE_ITEM_TYPE_TRAITOR "traitor"

// Progression traitor defines

/// How many telecrystals a normal traitor starts with
#define TELECRYSTALS_DEFAULT 20
/// How many telecrystals mapper/admin only "precharged" uplink implant
#define TELECRYSTALS_PRELOADED_IMPLANT 10
/// The normal cost of an uplink implant; used for calcuating how many
/// TC to charge someone if they get a free implant through choice or
/// because they have nothing else that supports an implant.
#define UPLINK_IMPLANT_TELECRYSTAL_COST 4

// Used for traitor objectives
/// If the objective hasn't been taken yet
#define OBJECTIVE_STATE_INACTIVE 1
/// If the objective is active and ongoing
#define OBJECTIVE_STATE_ACTIVE 2
/// If the objective has been completed.
#define OBJECTIVE_STATE_COMPLETED 3
/// If the objective has failed.
#define OBJECTIVE_STATE_FAILED 4
/// If the objective is no longer valid
#define OBJECTIVE_STATE_INVALID 5
