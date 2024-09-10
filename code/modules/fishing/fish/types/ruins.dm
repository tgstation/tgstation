///From oil puddles from the elephant graveyard. Also an evolution of the "unmarine bonemass"
/obj/item/fish/mastodon
	name = "unmarine mastodon"
	desc = "A monster of exposed muscles and innards, wrapped in a fish-like skeleton. You don't remember ever seeing it on the catalog."
	icon = 'icons/obj/aquarium/wide.dmi'
	icon_state = "mastodon"
	base_pixel_x = -16
	pixel_x = -16
	sprite_width = 12
	sprite_height = 7
	show_in_catalog = FALSE
	random_case_rarity = FISH_RARITY_NOPE
	fishing_difficulty_modifier = 30
	required_fluid_type = AQUARIUM_FLUID_ANY_WATER
	min_pressure = HAZARD_LOW_PRESSURE
	health = 300
	stable_population = 1 //This means they can only crossbreed.
	grind_results = list(/datum/reagent/bone_dust = 5, /datum/reagent/consumable/liquidgibs = 5)
	fillet_type = /obj/item/stack/sheet/bone
	num_fillets = 2
	feeding_frequency = 2 MINUTES
	breeding_timeout = 5 MINUTES
	average_size = 180
	average_weight = 5000
	death_text = "%SRC stops moving."
	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/amphibious, /datum/fish_trait/revival, /datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/aggressive)
	beauty = FISH_BEAUTY_BAD

///From the cursed spring
/obj/item/fish/soul
	name = "soulfish"
	desc = "A distant yet vaguely close critter, like a long lost relative. You feel your soul rejuvenated just from looking at it... Also, what the fuck is this shit?!"
	icon_state = "soulfish"
	sprite_width = 7
	sprite_height = 6
	average_size = 60
	average_weight = 1200
	stable_population = 4
	show_in_catalog = FALSE
	beauty = FISH_BEAUTY_EXCELLENT
	fish_movement_type = /datum/fish_movement/choppy //Glideless legacy movement? in my fishing minigame?
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = JUNKFOOD|FRIED,
		),
	)
	fillet_type = /obj/item/food/meat/cutlet/plain/human
	required_temperature_min = MIN_AQUARIUM_TEMP+3
	required_temperature_max = MIN_AQUARIUM_TEMP+38
	random_case_rarity = FISH_RARITY_NOPE

///From the cursed spring
/obj/item/fish/skin_crab
	name = "skin crab"
	desc = "<i>\"And on the eighth day, a demential mockery of both humanity and crabity was made.\"<i> Fascinating."
	icon_state = "skin_crab"
	sprite_width = 7
	sprite_height = 6
	average_size = 40
	average_weight = 750
	stable_population = 5
	show_in_catalog = FALSE
	beauty = FISH_BEAUTY_GREAT
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = JUNKFOOD|FRIED
		),
	)
	fillet_type = /obj/item/food/meat/slab/rawcrab
	random_case_rarity = FISH_RARITY_NOPE

