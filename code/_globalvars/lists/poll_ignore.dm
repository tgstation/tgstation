//Each lists stores ckeys for "Never for this round" option category

#define POLL_IGNORE_SENTIENCE_POTION "sentience_potion"
#define POLL_IGNORE_POSSESSED_BLADE "possessed_blade"
#define POLL_IGNORE_ALIEN_LARVA "alien_larva"
#define POLL_IGNORE_SYNDICATE "syndicate"
#define POLL_IGNORE_HOLOPARASITE "holoparasite"
#define POLL_IGNORE_POSIBRAIN "posibrain"
#define POLL_IGNORE_SPECTRAL_BLADE "spectral_blade"
#define POLL_IGNORE_CONSTRUCT "construct"
#define POLL_IGNORE_SPIDER "spider"
#define POLL_IGNORE_ASHWALKER "ashwalker"
#define POLL_IGNORE_GOLEM "golem"
#define POLL_IGNORE_SWARMER "swarmer"
#define POLL_IGNORE_DRONE "drone"

GLOBAL_LIST_INIT(poll_ignore_desc, list(
	POLL_IGNORE_SENTIENCE_POTION = "Sentience potion",
	POLL_IGNORE_POSSESSED_BLADE = "Possessed blade",
	POLL_IGNORE_ALIEN_LARVA = "Xenomorph larva",
	POLL_IGNORE_SYNDICATE = "Syndicate",
	POLL_IGNORE_HOLOPARASITE = "Holoparasite",
	POLL_IGNORE_POSIBRAIN = "Positronic brain",
	POLL_IGNORE_SPECTRAL_BLADE = "Spectral blade",
	POLL_IGNORE_CONSTRUCT = "Construct",
	POLL_IGNORE_SPIDER = "Spiders",
	POLL_IGNORE_ASHWALKER = "Ashwalker eggs",
	POLL_IGNORE_GOLEM = "Golems",
	POLL_IGNORE_SWARMER = "Swarmer shells",
	POLL_IGNORE_DRONE = "Drone shells",
))
GLOBAL_LIST_INIT(poll_ignore, init_poll_ignore())


/proc/init_poll_ignore()
	. = list()
	for (var/k in GLOB.poll_ignore_desc)
		.[k] = list()
