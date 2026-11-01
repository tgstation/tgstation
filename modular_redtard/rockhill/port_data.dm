// Ratwood data the porter writes (tools/port_rockhill.py) for systems that do not declare it themselves yet: the data
// only, read by the module's systems as they come to it.

/// Ratwood's SOCIAL_RANK_DIRT: the social rank of a role that names none. The ranks are 1 dirt, 2 peasant, 3 yeoman,
/// 4 minor noble, 5 noble, 6 royal (Ratwood __DEFINES/roguetown.dm); the porter writes them as these numbers.
#define PORT_SOCIAL_RANK_DIRT 1
/// Ratwood's pickprob of a subclass that names none: it is always offered.
#define PORT_PICKPROB_ALWAYS 100

/obj/item
	/// Ratwood's body_parts_covered as it is: TG's flags and ROGUE_COVER_* (clothing/_defines.dm). Null - what TG's
	/// body_parts_covered says, its HEAD the whole head and its CHEST the chest and the vitals (rogue_coverage_flags(),
	/// combat/armor.dm). The porters write it where TG's flags would say otherwise and on everything that covers part of the head.
	var/rogue_coverage

/obj/item/natural/clay
	/// What a kiln fires this raw piece into (Ratwood cooked_type, ceramicist/clay.dm); null - it only burns to ash.
	var/cooked_type

/datum/anvil_recipe
	/// Ratwood skip_quality: the thing takes the lowest quality of the bars put in, not the quality of the smithing.
	var/skip_quality = FALSE
	/// Ratwood req_trait: the trait a smith needs to see and forge the recipe (TRAIT_DWARF_REPAIR, Dwarvish Knowledge, for
	/// the dwarven armor and mauls; crafting/anvil.dm checks it); null - any smith.
	var/req_trait

/datum/crafting_recipe/roguetown
	/// Ratwood skip_quality: the result keeps the lowest quality of what it is made of instead of a quality by the
	/// crafter's skill (Azure Peak's plumed helmets: the helmet stays as it was forged).
	var/rogue_skip_quality = FALSE

/obj/structure/flora/roguegrass/herb
	/// Ratwood herbtype (alchemist/herb_flora.dm): what a hand picks from the herb, an /obj/item/alch ingredient (the manabloom
	/// gives its flower); Ratwood's herb grows it back 5 minutes after it is picked.
	var/herbtype

/mob/living
	/// Ratwood butcher_results (simple_animal.dm butcher()): item path = how many, what the carcass yields to a cut. Kept
	/// apart from TG's butcher_results, which TG's gib() would drop as loot (Ratwood's gibbed beasts leave none).
	var/list/rogue_butcher_results
	/// Ratwood botched_butcher_results: item path = how many, the yield of a botched cut (below journeyman Butchering); an
	/// item the list lacks yields nothing when botched.
	var/list/rogue_botched_butcher_results
	/// Ratwood perfect_butcher_results: item path = how many, the yield of a perfect cut (from journeyman Butchering).
	var/list/rogue_perfect_butcher_results

/datum/job/roguetown
	/// Ratwood allowed_races: the races that may take the role, as the text of Ratwood's species paths
	/// ("/datum/species/human/northern"; the module's races are other types). Null - every race (Ratwood RACES_ALL_KINDS).
	var/list/rogue_allowed_races
	/// Ratwood disallowed_races, written as rogue_allowed_races: the races barred from the role.
	var/list/rogue_disallowed_races
	/// Ratwood allowed_ages: "Adult", "Middle-Aged", "Old", "Immortal". Null - Ratwood ALL_AGES_LIST (adult, middle-aged, old).
	var/list/rogue_allowed_ages
	/// Ratwood allowed_sexes: MALE, FEMALE. Null - both.
	var/list/rogue_allowed_sexes
	/// Ratwood allowed_patrons: the patrons (/datum/patron) whose followers may take the role; null - any.
	var/list/rogue_allowed_patrons
	/// Ratwood social_rank, as a number (PORT_SOCIAL_RANK_DIRT above).
	var/rogue_social_rank = PORT_SOCIAL_RANK_DIRT
	/// Ratwood wanderer_examine: examining the holder tells a wanderer.
	var/rogue_wanderer_examine = FALSE
	/// Ratwood advjob_examine: examining the holder tells the subclass, not only the role.
	var/rogue_advjob_examine = FALSE
	/// Ratwood lowlife_examine: examining the holder tells a lowlife.
	var/rogue_lowlife_examine = FALSE

/datum/rockhill_advclass
	/// Ratwood's limits of the subclass, as those of /datum/job/roguetown: races (text of Ratwood's species paths), races
	/// barred, ages, sexes and patrons; null - none.
	var/list/rogue_allowed_races
	var/list/rogue_disallowed_races
	var/list/rogue_allowed_ages
	var/list/rogue_allowed_sexes
	var/list/rogue_allowed_patrons
	/// Ratwood pickprob: the chance in percent that the subclass is offered at all.
	var/rogue_pickprob = PORT_PICKPROB_ALWAYS
	/// Ratwood min_pq: the least player quality the subclass wants; null - none (Ratwood's default -100).
	var/rogue_min_pq
	/// Ratwood subclass_languages: the languages the subclass grants, as the text of Ratwood's language paths (the module has
	/// few of them yet).
	var/list/rogue_subclass_languages
	/// Ratwood subclass_social_rank: the social rank the subclass gives in place of its role's (as rogue_social_rank of
	/// /datum/job/roguetown); null - the role's.
	var/rogue_social_rank
	/// Ratwood subclass_stashed_items: "name" = item path, the things the holder can take out of a stash.
	var/list/rogue_stashed_items
	/// Ratwood horse: the mount (a mob path) the subclass arrives with.
	var/rogue_horse
	/// Ratwood noble_income: mammons the subclass's estate pays every day.
	var/rogue_estate_income = 0
	/// Ratwood adv_stat_ceiling: stat (ROGUE_STAT_*) = the most the holder may have of it.
	var/list/rogue_stat_ceilings
	/// Ratwood age_mod (/datum/class_age_mod): what the subclass gives at one age - list("age" = "Old", "stats" = list(stat =
	/// change), "skills" = list(skill = level it is raised up to), "traits" = list(...), "minor" and "utility" = extra mage
	/// aspect points).
	var/list/rogue_age_mod

/datum/rogue_migrant_role
	/// Ratwood allowed_races of the arrival, as rogue_allowed_races of /datum/job/roguetown; null - every race.
	var/list/rogue_allowed_races
	var/list/rogue_disallowed_races
	/// Ratwood show_wanderer_examine: examining the arrival tells a wanderer.
	var/rogue_wanderer_examine = TRUE
	/// Ratwood advjob_examine: examining the arrival tells its class.
	var/rogue_advjob_examine = TRUE

#undef PORT_SOCIAL_RANK_DIRT
#undef PORT_PICKPROB_ALWAYS
