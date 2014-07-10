/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/device/mmi/mmi = null
	var/list/req_access = list(access_robotics) //Access needed to pop out the brain.

	name = "Spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	wander = 0

	health = 10
	maxHealth = 10

	attacktext = "shocks"
	melee_damage_lower = 1
	melee_damage_upper = 3

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	var/obj/item/held_item = null //Storage for single item they can hold.
	var/emagged = 0               //IS WE EXPLODEN?
	var/syndie = 0                //IS WE SYNDICAT? (currently unused)
	speed = -1                    //Spiderbots gotta go fast.
	//pass_flags = PASSTABLE      //Maybe griefy?
	small = 1
	speak_emote = list("beeps","clicks","chirps")

/mob/living/simple_animal/spiderbot/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/device/mmi) || istype(O, /obj/item/device/mmi/posibrain))
		var/obj/item/device/mmi/B = O
		if(src.mmi) //There's already a brain in it.
			user << "\red There's already a brain in [src]!"
			return
		if(!B.brainmob)
			user << "\red Sticking an empty MMI into the frame would sort of defeat the purpose."
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				user << "<span class='notice'>[O] is completely unresponsive; there's no point.</span>"
				return

		if(B.brainmob.stat == DEAD)
			user << "\red [O] is dead. Sticking it into the frame would sort of defeat the purpose."
			return

		if(jobban_isbanned(B.brainmob, "Cyborg"))
			user << "\red [O] does not seem to fit."
			return

		user << "\blue You install [O] in [src]!"

		user.drop_item()
		src.mmi = O
		src.transfer_personality(O)

		O.loc = src
		src.update_icon()
		return 1

	if (istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = O
		if (WT.remove_fuel(0))
			if(health < maxHealth)
				health += pick(1,1,1,2,2,3)
				if(health > maxHealth)
					health = maxHealth
				add_fingerprint(user)
				for(var/mob/W in viewers(user, null))
					W.show_message(text("\red [user] has spot-welded some of the damage to [src]!"), 1)
			else
				user << "\blue [src] is undamaged!"
		else
			user << "Need more welding fuel!"
			return
	else if(istype(O, /obj/item/weapon/card/id)||istype(O, /obj/item/device/pda))
		if (!mmi)
			user << "\red There's no reason to swipe your ID - the spiderbot has no brain to remove."
			return 0

		var/obj/item/weapon/card/id/id_card

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.access)
			user << "\blue You swipe your access card and pop the brain out of [src]."
			eject_brain()

			if(held_item)
				held_item.loc = src.loc
				held_item = null

			return 1
		else
			user << "\red You swipe your card, with no effect."
			return 0
	else if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			user << "\red [src] is already overloaded - better run."
			return 0
		else
			emagged = 1
			user << "\blue You short out the security protocols and overload [src]'s cell, priming it to explode in a short time."
			spawn(100)	src << "\red Your cell seems to be outputting a lot of power..."
			spawn(200)	src << "\red Internal heat sensors are spiking! Something is badly wrong with your cell!"
			spawn(300)	src.explode()

	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			usr << "\red This weapon is ineffective, it does no damage."
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red [user] gently taps [src] with the [O]. ")

/mob/living/simple_animal/spiderbot/proc/transfer_personality(var/obj/item/device/mmi/M as obj)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		src.ckey = M.brainmob.ckey
		src.name = "Spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message("\red [src] makes an odd warbling noise, fizzles, and explodes.")
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	Die()

/mob/living/simple_animal/spiderbot/proc/update_icon()
	if(mmi)
		if(istype(mmi,/obj/item/device/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
		if(istype(mmi, /obj/item/device/mmi/posibrain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"

	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
		src.name = "Spider-bot"
		update_icon()

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	..()

/mob/living/simple_animal/spiderbot/New()

	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "Spiderbot-[real_name]"
	camera.network = list("SS13")

	..()

/mob/living/simple_animal/spiderbot/Die()

	living_mob_list -= src
	dead_mob_list += src

	if(camera)
		camera.status = 0
	if(held_item && !isnull(held_item))
		held_item.loc = src.loc
		held_item = null

	robogibs(src.loc, viruses)
	del(src)

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/spiderbot/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Spiderbot"

//	if(!istype(V,/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent))
//		return
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/welded = 0
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
		if(!v.welded)
			vent_found = v
			break
		else
			welded = 1
	if(vent_found)
		if(vent_found.network&&vent_found.network.normal_members.len)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in vent_found.network.normal_members)
				if(temp_vent.loc == loc)
					continue
				vents.Add(temp_vent)
			var/list/choices = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/vent in vents)
				if(vent.loc.z != loc.z)
					continue
				var/atom/a = get_turf(vent)
				choices.Add(a.loc)
			var/turf/startloc = loc
			var/obj/selection = input("Select a destination.", "Duct System") in choices
			var/selection_position = choices.Find(selection)
			if(loc==startloc)
				var/obj/target_vent = vents[selection_position]
				if(target_vent)
					loc = target_vent.loc
			else
				src << "\blue You need to remain still while entering a vent."
		else
			src << "\blue This vent is not connected to anything."
	else if(welded)
		src << "\red That vent is welded."
	else
		src << "\blue You must be standing on or beside an air vent to enter it."
	return

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/spiderbot/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Spiderbot"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")

//Cannibalized from the parrot mob. ~Zuhayr

/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	if(!held_item)
		usr << "\red You have nothing to drop!"
		return 0

	if(istype(held_item, /obj/item/weapon/grenade))
		visible_message("\red [src] launches \the [held_item]!", "\red You launch \the [held_item]!", "You hear a skittering noise and a thump!")
		var/obj/item/weapon/grenade/G = held_item
		G.loc = src.loc
		G.prime()
		held_item = null
		return 1

	visible_message("\blue [src] drops \the [held_item]!", "\blue You drop \the [held_item]!", "You hear a skittering noise and a soft thump.")

	held_item.loc = src.loc
	held_item = null
	return 1

	return

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat)
		return -1

	if(held_item)
		src << "\red You are already holding \the [held_item]"
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= 2)
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message("\blue [src] scoops up \the [held_item]!", "\blue You grab \the [held_item]!", "You hear a skittering noise and a clink.")
				return held_item
		src << "\red \The [selection] is too far away."
		return 0

	src << "\red There is nothing of interest to take."
	return 0

/mob/living/simple_animal/spiderbot/examine()
	..()
	if(src.held_item)
		usr << "It is carrying \a [src.held_item] \icon[src.held_item]."
