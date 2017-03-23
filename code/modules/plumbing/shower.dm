/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = 0
	anchored = 1
	use_power = 0
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling

/obj/machinery/shower/Initialize()
	create_reagents(5)
	..()


/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = 1
	mouse_opacity = 0


/obj/machinery/shower/attack_hand(mob/M)
	if(!on && !plumbing_has_reagents(5) && !reagents.total_volume)
		M << "<span class='warning'>Nothing comes out of the showerhead!</span>"
		return
	on = !on
	update_icon()
	add_fingerprint(M)
	master_plumber.request_liquid(src, 5)
	if(on)
		process()


/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.type == /obj/item/device/analyzer)
		to_chat(user, "<span class='notice'>The water temperature seems to be [watertemp].</span>")
	if(istype(I, /obj/item/weapon/wrench))
		to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with \the [I]...</span>")
		if(do_after(user, 50*I.toolspeed, target = src))
			switch(watertemp)
				if("normal")
					watertemp = "freezing"
				if("freezing")
					watertemp = "boiling"
				if("boiling")
					watertemp = "normal"
			user.visible_message("<span class='notice'>[user] adjusts the shower with \the [I].</span>", "<span class='notice'>You adjust the shower with \the [I] to [watertemp] temperature.</span>")
			log_game("[key_name(user)] has wrenched a shower to [watertemp] at ([x],[y],[z])")
			add_hiddenprint(user)


/obj/machinery/shower/update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	cut_overlays()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)

	if(on)
		add_overlay(image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir))
		if(watertemp == "freezing")
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = new /obj/effect/mist(loc)
		else
			ismist = 1
			mymist = new /obj/effect/mist(loc)
	else if(ismist)
		ismist = 1
		mymist = new /obj/effect/mist(loc)
		spawn(250)
			if(!on && mymist)
				qdel(mymist)
				ismist = 0


/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	if(on)
		if(isliving(O))
			var/mob/living/L = O
			if(wash_mob(L)) //it's a carbon mob.
				var/mob/living/carbon/C = L
				C.slip(4,2,null,NO_SLIP_WHEN_WALKING)
		else
			wash_obj(O)


/obj/machinery/shower/proc/wash_obj(atom/movable/O)
	O.clean_blood()

	if(istype(O,/obj/item))
		var/obj/item/I = O
		I.acid_level = 0
		I.extinguish()


/obj/machinery/shower/proc/wash_turf()
	if(isturf(loc))
		var/turf/tile = loc
		loc.clean_blood()
		for(var/obj/effect/E in tile)
			if(is_cleanable(E))
				qdel(E)


/obj/machinery/shower/proc/wash_mob(mob/living/L)
	L.wash_cream()
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = 1
		check_heat(M)
		for(var/obj/item/I in M.held_items)
			I.clean_blood()
		if(M.back)
			if(M.back.clean_blood())
				M.update_inv_back(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/washgloves = 1
			var/washshoes = 1
			var/washmask = 1
			var/washears = 1
			var/washglasses = 1

			if(H.wear_suit)
				washgloves = !(H.wear_suit.flags_inv & HIDEGLOVES)
				washshoes = !(H.wear_suit.flags_inv & HIDESHOES)

			if(H.head)
				washmask = !(H.head.flags_inv & HIDEMASK)
				washglasses = !(H.head.flags_inv & HIDEEYES)
				washears = !(H.head.flags_inv & HIDEEARS)

			if(H.wear_mask)
				if (washears)
					washears = !(H.wear_mask.flags_inv & HIDEEARS)
				if (washglasses)
					washglasses = !(H.wear_mask.flags_inv & HIDEEYES)

			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head()
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit()
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform()
			if(washgloves)
				H.clean_blood()
			if(H.shoes && washshoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes()
			if(H.wear_mask)
				if(washmask)
					if(H.wear_mask.clean_blood())
						H.update_inv_wear_mask()
			else
				H.lip_style = null
				H.update_body()
			if(H.glasses && washglasses)
				if(H.glasses.clean_blood())
					H.update_inv_glasses()
			if(H.ears && washears)
				if(H.ears.clean_blood())
					H.update_inv_ears()
			if(H.belt)
				if(H.belt.clean_blood())
					H.update_inv_belt()
		else
			if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
				if(M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
			M.clean_blood()
	else
		L.clean_blood()


/obj/machinery/shower/process()
	if(on)
		if(!reagents.total_volume)
			if(!master_plumber.request_liquid(src, 5))
				on = FALSE
				update_icon()
				return
		switch(watertemp)
			if("freezing")
				reagents.chem_temp = 50
			if("boiling")
				reagents.chem_temp = 300
			else
				reagents.chem_temp = initial(reagents.chem_temp)
		wash_turf()
		reagents.reaction(loc, TOUCH)
		for(var/atom/movable/G in loc)
			reagents.reaction(G, TOUCH)
			if(isliving(G))
				var/mob/living/L = G
				wash_mob(L)
			else
				wash_obj(G)
		reagents.clear_reagents()

/obj/machinery/shower/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 3)
	qdel(src)

/obj/machinery/shower/proc/check_heat(mob/living/carbon/C)
	if(watertemp == "freezing")
		C.bodytemperature = max(80, C.bodytemperature - 80)
		to_chat(C, "<span class='warning'>The water is freezing!</span>")
	else if(watertemp == "boiling")
		C.bodytemperature = min(500, C.bodytemperature + 35)
		C.adjustFireLoss(5)
		to_chat(C, "<span class='danger'>The water is searing!</span>")
