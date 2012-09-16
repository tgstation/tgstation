/* Parrots!
 * Contains
 * 		Defines
 *		Inventory (headset stuff)
 *		Attack responces
 *		AI
 *		Procs / Verbs (usable by players)
 *		Sub-types
 */

//TODO List:
// Make parrots faster (But not retardedly fast like when using byond's walk() procs)
// See if its possible for parrots to target a human's eyes (peck their eyes out)

/*
 * Defines
 */

//Only a maximum of one action and one intent should be active at any given time.
//Actions
#define PARROT_PERCH 1		//Sitting/sleeping, not moving
#define PARROT_SWOOP 2		//Moving towards or away from a target
#define PARROT_WANDER 4		//Moving without a specific target in mind

//Intents
#define PARROT_STEAL 8		//Flying towards a target to steal it/from it
#define PARROT_ATTACK 16	//Flying towards a target to attack it
#define PARROT_RETURN 32	//Flying towards its perch
#define PARROT_FLEE 64		//Flying away from its attacker


/mob/living/simple_animal/parrot
	name = "\improper Parrot"
	desc = "The parrot squacks, \"It's a Parrot! BAWWK!\""
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_sit "
	pass_flags = PASSTABLE

	speak = list("Hi","Hello!","Cracker?","BAWWWWK george mellons griffing me")
	speak_emote = list("squawks","says","yells")
	emote_hear = list("squawks","bawks")
	emote_see = list("flutters its wings")

	speak_chance = 8//4% (1 in 25) chance every tick
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/cracker/

	response_help  = "pets the"
	response_disarm = "gently moves aside the"
	response_harm   = "swats the"
	stop_automated_movement = 1


	var/parrot_state = PARROT_WANDER //Hunt for a perch when created
	var/parrot_sleep_max = 25 //The time the parrot sits while perched before looking around. Mosly a way to avoid the parrot's AI in life() being run every single tick.
	var/parrot_sleep_dur = 25 //Same as above, this is the var that physically counts down
	var/parrot_dam_zone = list("chest", "head", "l_arm", "l_leg", "r_arm", "r_leg") //For humans, select a bodypart to attack

	var/list/speech_buffer = list()

	//Headset for Poly to yell at engineers :)
	var/obj/item/device/radio/headset/ears = null

	//The thing the parrot is currently interested in. This gets used for items the parrot wants to pick up, mobs it wants to steal from,
	//mobs it wants to attack or mobs that have attacked it
	var/atom/movable/parrot_interest = null

	//Parrots will generally sit on their pertch unless something catches their eye.
	//These vars store their preffered perch and if they dont have one, what they can use as a perch
	var/obj/parrot_perch = null
	var/obj/desired_perches = list(/obj/structure/computerframe, 	/obj/structure/displaycase, \
									/obj/structure/closet, 			/obj/structure/filingcabinet, \
									/obj/machinery/computer,		/obj/machinery/clonepod, \
									/obj/machinery/dna_scanner,		/obj/machinery/dna_scannernew, \
									/obj/machinery/nuclearbomb,		/obj/machinery/particle_accelerator, \
									/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
									/obj/machinery/suit_storage_unit,	/obj/machinery/telecomms, \
									/obj/machinery/teleport)

	//Parrots are kleptomaniacs. These vars a used for just that.. holding items and storing a list of items the parrot wants to steal.
	var/obj/item/held_item = null
	var/list/desired_items = list(/obj/item/weapon/reagent_containers/food/snacks/cracker/, \
									/obj/item/smallDelivery, 	/obj/item/weapon/gift, \
									/obj/item/weapon/soap, 		/obj/item/toy, \
									/obj/item/weapon/coin,		/obj/item/weapon/stamp, \
									/obj/item/weapon/grenade,	/obj/item/device/radio/headset, \
									/obj/item/device/flash,		/obj/item/device/soulstone, \
									/obj/item/device/assembly,	/obj/item/weapon/bananapeel, \
									/obj/item/weapon/book,		/obj/item/weapon/caution, \
									/obj/item/weapon/cigpacket,	/obj/item/weapon/handcuffs,\
									/obj/item/weapon/pen,		/obj/item/weapon/pinpointer)


/mob/living/simple_animal/parrot/New()
	usr << "\red Parrots are still a work in progress, use at your own risk."
	..()
	parrot_sleep_dur = parrot_sleep_max //In case someone decides to change the max without changing the duration var
	verbs.Add(/mob/living/simple_animal/parrot/proc/steal_from_ground, \
			  /mob/living/simple_animal/parrot/proc/steal_from_mob, \
			  /mob/living/simple_animal/parrot/proc/drop_held_item)

/mob/living/simple_animal/parrot/Die()
	if(held_item)
		held_item.loc = src.loc
		held_item = null
	..()

/*
 * Inventory
 */
/mob/living/simple_animal/parrot/show_inv(mob/user as mob)
	user.machine = src
	if(user.stat) return

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(ears)
		dat +=	"<br><b>Headset:</b> [ears] (<a href='?src=\ref[src];remove_inv=ears'>Remove</a>)"
	else
		dat +=	"<br><b>Headset:</b> <a href='?src=\ref[src];add_inv=ears'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[real_name]")
	return

/mob/living/simple_animal/parrot/Topic(href, href_list)

	//Can the usr physically do this?
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		return

	//Is the usr's mob type able to do this? (lolaliens)
	if(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr))

		//Removing from inventory
		if(href_list["remove_inv"])
			var/remove_from = href_list["remove_inv"]
			switch(remove_from)
				if("ears")
					if(ears)
						src.say(":e BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
						ears.loc = src.loc
						ears = null
					else
						usr << "\red There is nothing to remove from its [remove_from]."
						return

		//Adding things to inventory
		else if(href_list["add_inv"])
			var/add_to = href_list["add_inv"]
			if(!usr.get_active_hand())
				usr << "\red You have nothing in your hand to put on its [add_to]."
				return
			switch(add_to)
				if("ears")
					if(ears)
						usr << "\red It's already wearing something."
						return
					else
						var/obj/item/item_to_add = usr.get_active_hand()
						if(!item_to_add)
							return

						if( !istype(item_to_add,  /obj/item/device/radio/headset) )
							usr << "\red This object won't fit."
							return

						usr.drop_item()
						item_to_add.loc = src
						src.ears = item_to_add
						usr << "You fit the headset onto [src]."
		else
			..()

/*
 * Attack responces
 */
//Humans, monkeys, aliens
/mob/living/simple_animal/parrot/attack_hand(mob/living/carbon/M as mob)
	..()
	if(client) return
	if(!stat && M.a_intent == "hurt")

		icon_state = "parrot_fly" //It is going to be flying regardless of whether it flees or attacks

		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = M
		parrot_state = PARROT_SWOOP //The parrot just got hit, it WILL move, now to pick a direction..

		if(M.health < 50) //Weakened mob? Fight back!
			parrot_state |= PARROT_ATTACK
		else
			parrot_state |= PARROT_FLEE		//Otherwise, fly like a bat out of hell!
			drop_held_item(0)
	return

/mob/living/simple_animal/parrot/attack_paw(mob/living/carbon/monkey/M as mob)
	attack_hand(M)

/mob/living/simple_animal/parrot/attack_alien(mob/living/carbon/monkey/M as mob)
	attack_hand(M)

//Simple animals
/mob/living/simple_animal/parrot/attack_animal(mob/living/simple_animal/M as mob)
	if(client) return


	if(parrot_state == PARROT_PERCH)
		parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

	if(M.melee_damage_upper > 0)
		parrot_interest = M
		parrot_state = PARROT_SWOOP | PARROT_ATTACK //Attack other animals regardless
		icon_state = "parrot_fly"

//Mobs with objects
/mob/living/simple_animal/parrot/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if(!stat && !client && !istype(O, /obj/item/stack/medical))
		if(O.force)
			if(parrot_state == PARROT_PERCH)
				parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

			parrot_interest = user
			parrot_state = PARROT_SWOOP | PARROT_FLEE
			icon_state = "parrot_fly"
			drop_held_item(0)
	return

//Bullets
/mob/living/simple_animal/parrot/bullet_act(var/obj/item/projectile/Proj)
	..()
	if(!stat && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = null
		parrot_state = PARROT_WANDER //OWFUCK, Been shot! RUN LIKE HELL!
		icon_state = "parrot_fly"
		drop_held_item(0)
	return


/*
 * AI - Not really intelligent, but I'm calling it AI anyway.
 */
/mob/living/simple_animal/parrot/Life()
	..()

	if(client || stat)
		return //Lets not force players or dead/incap parrots to move

	if(!isturf(src.loc) || !canmove || buckled || pulledby)
		return //If it can't move, dont let it move. (The buckled check probably isn't necessary)

	//Parrot speech mimickry! Phrases that the parrot hears in mob/living/say() get added to speach_buffer.
	//Every once in a while, the parrot picks one of the lines from the buffer and replaces an element of the 'speech' list.
	//Then it clears the buffer to make sure they dont magically remember something from hours ago.
	if(speech_buffer.len && prob(10))
		if(speak.len)
			speak.Remove(pick(speak))

		speak.Add(pick(speech_buffer))
		clearlist(speech_buffer)


	//Alright, here we go... down the slope

//-----SLEEPING
	if(parrot_state == PARROT_PERCH)
		if(parrot_perch.loc != src.loc) //Make sure someone hasnt moved our perch on us
			if(parrot_perch in view(src))
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				icon_state = "parrot_fly"
				return
			else
				parrot_state = PARROT_WANDER
				icon_state = "parrot_fly"
				return

		if(--parrot_sleep_dur) //Zzz
			return

		else
			parrot_sleep_dur = parrot_sleep_max //This way we only call the loop below once every [sleep_max] ticks.
			parrot_interest = search_for_item()
			if(parrot_interest)
				emote("[src] looks in [parrot_interest]'s direction and takes flight.")
				parrot_state = PARROT_SWOOP | PARROT_STEAL
				icon_state = "parrot_fly"
			return

//-----WANDERING - This is basically a 'I dont know what to do yet' state
	else if(parrot_state == PARROT_WANDER)
		//Stop movement, we'll set it later
		walk(src, 0)
		parrot_interest = null

		//Wander around aimlessly. This will help keep the loops from searches down
		//and possibly move the mob into a new are in view of something they can use
		if(prob(90))
			step(src, pick(cardinal))
			return

		if(!held_item && !parrot_perch) //If we've got nothing to do.. look for something to do.
			var/atom/movable/AM = search_for_perch_and_item() //This handles checking through lists so we know it's either a perch or stealable item
			if(AM)
				if(istype(AM, /obj/item) || isliving(AM))	//If stealable item
					parrot_interest = AM
					emote("[src] turns and flies towards [parrot_interest].")
					parrot_state = PARROT_SWOOP | PARROT_STEAL
					return
				else	//Else it's a perch
					parrot_perch = AM
					parrot_state = PARROT_SWOOP | PARROT_RETURN
					return
			return

		if(parrot_interest && parrot_interest in view(src))
			parrot_state = PARROT_SWOOP | PARROT_STEAL
			return

		if(parrot_perch && parrot_perch in view(src))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		else //Have an item but no perch? Find one!
			parrot_perch = search_for_perch()
			if(parrot_perch)
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				return
//-----STEALING
	else if(parrot_state == (PARROT_SWOOP | PARROT_STEAL))
		walk(src,0)
		if(!parrot_interest || held_item)
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(!(parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(in_range(src, parrot_interest))
			if(isliving(parrot_interest))
				steal_from_mob()
			else
				steal_from_ground()

			parrot_interest = null
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		var/oldloc = src.loc
		step_towards(src, get_step_towards(src,parrot_interest))
		if(src.loc == oldloc) //Check if the mob is stuck
			parrot_state = PARROT_WANDER //and demonstrate your amazing obstical avoidance AI

		return

//-----RETURNING TO PERCH
	else if(parrot_state == (PARROT_SWOOP | PARROT_RETURN))
		walk(src, 0)
		if(!parrot_perch || !isturf(parrot_perch.loc)) //Make sure the perch exists and somehow isnt inside of something else.
			parrot_perch = null
			parrot_state = PARROT_WANDER
			return

		if(in_range(src, parrot_perch))
			src.loc = parrot_perch.loc
			drop_held_item()
			parrot_state = PARROT_PERCH
			icon_state = "parrot_sit"
			return

		var/oldloc = src.loc
		step_towards(src, get_step_towards(src,parrot_perch))
		if(src.loc == oldloc) //Check if the mob is stuck
			parrot_state = PARROT_WANDER //and demonstrate your amazing obstical avoidance AI
		return

//-----FLEEING
	else if(parrot_state == (PARROT_SWOOP | PARROT_FLEE))
		walk(src,0)
		if(!parrot_interest || !isliving(parrot_interest)) //Sanity
			parrot_state = PARROT_WANDER

		var/oldloc = src.loc
		step(src, get_step_away(src, parrot_interest))
		if(src.loc == oldloc) //Check if the mob is stuck
			parrot_state = PARROT_WANDER //and demonstrate your amazing obstical avoidance AI

//-----ATTACKING
	else if(parrot_state == (PARROT_SWOOP | PARROT_ATTACK))

		//If we're attacking a nothing, an object, a turf or a ghost for some stupid reason, switch to wander
		if(!parrot_interest || !isliving(parrot_interest))
			parrot_interest = null
			parrot_state = PARROT_WANDER
			return

		var/mob/living/L = parrot_interest

		//If the mob is close enough to interact with
		if(in_range(src, parrot_interest))

			//If the mob we've been chasing/attacking dies or falls into crit, check for loot!
			if(L.stat)
				parrot_interest = null
				if(!held_item)
					held_item = steal_from_ground()
					if(!held_item)
						held_item = steal_from_mob() //Apparently it's possible for dead mobs to hang onto items in certain circumstances.
				if(parrot_perch in view(src)) //If we have a home nearby, go to it, otherwise find a new home
					parrot_state = PARROT_SWOOP | PARROT_RETURN
				else
					parrot_state = PARROT_WANDER
				return

			//Time for the hurt to begin!
			var/damage = rand(5,10)

			if(ishuman(parrot_interest))
				var/mob/living/carbon/human/H = parrot_interest
				var/datum/organ/external/affecting = H.get_organ(ran_zone(pick(parrot_dam_zone)))

				H.apply_damage(damage, BRUTE, affecting, H.run_armor_check(affecting, "melee"))
				emote(pick("pecks [H]'s [affecting]", "cuts [H]'s [affecting] with its talons"))

			else
				L.adjustBruteLoss(damage)
				emote(pick("pecks at [L]", "claws [L]"))
			return

		//Otherwise, fly towards the mob!
		else
			var/oldloc = src.loc
			step_towards(src, get_step_towards(src,parrot_interest))
			if(src.loc == oldloc) //Check if the mob is stuck
				parrot_state = PARROT_WANDER //and demonstrate your amazing obstical avoidance AI

//-----STATE MISHAP
	else //This should not happen. If it does lets reset everything and try again
		walk(src,0)
		parrot_interest = null
		parrot_perch = null
		drop_held_item()
		parrot_state = PARROT_WANDER
		return

/*
 * Procs
 */

/mob/living/simple_animal/parrot/proc/search_for_item()
	for(var/atom/movable/AM in view(src))
		for(var/path in desired_items)
			if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src) //Skip items we already stole or are wearing
				continue

			if(istype(AM, path))
				return AM

			if(iscarbon(AM))
				var/mob/living/carbon/C = AM
				if(istype(C.l_hand, path) || istype(C.r_hand, path))
					return C
	return null

/mob/living/simple_animal/parrot/proc/search_for_perch()
	for(var/obj/O in view(src))
		for(var/path in desired_perches)
			if(istype(O, path))
				return O
	return null

//This proc was made to save on doing two 'in view' loops seperatly
/mob/living/simple_animal/parrot/proc/search_for_perch_and_item()
	for(var/atom/movable/AM in view(src))
		for(var/perch_path in desired_perches)
			if(istype(AM, perch_path))
				return AM

		for(var/item_path in desired_items)
			if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src) //Skip items we already stole or are wearing
				continue

			if(istype(AM, item_path))
				return AM

			if(iscarbon(AM))
				var/mob/living/carbon/C = AM
				if(istype(C.l_hand, item_path) || istype(C.r_hand, item_path))
					return AM
	return null


/*
 * Verbs - These are actually procs, but can be used as verbs by player-controlled parrots.
 */
/mob/living/simple_animal/parrot/proc/steal_from_ground()
	set name = "Steal from ground"
	set category = "Parrot"
	set desc = "Grabs a nearby item."

	if(stat)
		return -1

	if(held_item)
		usr << "\red You are already holding the [held_item]"
		return 1

	for(var/obj/item/I in view(1,src))
		for(var/path in desired_items)
			if(istype(I, path) && I.loc != src)
				held_item = I
				I.loc = src
				visible_message("[src] grabs the [held_item]!", "\blue You grab the [held_item]!", "You hear the sounds of wings flapping furiously.")
				return held_item

	usr << "\red There is nothing of interest to take."
	return 0

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	set name = "Steal from mob"
	set category = "Parrot"
	set desc = "Steals an item right out of a person's hand!"
	if(stat)
		return -1

	if(held_item)
		usr << "\red You are already holding the [held_item]"
		return 1

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1,src))
		for(var/path in desired_items)
			if(istype(C.l_hand, path))
				stolen_item = C.l_hand

			if(istype(C.r_hand, path))
				stolen_item = C.r_hand

			if(stolen_item)
				C.u_equip(stolen_item)
				held_item = stolen_item
				stolen_item.loc = src
				visible_message("[src] grabs the [held_item] out of [C]'s hand!", "\blue You snag the [held_item] out of [C]'s hand!", "You hear the sounds of wings flapping furiously.")
				return held_item

	usr << "\red There is nothing of interest to take."
	return 0

/mob/living/simple_animal/parrot/proc/drop_held_item(var/drop_gently = 1)
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return -1

	if(!held_item)
		usr << "\red You have nothing to drop!"
		return 0

	if(!drop_gently)
		if(istype(held_item, /obj/item/weapon/grenade))
			var/obj/item/weapon/grenade/G = held_item
			G.loc = get_turf(src)
			G.prime()
			held_item = null

	usr << "You drop the [held_item]."

	held_item.loc = src.loc
	held_item = null
	return 1

/*
 * Sub-types
 */
/mob/living/simple_animal/parrot/Poly
	name = "Poly"
	desc = "Poly the Parrot. An expert on quantum cracker theory."
	speak = list("Poly wanna cracker!", ":e Check the singlo, you chucklefucks!",":e Wire the solars, you lazy bums!",":e WHO TOOK THE DAMN HARDSUITS?",":e OH GOD ITS FREE CALL THE SHUTTLE")

/mob/living/simple_animal/parrot/Poly/New()
	ears = new /obj/item/device/radio/headset/headset_eng(src)
	..()
