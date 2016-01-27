/mob/living/simple_animal/farm/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken_white"
	icon_living = "chicken_white"
	icon_dead = "chicken_white_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = 0
	speak_chance = 2
	turns_per_move = 3
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "pecks at"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = 2
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	mob_birth_type = /mob/living/simple_animal/farm/chick
	default_breeding_trait = /datum/farm_animal_trait/herbivore
	default_food_trait = /datum/farm_animal_trait/egg_layer



/mob/living/simple_animal/farm/chicken/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/farm/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps.")
	emote_see = list("pecks at the ground.","flaps its tiny wings.")
	density = 0
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 1
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = 2
	adult_version = /mob/living/simple_animal/farm/chicken
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	mob_birth_type = /mob/living/simple_animal/farm/chick
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/herbivore

/mob/living/simple_animal/farm/chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)