<<<<<<< HEAD
=======
//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos
#define NORODS 0
#define RODSADDED 1

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = 0
	anchored = 1
<<<<<<< HEAD
=======
	var/state = 0			//1 if rods added; 0 if not
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

<<<<<<< HEAD

/obj/structure/toilet/New()
	open = round(rand(0, 1))
	update_icon()


/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='userdanger'>[user] slams the toilet seat onto your head!</span>", "<span class='italics'>You hear reverberating porcelain.</span>")
		swirlie.adjustBruteLoss(5)

	else if(user.pulling && user.a_intent == "grab" && isliving(user.pulling))
		user.changeNext_move(CLICK_CD_MELEE)
		var/mob/living/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(GM.loc != get_turf(src))
				user << "<span class='warning'>[GM] needs to be on [src]!</span>"
				return
			if(!swirlie)
				if(open)
					GM.visible_message("<span class='danger'>[user] starts to give [GM] a swirlie!</span>", "<span class='userdanger'>[user] starts to give you a swirlie...</span>")
					swirlie = GM
					if(do_after(user, 30, 0, target = src))
						GM.visible_message("<span class='danger'>[user] gives [GM] a swirlie!</span>", "<span class='userdanger'>[user] gives you a swirlie!</span>", "<span class='italics'>You hear a toilet flushing.</span>")
						if(iscarbon(GM))
							var/mob/living/carbon/C = GM
							if(!C.internal)
								C.adjustOxyLoss(5)
						else
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
					GM.visible_message("<span class='danger'>[user] slams [GM.name] into [src]!</span>", "<span class='userdanger'>[user] slams you into [src]!</span>")
					GM.adjustBruteLoss(5)
		else
			user << "<span class='warning'>You need a tighter grip!</span>"

	else if(cistern && !open)
		if(!contents.len)
			user << "<span class='notice'>The cistern is empty.</span>"
=======
/obj/structure/toilet/New()
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/verb/empty_container_into()
	set name = "Empty container into"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	if(!open)
		to_chat(usr, "<span class='warning'>\The [src] is closed!</span>")
		return
	var/obj/item/weapon/reagent_containers/container = usr.get_active_hand()
	if(!istype(container))
		to_chat(usr, "<span class='warning'>You need a reagent container in your active hand to do that.</span>")
		return
	return container.drain_into(usr, src)

/obj/structure/toilet/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()
/obj/structure/toilet/attack_hand(mob/living/user as mob)
	if(swirlie)
		usr.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='notice'>You slam the toilet seat onto [swirlie.name]'s head!</span>", "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.loc = get_turf(src)
<<<<<<< HEAD
			user << "<span class='notice'>You find [I] in the cistern.</span>"
			w_items -= I.w_class
	else
		open = !open
		update_icon()

=======
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	open = !open
	update_icon()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"

<<<<<<< HEAD

/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user << "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]...</span>"
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, 30/I.toolspeed, target = src))
			user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>You hear grinding porcelain.</span>")
			cistern = !cistern
			update_icon()

	else if(cistern)
		if(user.a_intent != "harm")
			if(I.w_class > 3)
				user << "<span class='warning'>[I] does not fit!</span>"
				return
			if(w_items + I.w_class > 5)
				user << "<span class='warning'>The cistern is full!</span>"
				return
			if(!user.drop_item())
				user << "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the cistern!</span>"
				return
			I.loc = src
			w_items += I.w_class
			user << "<span class='notice'>You carefully place [I] into the cistern.</span>"

	else if(istype(I, /obj/item/weapon/reagent_containers))
		if (!open)
			return
		var/obj/item/weapon/reagent_containers/RG = I
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user << "<span class='notice'>You fill [RG] from [src]. Gross.</span>"
	else
		return ..()


=======
/obj/structure/toilet/attackby(obj/item/I as obj, mob/living/user as mob)
	if(iswrench(I))
		to_chat(user, "<span class='notice'>You [anchored ? "un":""]bolt \the [src]'s grounding lines.</span>")
		anchored = !anchored
	if(anchored == 0)
		return
	if(open && cistern && state == NORODS && istype(I,/obj/item/stack/rods)) //State = 0 if no rods
		var/obj/item/stack/rods/R = I
		if(R.amount < 2) return
		to_chat(user, "<span class='notice'>You add the rods to the toilet, creating flood avenues.</span>")
		R.use(2)
		state = RODSADDED //State 0 -> 1
		return
	if(open && cistern && state == RODSADDED && istype(I,/obj/item/weapon/paper)) //State = 1 if rods are added
		to_chat(user, "<span class='notice'>You create a filter with the paper and insert it.</span>")
		var/obj/structure/centrifuge/C = new /obj/structure/centrifuge(src.loc)
		C.dir = src.dir
		qdel(I)
		qdel(src)
		return
	if(iscrowbar(I))
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, src, 30))
			user.visible_message("<span class='notice'>[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!</span>", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "You hear grinding porcelain.")
			cistern = !cistern
			update_icon()
			return

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I

		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting

			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the toilet.</span>")
					return
				if(open && !swirlie)
					user.visible_message("<span class='danger'>[user] starts to give [GM.name] a swirlie!</span>", "<span class='notice'>You start to give [GM.name] a swirlie!</span>")
					swirlie = GM
					if(do_after(user, 30, 5, 0))
						user.visible_message("<span class='danger'>[user] gives [GM.name] a swirlie!</span>", "<span class='notice'>You give [GM.name] a swirlie!</span>", "You hear a toilet flushing.")
						if(!GM.internal)
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
					GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

	if(cistern)
		if(I.w_class > W_CLASS_MEDIUM)
			to_chat(user, "<span class='notice'>\The [I] does not fit.</span>")
			return
		if(w_items + I.w_class > W_CLASS_HUGE)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return
		if(user.drop_item(I, src))
			w_items += I.w_class
			to_chat(user, "You carefully place \the [I] into the cistern.")
			return

/obj/structure/toilet/bite_act(mob/user)
	user.simple_message("<span class='notice'>That would be disgusting.</span>", "<span class='info'>You're not high enough for that... Yet.</span>") //Second message 4 hallucinations
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1

<<<<<<< HEAD

/obj/structure/urinal/attack_hand(mob/user)
	if(user.pulling && user.a_intent == "grab" && isliving(user.pulling))
		var/mob/living/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(GM.loc != get_turf(src))
				user << "<span class='notice'>[GM.name] needs to be on [src].</span>"
				return
			user.changeNext_move(CLICK_CD_MELEE)
			user.visible_message("<span class='danger'>[user] slams [GM] into [src]!</span>", "<span class='danger'>You slam [GM] into [src]!</span>")
			GM.adjustBruteLoss(8)
		else
			user << "<span class='warning'>You need a tighter grip!</span>"
	else
		..()
=======
/obj/structure/urinal/verb/empty_container_into()
	set name = "Empty container into"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	var/obj/item/weapon/reagent_containers/container = usr.get_active_hand()
	if(!istype(container))
		to_chat(usr, "<span class='warning'>You need a reagent container in your active hand to do that.</span>")
		return
	return container.drain_into(usr, src)

/obj/structure/urinal/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()

/obj/structure/urinal/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the urinal.</span>")
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

/obj/structure/urinal/bite_act(mob/user)
	user.simple_message("<span class='notice'>That would be disgusting.</span>", "<span class='info'>You're not high enough for that... Yet.</span>") //Second message 4 hallucinations
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
<<<<<<< HEAD
=======
	icon_state_open = "shower_t"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	density = 0
	anchored = 1
	use_power = 0
	var/on = 0
	var/obj/effect/mist/mymist = null
<<<<<<< HEAD
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling

=======
	var/ismist = 0 //Needs a var so we can make it linger~
	var/watertemp = "cool" //Freezing, normal, or boiling
	var/mobpresent = 0 //True if there is a mob on the shower's loc, this is to ease process()
	var/obj/item/weapon/reagent_containers/glass/beaker/water/watersource = null

	machine_flags = SCREWTOGGLE

	ghost_read = 0
	ghost_write = 0

/obj/machinery/shower/New() //Our showers actually wet people and floors now
	..()
	watersource = new /obj/item/weapon/reagent_containers/glass/beaker/water()

//Add heat controls? When emagged, you can freeze to death in it?
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
<<<<<<< HEAD
	layer = FLY_LAYER
	anchored = 1
	mouse_opacity = 0


/obj/machinery/shower/attack_hand(mob/M)
	on = !on
	update_icon()
	add_fingerprint(M)
	if(on)
		wash_turf()
		for(var/atom/movable/G in loc)
			if(isliving(G))
				var/mob/living/L = G
				wash_mob(L)
			else
				wash_obj(G)
	else
		if(istype(loc, /turf/open))
			var/turf/open/tile = loc
			tile.MakeSlippery(min_wet_time = 5, wet_time_to_add = 1)


/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.type == /obj/item/device/analyzer)
		user << "<span class='notice'>The water temperature seems to be [watertemp].</span>"
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin to adjust the temperature valve with \the [I]...</span>"
		if(do_after(user, 50/I.toolspeed, target = src))
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
=======
	layer = MOB_LAYER + 1
	plane = PLANE_EFFECTS
	anchored = 1
	mouse_opacity = 0

/obj/machinery/shower/togglePanelOpen(var/obj/toggleitem, var/mob/user)
	if(on)
		to_chat(user, "<span class='warning'>You need to turn off \the [src] first.</span>")
		return
	..()

/obj/machinery/shower/attack_hand(mob/M as mob)
	if(..())
		return
	if(panel_open)
		to_chat(M, "<span class='warning'>\The [src]'s maintenance hatch needs to be closed first.</span>")
		return
	if(!anchored)
		to_chat(M, "<span class='warning'>\The [src] needs to be bolted to the floor to work.</span>")
		return

	on = !on
	M.visible_message("<span class='notice'>[M] turns \the [src] [on ? "on":"off"]</span>", \
					  "<span class='notice'>You turn \the [src] [on ? "on":"off"]</span>")
	update_icon()
	if(on)
		for(var/atom/movable/G in get_turf(src))
			G.clean_blood()

/obj/machinery/shower/attackby(obj/item/I as obj, mob/user as mob)

	..()

	if(I.type == /obj/item/device/analyzer)
		to_chat(user, "<span class='notice'>The water's temperature seems to be [watertemp].</span>")
	if(panel_open) //The panel is open
		if(iswrench(I))
			user.visible_message("<span class='warning'>[user] starts adjusting the bolts on \the [src].</span>", \
								 "<span class='notice'>You start adjusting the bolts on \the [src].</span>")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			if(do_after(user, src, 50))
				if(anchored == 1)
					src.visible_message("<span class='warning'>[user] unbolts \the [src] from the floor.</span>", \
								 "<span class='notice'>You unbolt \the [src] from the floor.</span>")
					anchored = 0
				else
					src.visible_message("<span class='warning'>[user] bolts \the [src] to the floor.</span>", \
								 "<span class='notice'>You bolt \the [src] to the floor.</span>")
					anchored = 1
	else
		if(iswrench(I))
			user.visible_message("<span class='warning'>[user] begins to adjust \the [src]'s temperature valve with \a [I.name].</span>", \
								 "<span class='notice'>You begin to adjust \the [src]'s temperature valve with \a [I.name].</span>")
			if(do_after(user, src, 50))
				switch(watertemp)
					if("cool")
						watertemp = "freezing cold"
					if("freezing cold")
						watertemp = "searing hot"
					if("searing hot")
						watertemp = "cool"
				user.visible_message("<span class='warning'>[user] adjusts \the [src]'s temperature with \a [I.name].</span>",
				"<span class='notice'>You adjust \the [src]'s temperature with \a [I.name], the water is now [watertemp].</span>")
				add_fingerprint(user)

/obj/machinery/shower/update_icon()	//This is terribly unreadable, but basically it makes the shower mist up
	overlays.len = 0 //Once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		returnToPool(mymist)

	if(on)
		var/image/water = image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
		water.plane = PLANE_EFFECTS
		overlays += water
		if(watertemp == "freezing") //No mist if the water is really cold
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
<<<<<<< HEAD
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
	L.ExtinguishMob()
	L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = 1
		check_heat(M)
		if(M.r_hand)
			M.r_hand.clean_blood()
		if(M.l_hand)
			M.l_hand.clean_blood()
		if(M.back)
=======
					mymist = getFromPool(/obj/effect/mist, get_turf(src))
		else
			ismist = 1
			mymist = getFromPool(/obj/effect/mist, get_turf(src))
	else if(ismist)
		ismist = 1
		mymist = getFromPool(/obj/effect/mist, get_turf(src))
		spawn(250)
			if(src && !on)
				returnToPool(mymist)
				ismist = 0

/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	wash(O)
	if(ismob(O))
		mobpresent++

/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mobpresent--
	..()

//Yes, showers are super powerful as far as washing goes
//Shower cleaning has been nerfed (no, really). 75 % chance to clean everything on each tick
//You'll have to stay under it for a bit to clean every last noggin

#define CLEAN_PROB 75 //Percentage

/obj/machinery/shower/proc/wash(atom/movable/O as obj|mob)
	if(!on)
		return

	if(iscarbon(O))
		var/mob/living/carbon/M = O
		for(var/obj/item/I in M.held_items)
			if(prob(CLEAN_PROB))
				I.clean_blood()
				M.update_inv_hand(M.is_holding_item(I))
		if(M.back && prob(CLEAN_PROB))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
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
				clean_blood()
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
		wash_turf()
		for(var/atom/movable/G in loc)
			if(isliving(G))
				var/mob/living/L = G
				wash_mob(L)
			else
				wash_obj(G)


/obj/machinery/shower/proc/check_heat(mob/living/carbon/C)
	if(watertemp == "freezing")
		C.bodytemperature = max(80, C.bodytemperature - 80)
		C << "<span class='warning'>The water is freezing!</span>"
	else if(watertemp == "boiling")
		C.bodytemperature = min(500, C.bodytemperature + 35)
		C.adjustFireLoss(5)
		C << "<span class='danger'>The water is searing!</span>"




/obj/item/weapon/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"


=======
				washgloves = !(is_slot_hidden(H.wear_suit.body_parts_covered, HIDEGLOVES))
				washshoes = !(is_slot_hidden(H.wear_suit.body_parts_covered, HIDESHOES))

			if(H.head)
				washmask = !(is_slot_hidden(H.head.body_parts_covered, HIDEMASK))
				washglasses = !(is_slot_hidden(H.head.body_parts_covered, HIDEEYES))
				washears = !(is_slot_hidden(H.head.body_parts_covered, HIDEEARS))

			if(H.wear_mask)
				if(washears)
					washears = !(is_slot_hidden(H.wear_mask.body_parts_covered, HIDEEARS))
				if(washglasses)
					washglasses = !(is_slot_hidden(H.wear_mask.body_parts_covered, HIDEEYES))

			if(H.head)
				if(prob(CLEAN_PROB) && H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(prob(CLEAN_PROB) && H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(prob(CLEAN_PROB) && H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.gloves && washgloves)
				if(prob(CLEAN_PROB) && H.gloves.clean_blood())
					H.update_inv_gloves(0)
			if(H.shoes && washshoes)
				if(prob(CLEAN_PROB) && H.shoes.clean_blood())
					H.update_inv_shoes(0)
			if(H.wear_mask && washmask)
				if(prob(CLEAN_PROB) && H.wear_mask.clean_blood())
					H.update_inv_wear_mask(0)
			if(H.glasses && washglasses)
				if(prob(CLEAN_PROB) && H.glasses.clean_blood())
					H.update_inv_glasses(0)
			if(H.ears && washears)
				if(prob(CLEAN_PROB) && H.ears.clean_blood())
					H.update_inv_ears(0)
			if(H.belt)
				if(prob(CLEAN_PROB) && H.belt.clean_blood())
					H.update_inv_belt(0)
		else
			if(M.wear_mask) //If the mob is not human, it cleans the mask without asking for bitflags
				if(prob(CLEAN_PROB) && M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
	else
		if(prob(CLEAN_PROB))
			O.clean_blood()

	var/turf/turf = get_turf(src)
	if(prob(CLEAN_PROB))
		turf.clean_blood()
		for(var/obj/effect/E in turf)
			if(istype(E, /obj/effect/rune) || istype(E, /obj/effect/decal/cleanable) || istype(E, /obj/effect/overlay))
				qdel(E)

/obj/machinery/shower/process()
	if(!on)
		return
	for(var/atom/movable/O in loc)
		if(iscarbon(O))
			var/mob/living/carbon/C = O
			check_heat(C)
		wash(O)
		watersource.reagents.reaction(O, TOUCH)
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			var/obj/item/weapon/reagent_containers/glass/G = O
			G.reagents.add_reagent(WATER, 5)
	watersource.reagents.reaction(get_turf(src), TOUCH)

/obj/machinery/shower/proc/check_heat(mob/living/carbon/C as mob)
	if(!on)
		return

	//Note : Remember process() rechecks this, so the mix/max procs slowly increase/decrease body temperature
	//Every second under the shower adjusts body temperature by 0.5°C. Water conducts heat pretty efficiently in real life too
	if(watertemp == "freezing cold") //Down to 0°C, Nanotrasen waterworks are perfect and never fluctuate even slightly below that
		C.bodytemperature = max(T0C, C.bodytemperature - 0.5)
		return
	if(watertemp == "searing hot") //Up to 60°c, upper limit for common water boilers
		C.bodytemperature = min(T0C + 60, C.bodytemperature + 0.5)
		return
	if(watertemp == "cool") //Adjusts towards "perfect" body temperature, 37.5°C. Actual showers tend to average at 40°C, but it's the future
		if(C.bodytemperature > T0C + 37.5) //Cooling down
			C.bodytemperature = max(T0C + 37.5, C.bodytemperature - 0.5)
			return
		if(C.bodytemperature < T0C + 37.5) //Heating up
			C.bodytemperature = min(T0C + 37.5, C.bodytemperature + 0.5)
			return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment

<<<<<<< HEAD

/obj/structure/sink/attack_hand(mob/living/user)
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return

	if(busy)
		user << "<span class='notice'>Someone's already washing here.</span>"
		return
	var/selected_area = parse_zone(user.zone_selected)
	var/washing_face = 0
	if(selected_area in list("head", "mouth", "eyes"))
		washing_face = 1
	user.visible_message("<span class='notice'>[user] start washing their [washing_face ? "face" : "hands"]...</span>", \
						"<span class='notice'>You start washing your [washing_face ? "face" : "hands"]...</span>")
	busy = 1

	if(!do_after(user, 40, target = src))
		busy = 0
		return

	busy = 0

	user.visible_message("<span class='notice'>[user] washes their [washing_face ? "face" : "hands"] using [src].</span>", \
						"<span class='notice'>You wash your [washing_face ? "face" : "hands"] using [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null //Washes off lipstick
			H.lip_color = initial(H.lip_color)
			H.wash_cream()
			H.regenerate_icons()
		user.drowsyness = max(user.drowsyness - rand(2,3), 0) //Washing your face wakes you up if you're falling asleep
	else
		user.clean_blood()


/obj/structure/sink/attackby(obj/item/O, mob/user, params)
	if(busy)
		user << "<span class='warning'>Someone's already washing here!</span>"
		return

	if(istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		if(RG.flags & OPENCONTAINER)
			RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
			user << "<span class='notice'>You fill [RG] from [src].</span>"
			return 1

	if(istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if(B.bcell)
			if(B.bcell.charge > 0 && B.status == 1)
				flick("baton_active", src)
				var/stunforce = B.stunforce
				user.Stun(stunforce)
				user.Weaken(stunforce)
				user.stuttering = stunforce
				B.deductcharge(B.hitcost)
				user.visible_message("<span class='warning'>[user] shocks themself while attempting to wash the active [B.name]!</span>", \
									"<span class='userdanger'>You unwisely attempt to wash [B] while it's still on.</span>")
				playsound(src, "sparks", 50, 1)
				return

	if(istype(O, /obj/item/weapon/mop))
		O.reagents.add_reagent("water", 5)
		user << "<span class='notice'>You wet [O] in [src].</span>"
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = O
		user << "<span class='notice'>You place [src] under a stream of water...</span>"
		user.drop_item()
		M.loc = get_turf(src)
		M.Expand()
		return

	if(!istype(O))
		return
	if(O.flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return

	if(user.a_intent != "harm")
		user << "<span class='notice'>You start washing [O]...</span>"
		busy = 1
		if(!do_after(user, 40, target = src))
			busy = 0
			return 1
		busy = 0
		O.clean_blood()
		user.visible_message("<span class='notice'>[user] washes [O] using [src].</span>", \
							"<span class='notice'>You wash [O] using [src].</span>")
		return 1
	else
		return ..()

=======
/obj/structure/sink/verb/empty_container_into()
	set name = "Empty container into"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	var/obj/item/weapon/reagent_containers/container = usr.get_active_hand()
	if(!istype(container))
		to_chat(usr, "<span class='warning'>You need a reagent container in your active hand to do that.</span>")
		return
	return container.drain_into(usr, src)

/obj/structure/sink/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()

/obj/structure/sink/attack_hand(mob/M as mob)
	if(isrobot(M) || isAI(M))
		return

	if(!Adjacent(M))
		return

	if(anchored == 0)
		return

	if(busy)
		to_chat(M, "<span class='warning'>Someone's already washing here.</span>")
		return

	to_chat(usr, "<span class='notice'>You start washing your hands.</span>")

	busy = 1
	sleep(40)
	busy = 0

	if(!Adjacent(M)) return		//Person has moved away from the sink

	M.clean_blood()
	if(ishuman(M))
		M:update_inv_gloves()
	for(var/mob/V in viewers(src, null))
		V.show_message("<span class='notice'>[M] washes their hands using \the [src].</span>")

/obj/structure/sink/mop_act(obj/item/weapon/mop/M, mob/user)
	if(busy) return 1
	user.visible_message("<span class='notice'>[user] puts \the [M] underneath the running water.","<span class='notice'>You put \the [M] underneath the running water.</span>")
	busy = 1
	sleep(40)
	busy = 0
	M.clean_blood()
	if(M.reagents.maximum_volume > M.reagents.total_volume)
		playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
		M.reagents.add_reagent(WATER, min(M.reagents.maximum_volume - M.reagents.total_volume, 50))
		user.visible_message("<span class='notice'>[user] finishes soaking \the [M], \he could clean the entire station with that.</span>","<span class='notice'>You finish soaking \the [M], you feel as if you could clean anything now, even the Chef's backroom...</span>")
	else
		user.visible_message("<span class='notice'>[user] removes \the [M], cleaner than before.</span>","<span class='notice'>You remove \the [M] from \the [src], it's all nice and sparkly now but somehow didnt get it any wetter.</span>")
	return 1

/obj/structure/sink/attackby(obj/item/O as obj, mob/user as mob)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	if(iswrench(O))
		to_chat(user, "<span class='notice'>You [anchored ? "un":""]bolt \the [src]'s grounding lines.</span>")
		anchored = !anchored
	if(anchored == 0)
		return

	if(istype(O, /obj/item/weapon/mop)) return

	if (istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		if(RG.reagents.total_volume >= RG.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>\The [RG] is full.</span>")
			return
		if (istype(RG, /obj/item/weapon/reagent_containers/chempack)) //Chempack can't use amount_per_transfer_from_this, so it needs its own if statement.
			var/obj/item/weapon/reagent_containers/chempack/C = RG
			C.reagents.add_reagent(WATER, C.fill_amount)
		else
			RG.reagents.add_reagent(WATER, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("<span class='notice'>[user] fills \the [RG] using \the [src].</span>","<span class='notice'>You fill the [RG] using \the [src].</span>")
		return

	else if (istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if (B.bcell && B.bcell.charge > 0 && B.status == 1)
			flick("baton_active", src)
			user.Stun(10)
			user.stuttering = 10
			user.Weaken(10)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				B.deductcharge(1)
			user.visible_message( \
				"<span class='warning'>[user] was stunned by \his wet [O.name]!</span>", \
				"<span class='warning'>You have wet \the [O.name], it shocks you!</span>")
			return

	if (!isturf(user.loc))
		return

	if (isitem(O))
		to_chat(user, "<span class='notice'>You start washing \the [O].</span>")
		busy = TRUE

		if (do_after(user,src, 40))
			O.clean_blood()
			user.visible_message( \
				"<span class='notice'>[user] washes \a [O] using \the [src].</span>", \
				"<span class='notice'>You wash \a [O] using \the [src].</span>")

		busy = FALSE
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"

<<<<<<< HEAD
/obj/structure/sink/puddle/attack_hand(mob/M)
=======
/obj/structure/sink/puddle/attack_hand(mob/M as mob)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

<<<<<<< HEAD
/obj/structure/sink/puddle/attackby(obj/item/O, mob/user, params)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"


//Shower Curtains//
//Defines used are pre-existing in layers.dm//


/obj/structure/curtain
	name = "curtain"
	desc = "Contains less than 1% mercury."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "open"
	color = "#ACD1E9" //Default color, didn't bother hardcoding other colors, mappers can and should easily change it.
	alpha = 200 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = WALL_OBJ_LAYER
	anchored = 1
	opacity = 0
	density = 0
	var/open = TRUE


/obj/structure/curtain/proc/toggle()
	open = !open
	update_icon()

/obj/structure/curtain/update_icon()
	if(!open)
		icon_state = "closed"
		layer = WALL_OBJ_LAYER
		density = 1
		open = FALSE

	else
		icon_state = "open"
		layer = SIGN_LAYER
		density = 0
		open = TRUE

/obj/structure/curtain/attack_hand(mob/user)
	playsound(loc, 'sound/effects/curtain.ogg', 50, 1)
	toggle()
	..()

=======
/obj/structure/sink/puddle/attackby(obj/item/O as obj, mob/user as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
