//Crafting
/obj/item/garrotehandles
	name = "garrote handles"
	desc = "Two handles for a garrote to be made. Needs cable to finish it."
	icon_state = "garrotehandles"
	// item_state = "rods"
	icon = 'hippiestation/icons/obj/garrote.dmi'
	w_class = 2
	materials = list(MAT_METAL=1000)

/obj/item/garrotehandles/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/R = I
		if (R.use(20))
			var/obj/item/garrote/W = new /obj/item/garrote
			if(!remove_item_from_storage(user))
				user.temporarilyRemoveItemFromInventory(src)
			W.item_color = I.item_color
			W.update_icon()
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>You attach the cable to the handles and pull on them tightly, creating a garrote.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need 20 cables to make a garrote!</span>")
			return

//Wepon
/obj/item/garrote
	name = "garrote"
	desc = "Extremely robust for stealth takedowns and rapid chokeholds."
	w_class = 2
	icon = 'hippiestation/icons/obj/garrote.dmi'
	icon_state = "garrote"
	item_color = ""
	var/garroting = FALSE
	var/next_garrote = 0

/obj/item/garrote/Initialize()
	..()
	update_icon()

/obj/item/garrote/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/garrote/update_icon()
	if (!item_color)
		item_color = pick("red", "yellow", "blue", "green")
	icon_state = "garrote[garroting ? "_w" : ""][item_color ? "_[item_color]" : ""]"

/obj/item/garrote/proc/start_garroting(mob/user)
	var/mob/living/M = user.pulling
	M.LAssailant = user
	playsound(M.loc, 'hippiestation/sound/weapons/grapple.ogg', 40, 1, -4)
	playsound(M.loc, 'sound/weapons/cablecuff.ogg', 15, 1, -5)
	garroting = TRUE
	update_icon()
	START_PROCESSING(SSobj, src)
	next_garrote = world.time + 10
	user.visible_message(
		"<span class='danger'>[user] has grabbed \the [user.pulling] with \the [src]!</span>",\
		"<span class='danger'>You grab \the [user.pulling] with \the [src]!</span>",\
		"You hear some struggling and muffled cries of surprise")
			
/obj/item/garrote/proc/stop_garroting()
	garroting = FALSE
	STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/garrote/attack_self(mob/user)
	if(garroting)
		to_chat(user, "<span class='notice'>You release the garrote on your victim.</span>") //Not the grab, though. Only the garrote.
		garroting = FALSE
		STOP_PROCESSING(SSobj, src)
		update_icon()
		return
	if(world.time <= next_garrote) return

	if(iscarbon(user))
		if(!user.pulling || !iscarbon(user.pulling))
			to_chat(user, "<span class='warning'>You must be grabbing someone to garrote them!</span>")
			return

		start_garroting(user)

/obj/item/garrote/afterattack(atom/A, mob/living/user as mob, proximity, click_parameters)
	if(!proximity) return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(user != C)
			if(user.zone_selected != "mouth" && user.zone_selected != "eyes" && user.zone_selected != "head")
				to_chat(user, "<span class='notice'>You must target head for garroting to work!</span>")
				return
			if(!garroting)
				add_logs(user, C, "garroted")
				user.grab_state = GRAB_PASSIVE
				//Autograb. The trick is to switch to grab intent and reinforce it for quick chokehold.
				// N E V E R  autograb into Aggressive. Passive autograb is good enough.
				C.grabbedby(user)
				C.grippedby(user)
				start_garroting(user)
			else
				if(user.grab_state == GRAB_KILL)
					return
				user.changeNext_move(CLICK_CD_GRABBING)
				visible_message("<span class='danger'>[user] starts to tighten the garrote on [src]!</span>", \
				"<span class='userdanger'>[user] starts to tighten the garrote on you!</span>")
				if(!do_mob(user, C, 30))
					return 0
				playsound(C.loc, 'hippiestation/sound/weapons/grapple.ogg', 40, 1, -4)
				playsound(C.loc, 'sound/weapons/cablecuff.ogg', 15, 1, -5)
				user.grab_state++
				switch(user.grab_state)
					if(GRAB_AGGRESSIVE)
						visible_message("<span class='danger'>[user] has tightend the garrote around [src]!</span>", \
								"<span class='userdanger'>[user] has grabbed [src] aggressively!</span>")
					if(GRAB_NECK)
						visible_message("<span class='danger'>[C] looks like they're struggling to breath!</span>",\
								"<span class='userdanger'>You can't breath!</span>")
						C.Move(user.loc)
					if(GRAB_KILL)
						visible_message("<span class='danger'>[C] looks like they're fighting for their life!</span>", \
								"<span class='userdanger'>You feel like these might be your last few moments!</span>")
						C.Move(user.loc)
	return

/obj/item/garrote/process()
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(!C.is_holding(src)) //THE GARROTE IS NOT IN HANDS, ABORT
			STOP_PROCESSING(SSobj, src)
			C.grab_state = GRAB_PASSIVE
			return

		if(!C.pulling || !iscarbon(C.pulling))
			STOP_PROCESSING(SSobj, src)
			C.grab_state = GRAB_PASSIVE
			return

		var/mob/living/carbon/human/H = C.pulling
		if(istype(H))
			if(H.is_mouth_covered())
				return
			H.forcesay(list("-hrk!", "-hrgh!", "-urgh!", "-kh!", "-hrnk!"))

		var/mob/living/M = C.pulling
		if(C.grab_state >= GRAB_NECK) //Only do oxyloss if in neck grab to prevent passive grab choking or something.
			if(C.grab_state >= GRAB_KILL)
				M.adjustOxyLoss(3) //Stack the chokes with additional oxyloss for quicker death
			else
				if(prob(40))
					M.stuttering = max(M.stuttering, 3) //It will hamper your voice, being choked and all.
					M.losebreath = min(M.losebreath + 2, 3) //Tell the game we're choking them
	else
		STOP_PROCESSING(SSobj, src)

