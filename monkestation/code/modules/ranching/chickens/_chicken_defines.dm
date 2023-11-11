#define DEFAULT_CHICKEN_ABILITY_COOLDOWN 30 SECONDS

/mob/living/basic
	///the child type of the parent, basically spawns in the baby version instead of the adult version. Used if mutations fail
	var/child_type
	///if they lay eggs the egg type
	var/egg_type
	///ALL possible mutations this simple animal has
	var/list/mutation_list = list()
	///How many eggs can the chicken still lay?
	var/eggs_left = 0
	///can it still lay eggs?
	var/eggs_fertile = TRUE

	///How happy the animal is, used on mutation to see if it can branch
	var/happiness = 0
	///Consumed food
	var/list/consumed_food = list()
	///All Consumed reagents
	var/list/datum/reagent/consumed_reagents = new/list()

/mob/living/basic/chicken

	faction = list("chicken")
	ai_controller = /datum/ai_controller/chicken
	///Message you get when it is fed
	var/list/feedMessages = list("It clucks happily.","It gobbles up the food voraciously.","It noms happily.")
	///Message that is sent when an egg is laid
	var/list/layMessage = EGG_LAYING_MESSAGES
	//Global amount of chickens
	var/static/chicken_count = 0
	///Needed cause i can't iterate a new spawn with the ref to a mob
	var/chicken_path = /mob/living/basic/chicken
	///Breed of the chicken needed for naming
	var/breed_name = "White"
	///Do we wanna call the male rooster something different?
	var/breed_name_male
	///Is the hen also different?
	var/breed_name_female
	///Total times eaten
	var/total_times_eaten = 0
	///Current fed level
	var/current_feed_amount = 0
	///Overcrowding amount
	var/overcrowding = 10
	///Age of the chicken
	var/age = 0
	///max age of a chicken
	var/max_age = 100
	///Cooldown for aging
	COOLDOWN_DECLARE(age_cooldown)
	///Aging Speed
	var/age_speed = 30 SECONDS
	///max generational happiness
	var/max_happiness_per_generation = 100
	///How sad until they die of sadness?
	var/minimum_living_happiness = -200

	///List of happy chems
	var/list/happy_chems = list(
	/datum/reagent/drug/methamphetamine = 0.5,
	/datum/reagent/toxin/lipolicide = 0.25,
	/datum/reagent/consumable/sugar = 0.1,)
	///List of liked foods
	var/list/liked_foods = list(/obj/item/food/grown/wheat = 3,)
	///list of disliked foods
	var/list/disliked_food_types = list(MEAT = 4,)
	///list of disliked foods
	var/list/disliked_foods = list()
	///list of dislike chemicals
	var/list/disliked_chemicals = list(/datum/reagent/blood = 1,)
	///if this chicken likes pets
	var/likes_pets = TRUE

	///unique ability for chicken
	var/self_ability = null
	///targeted ability of this chicken
	var/targeted_ability = null
	/// probability for ability
	var/ability_prob = 3
	///what type of projectile do we shoot?
	var/projectile_type = null
	///probabilty of firing a shot on any given attack
	var/ranged_cooldown = 1 SECONDS

	///Glass Chicken exclusive: reagents for eggs
	var/list/glass_egg_reagents = list()
	///Stone Chicken Exclusive: ore type for eggs
	var/obj/item/stack/ore/production_type = null
	///list of all friends will not attack them and can be ordered around by them if high enough
	var/list/Friends = list()
	/// Last phrase said near it and person who said it
	var/list/speech_buffer = list()
	/// the icon suffix
	var/icon_suffix = ""
	///What shows up in the encyclopedia, will need some lovin
	var/book_desc = "White Chickens lay White Eggs, however, if they are happy they will lay Brown Eggs instead. "
	///if this chicken is marked, will add a sigil above it to show its marked
	var/is_marked = FALSE
	///the current visual effect applied
	var/mutable_appearance/applied_visual
	///the self ability planning tree
	var/ability_planning_tree = /datum/ai_planning_subtree/use_mob_ability/chicken
	///the targeted ability planning tree
	var/targeted_ability_planning_tree = /datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/attack/chicken,
		/datum/pet_command/point_targetting/fetch,
		/datum/pet_command/play_dead,
	)
	///how much extra fertile we are
	var/fertility_boosting = 0
	///extra chance of mutation
	var/instability = 0
	///modifier to the egg laying cooldown
	var/egg_laying_boosting = 0

#undef DEFAULT_CHICKEN_ABILITY_COOLDOWN

/obj/item/food/egg
	name = "White Egg"
	///the amount the chicken is grown
	var/amount_grown = 0
	///the type of chicken that laid this egg
	var/mob/living/basic/chicken/layer_hen_type = /mob/living/basic/chicken
	///happiness of the chicken
	var/happiness = 0
	///list of consumed food
	var/list/consumed_food
	///list of consumed reagents
	var/list/consumed_reagents
	///list of all possible mutations
	var/list/mutations = list()
	///eggs ore type
	var/obj/item/stack/ore/production_type = null
	///list of picked mutations should only ever be one
	var/list/possible_mutations = list()
	///list of all friends will not attack them and can be ordered around by them if high enough
	var/list/Friends = list()
	///was this just layed as a mutation if so don't let it grow via incubators
	var/fresh_mutation = FALSE
	///is this egg fertile? used when picked up / dropped
	var/is_fertile = FALSE
	///the holder of our factions used so that we keep faction friends through generations
	var/list/faction_holder = list()
	///our stored_glass_egg_reagents from the parent
	var/list/glass_egg_reagents = list()

/datum/action/cooldown/mob_cooldown/chicken
	melee_cooldown_time =  1 // dumb
	var/datum/ai_behavior/targeted_mob_ability/min_range/chicken/what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/melee

/datum/pet_command/point_targetting/attack/chicken
	attack_behaviour = /datum/ai_behavior/basic_melee_attack/chicken
