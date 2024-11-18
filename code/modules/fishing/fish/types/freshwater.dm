/obj/item/fish/goldfish
	name = "goldfish"
	fish_id = "goldfish"
	desc = "Despite common belief, goldfish do not have three-second memories. \
		They can actually remember things that happened up to three months ago."
	icon_state = "goldfish"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#D8540D"
	sprite_width = 5
	sprite_height = 3
	stable_population = 9
	average_size = 20
	average_weight = 200
	weight_size_deviation = 0.35
	favorite_bait = list(/obj/item/food/bait/worm)
	required_temperature_min = MIN_AQUARIUM_TEMP+18
	required_temperature_max = MIN_AQUARIUM_TEMP+26
	evolution_types = list(/datum/fish_evolution/three_eyes, /datum/fish_evolution/chainsawfish)
	compatible_types = list(/obj/item/fish/goldfish/gill, /obj/item/fish/goldfish/three_eyes, /obj/item/fish/goldfish/three_eyes/gill)

/obj/item/fish/goldfish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	add_traits(list(TRAIT_FISHING_BAIT, TRAIT_GOOD_QUALITY_BAIT), INNATE_TRAIT)

/obj/item/fish/goldfish/gill
	name = "McGill"
	desc = "A great rubber duck tool for Lawyers who can't get a grasp over their case."
	stable_population = 1
	random_case_rarity = FISH_RARITY_NOPE
	fish_flags = parent_type::fish_flags & ~FISH_FLAG_SHOW_IN_CATALOG
	beauty = FISH_BEAUTY_GOOD
	compatible_types = list(/obj/item/fish/goldfish, /obj/item/fish/goldfish/three_eyes)
	fish_traits = list(/datum/fish_trait/recessive)

/obj/item/fish/goldfish/gill/get_fish_taste()
	return list("raw fish" = 2.5, "objection" = 1)

/obj/item/fish/goldfish/three_eyes
	name = "three-eyed goldfish"
	fish_id = "three_eyes"
	desc = "A goldfish with an extra half a pair of eyes. You wonder what it's been feeding on lately..."
	icon_state = "three_eyes"
	stable_population = 4
	fish_traits = list(/datum/fish_trait/recessive, /datum/fish_trait/shiny_lover)
	compatible_types = list(/obj/item/fish/goldfish, /obj/item/fish/goldfish/gill, /obj/item/fish/goldfish/three_eyes/gill)
	beauty = FISH_BEAUTY_GOOD
	fishing_difficulty_modifier = 10
	random_case_rarity = FISH_RARITY_VERY_RARE
	food = /datum/reagent/toxin/mutagen
	favorite_bait = list(
		list(
			"Type" = "Reagent",
			"Value" = /datum/reagent/toxin/mutagen,
			"Amount" = 3,
		),
	)

/obj/item/fish/goldfish/three_eyes/get_fish_taste()
	return list("raw fish" = 2.5, "chemical waste" = 0.5)

/obj/item/fish/goldfish/three_eyes/gill
	name = "McGill"
	desc = "A great rubber duck tool for Lawyers who can't get a grasp over their case. It looks kinda different today..."
	compatible_types = list(/obj/item/fish/goldfish, /obj/item/fish/goldfish/three_eyes)
	beauty = FISH_BEAUTY_GREAT
	fish_flags = parent_type::fish_flags & ~FISH_FLAG_SHOW_IN_CATALOG
	stable_population = 1
	random_case_rarity = FISH_RARITY_NOPE

/obj/item/fish/goldfish/three_eyes/gill/get_fish_taste()
	return list("raw fish" = 2.5, "objection" = 1)

/obj/item/fish/angelfish
	name = "angelfish"
	fish_id = "angelfish"
	desc = "Young Angelfish often live in groups, while adults prefer solitary life. They become territorial and aggressive toward other fish when they reach adulthood."
	icon_state = "angelfish"
	sprite_width = 4
	sprite_height = 7
	average_size = 30
	average_weight = 500
	stable_population = 3
	fish_traits = list(/datum/fish_trait/aggressive)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/guppy
	name = "guppy"
	fish_id = "guppy"
	desc = "Guppy is also known as rainbow fish because of the brightly colored body and fins."
	icon_state = "guppy"
	sprite_width = 5
	sprite_height = 2
	sprite_width = 8
	sprite_height = 5
	average_size = 30
	average_weight = 500
	stable_population = 6
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/plasmatetra
	name = "plasma tetra"
	fish_id = "plasmatetra"
	desc = "Due to their small size, tetras are prey to many predators in their watery world, including eels, crustaceans, and invertebrates."
	icon_state = "plastetra"
	sprite_width = 4
	sprite_height = 2
	average_size = 30
	average_weight = 500
	stable_population = 3
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/catfish
	name = "catfish"
	fish_id = "catfish"
	desc = "A catfish has about 100,000 taste buds, and their bodies are covered with them to help detect chemicals present in the water and also to respond to touch."
	icon_state = "catfish"
	sprite_width = 8
	sprite_height = 4
	average_size = 80
	average_weight = 1600
	weight_size_deviation = 0.35
	stable_population = 3
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = JUNKFOOD
		)
	)
	required_temperature_min = MIN_AQUARIUM_TEMP+12
	required_temperature_max = MIN_AQUARIUM_TEMP+30
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/zipzap
	name = "anxious zipzap"
	fish_id = "zipzap"
	desc = "A fish overflowing with crippling anxiety and electric potential. Worried about the walls of its tank closing in constantly. Both literally and as a general metaphorical unease about life's direction."
	icon_state = "zipzap"
	icon_state_dead = "zipzap_dead"
	sprite_width = 6
	sprite_height = 3
	stable_population = 3
	average_size = 30
	average_weight = 500
	random_case_rarity = FISH_RARITY_VERY_RARE
	favorite_bait = list(/obj/item/stock_parts/power_store/cell/lead)
	required_temperature_min = MIN_AQUARIUM_TEMP+18
	required_temperature_max = MIN_AQUARIUM_TEMP+26
	fish_traits = list(
		/datum/fish_trait/no_mating,
		/datum/fish_trait/wary,
		/datum/fish_trait/anxiety,
		/datum/fish_trait/electrogenesis,
	)
	//anxiety naturally limits the amount of zipzaps per tank, so they are stronger alone
	electrogenesis_power = 6.7 MEGA JOULES
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/zipzap/get_fish_taste()
	return list("raw fish" = 2, "anxiety" = 1)

/obj/item/fish/tadpole
	name = "tadpole"
	desc = "The larval spawn of an amphibian. A very minuscle, round creature with a long tail it uses to swim around."
	icon_state = "tadpole"
	average_size = 3
	average_weight = 10
	sprite_width = 3
	sprite_height = 1
	health = 50
	feeding_frequency = 1.5 MINUTES
	required_temperature_min = MIN_AQUARIUM_TEMP+15
	required_temperature_max = MIN_AQUARIUM_TEMP+20
	fillet_type = null
	fish_traits = list(/datum/fish_trait/no_mating) //They grow into frogs and that's it.
	beauty = FISH_BEAUTY_NULL
	random_case_rarity = FISH_RARITY_NOPE //Why would you want generic frog tadpoles you get from ponds inside fish cases?
	/// Once dead, tadpoles disappear after a dozen seconds, since you can get infinite tadpoles.
	var/del_timerid

/obj/item/fish/tadpole/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	AddComponent(/datum/component/fish_growth, /mob/living/basic/frog, rand(2 MINUTES, 3 MINUTES))
	RegisterSignal(src, COMSIG_FISH_BEFORE_GROWING, PROC_REF(growth_checks))
	RegisterSignal(src, COMSIG_FISH_FINISH_GROWING, PROC_REF(on_growth))

/obj/item/fish/tadpole/make_edible()
	return

/obj/item/fish/tadpole/set_status(new_status, silent = FALSE)
	. = ..()
	if(status == FISH_DEAD)
		del_timerid = QDEL_IN_STOPPABLE(src, 12 SECONDS)
	else
		deltimer(del_timerid)

/obj/item/fish/tadpole/proc/growth_checks(datum/source, seconds_per_tick, growth, result_path)
	SIGNAL_HANDLER
	var/hunger = get_hunger()
	if(hunger >= 0.7) //too hungry to grow
		return COMPONENT_DONT_GROW
	var/obj/structure/aquarium/aquarium = loc
	if(istype(aquarium) && !aquarium.reproduction_and_growth) //the aquarium has breeding disabled
		return COMPONENT_DONT_GROW

/obj/item/fish/tadpole/proc/on_growth(datum/source, mob/living/basic/frog/result)
	SIGNAL_HANDLER
	playsound(result, result.attack_sound, 50, TRUE) // reeeeeeeeeeeeeee...

/obj/item/fish/tadpole/get_export_price(price, elasticity_percent)
	return 2 //two credits. Tadpoles aren't really that valueable.

/obj/item/fish/perch
	name = "perch"
	fish_id = "perch"
	desc = "An all around popular panfish, game fish and unfortunate prey to other, bigger predators."
	icon_state = "perch"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#9D8C64"
	sprite_width = 5
	sprite_height = 3
	stable_population = 7
	average_size = 25
	average_weight = 400
	required_temperature_min = MIN_AQUARIUM_TEMP+5
	required_temperature_max = MIN_AQUARIUM_TEMP+26
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = BUGS,
		),
	/obj/item/fish,
	/obj/item/fishing_lure, //they love lures in general.
	)

///Memetic fish from a paleontologically inaccurate, goofy replica of a specimen. Sells decently for its size.
/obj/item/fish/sacabambaspis
	name = "sacabambaspis"
	fish_id = "sacabambaspis"
	desc = "A jawless fish ought to be extinct by the end of the Ordovician period. Some speculate alien intervention may have been behind its survival and inevitable evolution as a dweller of hot springs."
	icon_state = "sacabambaspis"
	sprite_width = 5
	sprite_height = 3
	stable_population = 7
	average_size = 27
	average_weight = 500
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+45
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	beauty = FISH_BEAUTY_GOOD
	fish_traits = list(/datum/fish_trait/necrophage, /datum/fish_trait/wary)

/obj/item/fish/sacabambaspis/get_export_price(price, percent)
	return ..() * 4.5
