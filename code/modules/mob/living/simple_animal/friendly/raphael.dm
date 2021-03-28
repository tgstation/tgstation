/mob/living/simple_animal/pet/raphael
	name = "Raphael"
	desc = "And to think you wanted to kill him 2 times, in this timeloop you have become my friend.. I love you Raphael"
	icon = 'icons/mob/pets.dmi'
	icon_state = "raphael"
	icon_living = "raphael"
	icon_dead = "raphael_dead"
	health = 30
	maxHealth = 30
	armour_penetration = 0
	melee_damage_lower = 0
	melee_damage_upper = 5
	weather_immunities = list("lava","ash")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = TCMB
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_SMALL
	deathmessage = "seizes and curls up, lifeless..."
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/xeno = 2)
	faction = list("neutral","silicon","turret","sabbatziege")
	can_be_held = TRUE
	held_state = "raphael"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	pet_bonus = TRUE
	pet_bonus_emote = "screeches!"
	speak = list("eugh!", "hhgh!", "eeggrh", "hh")
	speak_emote = list("bubbles", "pops")
	emote_hear = list("sizzles.", "bubbles.")
	emote_see = list("shudders.", "shivers.")
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	///Limits how often raph can spam chasing mice.
	var/emote_cooldown = 0
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6

/mob/living/simple_animal/pet/raphael/attackby(obj/item/O, mob/user) //its either i made a list of every single fucking food item or i made him work like a christmas tree
	if(istype(O, /obj/item/reagent_containers/food/snacks/deadmouse))
		to_chat(user, "<span class='notice'>[name] devours the offering and has given you something in return! Thank the LORD!</span>")
		qdel(O)
		var/given_food = pick(subtypesof(/obj/item/reagent_containers/food))
		new given_food(loc)
		return 1
	else
		return ..()

/mob/living/simple_animal/pet/raphael/Life()
	if((src.loc) && isturf(src.loc))
		if(!stat && !resting && !buckled)
			for(var/mob/living/simple_animal/mouse/M in view(1,src))
				if(!M.stat && Adjacent(M))
					manual_emote("chomps \the [M]!")
					M.splat()
					movement_target = null
					stop_automated_movement = 0
					break
	..()
	if(!stat && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)