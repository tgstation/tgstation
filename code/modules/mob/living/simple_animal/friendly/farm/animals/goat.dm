/mob/living/simple_animal/farm/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays.")
	emote_see = list("shakes its head.", "stamps a foot.", "glares around.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 4)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/goat
	mob_birth_type = /mob/living/simple_animal/farm/goat
	default_breeding_trait = /datum/farm_animal_trait/herbivore
	default_food_trait = /datum/farm_animal_trait/mammal
	default_retaliate_trait = /datum/farm_animal_trait/defensive
	default_traits = list(/datum/farm_animal_trait/udders, /datum/farm_animal_trait/aggressive, /datum/farm_animal_trait/vine_eating)
