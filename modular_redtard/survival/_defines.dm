// Stage 2: survival and daily life. Cross-file defines of the survival module.

/// Ratwood screen alerts of food buffs and fire rest (icons/mob/screen_alert.dmi: foodbuff, campfire, fireplace).
#define ROGUE_SURVIVAL_ALERTS 'modular_redtard/survival/icons/alerts.dmi'

/// Ratwood get_cooktime_divisor() (modular/Neu_Food/cooking_helpers.dm): how many times faster a cook of each cooking rank (0-6) works.
#define ROGUE_COOK_DIVISORS list(0.75, 1, 1.5, 2, 2.5, 3, 3.5)
/// The burnt result of Ratwood cooking (heating_act() without a fitting result, burned food).
#define ROGUE_BURNT_FOOD /obj/item/reagent_containers/food/snacks/badrecipe

/// Ratwood stress points to TG mood points (a stress event of -1 is a mood event of +2).
#define ROGUE_STRESS_TO_MOOD 2
/// Ratwood nausea to TG disgust (100 nausea, a raw bite, makes Ratwood vomit; 40 disgust is TG's "gross" and a bit more).
#define ROGUE_NAUSEA_TO_DISGUST 0.4

/// Body heat the Ratwood fires give per heat level of the floor and Life tick (species.dm handle_environment(): heat * 4).
#define ROGUE_FLOOR_WARMTH_PER_HEAT 4
/// Ratwood floor heat is capped at 5 (floor.dm set_heat()).
#define ROGUE_FLOOR_HEAT_MAX 5
/// Body heat of warming the hands at a campfire, fireplace or hearth (Ratwood +75), up to normal.
#define ROGUE_HAND_WARMTH 75
/// Body heat of warming the hands at a brazier (Ratwood firebowl attack_right(): +10).
#define ROGUE_BRAZIER_WARMTH 10
/// The rest by a fire warms a body this much colder than normal (Ratwood: under 300 K)...
#define ROGUE_FIRE_REST_COLD 10
/// ...by this much a second (Ratwood campfire_stamina: +5).
#define ROGUE_FIRE_REST_WARMTH 5

// Ratwood reagents (survival/soups.dm). Ratwood counts a reagent once per Life tick of two seconds, TG once per second.
/// Seconds in a Ratwood Life tick: Ratwood per-tick numbers become TG per-second numbers through it.
#define ROGUE_REAGENT_TICK 2
/// A Ratwood metabolization rate (units per Life tick) as a TG one (units per second).
#define ROGUE_REAGENT_RATE(rate) ((rate) / ROGUE_REAGENT_TICK)
/// Ratwood nutriment feeds 35 per unit, TG nutriment 15: Ratwood soup nutrition keeps its share against food at this scale.
#define ROGUE_REAGENT_NUTRITION (15 / 35)
/// Ratwood REAGENTS_EFFECT_MULTIPLIER (its metabolism of 1 over the old 0.4): the per-tick heals of its soups are written with it.
#define ROGUE_REAGENT_EFFECT 2.5
/// Blood every Ratwood soup gives per tick to someone below normal blood (soup on_mob_life()).
#define ROGUE_SOUP_BLOOD 10
/// Energy caffeine gives per tick (caffeine on_mob_life(): energy_add(5)).
#define ROGUE_CAFFEINE_ENERGY 5
/// Chance in percent per tick of a heart attack from a caffeine overdose.
#define ROGUE_CAFFEINE_HEART_CHANCE 5
/// Jitter per tick of a caffeine overdose (Ratwood Jitter(2)).
#define ROGUE_CAFFEINE_JITTER (2 SECONDS)
/// The most jitter a caffeine overdose builds up.
#define ROGUE_CAFFEINE_JITTER_MAX (20 SECONDS)
/// Dirty water: nausea and toxins per tick to whoever drinks it without a strong stomach (water/gross on_mob_life()).
#define ROGUE_GROSS_WATER_NAUSEA 12
#define ROGUE_GROSS_WATER_TOXIN 1
/// Ratwood boils dirty water clean at this temperature (grosswaterboil).
#define ROGUE_BOIL_TEMPERATURE 375

// Ratwood pot on the hearth (code/game/objects/lighting/rogue_fires.dm, modular/Neu_Food/code/recipes/stew_recipes.dm).
/// The temperature a hearth heats its pot towards, and how much of the gap one round closes (try_cook()).
#define ROGUE_HEARTH_HEAT 400
#define ROGUE_HEARTH_HEAT_COEFF 0.033
/// A pot boils and takes stew ingredients from this temperature (MIN_STEW_TEMPERATURE).
#define ROGUE_STEW_TEMPERATURE 374
/// Water one ingredient takes at once, and the last unit it takes when the stew is done (VOLUME_PER_STEW_COOK, _AFTER).
#define ROGUE_STEW_WATER 29
#define ROGUE_STEW_WATER_AFTER 1
/// Default simmering time of a stew ingredient (STEW_COOKING_TIME).
#define ROGUE_STEW_TIME (60 SECONDS)
/// Time to put an ingredient into the pot, or fat to melt, before the cook's skill.
#define ROGUE_STEW_STEP (2 SECONDS)
/// Deep frying in tallow: the time and the tallow one fry takes (DEEP_FRY_TIME, OIL_CONSUMED).
#define ROGUE_DEEP_FRY_TIME (5 SECONDS)
#define ROGUE_DEEP_FRY_OIL 5

// Ratwood kneading and pastry (modular/Neu_Food/code/raw, NeuFood.dm, others/dairy.dm).
/// Ratwood short_cooktime and long_cooktime of a hand step before the cook's skill.
#define ROGUE_COOK_SHORT (2 SECONDS)
#define ROGUE_COOK_LONG (3 SECONDS)
/// Water flour takes to become wet flour.
#define ROGUE_FLOUR_WATER 10
/// Milk one pinch of salt turns salted, salted milk one stick of butter takes, salted milk one fresh cheese takes.
#define ROGUE_MILK_PER_SALT 15
#define ROGUE_MILK_PER_BUTTER 15
#define ROGUE_MILK_PER_CHEESE 5
/// Servings of filling a pie bottom takes before its roof.
#define ROGUE_PIE_FILLINGS 3

// Ratwood vessels and water (code/modules/reagents/reagent_containers/glass.dm, turfs/open/water.dm, structures/well.dm).
/// Water a vessel takes from open water at once, and the time it takes (turf/open/water attackby()).
#define ROGUE_WATER_FILL 300
#define ROGUE_WATER_FILL_TIME (0.8 SECONDS)
/// Water a bucket draws from a well or a vessel from a fountain, and the time it takes.
#define ROGUE_WELL_WATER 250
#define ROGUE_WELL_TIME (1 SECONDS)
/// A spoonful from a bowl: how much and how long (bowl attackby()).
#define ROGUE_SPOON_SIP 5
#define ROGUE_SPOON_TIME (1 SECONDS)
/// Time to fill a bowl from a pot (pot attackby()).
#define ROGUE_BOWL_FILL_TIME (2 SECONDS)
/// Pouring between vessels: the most measures in one go and the time of each (glass attack_obj(): 11 rounds of do_after(8)).
#define ROGUE_POUR_ROUNDS 11
#define ROGUE_POUR_TIME (0.8 SECONDS)

// Ratwood fare (code/__DEFINES/food.dm FARE_*): how fine a food is, for the noble palate.
#define ROGUE_FARE_IMPOVERISHED 1
#define ROGUE_FARE_POOR 2
#define ROGUE_FARE_NEUTRAL 3
#define ROGUE_FARE_FINE 4
#define ROGUE_FARE_LAVISH 5
/// Chance in percent of the picky eater's remark (Ratwood prob(25)).
#define ROGUE_PICKY_REMARK_CHANCE 25
/// Ratwood nausea of a noble forced to eat food for the desperate while not starving.
#define ROGUE_NOBLE_POOR_FOOD_NAUSEA 34
/// Keys of the culinary preferences (Ratwood CULINARY_*).
#define ROGUE_CULINARY_FAVOURITE_FOOD "favourite_food"
#define ROGUE_CULINARY_HATED_FOOD "hated_food"
#define ROGUE_CULINARY_FAVOURITE_DRINK "favourite_drink"
#define ROGUE_CULINARY_HATED_DRINK "hated_drink"

// Ratwood cooking smells (temporary_pollution_emission of cooked_smell, pollution.dm smell_act()).
/// How long fresh cooking smells, and how often it reaches the noses around.
#define ROGUE_SMELL_DURATION (5 MINUTES)
#define ROGUE_SMELL_INTERVAL (10 SECONDS)
/// How far a smell carries, and within what distance it is "unmistakable" or plain rather than "subtle".
#define ROGUE_SMELL_RANGE 4
#define ROGUE_SMELL_STRONG_RANGE 1
#define ROGUE_SMELL_NORMAL_RANGE 2
/// How often one nose notices a smell (Ratwood SMELL_COOLDOWN).
#define ROGUE_SMELL_COOLDOWN (1 MINUTES)

// Ratwood traits the survival mechanics check; the porter writes only the traits its roles use, so define the missing ones.
#ifndef TRAIT_NASTY_EATER
#define TRAIT_NASTY_EATER "Inhumen Digestion"
#endif
#ifndef TRAIT_ORGAN_EATER
#define TRAIT_ORGAN_EATER "Blessing of Graggar"
#endif
#ifndef TRAIT_WILD_EATER
#define TRAIT_WILD_EATER "Beastly Digestion"
#endif
#ifndef TRAIT_RAW_EATER
#define TRAIT_RAW_EATER "Raw Diet"
#endif
#ifndef TRAIT_ROT_EATER
#define TRAIT_ROT_EATER "Blessing of Pestra"
#endif
#ifndef TRAIT_NOSLEEP
#define TRAIT_NOSLEEP "Fatal Insomnia"
#endif
#ifndef TRAIT_FASTSLEEP
#define TRAIT_FASTSLEEP "Fast Sleeper"
#endif
#ifndef TRAIT_BETTER_SLEEP
#define TRAIT_BETTER_SLEEP "Better Sleep"
#endif
#ifndef TRAIT_EXTEROCEPTION
#define TRAIT_EXTEROCEPTION "Exteroception"
#endif
