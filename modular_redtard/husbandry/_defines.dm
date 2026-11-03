// Stage 4: husbandry and taming. Cross-file defines of the husbandry module.

/// Ratwood's food meter of a beast (simple_animal.dm food): full at 100, looks for food at 50 and below.
#define ROGUE_BEAST_FOOD_MAX 100
#define ROGUE_BEAST_HUNGRY 50
/// What one meal or one hand-feeding fills (Ratwood +30).
#define ROGUE_BEAST_MEAL 30
/// Ratwood drains the meter and fills production by one point a Life (2 seconds).
#define ROGUE_BEAST_FOOD_PER_SECOND 0.5
#define ROGUE_BEAST_PRODUCTION_MAX 100
/// Hand-feeding heals (Ratwood adjustHealth(-rand(10, 20))).
#define ROGUE_FEED_HEAL_MIN 10
#define ROGUE_FEED_HEAL_MAX 20
/// Starvation (not in Ratwood): a kept beast with an empty meter this long starts losing this share of its health a second.
#define ROGUE_BEAST_STARVE_DELAY (10 MINUTES)
#define ROGUE_BEAST_STARVE_DAMAGE 0.005

/// A mother needs this much in her to give birth (Ratwood make_babies(): food < 10).
#define ROGUE_BREED_FOOD 10
/// Young of hers within this many tiles that stop her giving birth again, and how many (Ratwood: view(7), 3).
#define ROGUE_BREED_RANGE 7
#define ROGUE_BREED_MAX_YOUNG 3
/// How long a mother keeps trying to reach the father before she gives up until her next season.
#define ROGUE_BREED_SEEK_TIME (30 SECONDS)
/// Growth of the young a second: Ratwood 0.5 a Life (2 seconds) to 100; the chick rand(1, 2) a Life.
#define ROGUE_YOUNG_GROWTH 0.25
#define ROGUE_CHICK_GROWTH 0.75

/// What laying an egg costs a hen, and what she must have over (Ratwood chicken Life(): production > 29, -30).
#define ROGUE_EGG_PRODUCTION 30
/// Chance an egg is fertile: a nesting hen (Ratwood rogue chicken) and a fed one (Ratwood friendly chicken).
#define ROGUE_EGG_FERTILE_CHANCE 50
#define ROGUE_FED_EGG_FERTILE_CHANCE 25
/// How far a hen looks for a nest or nesting stuff (Ratwood oview() at its world.view, 15x15).
#define ROGUE_NEST_SIGHT 7
/// No fertile eggs while this many chickens live (Ratwood MAX_CHICKENS).
#define ROGUE_MAX_CHICKENS 50
/// A fed hen lays from a store of eggs: 1-4 a meal, at most 8 (Ratwood friendly chicken attackby()).
#define ROGUE_FED_EGGS_MAX 8
/// A fertile egg grows rand(1, 2) every 2 seconds to 100 (Ratwood egg process()); TG's fertile_egg multiplies by the tick's seconds.
#define ROGUE_EGG_HATCH_GROWTH 200

/// How long held-out food or a beckon draws a beast, and how long a hen walks to a nest or nesting stuff (Ratwood return_action timers).
#define ROGUE_LURE_TIME (3 SECONDS)
#define ROGUE_NEST_SEEK_TIME (15 SECONDS)
/// Tiles a shooed tamed beast looks for someone to set upon (Ratwood retaliate/rogue vision_range).
#define ROGUE_SHOO_RANGE 5
/// Taming an angry beast: it calms down and takes to the feeder with this chance, else it stays wild (Ratwood retaliate/rogue tamed()).
#define ROGUE_TAME_ANGRY_CHANCE 23

/// Truffles under dirt in the woods (Ratwood trufflepig.dm): chance a dirt tile hides them, how far the pig smells, the pig's
/// patience before it sulks, what a potato takes off it, and the digging.
#define ROGUE_TRUFFLE_CHANCE 4
#define ROGUE_TRUFFLE_SNIFF_RANGE 5
#define ROGUE_PIG_HANGRY_MAX 9
#define ROGUE_PIG_POTATO_RELIEF 2
#define ROGUE_TRUFFLE_DIG_TIME (3 SECONDS)

/// Where a lured beast walks (held-out food, a beckon), and the nest or nesting stuff a hen walks to.
#define BB_ROGUE_LURE_TARGET "rogue_lure_target"
#define BB_ROGUE_NEST_TARGET "rogue_nest_target"

/// Source of the traits the husbandry module gives.
#define ROGUE_HUSBANDRY_TRAIT "rogue_husbandry"

/// From a tamer when a beast takes to them (Ratwood COMSIG_ANIMAL_TAMED, the hook of the personal goal "Tame an Animal"):
/// (mob/living/basic/rockhill/beast)
#define COMSIG_ROGUE_ANIMAL_TAMED "rogue_animal_tamed"

/// Riding and tack (husbandry/mounts.dm, husbandry/tack.dm): numbers of the mechanics registry (config/redtard/mechanics/values/husbandry.txt).
#define ROGUE_SADDLE_TIME rogue_value("mount_saddle_time")
#define ROGUE_UNSADDLE_TIME rogue_value("mount_unsaddle_time")
#define ROGUE_TACK_TIME rogue_value("mount_tack_time")
#define ROGUE_UNTACK_TIME rogue_value("mount_untack_time")
#define ROGUE_MOUNT_TIME rogue_value("mount_time")
#define ROGUE_MOUNT_TIME_UNSKILLED rogue_value("mount_time_unskilled")
#define ROGUE_DISMOUNT_TIME_UNSKILLED rogue_value("dismount_time_unskilled")
#define ROGUE_MOUNT_QUICK_RANK rogue_value("mount_quick_rank")
#define ROGUE_MOUNT_FALL_TIME rogue_value("mount_fall_time")
#define ROGUE_MOUNT_GALLOP_BONUS rogue_value("mount_gallop_bonus")
#define ROGUE_MOUNT_UNSKILLED_BONUS rogue_value("mount_unskilled_bonus")
#define ROGUE_MOUNT_SKILL_BONUS rogue_value("mount_skill_bonus")
#define ROGUE_MOUNT_RANK_DIVISOR rogue_value("mount_rank_divisor")
#define ROGUE_MOUNT_STEPPE_BONUS rogue_value("mount_steppe_bonus")
#define ROGUE_MOUNT_HURT_SHARE rogue_value("mount_hurt_share")
#define ROGUE_MOUNT_HURT_DELAY rogue_value("mount_hurt_delay")
#define ROGUE_MOUNT_COMBAT_WALK rogue_value("mount_combat_walk")
#define ROGUE_MOUNT_COMBAT_GALLOP rogue_value("mount_combat_gallop")
#define ROGUE_MOUNT_FIXED_WALK rogue_value("mount_fixed_walk")
#define ROGUE_MOUNT_FIXED_GALLOP rogue_value("mount_fixed_gallop")
#define ROGUE_MOUNT_MIN_DELAY rogue_value("mount_min_delay")
#define ROGUE_RIDING_XP_MOVES rogue_value("riding_xp_moves")
#define ROGUE_RIDING_XP_PER_INTELLIGENCE rogue_value("riding_xp_per_intelligence")
#define ROGUE_RIDING_XP_UNTRAINED rogue_value("riding_xp_untrained")
#define ROGUE_RIDING_XP_TRAINED rogue_value("riding_xp_trained")
#define ROGUE_MOUNT_APPLE_TIME rogue_value("mount_apple_time")
#define ROGUE_MOUNT_APPLE_HEAL rogue_value("mount_apple_heal")

/// Milking (husbandry/milking.dm): numbers of the mechanics registry.
#define ROGUE_MILK_UDDER_SIZE rogue_value("milk_udder_size")
#define ROGUE_MILK_START_MAX rogue_value("milk_start_max")
#define ROGUE_MILK_PER_PRODUCTION rogue_value("milk_per_production")
#define ROGUE_MILK_MIN rogue_value("milk_min")
#define ROGUE_MILK_TIME rogue_value("milk_time")

/// Manure (husbandry/manure.dm): numbers of the mechanics registry.
#define ROGUE_MANURE_TIME rogue_value("manure_time")
#define ROGUE_MANURE_TILE_CAP rogue_value("manure_tile_cap")

/// Layers of a mount's tack over its rider (Ratwood update_icon(): the saddle's front and the mount's neck at 4.3, a caparison
/// at 5 and a bard at 6, the other way round when the caparison covers the bard, each with a front part 0.69 lower).
#define ROGUE_TACK_FRONT_LAYER (MOB_LAYER + 0.3)
#define ROGUE_TACK_LOW_LAYER (MOB_LAYER + 1)
#define ROGUE_TACK_HIGH_LAYER (MOB_LAYER + 2)
#define ROGUE_TACK_FRONT_DROP 0.69
