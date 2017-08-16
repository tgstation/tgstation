//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "Free crabs!"
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks.")
	emote_see = list("clacks.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement = 1
	friendly = "pinches"
	ventcrawler = VENTCRAWLER_ALWAYS
	var/obj/item/inventory_head
	var/obj/item/inventory_mask
	gold_core_spawnable = 2

/mob/living/simple_animal/crab/Life()
	..()
	//CRAB movement
	if(!ckey && !stat)
		if(isturf(src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				var/east_vs_west = pick(4,8)
				if(Process_Spacemove(east_vs_west))
					Move(get_step(src,east_vs_west), east_vs_west)
					turns_since_move = 0
	regenerate_icons()

//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	gender = FEMALE
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	gold_core_spawnable = 0