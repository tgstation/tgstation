/mob/living/simple_animal
	name = "animal"
	var/icon_living = ""
	var/icon_dead = ""
	var/max_health = 20
	var/alive = 1
	var/list/speak = null
	var/list/speak_emote = null//list()	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
	var/speak_chance = 0
	var/list/emote_hear = list()	//EHearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	health = 20
	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 1
	var/meat_amount = 0
	var/meat_type
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.

	//Interaction
	var/response_help   = "You try to help"
	var/response_disarm = "You try to disarm"
	var/response_harm   = "You try to hurt"
	var/harm_intent_damage = 3

	//Temperature effect
	var/minbodytemp = 270
	var/maxbodytemp = 370
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atoms_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above.

//Cat

/mob/living/simple_animal/cat
	name = "Cat"
	desc = "Kitty!!"
	icon = 'mob.dmi'
	icon_state = "tempcat"
	icon_living = "tempcat"
	icon_dead = "catdeath"
	speak = list("Meow!","Esp!","Purr!","HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows","mews")
	emote_see = list("shakes it's head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"

/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = ""
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"

//Corgi
/mob/living/simple_animal/corgi
	name = "Corgi"
	desc = "Puppy!!"
	icon = 'mob.dmi'
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	speak = list("YAP","Woof!","Bark!","AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks","woofs","yaps")
	emote_see = list("shakes it's head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	meat_amount = 3
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	var/obj/item/inventory_head
	var/obj/item/inventory_back

/mob/living/simple_animal/corgi/update_clothing()
	overlays = list()

	if(inventory_head)
		var/head_icon_state = inventory_head.icon_state
		if(health <= 0)
			head_icon_state += "2"

		var/icon/head_icon = icon('corgi_head.dmi',head_icon_state)
		if(head_icon)
			overlays += head_icon

	if(inventory_back)
		var/back_icon_state = inventory_back.icon_state
		if(health <= 0)
			back_icon_state += "2"

		var/icon/back_icon = icon('corgi_back.dmi',back_icon_state)
		if(back_icon)
			overlays += back_icon
	return

/mob/living/simple_animal/corgi/Life()
	..()
	update_clothing()

/mob/living/simple_animal/corgi/show_inv(mob/user as mob)
	user.machine = src

	var/dat = 	"<div align='center'><b>Inventory of [src]</b></div><p>"
	if(inventory_head)
		dat +=	"<br><b>Head:</b> [inventory_head] (<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		dat +=	"<br><b>Back:</b> [inventory_back] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return

/mob/living/simple_animal/corgi/Topic(href, href_list)
	//Removing from inventory
	if(href_list["remove_inv"])
		if(get_dist(src,usr) > 1)
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					inventory_head.loc = src.loc
					inventory_head = null
				else
					usr << "\red There is nothing on this slot."
					return
			if("back")
				if(inventory_back)
					inventory_back.loc = src.loc
					inventory_back = null
				else
					usr << "\red There is nothing on this slot."
					return

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(get_dist(src,usr) > 1)
			return
		if(!usr.get_active_hand())
			usr << "\red You have nothing in your active hand to put in the slot."
			return
		var/add_to = href_list["add_inv"]
		switch(add_to)
			if("head")
				if(inventory_head)
					usr << "\red The [inventory_head] is alraedy in this slot."
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.

					var/list/allowed_types = list(
						/obj/item/clothing/head/helmet
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red The object cannot fit on this animal."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_head = item_to_add

			if("back")
				if(inventory_back)
					usr << "\red The [inventory_back] is alraedy in this slot."
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.

					var/list/allowed_types = list(
						/obj/item/clothing/suit/armor/vest
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red The object cannot fit on this animal."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add

		show_inv(usr)
	else
		..()

/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	desc = "It's Ian, what else do you need to know?"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/obj/movement_target

/mob/living/simple_animal/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(alive && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						dir = WEST
					else if (movement_target.loc.x > src.x)
						dir = EAST
					else if (movement_target.loc.y < src.y)
						dir = SOUTH
					else if (movement_target.loc.y > src.y)
						dir = NORTH
					else
						dir = SOUTH

				if(isturf(movement_target.loc) )
					movement_target.attack_animal(src)
				else if(ishuman(movement_target.loc) )
					if(prob(20))
						emote("stares at the [movement_target] that [movement_target.loc] has with a sad puppy-face")

		if(prob(1))
			emote("dances around")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/mob/living/simple_animal/New()
	..()
	verbs -= /mob/verb/observe

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = null

/mob/living/simple_animal/Life()

	//Health
	if(!alive)
		if(health > 0)
			icon_state = icon_living
			alive = 1
			stat = 0 		//Alive - conscious
			density = 1
		return

	if(health < 1)
		alive = 0
		icon_state = icon_dead
		stat = 2 			//Dead
		density = 0
		return

	if(health > max_health)
		health = max_health

	//Movement
	if(!ckey && !stop_automated_movement)
		if(isturf(src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(cardinal)))
				turns_since_move = 0

	//Speaking
	if(speak_chance)
		if(prob(speak_chance))
			if(speak && (emote_hear || emote_see) )
				var/length = speak.len
				if(emote_hear)
					length += emote_hear.len
				if(emote_see)
					length += emote_see.len
				var/pick = rand(1,length)
				if(pick <= speak.len)
					say(pick(speak))
				else
					pick -= speak.len
					if(emote_see && pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)
			if(!speak)
				if(!emote_hear && emote_see)
					emote(pick(emote_see),1)
				if(emote_hear && !emote_see)
					emote(pick(emote_hear),2)
				if(emote_hear && emote_see)
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)
			if(speak && !(emote_see || emote_hear))
				say(pick(speak))

	//Atmos
	var/atmos_suitable = 1

	var/atom/A = src.loc
	if(isturf(A))
		var/turf/T = A
		var/areatemp = T.temperature
		if( abs(areatemp - bodytemperature) > 50 )
			var/diff = areatemp - bodytemperature
			diff = diff / 5
			//world << "changed from [bodytemperature] by [diff] to [bodytemperature + diff]"
			bodytemperature += diff

		if(istype(T,/turf/simulated))
			var/turf/simulated/ST = T
			if(ST.air)
				var/tox = ST.air.toxins
				var/oxy = ST.air.oxygen
				var/n2  = ST.air.nitrogen
				var/co2 = ST.air.carbon_dioxide

				if(min_oxy)
					if(oxy < min_oxy)
						atmos_suitable = 0
				if(max_oxy)
					if(oxy > max_oxy)
						atmos_suitable = 0
				if(min_tox)
					if(tox < min_tox)
						atmos_suitable = 0
				if(max_tox)
					if(tox > max_tox)
						atmos_suitable = 0
				if(min_n2)
					if(n2 < min_n2)
						atmos_suitable = 0
				if(max_n2)
					if(n2 > max_n2)
						atmos_suitable = 0
				if(min_co2)
					if(co2 < min_co2)
						atmos_suitable = 0
				if(max_co2)
					if(co2 > max_co2)
						atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		health -= cold_damage_per_tick
	else if(bodytemperature > maxbodytemp)
		health -= heat_damage_per_tick

	if(!atmos_suitable)
		health -= unsuitable_atoms_damage

/mob/living/simple_animal/Bumped(AM as mob|obj)
	if(!AM) return
	if(isturf(src.loc) && !resting && !buckled)
		if(ismob(AM))
			var/newamloc = src.loc
			src.loc = AM:loc
			AM:loc = newamloc
		else
			..()

/mob/living/simple_animal/gib()
	if(meat_amount && meat_type)
		for(var/i = 0; i < meat_amount; i++)
			new meat_type(src.loc)
	..()

/mob/living/simple_animal/say_quote(var/text)
	if(speak_emote)
		var/emote = pick(speak_emote)
		if(emote)
			return "[emote], \"[text]\""
	return "says, \"[text]\"";

/mob/living/simple_animal/emote(var/act)
	if(act)
		for (var/mob/O in viewers(src, null))
			O.show_message("<B>[src]</B> [act].")

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if ("help")
			if (health > 0)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\blue [M] [response_help] [src]")

		if ("grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()

			LAssailant = M

			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		if ("hurt")
			health -= harm_intent_damage
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message("\red [M] [response_harm] [src]")

		if ("disarm")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message("\blue [M] [response_disarm] [src]")

	return

/mob/living/simple_animal/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/stack/medical))
		if(alive)
			var/obj/item/stack/medical/MED = O
			if(health < max_health)
				if(MED.amount >= 1)
					health = min(max_health, health + MED.heal_brute)
					MED.amount -= 1
					if(MED.amount <= 0)
						del(MED)
					for(var/mob/M in viewers(src, null))
						if ((M.client && !( M.blinded )))
							M.show_message("\blue [user] applies the [MED] on [src]")
		else
			user << "\blue this [src] is dead, medical items won't bring it back to life."
	else
		if(O.force)
			health -= O.force
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			usr << "\red This weapon is ineffective, it does no damage."
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red [user] gently taps [src] with the [O]. ")


//MEAT

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."