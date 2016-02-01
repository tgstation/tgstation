/mob/living/simple_animal/farm/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")

	//Space carp aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	pressure_resistance = 200
	gold_core_spawnable = 1

	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/carp
	mob_birth_type = /mob/living/simple_animal/farm/carp
	default_breeding_trait = /datum/farm_animal_trait/carnivore
	default_food_trait = /datum/farm_animal_trait/egg_layer
	default_retaliate_trait = /datum/farm_animal_trait/defensive
	default_traits = list(/datum/farm_animal_trait/fast, /datum/farm_animal_trait/aggressive/hyper, /datum/farm_animal_trait/weakening_strikes)

/mob/living/simple_animal/farm/carp/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/farm/carp/megacarp
	icon = 'icons/mob/alienqueen.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	default_traits = list(/datum/farm_animal_trait/fast, /datum/farm_animal_trait/aggressive/hyper, /datum/farm_animal_trait/weakening_strikes, /datum/farm_animal_trait/strong)


/mob/living/simple_animal/farm/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	maxbodytemp = INFINITY
	gold_core_spawnable = 0
	del_on_death = 1

/mob/living/simple_animal/farm/carp/cayenne
	name = "Cayenne"
	desc = "A failed Syndicate experiment in weaponized space carp technology, it now serves as a lovable mascot."
	speak_emote = list("squeaks")
	gold_core_spawnable = 0
	faction = list("syndicate")