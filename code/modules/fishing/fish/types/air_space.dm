/obj/item/fish/sand_surfer
	name = "sand surfer"
	desc = "A bronze alien \"fish\" living and swimming underneath faraway sandy places."
	icon_state = "sand_surfer"
	sprite_height = 6
	sprite_width = 6
	stable_population = 5
	average_size = 65
	average_weight = 1100
	weight_size_deviation = 0.35
	random_case_rarity = FISH_RARITY_RARE
	required_fluid_type = AQUARIUM_FLUID_AIR
	required_temperature_min = MIN_AQUARIUM_TEMP+25
	required_temperature_max = MIN_AQUARIUM_TEMP+60
	fish_movement_type = /datum/fish_movement/plunger
	fishing_difficulty_modifier = 5
	fish_traits = list(/datum/fish_trait/shiny_lover)
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/sand_crab
	name = "burrower crab"
	desc = "A sand-dwelling crustacean. It looks like a crab and tastes like a crab, but waddles like a fish."
	icon_state = "crab"
	dedicated_in_aquarium_icon_state = "crab_small"
	sprite_height = 6
	sprite_width = 10
	average_size = 60
	average_weight = 1000
	weight_size_deviation = 0.1
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+40
	fillet_type = /obj/item/food/meat/slab/rawcrab
	fish_traits = list(/datum/fish_trait/amphibious, /datum/fish_trait/shiny_lover, /datum/fish_trait/carnivore)
	fish_movement_type = /datum/fish_movement/slow
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = SEAFOOD,
		),
	)

/obj/item/fish/bumpy
	name = "bump-fish"
	desc = "An misshapen fish-thing all covered in stubby little tendrils"
	icon_state = "bumpy"
	sprite_height = 4
	sprite_width = 5
	stable_population = 4
	required_fluid_type = AQUARIUM_FLUID_ANY_WATER
	required_temperature_min = MIN_AQUARIUM_TEMP+15
	required_temperature_max = MIN_AQUARIUM_TEMP+40
	beauty = FISH_BEAUTY_BAD
	fish_traits = list(/datum/fish_trait/amphibious, /datum/fish_trait/vegan)
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = VEGETABLES,
		),
	)

/obj/item/fish/starfish
	name = "cosmostarfish"
	desc = "A peculiar, gravity-defying, echinoderm-looking critter from hyperspace."
	icon_state = "starfish"
	icon_state_dead = "starfish_dead"
	sprite_height = 3
	sprite_width = 4
	average_size = 30
	average_weight = 300
	stable_population = 3
	required_fluid_type = AQUARIUM_FLUID_AIR
	random_case_rarity = FISH_RARITY_NOPE
	required_temperature_min = 0
	required_temperature_max = INFINITY
	safe_air_limits = null
	min_pressure = 0
	max_pressure = INFINITY
	grind_results = list(/datum/reagent/bluespace = 10)
	fillet_type = null
	fish_traits = list(/datum/fish_trait/antigrav, /datum/fish_trait/mixotroph)
	beauty = FISH_BEAUTY_GREAT

/obj/item/fish/starfish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/fish/starfish/update_overlays()
	. = ..()
	if(status == FISH_ALIVE)
		. += emissive_appearance(icon, "starfish_emissive", src)

///It spins, and dimly glows in the dark.
/obj/item/fish/starfish/flop_animation()
	DO_FLOATING_ANIM(src)
