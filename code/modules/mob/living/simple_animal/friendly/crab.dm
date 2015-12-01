//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "A hard-shelled crustacean. Seems quite content to lounge around all the time."
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 5
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement = 1
	friendly = "pinches"
	size = SIZE_TINY

	var/obj/item/inventory_head
	var/obj/item/inventory_mask

/mob/living/simple_animal/crab/Life()
	if(timestopped) return 0 //under effects of time magick
	..()
	//CRAB movement
	if(!ckey && !stat)
		if(isturf(src.loc) && !resting && !locked_to)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(4,8)))
				turns_since_move = 0
	regenerate_icons()

//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"

//LOOK AT THIS - ..()??
/mob/living/simple_animal/crab/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/wirecutters))
		if(prob(50))
			to_chat(user, "<span class='danger'>This kills the crab.</span>")
			health -= 20
			Die()
		else
			GetMad()
	else
		return ..()

/mob/living/simple_animal/crab/proc/GetMad()
	name = "MEGAMADCRAB"
	real_name = "MEGAMADCRAB"
	desc = "OH NO YOU DUN IT NOW."
	icon = 'icons/mob/mob.dmi'
	icon_state = "madcrab"
	icon_living = "madcrab"
	icon_dead = "madcrab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks with fury", "clicks angrily")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 15//Gotta go fast
	maxHealth = 100//So they don't die as quickly
	health = 100
	melee_damage_lower = 3
	melee_damage_upper = 10//Kill them. Kill them all
	if(inventory_head)//Drops inventory so it doesn't have to be dealt with
		inventory_head.loc = src.loc
		inventory_head = null
	if(inventory_mask)
		inventory_mask.loc = src.loc
		inventory_mask = null

/mob/living/simple_animal/crab/kickstool
	name = "kickstool crab"
	desc = "Small, docile crab. They tend to live in large libraries, and eat dust for some reason."
	icon_state = "kickstool"
	icon_living = "kickstool"
	icon_dead = "kickstool_dead"

/mob/living/simple_animal/crab/norris
	name = "Norris"
	desc = "Some weird Thing that makes a neat pet. Screams a lot."
	icon_state = "norris"
	icon_living = "norris"
	icon_dead = "norris_dead"
	speak_emote = list("screams")
	emote_hear = list("screams")
	emote_see = list("screams")
	friendly = "bites"