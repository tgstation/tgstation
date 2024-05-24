/mob/living/basic
	///the child type of the parent, basically spawns in the baby version instead of the adult version. Used if mutations fail
	var/child_type
	///if they lay eggs the egg type
	var/egg_type
	///ALL possible mutations this simple animal has
	var/list/mutation_list = list()
	///this is the created_mutations
	var/list/created_mutations = list()
	///How many eggs can the chicken still lay?
	var/eggs_left = 0
	///can it still lay eggs?
	var/eggs_fertile = TRUE

	///Consumed food
	var/list/consumed_food = list()
	///All Consumed reagents
	var/list/datum/reagent/consumed_reagents = list()
	///list of our "consumed" items
	var/list/consumed_items = list()

/mob/living/basic/Initialize(mapload)
	. = ..()
	create_mutations()

/mob/living/basic/proc/create_mutations()
	for(var/datum/mutation/ranching/mutation as anything in mutation_list )
		var/datum/mutation/ranching/new_mut = new mutation
		if(!istype(new_mut))
			continue
		created_mutations += new_mut

/mob/living/basic/Destroy()
	. = ..()
	QDEL_LIST(created_mutations)
	created_mutations = null
	consumed_items = null

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
	///max generational happiness
	var/max_happiness_per_generation = 100
	///How sad until they die of sadness?
	var/minimum_living_happiness = -200

	///List of happy chems
	var/list/happy_chems = list(
		/datum/reagent/drug/methamphetamine = 0.5,
		/datum/reagent/toxin/lipolicide = 0.25,
		/datum/reagent/consumable/sugar = 0.1,
	)
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
	/// Last phrase said near it and person who said it
	var/list/speech_buffer = list()
	/// the icon suffix
	var/icon_suffix = ""
	///What shows up in the encyclopedia, will need some lovin
	var/book_desc = "White Chickens lay White Eggs, however, if they are happy they will lay Brown Eggs instead. "
	///if this chicken is marked, will add a sigil above it to show its marked
	var/is_marked = FALSE
	///the self ability planning tree
	var/ability_planning_tree = /datum/ai_planning_subtree/use_mob_ability/chicken
	///the targeted ability planning tree
	var/targeted_ability_planning_tree = /datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken
	var/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack/chicken,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/play_dead,
	)
	///how much extra fertile we are
	var/fertility_boosting = 0
	///extra chance of mutation
	var/instability = 0
	///modifier to the egg laying cooldown
	var/egg_laying_boosting = 0
