/obj/item/fish/ratfish
	name = "ratfish"
	desc = "A rat exposed to the murky waters of maintenance too long. Any higher power, if it revealed itself, would state that the ratfish's continued existence is extremely unwelcome."
	icon_state = "ratfish"
	sprite_width = 7
	sprite_height = 5
	random_case_rarity = FISH_RARITY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 10 //set by New, but this is the default config value
	fillet_type = /obj/item/food/meat/slab/human/mutant/zombie //eww...
	fish_traits = list(/datum/fish_trait/necrophage)
	required_temperature_min = MIN_AQUARIUM_TEMP+15
	required_temperature_max = MIN_AQUARIUM_TEMP+35
	fish_movement_type = /datum/fish_movement/zippy
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = DAIRY
		)
	)
	beauty = FISH_BEAUTY_DISGUSTING

/obj/item/fish/ratfish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	//stable pop reflects the config for how many mice migrate. powerful...
	stable_population = CONFIG_GET(number/mice_roundstart)

/obj/item/fish/sludgefish
	name = "sludgefish"
	desc = "A misshapen, fragile, loosely fish-like living goop, the only thing that'd ever thrive in the acidic and claustrophobic cavities of the station's organic waste disposal system."
	icon_state = "sludgefish"
	sprite_width = 7
	sprite_height = 6
	required_fluid_type = AQUARIUM_FLUID_SULPHWATEVER
	stable_population = 8
	average_size = 20
	average_weight = 400
	health = 50
	breeding_timeout = 2.5 MINUTES
	fish_traits = list(/datum/fish_trait/parthenogenesis, /datum/fish_trait/no_mating)
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+40
	evolution_types = list(/datum/fish_evolution/purple_sludgefish)
	beauty = FISH_BEAUTY_NULL

/obj/item/fish/sludgefish/purple
	name = "purple sludgefish"
	desc = "A misshapen, fragile, loosely fish-like living goop. This one has developed sexual reproduction mechanisms, and a purple tint to boot."
	icon_state = "sludgefish_purple"
	random_case_rarity = FISH_RARITY_NOPE
	fish_traits = list(/datum/fish_trait/parthenogenesis)

/obj/item/fish/slimefish
	name = "acquatic slime"
	desc = "Kids, this is what happens when a slime overcomes its hydrophobic nature. It goes glug glug."
	icon_state = "slimefish"
	icon_state_dead = "slimefish_dead"
	sprite_width = 7
	sprite_height = 7
	do_flop_animation = FALSE //it already has a cute bouncy wiggle. :3
	random_case_rarity = FISH_RARITY_VERY_RARE
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	stable_population = 4
	health = 150
	fillet_type = /obj/item/slime_extract/grey
	grind_results = list(/datum/reagent/toxin/slimejelly = 10)
	fish_traits = list(/datum/fish_trait/toxin_immunity, /datum/fish_trait/crossbreeder)
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = TOXIC,
		),
		list(
			FISH_BAIT_TYPE = FISH_BAIT_REAGENT,
			FISH_BAIT_VALUE = /datum/reagent/toxin,
			FISH_BAIT_AMOUNT = 5,
		),
	)
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	beauty = FISH_BEAUTY_GREAT
