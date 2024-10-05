//Each lists stores ckeys for "Never for this round" option category

#define POLL_IGNORE_ACADEMY_WIZARD "academy_wizard"
#define POLL_IGNORE_ALIEN_LARVA "alien_larva"
#define POLL_IGNORE_ASH_SPIRIT "ash_spirit"
#define POLL_IGNORE_ASHWALKER "ashwalker"
#define POLL_IGNORE_BLOB "blob"
#define POLL_IGNORE_BOTS "bots"
#define POLL_IGNORE_CARGORILLA "cargorilla"
#define POLL_IGNORE_CONSTRUCT "construct"
#define POLL_IGNORE_CONTRACTOR_SUPPORT "contractor_support"
#define POLL_IGNORE_DRONE "drone"
#define POLL_IGNORE_FIRE_SHARK "fire_shark"
#define POLL_IGNORE_FUGITIVE "fugitive"
#define POLL_IGNORE_GLITCH "glitch"
#define POLL_IGNORE_GOLEM "golem"
#define POLL_IGNORE_HERETIC_MONSTER "heretic_monster"
#define POLL_IGNORE_HOLOPARASITE "holoparasite"
#define POLL_IGNORE_IMAGINARYFRIEND "imaginary_friend"
#define POLL_IGNORE_LAVALAND_ELITE "lavaland_elite"
#define POLL_IGNORE_MAID_IN_MIRROR "maid_in_mirror"
#define POLL_IGNORE_MONKEY_HELMET "mind_magnified_monkey"
#define POLL_IGNORE_PAI "pai"
#define POLL_IGNORE_POSIBRAIN "posibrain"
#define POLL_IGNORE_POSSESSED_BLADE "possessed_blade"
#define POLL_IGNORE_PYROSLIME "slime"
#define POLL_IGNORE_RAW_PROPHET "raw_prophet"
#define POLL_IGNORE_REGAL_RAT "regal_rat"
#define POLL_IGNORE_RUST_SPIRIT "rust_spirit"
#define POLL_IGNORE_SENTIENCE_POTION "sentience_potion"
#define POLL_IGNORE_SHADE "shade"
#define POLL_IGNORE_SHUTTLE_DENIZENS "shuttle_denizens"
#define POLL_IGNORE_SPECTRAL_BLADE "spectral_blade"
#define POLL_IGNORE_SPIDER "spider"
#define POLL_IGNORE_SPLITPERSONALITY "split_personality"
#define POLL_IGNORE_STALKER "stalker"
#define POLL_IGNORE_SYNDICATE "syndicate"
#define POLL_IGNORE_VENUSHUMANTRAP "venus_human_trap"
#define POLL_IGNORE_RECOVERED_CREW "recovered_crew"

GLOBAL_LIST_INIT(poll_ignore_desc, list(
	POLL_IGNORE_ACADEMY_WIZARD = "Academy Wizard Defender",
	POLL_IGNORE_ALIEN_LARVA = "Xenomorph larva",
	POLL_IGNORE_ASH_SPIRIT = "Ash Spirit",
	POLL_IGNORE_ASHWALKER = "Ashwalker eggs",
	POLL_IGNORE_BLOB = "Blob spores",
	POLL_IGNORE_BOTS = "Bots",
	POLL_IGNORE_CARGORILLA = "Cargorilla",
	POLL_IGNORE_CONSTRUCT = "Construct",
	POLL_IGNORE_CONTRACTOR_SUPPORT = "Contractor Support Unit",
	POLL_IGNORE_DRONE = "Drone shells",
	POLL_IGNORE_FIRE_SHARK = "Fire Shark",
	POLL_IGNORE_FUGITIVE = "Fugitive Hunter",
	POLL_IGNORE_GLITCH = "Glitch",
	POLL_IGNORE_GOLEM = "Golems",
	POLL_IGNORE_HERETIC_MONSTER = "Heretic Monster",
	POLL_IGNORE_HOLOPARASITE = "Holoparasite",
	POLL_IGNORE_IMAGINARYFRIEND = "Imaginary Friend",
	POLL_IGNORE_LAVALAND_ELITE = "Lavaland elite",
	POLL_IGNORE_MAID_IN_MIRROR = "Maid in the Mirror",
	POLL_IGNORE_MONKEY_HELMET = "Mind magnified monkey",
	POLL_IGNORE_PAI = JOB_PERSONAL_AI,
	POLL_IGNORE_POSIBRAIN = "Positronic brain",
	POLL_IGNORE_POSSESSED_BLADE = "Possessed blade",
	POLL_IGNORE_PYROSLIME = "Slime",
	POLL_IGNORE_RAW_PROPHET = "Raw Prophet",
	POLL_IGNORE_REGAL_RAT = "Regal rat",
	POLL_IGNORE_RUST_SPIRIT = "Rust Spirit",
	POLL_IGNORE_SENTIENCE_POTION = "Sentience potion",
	POLL_IGNORE_SHADE = "Shade",
	POLL_IGNORE_SHUTTLE_DENIZENS = "Shuttle denizens",
	POLL_IGNORE_SPECTRAL_BLADE = "Spectral blade",
	POLL_IGNORE_SPIDER = "Spiders",
	POLL_IGNORE_SPLITPERSONALITY = "Split Personality",
	POLL_IGNORE_STALKER = "Stalker",
	POLL_IGNORE_SYNDICATE = "Syndicate",
	POLL_IGNORE_VENUSHUMANTRAP = "Venus Human Traps",
	POLL_IGNORE_RECOVERED_CREW = "recovered_crew",
))
GLOBAL_LIST_INIT(poll_ignore, init_poll_ignore())


/proc/init_poll_ignore()
	. = list()
	for (var/k in GLOB.poll_ignore_desc)
		.[k] = list()
