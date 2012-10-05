//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = 0
	anchored = 1
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/New()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user as mob)
	if(swirlie)
		usr.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='notice'>You slam the toilet seat onto [swirlie.name]'s head!</span>", "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
		if(!contents.len)
			user << "<span class='notice'>The cistern is empty.</span>"
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.loc = get_turf(src)
			user << "<span class='notice'>You find \an [I] in the cistern.</span>"
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/I as obj, mob/living/user as mob)
	if(istype(I, /obj/item/weapon/crowbar))
		user << "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>"
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, 30))
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
					user << "<span class='notice'>[GM.name] needs to be on the toilet.</span>"
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
				user << "<span class='notice'>You need a tighter grip.</span>"

	if(cistern)
		if(I.w_class > 3)
			user << "<span class='notice'>\The [I] does not fit.</span>"
			return
		if(w_items + I.w_class > 5)
			user << "<span class='notice'>The cistern is full.</span>"
			return
		user.drop_item()
		I.loc = src
		w_items += I.w_class
		user << "You carefully place \the [I] into the cistern."
		return



/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1

/obj/structure/urinal/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					user << "<span class='notice'>[GM.name] needs to be on the urinal.</span>"
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				GM.adjustBruteLoss(8)
			else
				user << "<span class='notice'>You need a tighter grip.</span>"



/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = 0
	anchored = 1
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/mobpresent = 0		//true if there is a mob on the shower's loc, this is to ease process()

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = MOB_LAYER + 1
	anchored = 1
	mouse_opacity = 0

/obj/machinery/shower/attack_hand(mob/M as mob)
	on = !on
	update_icon()
	if(on)
		if (M.loc == loc)
			wash(M)
			check_heat(M)
		for (var/atom/movable/G in src.loc)
			G.clean_blood()

/obj/machinery/shower/attackby(obj/item/I as obj, mob/user as mob)
	if(I.type == /obj/item/device/analyzer)
		user << "<span class='notice'>The water temperature seems to be [watertemp].</span>"
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin to adjust the temperature valve with the [I].</span>"
		if(do_after(user, 50))
			switch(watertemp)
				if("normal")
					watertemp = "freezing"
				if("freezing")
					watertemp = "boiling"
				if("boiling")
					watertemp = "normal"
			user.visible_message("<span class='notice'>[user] adjusts the shower with the [I].</span>", "<span class='notice'>You adjust the shower with the [I].</span>")

/obj/machinery/shower/update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	overlays = null					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		del(mymist)

	if(on)
		overlays += image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
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
			if(src && !on)
				del(mymist)
				ismist = 0

/obj/machinery/shower/HasEntered(atom/movable/O)
	..()
	wash(O)
	if(ismob(O))
		mobpresent += 1
		check_heat(O)

/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mobpresent -= 1
	..()

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O as obj|mob)
	if(!on) return

	if(iscarbon(O))
		var/mob/living/carbon/M = O
		if(M.r_hand)
			M.r_hand.clean_blood()
		if(M.l_hand)
			M.l_hand.clean_blood()
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
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.gloves && washgloves)
				if(H.gloves.clean_blood())
					H.update_inv_gloves(0)
			if(H.shoes && washshoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
			if(H.wear_mask && washmask)
				if(H.wear_mask.clean_blood())
					H.update_inv_wear_mask(0)
			if(H.glasses && washglasses)
				if(H.glasses.clean_blood())
					H.update_inv_glasses(0)
			if(H.ears && washears)
				if(H.ears.clean_blood())
					H.update_inv_ears(0)
			if(H.belt)
				if(H.belt.clean_blood())
					H.update_inv_belt(0)
		else
			if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
				if(M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
	else
		O.clean_blood()

	if(isturf(loc))
		var/turf/tile = loc
		loc.clean_blood()
		for(var/obj/effect/E in tile)
			if(istype(E,/obj/effect/rune) || istype(E,/obj/effect/decal/cleanable) || istype(E,/obj/effect/overlay))
				del(E)

/obj/machinery/shower/process()
	if(!on || !mobpresent) return
	for(var/mob/living/carbon/C in loc)
		check_heat(C)

/obj/machinery/shower/proc/check_heat(mob/M as mob)
	if(!on || watertemp == "normal") return
	if(iscarbon(M))
		var/mob/living/carbon/C = M

		if(watertemp == "freezing")
			C.bodytemperature = max(80, C.bodytemperature - 80)
			C << "<span class='warning'>The water is freezing!</span>"
			return
		if(watertemp == "boiling")
			C.bodytemperature = min(500, C.bodytemperature + 35)
			C.adjustFireLoss(5)
			C << "<span class='danger'>The water is searing!</span>"
			return



/obj/item/weapon/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"



/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/sink/attack_hand(mob/M as mob)
	if(isrobot(M) || isAI(M))
		return

	if(busy)
		M << "\red Someone's already washing here."
		return

	var/turf/location = M.loc
	if(!isturf(location)) return
	usr << "\blue You start washing your hands."

	busy = 1
	sleep(40)
	busy = 0

	if(M.loc != location) return		//Person has moved away from the sink

	M.clean_blood()
	for(var/mob/V in viewers(src, null))
		V.show_message("\blue [M] washes their hands using \the [src].")

/obj/structure/sink/attackby(obj/item/O as obj, mob/user as mob)
	if(busy)
		user << "\red Someone's already washing here."
		return

	if (istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("\blue [user] fills the [RG] using \the [src].","\blue You fill the [RG] using \the [src].")
		return

	else if (istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if (B.charges > 0 && B.status == 1)
			flick("baton_active", src)
			user.Stun(10)
			user.stuttering = 10
			user.Weaken(10)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				B.charges--
			user.visible_message( \
				"[user] was stunned by his wet [O].", \
				"\red You have wet \the [O], it shocks you!")
			return

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item)) return

	usr << "\blue You start washing \the [I]."

	busy = 1
	sleep(40)
	busy = 0

	if(user.loc != location) return				//User has moved
	if(!I) return 								//Item's been destroyed while washing
	if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

	O.clean_blood()
	user.visible_message( \
		"\blue [user] washes \a [I] using \the [src].", \
		"\blue You wash \a [I] using \the [src].")


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"

/obj/structure/sink/puddle/attack_hand(mob/M as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O as obj, mob/user as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"