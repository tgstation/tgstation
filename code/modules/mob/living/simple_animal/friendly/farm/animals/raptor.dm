/mob/living/simple_animal/farm/raptor
	name = "\improper raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptoryellow"
	icon_living = "raptoryellow"
	icon_dead = "raptoryellow"
	speak = list("WARK!","KWEH!")
	speak_emote = list("clucks","croons")
	emote_hear = list("warks.", "kwehs.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = 1
	speak_chance = 2
	turns_per_move = 3
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "pecks at"
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = 2
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/random
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/yellow
	default_breeding_trait = null
	default_food_trait = null
	can_buckle = 1
	buckle_lying = 0
	default_traits = list(/datum/farm_animal_trait/ridable)

/mob/living/simple_animal/farm/raptor/yellow
	name = "\improper yellow raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptoryellow"
	icon_living = "raptoryellow"
	icon_dead = "raptoryellow"
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/yellow
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/yellow
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = null


/mob/living/simple_animal/farm/raptor/green
	name = "\improper green raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago. This raptor is suited to eating vegetarian foods."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptorgreen"
	icon_living = "raptorgreen"
	icon_dead = "raptorgreen"
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/green
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/green
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/herbivore

/mob/living/simple_animal/farm/raptor/red
	name = "\improper red raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago. This raptor is suited to eating meaty foods."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptorred"
	icon_living = "raptorred"
	icon_dead = "raptorred"
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/red
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/red
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/carnivore

/*

	BABY RAPTORS

*/

/mob/living/simple_animal/farm/raptor_chick
	name = "\improper raptor chick"
	desc = "Adorable! They make such a racket though."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("WARK!","KWEH!")
	speak_emote = list("clucks","croons")
	emote_hear = list("warks.", "kwehs.")
	emote_see = list("pecks at the ground.","flaps its tiny wings.")
	density = 0
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "pecks"
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = 2
	adult_version = /mob/living/simple_animal/farm/raptor/yellow
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/herbivore


/mob/living/simple_animal/farm/raptor_chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)


/mob/living/simple_animal/farm/raptor_chick/yellow
	name = "\improper yellow baby raptor"
	icon_state = "babyellow"
	icon_living = "babyellow"
	icon_dead = "babyellow"
	icon_gib = "babyellow"
	adult_version = /mob/living/simple_animal/farm/raptor/yellow
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = null

/mob/living/simple_animal/farm/raptor_chick/red
	name = "\improper red baby raptor"
	icon_state = "babyred"
	icon_living = "babyred"
	icon_dead = "babyred"
	icon_gib = "babyred"
	adult_version = /mob/living/simple_animal/farm/raptor/red
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/carnivore

/mob/living/simple_animal/farm/raptor_chick/green
	name = "\improper green baby raptor"
	icon_state = "babygreen"
	icon_living = "babygreen"
	icon_dead = "babygreen"
	icon_gib = "babygreen"
	adult_version = /mob/living/simple_animal/farm/raptor/green
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/herbivore