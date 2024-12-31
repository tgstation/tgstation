//Tiziran Fish.

/obj/item/fish/moonfish
	name = "zagoskian moonfish"
	fish_id = "moonfish"
	desc = "A disc-shaped fish native of the less shallow areas of Tizira's oceans, roughly the size of a tuna. Highly prized in lizard cuisine for their large eggs."
	icon_state = "tizira_moonfish"
	sprite_height = 7
	sprite_width = 7
	fillet_type = /obj/item/food/fishmeat/moonfish
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 2
	average_size = 95
	average_weight = 2000
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+30
	beauty = FISH_BEAUTY_GOOD
	weight_size_deviation = 0.1
	fishing_difficulty_modifier = 10
	random_case_rarity = FISH_RARITY_RARE
	fish_traits = list(/datum/fish_trait/predator)
	compatible_types = list(/obj/item/fish/moonfish, /obj/item/fish/moonfish/dwarf)
	evolution_types = list(/datum/fish_evolution/dwarf_moonfish)
	favorite_bait = list(
		/obj/item/fish/armorfish,
		/obj/item/fish/needlefish,
		/obj/item/fish/gunner_jellyfish,
	)
	var/egg_laying_time = 2.75 MINUTES

/obj/item/fish/moonfish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	AddComponent(/datum/component/fish_growth, /obj/item/food/moonfish_eggs, egg_laying_time, use_drop_loc = FALSE, del_on_grow = FALSE, inherit_name = FALSE)
	RegisterSignal(src, COMSIG_FISH_BEFORE_GROWING, PROC_REF(egg_checks))

///Stop laying eggs if we're in an unsafe environment, starving of if there are simply too many eggs already.
/obj/item/fish/moonfish/proc/egg_checks(datum/source, seconds_per_tick, growth, result_path)
	if(result_path != /obj/item/food/moonfish_eggs) //Don't stop the growth of the dwarf subtype.
		return
	if(!proper_environment() || get_starvation_mult())
		return COMPONENT_DONT_GROW
	var/count = 0
	for(var/obj/item/food/moonfish_eggs/egg in loc)
		count ++
		if(count > 10)
			return COMPONENT_DONT_GROW

/obj/item/fish/moonfish/dwarf
	name = "dwarf moonfish"
	fish_id = "dwarf_moonfish"
	desc = "Ordinarily in the wild, the Zagoskian moonfish is around the size of a tuna, however through selective breeding a smaller breed suitable for being kept as an aquarium pet has been created."
	icon_state = "dwarf_moonfish"
	sprite_height = 6
	sprite_width = 6
	stable_population = 3
	average_size = 50
	average_weight = 950
	fishing_difficulty_modifier = 0
	egg_laying_time = 4.25 MINUTES
	random_case_rarity = FISH_RARITY_BASIC
	fish_traits = list()
	evolution_types = list(/datum/fish_evolution/moonfish)

/obj/item/fish/moonfish/dwarf/update_size_and_weight(new_size = average_size, new_weight = average_weight, update_materials = TRUE)
	. = ..()
	var/multiplier = (size / (average_size * 1.5)) * (weight / (average_weight * 1.5))

	AddComponent(/datum/component/fish_growth, /datum/fish_evolution/moonfish, 2.5 MINUTES * multiplier, use_drop_loc = FALSE)

/obj/item/fish/gunner_jellyfish
	name = "gunner jellyfish"
	fish_id = "gunner_jellyfish"
	desc = "So called due to their resemblance to an artillery shell, the gunner jellyfish is native to Tizira, where it is enjoyed as a delicacy. Produces a mild hallucinogen that is destroyed by cooking."
	icon_state = "gunner_jellyfish"
	sprite_height = 4
	sprite_width = 5
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/gunner_jellyfish
	fish_traits = list(/datum/fish_trait/hallucinogenic)
	required_temperature_min = MIN_AQUARIUM_TEMP+24
	required_temperature_max = MIN_AQUARIUM_TEMP+32
	beauty = FISH_BEAUTY_GOOD
	favorite_bait = list(
		/obj/item/fish/armorfish,
		/obj/item/fish/needlefish,
	)

/obj/item/fish/gunner_jellyfish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	AddElement(/datum/element/quality_food_ingredient, FOOD_COMPLEXITY_2)

/obj/item/fish/gunner_jellyfish/get_fish_taste()
	return list("cold jelly" = 2)

/obj/item/fish/gunner_jellyfish/get_fish_taste_cooked()
	return list("crunchy tenderness" = 2)

/obj/item/fish/needlefish
	name = "needlefish"
	fish_id = "needlefish"
	desc = "A tiny, transparent fish which resides in large schools in the oceans of Tizira. A common food for other, larger fish."
	icon_state = "needlefish"
	sprite_height = 3
	sprite_width = 7
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 12
	breeding_timeout = 1 MINUTES
	fillet_type = null
	average_size = 20
	average_weight = 300
	fish_traits = list(/datum/fish_trait/carnivore)
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+32

/obj/item/fish/needlefish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	add_traits(list(TRAIT_FISHING_BAIT, TRAIT_GOOD_QUALITY_BAIT), INNATE_TRAIT)

/obj/item/fish/armorfish
	name = "armorfish"
	fish_id = "armorfish"
	desc = "A small shellfish native to Tizira's oceans, known for its exceptionally hard shell. Consumed similarly to prawns."
	icon_state = "armorfish"
	sprite_height = 5
	sprite_width = 6
	average_size = 25
	average_weight = 350
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 10
	breeding_timeout = 1.25 MINUTES
	fillet_type = /obj/item/food/fishmeat/armorfish
	fish_movement_type = /datum/fish_movement/slow
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+32

/obj/item/fish/armorfish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	add_traits(list(TRAIT_FISHING_BAIT, TRAIT_GOOD_QUALITY_BAIT), INNATE_TRAIT)

/obj/item/fish/armorfish/get_fish_taste()
	return list("raw prawn" = 2)

/obj/item/fish/armorfish/get_fish_taste_cooked()
	return list("cooked prawn" = 2)
