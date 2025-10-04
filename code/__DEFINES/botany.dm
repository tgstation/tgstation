/// -- Botany plant stat defines. --
/// MAXES:
#define MAX_PLANT_YIELD 10
#define MAX_PLANT_LIFESPAN 100
#define MAX_PLANT_ENDURANCE 100
#define MAX_PLANT_PRODUCTION 10
#define MAX_PLANT_POTENCY 100
#define MAX_PLANT_INSTABILITY 100
#define MAX_PLANT_WEEDRATE 10
#define MAX_PLANT_WEEDCHANCE 67
/// MINS:
#define MIN_PLANT_ENDURANCE 10

/// Default reagent volume for grown plants
#define PLANT_REAGENT_VOLUME 100

/// -- Some botany trait value defines. --
/// Weed Hardy can only reduce plants to 3 yield.
#define WEED_HARDY_YIELD_MIN 3
/// Carnivory potency can only reduce potency to 30.
#define CARNIVORY_POTENCY_MIN 30
/// Fungle megabolism plants have a min yield of 1.
#define FUNGAL_METAB_YIELD_MIN 1
/// Semiaquatic plants gets 50% more weeds in soil.
#define SEMIAQUATIC_SOIL_WEED_MALUS 1.5
/// Soil loving plants get worse yield when grown in a medium that isn't soil.
#define SOIL_LOVER_HYDRO_YIELD_MALUS 0.7
/// Upper bound of produce size mod for soil lowers grown without soil.
#define SOIL_LOVER_HYDRO_POTENCY_MAX 0.8
/// Lower bound of produce size mod for soil lowers grown without soil
#define SOIL_LOVER_HYDRO_POTENCY_MIN 0.5


/// -- Hydroponics tray defines. --
///  Base amount of nutrients a tray can old.
#define STATIC_NUTRIENT_CAPACITY 10
/// Maximum amount of toxins a tray can reach.
#define MAX_TRAY_TOXINS 100
/// Maxumum pests a tray can reach.
#define MAX_TRAY_PESTS 10
/// Maximum weeds a tray can reach.
#define MAX_TRAY_WEEDS 10
/// Minumum plant health required for gene shears.
#define GENE_SHEAR_MIN_HEALTH 15
/// Minumum plant endurance required to lock a mutation with a somatoray.
#define FLORA_GUN_MIN_ENDURANCE 20

/// -- Flags for genes --
/// Plant genes that can be removed via gene shears.
#define PLANT_GENE_REMOVABLE (1<<0)
/// Plant genes that can be mutated randomly in strange seeds / due to high instability.
#define PLANT_GENE_MUTATABLE (1<<1)
/// Plant genes that can be graftable. Used in formatting text, as they need to be set to be graftable anyways.
#define PLANT_GENE_GRAFTABLE (1<<2)

/// -- Flags for seeds. --
/// Allows a plant to wild mutate (mutate on haravest) at a certain instability.
#define MUTATE_EARLY (1<<0)

/// -- Flags for traits. --
/// Caps the plant's yield at 5 instead of 10.
#define TRAIT_HALVES_YIELD (1<<0)
/// Doesn't get bonuses from tray yieldmod
#define TRAIT_NO_POLLINATION (1<<1)
/// Shows description on examine
#define TRAIT_SHOW_EXAMINE (1<<2)

/// -- Trait IDs. Plants that match IDs cannot be added to the same plant. --
/// Plants that glow.
#define GLOW_ID (1<<0)
/// Plant types.
#define PLANT_TYPE_ID (1<<1)
/// Plants that affect the reagent's temperature.
#define TEMP_CHANGE_ID (1<<2)
/// Plants that affect the reagent contents.
#define CONTENTS_CHANGE_ID (1<<3)
/// Plants that do something special when they impact.
#define THROW_IMPACT_ID (1<<4)
/// Plants that transfer reagents on impact.
#define REAGENT_TRANSFER_ID (1<<5)
/// Plants that have a unique effect on attack_self.
#define ATTACK_SELF_ID (1<<6)

#define GLOWSHROOM_SPREAD_BASE_DIMINISH_FACTOR 10
#define GLOWSHROOM_SPREAD_DIMINISH_FACTOR_PER_GLOWSHROOM 0.2
#define GLOWSHROOM_BASE_INTEGRITY 60

// obj/machinery/hydroponics/var/plant_status defines

/// How long to wait between plant age ticks, by default. See [/obj/machinery/hydroponics/var/cycledelay]
#define HYDROTRAY_CYCLE_DELAY 20 SECONDS

#define HYDROTRAY_NO_PLANT "missing"
#define HYDROTRAY_PLANT_DEAD "dead"
#define HYDROTRAY_PLANT_GROWING "growing"
#define HYDROTRAY_PLANT_HARVESTABLE "harvestable"

/// A list of possible egg laying descriptions
#define EGG_LAYING_MESSAGES list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")

/// Used as a baseline plant rarity for more uncommon plants, usually requiring mutation
#define PLANT_MODERATELY_RARE 20

/// How much water drain is reduced for trays with the SUPERWATER modifier such as superabsorbent hydrogel beads.
#define SUPER_WATER_MODIFIER 0.5
// How much faster our mushrooms mature on a good mushroom growing soil such as korta coir.
#define FAST_MUSH_MODIFIER 1.4
// How many grafts we harvest from one plant if planted in a tray with the MULTI_GRAFT flag.
#define MULTI_GRAFT_MAX_COUNT 3

/// TRAY BITFLAGS

/// For watery trays, capable of growing aquatic plants.
#define HYDROPONIC (1 << 0)
/// For soil type trays that provide structure for soil loving plants.
#define SOIL (1 << 1)
/// Allows you to take up to 3 grafts from the same plant.
#define MULTIGRAFT (1 << 2)
/// Allows you to plant grafts into this tray to propagate them vegetativley.
#define GRAFT_MEDIUM (1 << 3)
/// Musrooms mature faster in this type of tray.
#define FAST_MUSHROOMS (1 << 4)
/// Extra slimy worms can be created by composting greens in this soil.
#define WORM_HABITAT (1 << 5)
/// Water drains at a slower rate from this soil.
#define SUPERWATER (1 << 6)
/// If this tray runs out of nutrients, add a little nitrogen from the breakdown of natural fertilizers or nitrogen fixating bacteria.
#define SLOW_RELEASE (1 << 7)
