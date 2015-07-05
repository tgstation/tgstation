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


/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='userdanger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='italics'>You hear reverberating porcelain.</span>")
		swirlie.adjustBruteLoss(5)
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
			user << "<span class='notice'>You find [I] in the cistern.</span>"
			w_items -= I.w_class
			return

	open = !open
	update_icon()


/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"


/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user << "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]...</span>"
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>You hear grinding porcelain.</span>")
			cistern = !cistern
			update_icon()
			return

	if(istype(I, /obj/item/weapon/grab))
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/grab/G = I
		if(!G.confirm())
			return
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state >= GRAB_AGGRESSIVE)
				if(GM.loc != get_turf(src))
					user << "<span class='warning'>[GM] needs to be on [src]!</span>"
					return
				if(!swirlie)
					if(open)
						GM.visible_message("<span class='danger'>[user] starts to give [GM] a swirlie!</span>", "<span class='userdanger'>[user] starts to give [GM] a swirlie...</span>")
						swirlie = GM
						if(do_after(user, 30, 5, 0, target = src))
							GM.visible_message("<span class='danger'>[user] gives [GM] a swirlie!</span>", "<span class='userdanger'>[user] gives [GM] a swirlie!</span>", "<span class='italics'>You hear a toilet flushing.</span>")
							if(iscarbon(GM))
								var/mob/living/carbon/C = GM
								if(!C.internal)
									C.adjustOxyLoss(5)
							else
								GM.adjustOxyLoss(5)
						swirlie = null
					else
						playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
						GM.visible_message("<span class='danger'>[user] slams [GM.name] into [src]!</span>", "<span class='userdanger'>[user] slams [GM.name] into [src]!</span>")
						GM.adjustBruteLoss(5)
			else
				user << "<span class='warning'>You need a tighter grip!</span>"

	if(cistern)
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
		return



/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1


/obj/structure/urinal/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(!G.confirm())
			return
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state >= GRAB_AGGRESSIVE)
				if(GM.loc != get_turf(src))
					user << "<span class='notice'>[GM.name] needs to on [src].</span>"
					return
				user.visible_message("<span class='danger'>[user] slams [GM] into [src]!</span>", "<span class='notice'>You slam [GM] into [src]!</span>")
				GM.adjustBruteLoss(8)
			else
				user << "<span class='warning'>You need a tighter grip!</span>"


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
	var/mobpresent = 0		//true if there is a mob on the shower's loc, this is to ease process()


/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = MOB_LAYER + 1
	anchored = 1
	mouse_opacity = 0


/obj/machinery/shower/attack_hand(mob/M)
	on = !on
	update_icon()
	add_fingerprint(M)
	if(on)
		for (var/atom/movable/G in loc)
			wash(G)
	else
		if(istype(loc, /turf/simulated))
			var/turf/simulated/tile = loc
			tile.MakeSlippery()


/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.type == /obj/item/device/analyzer)
		user << "<span class='notice'>The water temperature seems to be [watertemp].</span>"
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin to adjust the temperature valve with \the [I]...</span>"
		if(do_after(user, 50, target = src))
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
	overlays.Cut()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)

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
			if(src && !on && mymist)
				qdel(mymist)
				ismist = 0


/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	wash(O)
	if(iscarbon(O) && on)
		var/mob/living/carbon/M=O
		M.slip(4,2,null,NO_SLIP_WHEN_WALKING)



/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mobpresent -= 1
	..()


//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O)
	if(!on) return

	if(ismob(O))
		mobpresent += 1
		check_heat(O)
	if(isliving(O))
		var/mob/living/L = O
		L.ExtinguishMob()
		L.fire_stacks = -20 //Douse ourselves with water to avoid fire more easily
		L << "<span class='warning'>You're drenched in water!</span>"
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
				if(H.wear_mask)
					if(washmask)
						if(H.wear_mask.clean_blood())
							H.update_inv_wear_mask(0)
				else
					H.lip_style = null
					H.update_body()
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

	else
		O.clean_blood()

		if(istype(O,/obj/item))
			var/obj/item/Item = O
			Item.extinguish()

	if(isturf(loc))
		var/turf/tile = loc
		loc.clean_blood()
		for(var/obj/effect/E in tile)
			if(is_cleanable(E))
				qdel(E)

/obj/machinery/shower/process()
	if(!on || !mobpresent) return
	for(var/mob/living/carbon/C in loc)
		check_heat(C)



/obj/machinery/shower/proc/check_heat(mob/M)
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


/obj/structure/sink/attack_hand(mob/user)
	if(isrobot(user) || isAI(user))
		return
	if(!Adjacent(user))
		return

	if(busy)
		user << "<span class='notice'>Someone's already washing here.</span>"
		return

	user << "<span class='notice'>You start washing your hands...</span>"

	busy = 1
	sleep(40)
	busy = 0

	if(!Adjacent(user)) return		//Person has moved away from the sink

	user.clean_blood()
	user.visible_message("[user] washes their hands in [src].", "<span class='notice'>You wash your hands in [src].</span>")


/obj/structure/sink/attackby(obj/item/O, mob/user, params)
	if(busy)
		user << "<span class='warning'>Someone's already washing here!</span>"
		return

	if(istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user << "<span class='notice'>You fill [RG] from [src].</span>"
		return

	if(istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if(B.bcell)
			if(B.bcell.charge > 0 && B.status == 1)
				flick("baton_active", src)
				user.Stun(10)
				user.stuttering = 10
				user.Weaken(10)
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					R.cell.charge -= 20
				else
					B.deductcharge(B.hitcost)
				user.visible_message( \
					"<span class='danger'>[user] was stunned by \his wet [O]!</span>", \
					"<span class='userdanger'>[user] was stunned by \his wet [O]!</span>")
				return

	if(istype(O, /obj/item/weapon/mop))
		O.reagents.add_reagent("water", 5)
		user << "<span class='notice'>You wet [O] in [src].</span>"
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item)) return

	usr << "<span class='notice'>You start washing [I]...</span>"

	busy = 1
	sleep(40)
	busy = 0

	if(user.loc != location) return				//User has moved
	if(!I) return 								//Item's been destroyed while washing
	if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

	O.clean_blood()
	user.visible_message( \
		"[user] washes [I] using [src].", \
		"<span class='notice'>You wash [I] using [src].</span>")


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

/obj/structure/sink/puddle/attackby(obj/item/O as obj, mob/user as mob, params)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"