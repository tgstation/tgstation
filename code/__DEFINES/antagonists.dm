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

//Pirates

///Minimum amount the pirates will demand
#define PAYOFF_MIN 20000
///How long pirates will wait for a response before attacking
#define RESPONSE_MAX_TIME 2 MINUTES

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


// Heretic path defines.
#define PATH_START "Start Path"
#define PATH_SIDE "Side Path"
#define PATH_ASH "Ash Path"
#define PATH_RUST "Rust Path"
#define PATH_FLESH "Flesh Path"
#define PATH_VOID "Void Path"
#define PATH_BLADE "Blade Path"

/// Defines are used in /proc/has_living_heart() to report if the heretic has no heart period, no living heart, or has a living heart.
#define HERETIC_NO_HEART_ORGAN -1
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

/// A define used in ritual priority for heretics.
#define MAX_KNOWLEDGE_PRIORITY 100

/// Checks if the passed mob can become a heretic ghoul.
/// - Must be a human (type, not species)
/// - Skeletons cannot be husked (they are snowflaked instead of having a trait)
/// - Monkeys are monkeys, not quite human (balance reasons)
#define IS_VALID_GHOUL_MOB(mob) (ishuman(mob) && !isskeleton(mob) && !ismonkey(mob))

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
/// Number of times you need to perform the grand ritual to complete it
#define GRAND_RITUAL_FINALE_COUNT 7
/// The crew will start being warned every time a rune is created after this many invocations.
#define GRAND_RITUAL_RUNES_WARNING_POTENCY 3
/// The crew will get a louder warning when this level of rune is created, and the next one will be special
#define GRAND_RITUAL_IMMINENT_FINALE_POTENCY 6

/// Used in logging spells for roundend results
#define LOG_SPELL_TYPE "type"
#define LOG_SPELL_AMOUNT "amount"

///File to the traitor flavor
#define TRAITOR_FLAVOR_FILE "antagonist_flavor/traitor_flavor.json"

///File to the malf flavor
#define MALFUNCTION_FLAVOR_FILE "antagonist_flavor/malfunction_flavor.json"

/// JSON string file for all of our heretic influence flavors
#define HERETIC_INFLUENCE_FILE "antagonist_flavor/heretic_influences.json"

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

#define UPLINK_THEME_SYNDICATE "syndicate"

#define UPLINK_THEME_UNDERWORLD_MARKET "neutral"

/// Checks if the given mob is a blood cultist
#define IS_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult))

/// Checks if the given mob is a nuclear operative
#define IS_NUKE_OP(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/nukeop))

//Tells whether or not someone is a space ninja
#define IS_SPACE_NINJA(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/ninja))

/// Checks if the given mob is a heretic.
#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))
/// Check if the given mob is a heretic monster.
#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic_monster))
/// Checks if the given mob is either a heretic or a heretic monster.
#define IS_HERETIC_OR_MONSTER(mob) (IS_HERETIC(mob) || IS_HERETIC_MONSTER(mob))

/// Checks if the given mob is a wizard
#define IS_WIZARD(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/wizard))

/// Checks if the given mob is a revolutionary. Will return TRUE for rev heads as well.
#define IS_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev))

/// Checks if the given mob is a head revolutionary.
#define IS_HEAD_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev/head))

/// Checks if the given mob is a malf ai.
#define IS_MALF_AI(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/malf_ai))

/// List of human antagonist types which don't spawn directly on the space station
GLOBAL_LIST_INIT(human_invader_antagonists, list(
	/datum/antagonist/abductor,
	/datum/antagonist/fugitive,
	/datum/antagonist/fugitive_hunter,
	/datum/antagonist/ninja,
	/datum/antagonist/nukeop,
	/datum/antagonist/pirate,
	/datum/antagonist/wizard,
))

/// Returns true if the given mob has an antag datum which is assigned to a human antagonist who doesn't spawn on the space station
#define IS_HUMAN_INVADER(mob) (mob?.mind?.has_antag_datum_in_list(GLOB.human_invader_antagonists))

/// The dimensions of the antagonist preview icon. Will be scaled to this size.
#define ANTAGONIST_PREVIEW_ICON_SIZE 96

// Defines for objective items to determine what they can appear in
/// Can appear in everything
#define OBJECTIVE_ITEM_TYPE_NORMAL "normal"
/// Only appears in traitor objectives
#define OBJECTIVE_ITEM_TYPE_TRAITOR "traitor"

// Progression traitor defines

/// Chance that the traitor could roll hijack if the pop limit is met.
#define HIJACK_PROB 10
/// Hijack is unavailable as a random objective below this player count.
#define HIJACK_MIN_PLAYERS 30

/// Chance the traitor gets a martyr objective instead of having to escape alive, as long as all the objectives are martyr compatible.
#define MARTYR_PROB 20

/// Chance the traitor gets a kill objective. If this prob fails, they will get a steal objective instead.
#define KILL_PROB 50
/// If a kill objective is rolled, chance that it is to destroy the AI.
#define DESTROY_AI_PROB(denominator) (100 / denominator)
/// If the destroy AI objective doesn't roll, chance that we'll get a maroon instead. If this prob fails, they will get a generic assassinate objective instead.
#define MAROON_PROB 30

/// How many telecrystals a normal traitor starts with
#define TELECRYSTALS_DEFAULT 20
/// How many telecrystals mapper/admin only "precharged" uplink implant
#define TELECRYSTALS_PRELOADED_IMPLANT 10
/// The normal cost of an uplink implant; used for calcuating how many
/// TC to charge someone if they get a free implant through choice or
/// because they have nothing else that supports an implant.
#define UPLINK_IMPLANT_TELECRYSTAL_COST 4

/// Items with this stock key do not share stock with other items
#define UPLINK_SHARED_STOCK_UNIQUE "uplink_shared_stock_unique"
/// Stock keys for items that share inventory stock
#define UPLINK_SHARED_STOCK_KITS "uplink_shared_stock_kits"
#define UPLINK_SHARED_STOCK_SURPLUS "uplink_shared_stock_surplus"

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

/// Weights for traitor objective categories
#define OBJECTIVE_WEIGHT_VERY_UNLIKELY 2
#define OBJECTIVE_WEIGHT_UNLIKELY 5
#define OBJECTIVE_WEIGHT_DEFAULT 10
#define OBJECTIVE_WEIGHT_LIKELY 15
#define OBJECTIVE_WEIGHT_VERY_LIKELY 20

#define REVENANT_NAME_FILE "revenant_names.json"

/// Antag panel groups
#define ANTAG_GROUP_ABDUCTORS "Abductors"
#define ANTAG_GROUP_ABOMINATIONS "Extradimensional Abominations"
#define ANTAG_GROUP_ARACHNIDS "Arachnid Infestation"
#define ANTAG_GROUP_ASHWALKERS "Ash Walkers"
#define ANTAG_GROUP_BIOHAZARDS "Biohazards"
#define ANTAG_GROUP_CLOWNOPS "Clown Operatives"
#define ANTAG_GROUP_ERT "Emergency Response Team"
#define ANTAG_GROUP_HORRORS "Eldritch Horrors"
#define ANTAG_GROUP_LEVIATHANS "Spaceborne Leviathans"
#define ANTAG_GROUP_NINJAS "Ninja Clan"
#define ANTAG_GROUP_OVERGROWTH "Invasive Overgrowth"
#define ANTAG_GROUP_PIRATES "Pirate Crew"
#define ANTAG_GROUP_SYNDICATE "Syndicate"
#define ANTAG_GROUP_WIZARDS "Wizard Federation"
#define ANTAG_GROUP_XENOS "Xenomorph Infestation"
