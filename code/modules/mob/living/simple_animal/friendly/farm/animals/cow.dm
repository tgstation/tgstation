/mob/living/simple_animal/farm/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays.")
	emote_see = list("shakes its head.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 6)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	gold_core_spawnable = 2
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/cow
	mob_birth_type = /mob/living/simple_animal/farm/cow
	default_breeding_trait = /datum/farm_animal_trait/herbivore
	default_food_trait = /datum/farm_animal_trait/mammal
	default_retaliate_trait = /datum/farm_animal_trait/coward
	default_traits = list(/datum/farm_animal_trait/udders)

/mob/living/simple_animal/farm/cow/attack_hand(mob/living/carbon/M) // this existed apparently
	if(!stat && M.a_intent == "disarm" && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>","<span class='notice'>You tip over [src].</span>")
		Weaken(30)
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				var/list/responses = list(	"[src] looks at you imploringly.",
											"[src] looks at you pleadingly",
											"[src] looks at you with a resigned expression.",
											"[src] seems resigned to its fate.")
				M << pick(responses)
	else
		..()