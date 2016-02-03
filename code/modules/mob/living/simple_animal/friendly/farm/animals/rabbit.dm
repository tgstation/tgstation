/mob/living/simple_animal/farm/rabbit
	name = "\improper rabbit"
	desc = "The hippiest hop around."
	icon = 'icons/mob/Easter.dmi'
	icon_state = "rabbit"
	icon_living = "rabbit"
	icon_dead = "rabbit_dead"
	speak = list("Hop into Easter!","Come get your eggs!","Prizes for everyone!")
	speak_emote = list("sniffles","twitches")
	emote_hear = list("hops.")
	emote_see = list("hops around","bounces up and down")
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 1)
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/loaded
	mob_birth_type = /mob/living/simple_animal/farm/rabbit
	default_breeding_trait = /datum/farm_animal_trait/herbivore
	default_food_trait = /datum/farm_animal_trait/egg_layer

/mob/living/simple_animal/farm/rabbit/space
	icon_state = "s_rabbit"
	icon_living = "s_rabbit"
	icon_dead = "s_rabbit_dead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0	//This damage is taken when atmos doesn't fit all the requirements above
