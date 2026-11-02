// Ratwood palate (code/modules/food_and_drinks/food/snacks.dm On_Consume(), modules/client/preferences_culinary.dm,
// mob/living/rolecheck.dm, datums/stress/*_events.dm): how fine a food is (fare), the noble palate, favourite and hated
// food and drink, and the smell of fresh cooking (datums/pollutants/foods.dm). Ratwood stress is TG mood here (-1 stress is
// +ROGUE_STRESS_TO_MOOD mood).

/obj/item/reagent_containers/food
	/// Ratwood faretype (ROGUE_FARE_*).
	var/rogue_faretype
	/// Ratwood portable: a noble may eat it away from a table.
	var/rogue_portable
	/// Ratwood cooked_smell: what fills the air when this is cooked.
	var/rogue_cooked_smell

/obj/item/reagent_containers/food/proc/rogue_fare()
	return rogue_faretype

/obj/item/reagent_containers/food/proc/rogue_is_portable()
	return rogue_portable

/// The scent this food gives off when cooked, by its own Ratwood cooked_smell.
/obj/item/reagent_containers/food/proc/rogue_smell()
	if(rogue_cooked_smell)
		return rogue_cooked_smell

/// Ratwood heating_act(): what cooked out of raw food smells for a while (temporary_pollution_emission of cooked_smell).
/obj/item/reagent_containers/food/proc/rogue_cooking_smell(obj/item/reagent_containers/food/raw)
	if(istype(src, ROGUE_BURNT_FOOD) || !rogue_survival_enabled() || !CONFIG_GET(flag/rogue_food_smells))
		return
	var/scent = raw.rogue_smell()
	if(scent)
		AddComponent(/datum/component/rogue_food_smell, scent)

/// Examine lines of the palate (Ratwood snacks examine()): how fine the food is and whether a noble needs a table for it.
/obj/item/reagent_containers/food/proc/rogue_palate_examine()
	. = list()
	if(!rogue_survival_enabled())
		return
	switch(rogue_fare())
		if(ROGUE_FARE_IMPOVERISHED)
			. += span_smallnotice("It is food fit for the desperate.")
		if(ROGUE_FARE_POOR)
			. += span_smallnotice("It is food fit for the poor.")
		if(ROGUE_FARE_NEUTRAL)
			. += span_smallnotice("It is decent food.")
		if(ROGUE_FARE_FINE)
			. += span_smallnotice("It is fine food.")
		if(ROGUE_FARE_LAVISH)
			. += span_smallnotice("It is lavish food.")
	. += span_smallnotice((rogue_is_portable() ? "It can be eaten without a table." : "Eating this without a table would be disgraceful for a noble."))

/// Ratwood On_Consume(): what one bite means to the eater - a favourite or hated food, and for a noble, a yeoman or a courtier
/// whether the fare befits them. FALSE when their disdain spoils the good effect of the bite.
/obj/item/reagent_containers/food/proc/rogue_taste_for(mob/living/eater)
	var/mob/living/carbon/human/human_eater = eater
	if(!istype(human_eater) || !rogue_survival_enabled())
		return TRUE
	if(rogue_food_matches(human_eater.rogue_culinary_preference(ROGUE_CULINARY_FAVOURITE_FOOD)))
		human_eater.rogue_preference_mood("rogue_favourite_food", /datum/mood_event/rogue_favourite_food, span_green("Yum! My favorite food!"))
	if(rogue_food_matches(human_eater.rogue_culinary_preference(ROGUE_CULINARY_HATED_FOOD)))
		human_eater.rogue_preference_mood("rogue_hated_food", /datum/mood_event/rogue_hated_food, span_red("Yuck! My hated food!"))
	if(!CONFIG_GET(flag/rogue_noble_palate) || HAS_TRAIT(eater, TRAIT_NASTY_EATER) || HAS_TRAIT(eater, TRAIT_ORGAN_EATER) || HAS_TRAIT(eater, TRAIT_WILD_EATER))
		return TRUE
	// Bad food keeps its bad effect whoever eats it; only the good effects are lost on a disdainful eater.
	var/spoils_effect = !(eat_effect in list(/datum/status_effect/rogue_food/rotten, /datum/status_effect/rogue_food/burned, /datum/status_effect/rogue_food/uncooked))
	var/fare = rogue_fare()
	if(human_eater.rogue_is_noble())
		if(!rogue_is_portable() && !(locate(/obj/structure/table) in range(1, eater)))
			eater.add_mood_event("rogue_noble_table", /datum/mood_event/rogue_noble_ate_without_table)
			if(prob(ROGUE_PICKY_REMARK_CHANCE))
				to_chat(eater, span_red("I should really eat this at a table..."))
		switch(fare)
			if(ROGUE_FARE_IMPOVERISHED)
				eater.add_mood_event("rogue_noble_poor_food", /datum/mood_event/rogue_noble_impoverished_food)
				if(eater.nutrition >= NUTRITION_LEVEL_STARVING)
					eater.adjust_disgust(ROGUE_NOBLE_POOR_FOOD_NAUSEA * ROGUE_NAUSEA_TO_DISGUST)
					return FALSE
				eater.add_mood_event("rogue_noble_desperate", /datum/mood_event/rogue_noble_desperate)
				return !spoils_effect
			if(ROGUE_FARE_POOR, ROGUE_FARE_NEUTRAL)
				eater.add_mood_event("rogue_noble_bland", /datum/mood_event/rogue_noble_bland_food)
				if(prob(ROGUE_PICKY_REMARK_CHANCE))
					to_chat(eater, span_red("This is rather bland. I deserve better food than this..."))
				return !spoils_effect
			if(ROGUE_FARE_FINE)
				eater.clear_mood_event("rogue_noble_bland")
			if(ROGUE_FARE_LAVISH)
				eater.clear_mood_event("rogue_noble_bland")
				eater.add_mood_event("rogue_noble_lavish", /datum/mood_event/rogue_noble_lavish_food)
				if(prob(ROGUE_PICKY_REMARK_CHANCE))
					to_chat(eater, span_green("Ah, food fit for my title."))
		return TRUE
	if(human_eater.rogue_is_yeoman() || human_eater.rogue_is_courtier())
		if(fare != ROGUE_FARE_IMPOVERISHED)
			eater.clear_mood_event("rogue_noble_bland")
			return TRUE
		eater.add_mood_event("rogue_noble_bland", /datum/mood_event/rogue_noble_bland_food)
		if(prob(ROGUE_PICKY_REMARK_CHANCE))
			to_chat(eater, span_red("This is rather bland. I deserve better food than this..."))
		return !spoils_effect
	return TRUE

/// Ratwood favourite and hated food match: the type itself, a subtype of the same name, or its slice.
/obj/item/reagent_containers/food/proc/rogue_food_matches(wanted)
	if(!ispath(wanted, /obj/item/reagent_containers/food))
		return FALSE
	if(type == wanted)
		return TRUE
	var/obj/item/reagent_containers/food/wanted_food = wanted
	if(ispath(type, wanted) && name == initial(wanted_food.name))
		return TRUE
	return type == initial(wanted_food.slice_path)

/// Ratwood favourite and hated drinks (food_reagents.dm consumable on_mob_add()): by the reagent drunk or spooned.
/proc/rogue_drink_preference(mob/living/drinker, datum/reagent/drunk_type)
	var/mob/living/carbon/human/human_drinker = drinker
	if(!istype(human_drinker) || !ispath(drunk_type, /datum/reagent) || !rogue_survival_enabled())
		return
	if(rogue_reagent_matches(drunk_type, human_drinker.rogue_culinary_preference(ROGUE_CULINARY_FAVOURITE_DRINK)))
		human_drinker.rogue_preference_mood("rogue_favourite_drink", /datum/mood_event/rogue_favourite_drink, span_green("Yum! My favorite drink!"))
	if(rogue_reagent_matches(drunk_type, human_drinker.rogue_culinary_preference(ROGUE_CULINARY_HATED_DRINK)))
		human_drinker.rogue_preference_mood("rogue_hated_drink", /datum/mood_event/rogue_hated_drink, span_red("Yuck! My hated drink!"))

/proc/rogue_reagent_matches(datum/reagent/drunk_type, datum/reagent/wanted)
	if(!ispath(wanted, /datum/reagent))
		return FALSE
	return drunk_type == wanted || (ispath(drunk_type, wanted) && initial(drunk_type.name) == initial(wanted.name))

/// Ratwood glass attack(): a noble drinking soup straight from a bowl minds the bad manners.
/proc/rogue_noble_bad_manners(mob/living/drinker)
	var/mob/living/carbon/human/human_drinker = drinker
	if(!istype(human_drinker) || !rogue_survival_enabled() || !CONFIG_GET(flag/rogue_noble_palate) || !human_drinker.rogue_is_noble())
		return
	human_drinker.add_mood_event("rogue_noble_manners", /datum/mood_event/rogue_noble_bad_manners)
	if(prob(ROGUE_PICKY_REMARK_CHANCE))
		to_chat(human_drinker, span_red("I've got better manners than this..."))

// Who minds the fare (Ratwood rolecheck.dm, jobs.dm GLOB.noble_positions, courtier_positions, yeoman_positions).

GLOBAL_LIST_INIT(rogue_noble_positions, list("Grand Duke", "Baron", "Consort", "Suitor", "Prince", "Hand", "Knight Captain", "Marshal", "Councillor", "Steward", "Clerk", "Knight"))
GLOBAL_LIST_INIT(rogue_courtier_positions, list("Court Magician", "Magicians Associate", "Head Physician", "Apothecary", "Jester", "Seneschal", "Servant", "Court Chaplain", "Head Slave", "Palace Chaplain"))
GLOBAL_LIST_INIT(rogue_yeoman_positions, list("Merchant", "Innkeeper", "Archivist", "Scribe", "Town Crier", "Bathmaster", "Guildmaster", "Guildsman", "Slaver", "Tailor"))

/// Ratwood is_noble(): noble blood or a noble office, unless the blood was drained.
/mob/living/carbon/human/proc/rogue_is_noble()
	if(HAS_TRAIT(src, TRAIT_DEFILED_NOBLE))
		return FALSE
	return HAS_TRAIT(src, TRAIT_NOBLE) || (mind?.assigned_role?.title in GLOB.rogue_noble_positions)

/mob/living/carbon/human/proc/rogue_is_courtier()
	return mind?.assigned_role?.title in GLOB.rogue_courtier_positions

/mob/living/carbon/human/proc/rogue_is_yeoman()
	return mind?.assigned_role?.title in GLOB.rogue_yeoman_positions

// Culinary preferences (Ratwood preferences_culinary.dm). The character menu has no picker yet, so everyone has Ratwood's
// defaults - bread is the favourite food, beer the favourite drink, a burned mess the hated food - until something sets
// rogue_culinary (type paths by ROGUE_CULINARY_* key).

/mob/living/carbon/human
	/// Favourite and hated food and drink: ROGUE_CULINARY_* = type path. Missing keys take Ratwood's defaults.
	var/list/rogue_culinary
	/// world.time this nose may notice a cooking smell again (Ratwood SMELL_COOLDOWN).
	var/rogue_next_smell = 0

/mob/living/carbon/human/proc/rogue_culinary_preference(key)
	if(LAZYACCESS(rogue_culinary, key))
		return rogue_culinary[key]
	switch(key)
		if(ROGUE_CULINARY_FAVOURITE_FOOD)
			return /obj/item/reagent_containers/food/snacks/rogue/bread
		if(ROGUE_CULINARY_HATED_FOOD)
			return ROGUE_BURNT_FOOD
		if(ROGUE_CULINARY_FAVOURITE_DRINK)
			return /datum/reagent/consumable/ethanol/beer
	return null

/// Sets a favourite or hated food or drink (for the character menu): the key and a food type or a reagent type.
/mob/living/carbon/human/proc/rogue_set_culinary_preference(key, path)
	LAZYSET(rogue_culinary, key, path)

/// Ratwood human examine(): a royal servant (TRAIT_ROYALSERVANT) knows the tastes of the court - the favourite and hated food and
/// drink of the lord, the prince, the hand, the steward, a councillor, the court physician, a knight, the court magician and
/// the dungeoneer. Medieval maps only.
/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(!rogue_survival_enabled() || !HAS_TRAIT(user, TRAIT_ROYALSERVANT))
		return
	var/static/list/court_roles = typecacheof(list(
		/datum/job/roguetown/lord,
		/datum/job/roguetown/prince,
		/datum/job/roguetown/hand,
		/datum/job/roguetown/steward,
		/datum/job/roguetown/councillor,
		/datum/job/roguetown/physician,
		/datum/job/roguetown/knight,
		/datum/job/roguetown/magician,
		/datum/job/roguetown/dungeoneer,
	))
	var/datum/job/role = job ? SSjob.get_job(job) : null
	if(!is_type_in_typecache(role, court_roles))
		return
	var/list/favourites = rogue_palate_names(rogue_culinary_preference(ROGUE_CULINARY_FAVOURITE_FOOD), rogue_culinary_preference(ROGUE_CULINARY_FAVOURITE_DRINK))
	if(length(favourites) > 1)
		. += span_notice("Their favourites are [english_list(favourites)].")
	else if(length(favourites))
		. += span_notice("Their favourite is [favourites[1]].")
	var/list/hated = rogue_palate_names(rogue_culinary_preference(ROGUE_CULINARY_HATED_FOOD), rogue_culinary_preference(ROGUE_CULINARY_HATED_DRINK))
	if(length(hated))
		. += span_notice("They hate [english_list(hated)].")

/// The names of a food type and a reagent type, the food first; none for what is not set.
/proc/rogue_palate_names(food_type, drink_type)
	. = list()
	if(ispath(food_type, /obj/item))
		var/obj/item/food = food_type
		. += initial(food.name)
	if(ispath(drink_type, /datum/reagent))
		var/datum/reagent/drink = drink_type
		. += initial(drink.name)

/// A favourite or hated food or drink mood; the remark only when it is new (Ratwood can_apply()).
/mob/living/carbon/human/proc/rogue_preference_mood(category, datum/mood_event/mood, remark)
	var/fresh = !mob_mood?.has_mood_of_category(category)
	add_mood_event(category, mood)
	if(fresh)
		to_chat(src, remark)

/// Ratwood smell_act(): a cooking smell reaches this nose, plainer the nearer it is; once a minute at most.
/mob/living/carbon/human/proc/rogue_notice_smell(scent, distance)
	if(!client || stat != STABLE || IS_UNCONSCIOUS(src) || HAS_TRAIT(src, TRAIT_ANOSMIA) || world.time < rogue_next_smell)
		return
	rogue_next_smell = world.time + ROGUE_SMELL_COOLDOWN
	if(distance <= ROGUE_SMELL_STRONG_RANGE)
		to_chat(src, span_notice("The unmistakable smell of [scent] bombards your nostrils."))
	else if(distance <= ROGUE_SMELL_NORMAL_RANGE)
		to_chat(src, span_notice("The smell of [scent] fills the air."))
	else
		to_chat(src, span_notice("The subtle smell of [scent] tickles your nose..."))

/// Ratwood temporary_pollution_emission of a cooked food: for five minutes it wafts its scent to the noses around it.
/datum/component/rogue_food_smell
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/scent
	var/fades_at = 0
	var/smell_timer

/datum/component/rogue_food_smell/Initialize(scent)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.scent = scent
	fades_at = world.time + ROGUE_SMELL_DURATION
	smell_timer = addtimer(CALLBACK(src, PROC_REF(waft)), ROGUE_SMELL_INTERVAL, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)
	waft()

/datum/component/rogue_food_smell/Destroy(force)
	deltimer(smell_timer)
	smell_timer = null
	return ..()

/datum/component/rogue_food_smell/proc/waft()
	if(world.time >= fades_at)
		qdel(src)
		return
	var/turf/center = get_turf(parent)
	if(!center)
		return
	for(var/mob/living/carbon/human/sniffer in get_hearers_in_view(ROGUE_SMELL_RANGE, center))
		sniffer.rogue_notice_smell(scent, get_dist(sniffer, center))

// Mood events of the palate (Ratwood stress events).

/datum/mood_event/rogue_favourite_food
	description = "I ate my favourite food!"
	mood_change = 1 * ROGUE_STRESS_TO_MOOD
	timeout = 5 MINUTES

/datum/mood_event/rogue_hated_food
	description = "I had to eat my most hated food!"
	mood_change = -1 * ROGUE_STRESS_TO_MOOD
	timeout = 10 MINUTES

/datum/mood_event/rogue_favourite_drink
	description = "I had my favourite drink!"
	mood_change = 1 * ROGUE_STRESS_TO_MOOD
	timeout = 5 MINUTES

/datum/mood_event/rogue_hated_drink
	description = "I had to consume my most hated drink!"
	mood_change = -1 * ROGUE_STRESS_TO_MOOD
	timeout = 10 MINUTES

/datum/mood_event/rogue_noble_impoverished_food
	description = "This is disgusting. How can anyone eat this?"
	mood_change = -2 * ROGUE_STRESS_TO_MOOD
	timeout = 10 MINUTES

/datum/mood_event/rogue_noble_desperate
	description = "What level of desperation have I fallen to?"
	mood_change = -6 * ROGUE_STRESS_TO_MOOD
	timeout = 60 MINUTES

/datum/mood_event/rogue_noble_bland_food
	description = "This fare is really beneath me. I deserve better than this..."
	mood_change = -1 * ROGUE_STRESS_TO_MOOD
	timeout = 5 MINUTES

/datum/mood_event/rogue_noble_bad_manners
	description = "I should've used a spoon..."
	mood_change = -1 * ROGUE_STRESS_TO_MOOD
	timeout = 5 MINUTES

/datum/mood_event/rogue_noble_ate_without_table
	description = "Eating such a meal without a table? Churlish."
	mood_change = -1 * ROGUE_STRESS_TO_MOOD
	timeout = 2 MINUTES

/datum/mood_event/rogue_noble_lavish_food
	description = "Truly, a feast befitting my station."
	mood_change = 4 * ROGUE_STRESS_TO_MOOD
	timeout = 30 MINUTES
