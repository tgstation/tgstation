//Methods to interact with reagents in the holder
/// Makes it possible to add reagents through droppers and syringes.
#define INJECTABLE (1<<0)
/// Makes it possible to remove reagents through syringes.
#define DRAWABLE (1<<1)
/// Makes it possible to add reagents through any reagent container.
#define REFILLABLE (1<<2)
/// Makes it possible to remove reagents through any reagent container.
#define DRAINABLE (1<<3)
/// Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.
#define DUNKABLE (1<<4)

//Methods to examine reagents in the container
/// Used on containers which you want to be able to see the reagents of.
#define TRANSPARENT (1<<5)
/// For non-transparent containers that still have the general amount of reagents in them visible.
#define AMOUNT_VISIBLE (1<<6)

//Reaction flags
/// Applied to a reagent holder, the contents will not react with each other.
#define NO_REACT (1<<7)
/// Applied to a reagent holder, all of the reactions in the reagents datum will be instant. Meant to be used for things like smoke effects where reactions aren't meant to occur
#define REAGENT_HOLDER_INSTANT_REACT (1<<8)
///If the holder is "alive" (i.e. mobs and organs) - If this flag is applied to a holder it will cause reagents to split upon addition to the object
#define REAGENT_HOLDER_ALIVE (1<<9)

//Special properties
///If the holder is a sealed container - Used if you don't want reagent contents boiling out (plasma, specifically, in which case it only bursts out when at ignition temperatures)
#define SEALED_CONTAINER (1<<10)
/// Prevents spilling and splashing but does prevent pouring and drinking reagents like the badly named spillable var.
#define SMART_CAP (1<<11)
// Is an open container for all intents and purposes.
#define OPENCONTAINER (REFILLABLE | DRAINABLE | TRANSPARENT)

// Reagent exposure methods.
/// Used for splashing.
#define TOUCH (1<<0)
/// Used for ingesting the reagents. Food and drinks.
#define INGEST (1<<1)
/// Used by foams, sprays, and blob attacks.
#define VAPOR (1<<2)
/// Used by medical patches and gels.
#define PATCH (1<<3)
/// Used for direct injection of reagents.
#define INJECT (1<<4)
/// Exclusive to just plumbing. if set we use the round robin technique else we use proportional
#define LINEAR (1<<5)
/// Used by smoke or inhaling from a source. Smoke, cigarettes, and inhalers.
#define INHALE (1<<6)

///Smoke machines are both touch and inhaling
#define SMOKE_MACHINE (TOUCH | INHALE)

/// When returned by on_mob_life(), on_mob_dead(), overdose_start() or overdose_processed(), will cause the mob to updatehealth() afterwards
#define UPDATE_MOB_HEALTH 1

// How long do mime drinks silence the drinker (if they are a mime)?
#define MIMEDRINK_SILENCE_DURATION (1 MINUTES)
///Health threshold for synthflesh and rezadone to unhusk someone
#define UNHUSK_DAMAGE_THRESHOLD 50
///Amount of synthflesh required to unhusk someone
#define SYNTHFLESH_UNHUSK_AMOUNT 60
#define SYNTHFLESH_UNHUSK_MAX 100

//used by chem masters and pill presses
// The categories of reagent packaging
#define CAT_CONDIMENTS "condiments"
#define CAT_TUBES "tubes"
#define CAT_PILLS "pills"
#define CAT_PATCHES "patches"
#define DEFAULT_PATCH_STYLE "bandaid_blank"
//used by chem master
#define CONDIMASTER_STYLE_AUTO "auto"
#define CONDIMASTER_STYLE_FALLBACK "_"

#define ALLERGIC_REMOVAL_SKIP "Allergy"

//Used in holder.dm/equlibrium.dm to set values and volume limits
///The minimum volume of reagents than can be operated on.
#define CHEMICAL_QUANTISATION_LEVEL 0.0001
///Sanity check limit to clamp chems to sane amounts and prevent rounding errors during transfer.
#define CHEMICAL_VOLUME_ROUNDING 0.01
///Default pH for reagents datum
#define CHEMICAL_NORMAL_PH 7.000
///Minimum pH attainable by a solution
#define CHEMICAL_MIN_PH 0
///Maximum pH attainable by a solution
#define CHEMICAL_MAX_PH 14
///Ionizing strength of strong acidic/basic buffer (volume/holder.total_volume)*strength. So for 1u added to 50u the ph will change by 0.4
#define BUFFER_IONIZING_STRENGTH 30
///The maximum temperature a reagent holder can attain
#define CHEMICAL_MAXIMUM_TEMPERATURE 99999
///The default purity of all non reacted reagents
#define REAGENT_STANDARD_PURITY 0.75
/// Starting purity of consumable reagents
#define CONSUMABLE_STANDARD_PURITY 0.5 // 50% pure by default. Below - synthetic food. Above - natural food.
/// Starting purity of reagents made in biogenerator
#define BIOGEN_REAGENT_PURITY 0.3
/// the default temperature at which chemicals are added to reagent holders at
#define DEFAULT_REAGENT_TEMPERATURE 300

//reagent bitflags, used for altering how they works
///allows on_mob_dead() if present in a dead body
#define REAGENT_DEAD_PROCESS (1<<0)
///Doesn't appear on handheld health analyzers.
#define REAGENT_INVISIBLE (1<<1)
///When inverted, the inverted chem uses the name of the original chem
#define REAGENT_SNEAKYNAME (1<<2)
///Retains initial volume of chem when splitting for purity effects
#define REAGENT_SPLITRETAINVOL (1<<3)
///Lets a given reagent be synthesized important for random reagents and things like the odysseus syringe gun(Replaces the old can_synth variable)
#define REAGENT_CAN_BE_SYNTHESIZED (1<<4)
///Allows a reagent to work on a mob regardless of stasis
#define REAGENT_IGNORE_STASIS (1<<5)
///This reagent won't be used in most randomized recipes. Meant for reagents that could be synthetized but are normally inaccessible or TOO hard to get.
#define REAGENT_NO_RANDOM_RECIPE (1<<6)
///Does this reagent clean things?
#define REAGENT_CLEANS (1<<7)
///Does this reagent affect wounds? Used to check if some procs should be ran.
#define REAGENT_AFFECTS_WOUNDS (1<<8)
/// If present, when metabolizing out of a mob, we divide by the mob's metabolism rather than multiply.
/// Without this flag: Higher metabolism means the reagent exits the system faster.
/// With this flag: Higher metabolism means the reagent exits the system slower.
#define REAGENT_REVERSE_METABOLISM (1<<9)
/// If present, this reagent will not be affected by the mob's metabolism at all, meaning it exits at a fixed rate for all mobs.
/// Supercedes [REAGENT_REVERSE_METABOLISM].
#define REAGENT_UNAFFECTED_BY_METABOLISM (1<<10)

//Chemical reaction flags, for determining reaction specialties
///Convert into impure/pure on reaction completion
#define REACTION_CLEAR_IMPURE (1<<0)
///Convert into inverse on reaction completion when purity is low enough
#define REACTION_CLEAR_INVERSE (1<<1)
///Clear converted chems retain their purities/inverted purities. Requires 1 or both of the above.
#define REACTION_CLEAR_RETAIN (1<<2)
///Used to create instant reactions
#define REACTION_INSTANT (1<<3)
///Used to force reactions to create a specific amount of heat per 1u created. So if thermic_constant = 5, for 1u of reagent produced, the heat will be forced up arbitarily by 5 irresepective of other reagents. If you use this, keep in mind standard thermic_constant values are 100x what it should be with this enabled.
#define REACTION_HEAT_ARBITARY (1<<4)
///Used to bypass the chem_master transfer block (This is needed for competitive reactions unless you have an end state programmed). More stuff might be added later. When defining this, please add in the comments the associated reactions that it competes with
#define REACTION_COMPETITIVE (1<<5)
///Used to force pH changes to be constant regardless of volume
#define REACTION_PH_VOL_CONSTANT (1<<6)
///If a reaction will generate its impure/inverse reagents in the middle of a reaction, as apposed to being determined on ingestion/on reaction completion
#define REACTION_REAL_TIME_SPLIT (1<<7)

///Used for overheat_temp - This sets the overheat so high it effectively has no overheat temperature.
#define NO_OVERHEAT 99999
////Used to force an equlibrium to end a reaction in reaction_step() (i.e. in a reaction_step() proc return END_REACTION to end it)
#define END_REACTION "end_reaction"

///Minimum requirement for addiction buzz to be met. Addiction code only checks this once every two seconds, so this should generally be low
#define MIN_ADDICTION_REAGENT_AMOUNT 1
///Nicotine requires much less in your system to be happy
#define MIN_NICOTINE_ADDICTION_REAGENT_AMOUNT 0.01
#define MAX_ADDICTION_POINTS 1000

///Addiction start/ends
#define WITHDRAWAL_STAGE1_START_CYCLE 61
#define WITHDRAWAL_STAGE1_END_CYCLE 120
#define WITHDRAWAL_STAGE2_START_CYCLE 121
#define WITHDRAWAL_STAGE2_END_CYCLE 180
#define WITHDRAWAL_STAGE3_START_CYCLE 181

///reagent tags - used to look up reagents for specific effects. Feel free to add to but comment it
/// This reagent does brute effects (BOTH damaging and healing)
#define REACTION_TAG_BRUTE (1<<0)
/// This reagent does burn effects (BOTH damaging and healing)
#define REACTION_TAG_BURN (1<<1)
/// This reagent does toxin effects (BOTH damaging and healing)
#define REACTION_TAG_TOXIN (1<<2)
/// This reagent does oxy effects (BOTH damaging and healing)
#define REACTION_TAG_OXY (1<<3)
/// This reagent primarily heals, or it's supposed to be used for healing (in the case of c2 - they are healing)
#define REACTION_TAG_HEALING (1<<4)
/// This reagent primarily damages
#define REACTION_TAG_DAMAGING (1<<5)
/// This reagent explodes as a part of its intended effect (i.e. not overheated/impure)
#define REACTION_TAG_EXPLOSIVE (1<<6)
/// This reagent does things that are unique and special
#define REACTION_TAG_OTHER (1<<7)
/// This reagent's reaction is dangerous to create (i.e. explodes if you fail it)
#define REACTION_TAG_DANGEROUS (1<<8)
/// This reagent's reaction is easy
#define REACTION_TAG_EASY (1<<9)
/// This reagent's reaction is difficult/involved
#define REACTION_TAG_MODERATE (1<<10)
/// This reagent's reaction is hard
#define REACTION_TAG_HARD (1<<11)
/// This reagent affects organs
#define REACTION_TAG_ORGAN (1<<12)
/// This reaction creates a drink reagent
#define REACTION_TAG_DRINK (1<<13)
/// This reaction has something to do with food
#define REACTION_TAG_FOOD (1<<14)
/// This reaction is a slime reaction
#define REACTION_TAG_SLIME (1<<15)
/// This reaction is a drug reaction
#define REACTION_TAG_DRUG (1<<16)
/// This reaction is a unique reaction
#define REACTION_TAG_UNIQUE (1<<17)
/// This reaction is produces a product that affects reactions
#define REACTION_TAG_CHEMICAL (1<<18)
/// This reaction is produces a product that affects plants
#define REACTION_TAG_PLANT (1<<19)
/// This reaction is produces a product that affects plants
#define REACTION_TAG_COMPETITIVE (1<<20)

//flags used by holder.dm to locate an reagent
///Direct type
#define REAGENT_STRICT_TYPE (1<<0)
///Parent type but not sub types for e.g. if param is obj/item it will look for obj/item/stack but not obj/item/stack/sheet
#define REAGENT_PARENT_TYPE (1<<1)
///same as istype() check
#define REAGENT_SUB_TYPE (1<<2)

#define RNGCHEM_INPUT "input"
#define RNGCHEM_CATALYSTS "catalysts"
#define RNGCHEM_OUTPUT "output"

/// Below are defines used for reagent associated machines only
/// For the pH meter flashing method
#define ENABLE_FLASHING -1
#define DISABLE_FLASHING 14

#define GOLDSCHLAGER_VODKA (10)
#define GOLDSCHLAGER_GOLD (1)

#define GOLDSCHLAGER_GOLD_RATIO (GOLDSCHLAGER_GOLD/(GOLDSCHLAGER_VODKA+GOLDSCHLAGER_GOLD))

/// The rate at which alcohol affects the drinker
#define ALCOHOL_RATE 0.005

#define BLASTOFF_DANCE_MOVE_CHANCE_PER_UNIT 3
#define BLASTOFF_DANCE_MOVES_PER_SUPER_MOVE 3

///This is the center of a 1 degree deadband in which water will neither freeze to ice nor melt to liquid
#define WATER_MATTERSTATE_CHANGE_TEMP 274.5

//chem grenades defines
/// Grenade is empty
#define GRENADE_EMPTY 1
/// Grenade has a activation trigger
#define GRENADE_WIRED 2
/// Grenade is ready to be finished
#define GRENADE_READY 3

/// Maximum amount of layers a pill can hold, aka maximum number of seconds a pill takes to dissolve
#define PILL_MAX_LAYERS 60
/// Maximum amount of layers above which you cannot taste the pill's contents
#define PILL_MAX_TASTE_LAYERS 20
/// Maximum amount of layers that a ChemMaster can produce
#define PILL_MAX_PRINTABLE_LAYERS 30

/// Cooldown between patch reagent messages
#define PATCH_MESSAGE_COOLDOWN 10 SECONDS
