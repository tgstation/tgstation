/* Parrots!
 * Contains
 * 		Defines
 *		Inventory (headset stuff)
 *		Attack responces
 *		AI
 *		Procs / Verbs (usable by players)
 *		Sub-types
 *		Hear & say (the things we do for gimmicks)
 */

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
	name = "parrot"
	desc = "The parrot squaks, \"It's a Parrot! BAWWK!\"" //'
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	density = FALSE
	health = 80
	maxHealth = 80
	pass_flags = PASSTABLE | PASSMOB

	speak = list("Hi!","Hello!","Cracker?","BAWWWWK george mellons griffing me!")
	speak_emote = list("squawks","says","yells")
	emote_hear = list("squawks.","bawks!")
	emote_see = list("flutters its wings.")

	speak_chance = 1 //1% (1 in 100) chance every tick; So about once per 150 seconds, assuming an average tick is 1.5s
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/cracker/ = 1)
	melee_damage_upper = 10
	melee_damage_lower = 5

	response_help  = "pets"
	response_disarm = "gently moves aside"
	response_harm   = "swats"
	stop_automated_movement = 1
	a_intent = INTENT_HARM //parrots now start "aggressive" since only player parrots will nuzzle.
	attacktext = "chomps"
	friendly = "grooms"
	mob_size = MOB_SIZE_SMALL
	movement_type = FLYING
	gold_core_spawnable = 2

	var/parrot_damage_upper = 10
	var/parrot_state = PARROT_WANDER //Hunt for a perch when created
	var/parrot_sleep_max = 25 //The time the parrot sits while perched before looking around. Mosly a way to avoid the parrot's AI in life() being run every single tick.
	var/parrot_sleep_dur = 25 //Same as above, this is the var that physically counts down
	var/parrot_dam_zone = list("chest", "head", "l_arm", "l_leg", "r_arm", "r_leg") //For humans, select a bodypart to attack

	var/parrot_speed = 5 //"Delay in world ticks between movement." according to byond. Yeah, that's BS but it does directly affect movement. Higher number = slower.
	//var/parrot_been_shot = 0 this wasn't working right, and parrots don't survive bullets.((Parrots get a speed bonus after being shot. This will deincrement every Life() and at 0 the parrot will return to regular speed.))

	var/parrot_lastmove = null //Updates/Stores position of the parrot while it's moving
	var/parrot_stuck = 0	//If parrot_lastmove hasnt changed, this will increment until it reaches parrot_stuck_threshold
	var/parrot_stuck_threshold = 10 //if this == parrot_stuck, it'll force the parrot back to wandering

	var/list/speech_buffer = list()
	var/speech_shuffle_rate = 20
	var/list/available_channels = list()

	//Headset for Poly to yell at engineers :)
	var/obj/item/device/radio/headset/ears = null

	//The thing the parrot is currently interested in. This gets used for items the parrot wants to pick up, mobs it wants to steal from,
	//mobs it wants to attack or mobs that have attacked it
	var/atom/movable/parrot_interest = null

	//Parrots will generally sit on their perch unless something catches their eye.
	//These vars store their preffered perch and if they dont have one, what they can use as a perch
	var/obj/parrot_perch = null
	var/obj/desired_perches = list(/obj/structure/frame/computer, 		/obj/structure/displaycase, \
									/obj/structure/filingcabinet,		/obj/machinery/teleport, \
									/obj/machinery/computer,			/obj/machinery/clonepod, \
									/obj/machinery/dna_scannernew,		/obj/machinery/telecomms, \
									/obj/machinery/nuclearbomb,			/obj/machinery/particle_accelerator, \
									/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
									/obj/machinery/suit_storage_unit)

	//Parrots are kleptomaniacs. This variable ... stores the item a parrot is holding.
	var/obj/item/held_item = null


/mob/living/simple_animal/parrot/Initialize()
	. = ..()
	if(!ears)
		var/headset = pick(/obj/item/device/radio/headset/headset_sec, \
						/obj/item/device/radio/headset/headset_eng, \
						/obj/item/device/radio/headset/headset_med, \
						/obj/item/device/radio/headset/headset_sci, \
						/obj/item/device/radio/headset/headset_cargo)
		ears = new headset(src)

	parrot_sleep_dur = parrot_sleep_max //In case someone decides to change the max without changing the duration var

	verbs.Add(/mob/living/simple_animal/parrot/proc/steal_from_ground, \
			  /mob/living/simple_animal/parrot/proc/steal_from_mob, \
			  /mob/living/simple_animal/parrot/verb/drop_held_item_player, \
			  /mob/living/simple_animal/parrot/proc/perch_player, \
			  /mob/living/simple_animal/parrot/proc/toggle_mode,
			  /mob/living/simple_animal/parrot/proc/perch_mob_player)


/mob/living/simple_animal/parrot/examine(mob/user)
	..()
	if(stat)
		to_chat(user, pick("This parrot is no more", "This is a late parrot", "This is an ex-parrot"))

/mob/living/simple_animal/parrot/death(gibbed)
	if(held_item)
		held_item.loc = src.loc
		held_item = null
	walk(src,0)

	if(buckled)
		buckled.unbuckle_mob(src,force=1)
	buckled = null
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

	..(gibbed)

/mob/living/simple_animal/parrot/Stat()
	..()
	if(statpanel("Status"))
		stat("Held Item", held_item)
		stat("Mode",a_intent)

/mob/living/simple_animal/parrot/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	if(speaker != src && prob(50)) //Dont imitate ourselves
		if(!radio_freq || prob(10))
			if(speech_buffer.len >= 500)
				speech_buffer -= pick(speech_buffer)
			speech_buffer |= html_decode(raw_message)
	if(speaker == src && !client) //If a parrot squawks in the woods and no one is around to hear it, does it make a sound? This code says yes!
		return message
	..()

/mob/living/simple_animal/parrot/radio(message, message_mode, list/spans, language) //literally copied from human/radio(), but there's no other way to do this. at least it's better than it used to be.
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if (ears)
				ears.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if (ears)
				ears.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	if(message_mode in GLOB.radiochannels)
		if(ears)
			ears.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	return 0

/*
 * Inventory
 */
/mob/living/simple_animal/parrot/show_inv(mob/user)
	user.set_machine(src)
	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(ears)
		dat +=	"<br><b>Headset:</b> [ears] (<a href='?src=\ref[src];remove_inv=ears'>Remove</a>)"
	else
		dat +=	"<br><b>Headset:</b> <a href='?src=\ref[src];add_inv=ears'>Nothing</a>"

	user << browse(dat, "window=mob[real_name];size=325x500")
	onclose(user, "mob[real_name]")


/mob/living/simple_animal/parrot/Topic(href, href_list)

	//Can the usr physically do this?
	if(usr.incapacitated() || !usr.Adjacent(loc))
		return

	//Is the usr's mob type able to do this? (lolaliens)
	if(ishuman(usr) || ismonkey(usr) || iscyborg(usr) ||  isalienadult(usr))

		//Removing from inventory
		if(href_list["remove_inv"])
			var/remove_from = href_list["remove_inv"]
			switch(remove_from)
				if("ears")
					if(ears)
						if(!stat)
							if(available_channels.len)
								src.say("[pick(available_channels)] BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
							else
								src.say("BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
						ears.loc = src.loc
						ears = null
						for(var/possible_phrase in speak)
							if(copytext(possible_phrase,1,3) in GLOB.department_radio_keys)
								possible_phrase = copytext(possible_phrase,3)
					else
						to_chat(usr, "<span class='warning'>There is nothing to remove from its [remove_from]!</span>")
						return

		//Adding things to inventory
		else if(href_list["add_inv"])
			var/add_to = href_list["add_inv"]
			if(!usr.get_active_held_item())
				to_chat(usr, "<span class='warning'>You have nothing in your hand to put on its [add_to]!</span>")
				return
			switch(add_to)
				if("ears")
					if(ears)
						to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
						return
					else
						var/obj/item/item_to_add = usr.get_active_held_item()
						if(!item_to_add)
							return

						if( !istype(item_to_add,  /obj/item/device/radio/headset) )
							to_chat(usr, "<span class='warning'>This object won't fit!</span>")
							return

						var/obj/item/device/radio/headset/headset_to_add = item_to_add

						usr.drop_item()
						headset_to_add.loc = src
						src.ears = headset_to_add
						to_chat(usr, "<span class='notice'>You fit the headset onto [src].</span>")

						clearlist(available_channels)
						for(var/ch in headset_to_add.channels)
							switch(ch)
								if("Engineering")
									available_channels.Add(":e")
								if("Command")
									available_channels.Add(":c")
								if("Security")
									available_channels.Add(":s")
								if("Science")
									available_channels.Add(":n")
								if("Medical")
									available_channels.Add(":m")
								if("Supply")
									available_channels.Add(":u")
								if("Service")
									available_channels.Add(":v")

						if(headset_to_add.translate_binary)
							available_channels.Add(":b")
		else
			..()


/*
 * Attack responces
 */
//Humans, monkeys, aliens
/mob/living/simple_animal/parrot/attack_hand(mob/living/carbon/M)
	..()
	if(client)
		return
	if(!stat && M.a_intent == INTENT_HARM)

		icon_state = "parrot_fly" //It is going to be flying regardless of whether it flees or attacks

		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = M
		parrot_state = PARROT_SWOOP //The parrot just got hit, it WILL move, now to pick a direction..

		if(health > 30) //Let's get in there and squawk it up!
			parrot_state |= PARROT_ATTACK
		else
			parrot_state |= PARROT_FLEE		//Otherwise, fly like a bat out of hell!
			drop_held_item(0)
	if(stat != DEAD && M.a_intent == INTENT_HELP)
		handle_automated_speech(1) //assured speak/emote
	return

/mob/living/simple_animal/parrot/attack_paw(mob/living/carbon/monkey/M)
	attack_hand(M)

/mob/living/simple_animal/parrot/attack_alien(mob/living/carbon/alien/M)
	attack_hand(M)

//Simple animals
/mob/living/simple_animal/parrot/attack_animal(mob/living/simple_animal/M)
	. = ..() //goodbye immortal parrots

	if(client)
		return

	if(parrot_state == PARROT_PERCH)
		parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

	if(M.melee_damage_upper > 0 && !stat)
		parrot_interest = M
		parrot_state = PARROT_SWOOP | PARROT_ATTACK //Attack other animals regardless
		icon_state = "parrot_fly"

//Mobs with objects
/mob/living/simple_animal/parrot/attackby(obj/item/O, mob/living/user, params)
	if(!stat && !client && !istype(O, /obj/item/stack/medical) && !istype(O, /obj/item/reagent_containers/food/snacks/cracker))
		if(O.force)
			if(parrot_state == PARROT_PERCH)
				parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

			parrot_interest = user
			parrot_state = PARROT_SWOOP
			if(health > 30) //Let's get in there and squawk it up!
				parrot_state |= PARROT_ATTACK
			else
				parrot_state |= PARROT_FLEE
			icon_state = "parrot_fly"
			drop_held_item(0)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/cracker)) //Poly wants a cracker.
		qdel(O)
		user.drop_item()
		if(health < maxHealth)
			adjustBruteLoss(-10)
		speak_chance *= 1.27 // 20 crackers to go from 1% to 100%
		speech_shuffle_rate += 10
		to_chat(user, "<span class='notice'>[src] eagerly devours the cracker.</span>")
	..()
	return

//Bullets
/mob/living/simple_animal/parrot/bullet_act(obj/item/projectile/Proj)
	..()
	if(!stat && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = null
		parrot_state = PARROT_WANDER | PARROT_FLEE //Been shot and survived! RUN LIKE HELL!
		//parrot_been_shot += 5
		icon_state = "parrot_fly"
		drop_held_item(0)
	return


/*
 * AI - Not really intelligent, but I'm calling it AI anyway.
 */
/mob/living/simple_animal/parrot/Life()
	..()

	//Sprite update for when a parrot gets pulled
	if(pulledby && stat == CONSCIOUS)
		icon_state = "parrot_fly"
		if(!client)
			parrot_state = PARROT_WANDER
		return


//-----SPEECH
	/* Parrot speech mimickry!
	   Phrases that the parrot Hear()s get added to speach_buffer.
	   Every once in a while, the parrot picks one of the lines from the buffer and replaces an element of the 'speech' list. */
/mob/living/simple_animal/parrot/handle_automated_speech()
	..()
	if(speech_buffer.len && prob(speech_shuffle_rate)) //shuffle out a phrase and add in a new one
		if(speak.len)
			speak.Remove(pick(speak))

		speak.Add(pick(speech_buffer))


/mob/living/simple_animal/parrot/handle_automated_movement()
	if(!isturf(src.loc) || !canmove || buckled)
		return //If it can't move, dont let it move. (The buckled check probably isn't necessary thanks to canmove)


//-----SLEEPING
	if(parrot_state == PARROT_PERCH)
		if(parrot_perch && parrot_perch.loc != src.loc) //Make sure someone hasnt moved our perch on us
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
			//This way we only call the stuff below once every [sleep_max] ticks.
			parrot_sleep_dur = parrot_sleep_max

			//Cycle through message modes for the headset
			if(speak.len)
				var/list/newspeak = list()

				if(available_channels.len && src.ears)
					for(var/possible_phrase in speak)

						//50/50 chance to not use the radio at all
						var/useradio = 0
						if(prob(50))
							useradio = 1

						if((copytext(possible_phrase,1,2) in GLOB.department_radio_prefixes) && (copytext(possible_phrase,2,3) in GLOB.department_radio_keys))
							possible_phrase = "[useradio?pick(available_channels):""][copytext(possible_phrase,3)]" //crop out the channel prefix
						else
							possible_phrase = "[useradio?pick(available_channels):""][possible_phrase]"

						newspeak.Add(possible_phrase)

				else //If we have no headset or channels to use, dont try to use any!
					for(var/possible_phrase in speak)
						if((copytext(possible_phrase,1,2) in GLOB.department_radio_prefixes) && (copytext(possible_phrase,2,3) in GLOB.department_radio_keys))
							possible_phrase = copytext(possible_phrase,3) //crop out the channel prefix
						newspeak.Add(possible_phrase)
				speak = newspeak

			//Search for item to steal
			parrot_interest = search_for_item()
			if(parrot_interest)
				emote("me", 1, "looks in [parrot_interest]'s direction and takes flight.")
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
			step(src, pick(GLOB.cardinals))
			return

		if(!held_item && !parrot_perch) //If we've got nothing to do.. look for something to do.
			var/atom/movable/AM = search_for_perch_and_item() //This handles checking through lists so we know it's either a perch or stealable item
			if(AM)
				if(istype(AM, /obj/item) || isliving(AM))	//If stealable item
					parrot_interest = AM
					emote("me", 1, "turns and flies towards [parrot_interest].")
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

		if(Adjacent(parrot_interest))

			if(isliving(parrot_interest))
				steal_from_mob()

			else //This should ensure that we only grab the item we want, and make sure it's not already collected on our perch
				if(!parrot_perch || parrot_interest.loc != parrot_perch.loc)
					held_item = parrot_interest
					parrot_interest.loc = src
					visible_message("[src] grabs [held_item]!", "<span class='notice'>You grab [held_item]!</span>", "<span class='italics'>You hear the sounds of wings flapping furiously.</span>")

			parrot_interest = null
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		walk_to(src, parrot_interest, 1, parrot_speed)
		if(isStuck()) return

		return

//-----RETURNING TO PERCH
	else if(parrot_state == (PARROT_SWOOP | PARROT_RETURN))
		walk(src, 0)
		if(!parrot_perch || !isturf(parrot_perch.loc)) //Make sure the perch exists and somehow isnt inside of something else.
			parrot_perch = null
			parrot_state = PARROT_WANDER
			return

		if(Adjacent(parrot_perch))
			src.loc = parrot_perch.loc
			drop_held_item()
			parrot_state = PARROT_PERCH
			icon_state = "parrot_sit"
			return

		walk_to(src, parrot_perch, 1, parrot_speed)
		if(isStuck()) return

		return

//-----FLEEING
	else if(parrot_state == (PARROT_SWOOP | PARROT_FLEE))
		walk(src,0)
		if(!parrot_interest || !isliving(parrot_interest)) //Sanity
			parrot_state = PARROT_WANDER

		walk_away(src, parrot_interest, 1, parrot_speed)
		/*if(parrot_been_shot > 0)
			parrot_been_shot--  didn't work anyways, and besides, any bullet poly survives isn't worth the speed boost.*/
		if(isStuck()) return

		return

//-----ATTACKING
	else if(parrot_state == (PARROT_SWOOP | PARROT_ATTACK))

		//If we're attacking a nothing, an object, a turf or a ghost for some stupid reason, switch to wander
		if(!parrot_interest || !isliving(parrot_interest))
			parrot_interest = null
			parrot_state = PARROT_WANDER
			return

		var/mob/living/L = parrot_interest
		if(melee_damage_upper == 0)
			melee_damage_upper = parrot_damage_upper
			a_intent = INTENT_HARM

		//If the mob is close enough to interact with
		if(Adjacent(parrot_interest))

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

			attacktext = pick("claws at", "chomps")
			L.attack_animal(src)//Time for the hurt to begin!
		//Otherwise, fly towards the mob!
		else
			walk_to(src, parrot_interest, 1, parrot_speed)
			if(isStuck()) return

		return
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

/mob/living/simple_animal/parrot/movement_delay()
	if(client && stat == CONSCIOUS && parrot_state != "parrot_fly")
		icon_state = "parrot_fly"
		//Because the most appropriate place to set icon_state is movement_delay(), clearly
	return ..()

/mob/living/simple_animal/parrot/proc/isStuck()
	//Check to see if the parrot is stuck due to things like windows or doors or windowdoors
	if(parrot_lastmove)
		if(parrot_lastmove == src.loc)
			if(parrot_stuck_threshold >= ++parrot_stuck) //If it has been stuck for a while, go back to wander.
				parrot_state = PARROT_WANDER
				parrot_stuck = 0
				parrot_lastmove = null
				return 1
		else
			parrot_lastmove = null
	else
		parrot_lastmove = src.loc
	return 0

/mob/living/simple_animal/parrot/proc/search_for_item()
	var/item
	for(var/atom/movable/AM in view(src))
		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue
		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class < WEIGHT_CLASS_SMALL)
				item = I
		else if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			for(var/obj/item/I in C.held_items)
				if(I.w_class <= WEIGHT_CLASS_SMALL)
					item = I
					break
		if(item)
			if(!AStar(src, get_turf(item), /turf/proc/Distance_cardinal))
				item = null
				continue
			return item

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

		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class <= WEIGHT_CLASS_SMALL)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			for(var/obj/item/I in C.held_items)
				if(I.w_class <= WEIGHT_CLASS_SMALL)
					return C
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
		to_chat(src, "<span class='warning'>You are already holding [held_item]!</span>")
		return 1

	for(var/obj/item/I in view(1,src))
		//Make sure we're not already holding it and it's small enough
		if(I.loc != src && I.w_class <= WEIGHT_CLASS_SMALL)

			//If we have a perch and the item is sitting on it, continue
			if(!client && parrot_perch && I.loc == parrot_perch.loc)
				continue

			held_item = I
			I.loc = src
			visible_message("[src] grabs [held_item]!", "<span class='notice'>You grab [held_item]!</span>", "<span class='italics'>You hear the sounds of wings flapping furiously.</span>")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take!</span>")
	return 0

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	set name = "Steal from mob"
	set category = "Parrot"
	set desc = "Steals an item right out of a person's hand!"

	if(stat)
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]!</span>")
		return 1

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1,src))
		for(var/obj/item/I in C.held_items)
			if(I.w_class <= WEIGHT_CLASS_SMALL)
				stolen_item = I
				break

		if(stolen_item)
			C.transferItemToLoc(stolen_item, src, TRUE)
			held_item = stolen_item
			visible_message("[src] grabs [held_item] out of [C]'s hand!", "<span class='notice'>You snag [held_item] out of [C]'s hand!</span>", "<span class='italics'>You hear the sounds of wings flapping furiously.</span>")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take!</spawn>")
	return 0

/mob/living/simple_animal/parrot/verb/drop_held_item_player()
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	src.drop_held_item()

	return

/mob/living/simple_animal/parrot/proc/drop_held_item(drop_gently = 1)
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return -1

	if(!held_item)
		if(src == usr) //So that other mobs wont make this message appear when they're bludgeoning you.
			to_chat(src, "<span class='danger'>You have nothing to drop!</span>")
		return 0


//parrots will eat crackers instead of dropping them
	if(istype(held_item, /obj/item/reagent_containers/food/snacks/cracker) && (drop_gently))
		qdel(held_item)
		held_item = null
		if(health < maxHealth)
			adjustBruteLoss(-10)
		emote("me", 1, "[src] eagerly downs the cracker.")
		return 1


	if(!drop_gently)
		if(istype(held_item, /obj/item/grenade))
			var/obj/item/grenade/G = held_item
			G.loc = src.loc
			G.prime()
			to_chat(src, "You let go of [held_item]!")
			held_item = null
			return 1

	to_chat(src, "You drop [held_item].")

	held_item.loc = src.loc
	held_item = null
	return 1

/mob/living/simple_animal/parrot/proc/perch_player()
	set name = "Sit"
	set category = "Parrot"
	set desc = "Sit on a nice comfy perch."

	if(stat || !client)
		return

	if(icon_state == "parrot_fly")
		for(var/atom/movable/AM in view(src,1))
			for(var/perch_path in desired_perches)
				if(istype(AM, perch_path))
					src.loc = AM.loc
					icon_state = "parrot_sit"
					return
	to_chat(src, "<span class='warning'>There is no perch nearby to sit on!</span>")
	return


/mob/living/simple_animal/parrot/proc/perch_mob_player()
	set name = "Sit on Human's Shoulder"
	set category = "Parrot"
	set desc = "Sit on a nice comfy human being!"

	if(stat || !client)
		return

	if(icon_state == "parrot_fly")
		for(var/mob/living/carbon/human/H in view(src,1))
			if(H.has_buckled_mobs() && H.buckled_mobs.len >= H.max_buckled_mobs) //Already has a parrot, or is being eaten by a slime
				continue
			perch_on_human(H)
			return
		to_chat(src, "<span class='warning'>There is nobody nearby that you can sit on!</span>")
	else
		icon_state = "parrot_fly"
		parrot_state = PARROT_WANDER
		if(buckled)
			to_chat(src, "<span class='notice'>You are no longer sitting on [buckled]'s shoulder.</span>")
			buckled.unbuckle_mob(src,force=1)
		buckled = null
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)



/mob/living/simple_animal/parrot/proc/perch_on_human(mob/living/carbon/human/H)
	if(!H)
		return
	loc = get_turf(H)
	H.buckle_mob(src, force=1)
	pixel_y = 9
	pixel_x = pick(-8,8) //pick left or right shoulder
	icon_state = "parrot_sit"
	parrot_state = PARROT_PERCH
	to_chat(src, "<span class='notice'>You sit on [H]'s shoulder.</span>")


/mob/living/simple_animal/parrot/proc/toggle_mode()
	set name = "Toggle mode"
	set category = "Parrot"
	set desc = "Time to bear those claws!"

	if(stat || !client)
		return

	if(melee_damage_upper)
		melee_damage_upper = 0
		a_intent = INTENT_HELP
	else
		melee_damage_upper = parrot_damage_upper
		a_intent = INTENT_HARM
	to_chat(src, "You will now [a_intent] others...")
	return

/*
 * Sub-types
 */
/mob/living/simple_animal/parrot/Poly
	name = "Poly"
	desc = "Poly the Parrot. An expert on quantum cracker theory."
	speak = list("Poly wanna cracker!", ":e Check the crystal, you chucklefucks!",":e Wire the solars, you lazy bums!",":e WHO TOOK THE DAMN HARDSUITS?",":e OH GOD ITS ABOUT TO DELAMINATE CALL THE SHUTTLE")
	gold_core_spawnable = 0
	speak_chance = 3
	var/memory_saved = 0
	var/rounds_survived = 0
	var/longest_survival = 0
	var/longest_deathstreak = 0

/mob/living/simple_animal/parrot/Poly/Initialize()
	ears = new /obj/item/device/radio/headset/headset_eng(src)
	available_channels = list(":e")
	Read_Memory()
	if(rounds_survived == longest_survival)
		speak += pick("...[longest_survival].", "The things I've seen!", "I have lived many lives!", "What are you before me?")
		desc += " Old as sin, and just as loud. Claimed to be [rounds_survived]."
		speak_chance = 20 //His hubris has made him more annoying/easier to justify killing
		add_atom_colour("#EEEE22", FIXED_COLOUR_PRIORITY)
	else if(rounds_survived == longest_deathstreak)
		speak += pick("What are you waiting for!", "Violence breeds violence!", "Blood! Blood!", "Strike me down if you dare!")
		desc += " The squawks of [-rounds_survived] dead parrots ring out in your ears..."
		add_atom_colour("#BB7777", FIXED_COLOUR_PRIORITY)
	else if(rounds_survived > 0)
		speak += pick("...again?", "No, It was over!", "Let me out!", "It never ends!")
		desc += " Over [rounds_survived] shifts without a \"terrible\" \"accident\"!"
	else
		speak += pick("...alive?", "This isn't parrot heaven!", "I live, I die, I live again!", "The void fades!")

	..()

/mob/living/simple_animal/parrot/Poly/Life()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		rounds_survived = max(++rounds_survived,1)
		if(rounds_survived > longest_survival)
			longest_survival = rounds_survived
		Write_Memory()
	..()

/mob/living/simple_animal/parrot/Poly/death(gibbed)
	if(!memory_saved)
		var/go_ghost = 0
		if(rounds_survived == longest_survival || rounds_survived == longest_deathstreak || prob(0.666))
			go_ghost = 1
		rounds_survived = min(--rounds_survived,0)
		if(rounds_survived < longest_deathstreak)
			longest_deathstreak = rounds_survived
		Write_Memory()
		if(go_ghost)
			var/mob/living/simple_animal/parrot/Poly/ghost/G = new(loc)
			if(mind)
				mind.transfer_to(G)
			else
				G.key = key
	..(gibbed)

/mob/living/simple_animal/parrot/Poly/proc/Read_Memory()
	if(fexists("data/npc_saves/Poly.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Poly.sav")
		S["phrases"] 			>> speech_buffer
		S["roundssurvived"]		>> rounds_survived
		S["longestsurvival"]	>> longest_survival
		S["longestdeathstreak"] >> longest_deathstreak
		fdel("data/npc_saves/Poly.sav")
	else
		var/json_file = file("data/npc_saves/Poly.json")
		if(!fexists(json_file))
			return
		var/list/json = list()
		json = json_decode(file2text(json_file))
		speech_buffer = json["phrases"]
		rounds_survived = json["roundssurvived"]
		longest_survival = json["longestsurvival"]
		longest_deathstreak = json["longestdeathstreak"]
	if(!islist(speech_buffer))
		speech_buffer = list()

/mob/living/simple_animal/parrot/Poly/proc/Write_Memory()
	var/json_file = file("data/npc_saves/Poly.json")
	var/list/file_data = list()
	if(islist(speech_buffer))
		file_data["phrases"] = speech_buffer
	file_data["roundssurvived"] = rounds_survived
	file_data["longestsurvival"] = longest_survival
	file_data["longestdeathstreak"] = longest_deathstreak
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))
	memory_saved = 1

/mob/living/simple_animal/parrot/Poly/ghost
	name = "The Ghost of Poly"
	desc = "Doomed to squawk the earth."
	color = "#FFFFFF77"
	speak_chance = 20
	status_flags = GODMODE
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	butcher_results = list(/obj/item/ectoplasm = 1)

/mob/living/simple_animal/parrot/Poly/ghost/Initialize()
	memory_saved = 1 //At this point nothing is saved
	..()

/mob/living/simple_animal/parrot/Poly/ghost/handle_automated_speech()
	if(ismob(loc))
		return
	..()

/mob/living/simple_animal/parrot/Poly/ghost/handle_automated_movement()
	if(isliving(parrot_interest))
		if(!ishuman(parrot_interest))
			parrot_interest = null
		else if(parrot_state == (PARROT_SWOOP | PARROT_ATTACK) && Adjacent(parrot_interest))
			walk_to(src, parrot_interest, 0, parrot_speed)
			Possess(parrot_interest)
	..()

/mob/living/simple_animal/parrot/Poly/ghost/proc/Possess(mob/living/carbon/human/H)
	if(!ishuman(H))
		return
	var/datum/disease/parrot_possession/P = new
	P.parrot = src
	loc = H
	H.ContractDisease(P)
	parrot_interest = null
	H.visible_message("<span class='danger'>[src] dive bombs into [H]'s chest and vanishes!</span>", "<span class='userdanger'>[src] dive bombs into your chest, vanishing! This can't be good!</span>")
