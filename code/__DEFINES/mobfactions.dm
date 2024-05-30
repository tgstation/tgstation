// Contains mob factions that are not handled by special role defines (for example, viscerators having ROLE_SYNDICATE)

// Default factions

/// Acts as a default faction for most violent creatures
#define FACTION_HOSTILE "hostile"
/// Acts as a default faction for most peaceful creatures
#define FACTION_NEUTRAL "neutral"

// Creature factions

/// Ashwalker related creatures
#define FACTION_ASHWALKER "ashwalker"
/// Megafauna bosses of mining
#define FACTION_BOSS "boss"
/// CARPS
#define FACTION_CARP "carp"
/// Creatures summoned by chemical reactions
#define FACTION_CHEMICAL_SUMMON "chemical_summon"
/// Clown creatures and the Clown themselves
#define FACTION_CLOWN "clowns"
/// Headslugs
#define FACTION_CREATURE "creature"
/// Cats
#define FACTION_CAT "cat"
/// Faithless and shadowpeople
#define FACTION_FAITHLESS "faithless"
/// Gnomes
#define FACTION_GNOME "gnomes"
/// Gondolas
#define FACTION_GONDOLA "gondola"
/// Slaughterdemons
#define FACTION_HELL "hell"
/// Hivebots
#define FACTION_HIVEBOT "hivebot"
/// Illusionary creaturs
#define FACTION_ILLUSION "illusion"
/// Creatures of the never finished jungle planet, and gorillas
#define FACTION_JUNGLE "jungle"
/// Small lizards
#define FACTION_LIZARD "lizard"
/// Maint creatures have mutual respect for eachother.
#define FACTION_MAINT_CREATURES "maint_creatures"
/// Animated objects and statues
#define FACTION_MIMIC "mimic"
/// Beasts found on the various mining environments
#define FACTION_MINING "mining"
/// Watchers don't like any creatures other than each other
#define FACTION_WATCHER "watcher"
/// Monkeys and gorillas
#define FACTION_MONKEY "monkey"
/// Mushrooms and mushroompeople
#define FACTION_MUSHROOM "mushroom"
/// Nanotrasen private security
#define FACTION_NANOTRASEN_PRIVATE "nanotrasen_private"
/// Mobs from the Netherworld
#define FACTION_NETHER "nether"
/// Mobs spawned by the emagged orion arcade
#define FACTION_ORION "orion"
/// Penguins and their chicks
#define FACTION_PENGUIN "penguin"
/// Plants, lots of overlap with vines
#define FACTION_PLANTS "plants"
/// Rats and mice
#define FACTION_RAT "rats"
/// Creatures from Space Russia
#define FACTION_RUSSIAN "russian"
/// Creatures affiliated with the AI and Cyborgs
#define FACTION_SILICON "silicon"
/// Spooky scary skeletons
#define FACTION_SKELETON "skeleton"
/// Slimey creatures
#define FACTION_SLIME "slime"
/// Spiders and their webs
#define FACTION_SPIDER "spiders"
/// Currently used only by floating eyeballs
#define FACTION_SPOOKY "spooky"
/// Statues that move around when nobody is watching them
#define FACTION_STATUE "statue"
/// Stick creatures summoned by the Paperwizard, and the wizard themselves
#define FACTION_STICKMAN "stickman"
/// Creatures ignored by various turrets
#define FACTION_TURRET "turret"
/// Vines, lots of overlap with plants
#define FACTION_VINES "vines"
///raptor factions
#define FACTION_RAPTOR "raptor"
// Antagonist factions

/// Cultists and their constructs
#define FACTION_CULT "cult"
/// Define for the heretic faction applied to heretics and heretic mobs.
#define FACTION_HERETIC "heretics"
/// Mainly used by pirate simplemobs. However I placed them here instead, as its also used by players
#define FACTION_PIRATE "pirate"

/// Generates a mob faction for the passed owner, used by stabilized pink extracts
#define FACTION_PINK_EXTRACT(owner) "pink_[owner]"
