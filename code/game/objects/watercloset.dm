//todo: flushing, flushing heads, showers actually cleaning people

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'watercloset.dmi'
	icon_state = "toilet0"
	density = 0
	anchored = 1
	var/open = 0

/obj/structure/toilet/New()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand()
	open = !open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open]"



/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1



/obj/structure/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'watercloset.dmi'
	icon_state = "shower"
	density = 0
	anchored = 1
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0	//needs a var so we can make it linger~

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'watercloset.dmi'
	icon_state = "mist"
	layer = MOB_LAYER + 1
	mouse_opacity = 0

/obj/structure/shower/attack_hand(mob/M as mob)
	on = !on
	update_icon()
	if(on && M.loc == loc)
		wash(M)

/obj/structure/shower/attackby(mob/M as mob)
	attack_hand(M)

/obj/structure/shower/update_icon()
	overlays = null
	if(mymist)
		del(mymist)

	if(on)
		overlays += image('watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
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

/obj/structure/shower/HasEntered(atom/movable/O as obj|mob)
	..()
	wash(O)

//Yes, showers are super powerful as far as washing goes.
/obj/structure/shower/proc/wash(atom/movable/O as obj|mob)
	..()
	if(!on) return

	O.clean_blood()

	if(istype(O, /mob/living/carbon))
		var/mob/living/carbon/monkey = O	//it's not necessarily a monkey, but >accurate varnames
		if(monkey.r_hand)
			monkey.r_hand.clean_blood()
		if(monkey.l_hand)
			monkey.l_hand.clean_blood()
		if(monkey.wear_mask)
			monkey.wear_mask.clean_blood()

		if(istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/washer = O
			if(washer.head)
				washer.head.clean_blood()
			if(washer.w_uniform)
				washer.w_uniform.clean_blood()
			if(washer.wear_suit)
				washer.wear_suit.clean_blood()
			if(washer.shoes)
				washer.shoes.clean_blood()
			if(washer.gloves)
				washer.gloves.clean_blood()
			if(washer.head)
				washer.head.clean_blood()

	if(loc)
		var/turf/tile = get_turf(loc)
		loc.clean_blood()
		for(var/obj/effect/rune/R in tile)
			del(R)
		for(var/obj/effect/decal/cleanable/R in tile)
			del(R)
		for(var/obj/effect/overlay/R in tile)
			del(R)



/obj/item/weapon/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"



/obj/structure/sink
	name = "sink"
	icon = 'watercloset.dmi'
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

	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/washer = C
			if(washer.gloves)					//if they have gloves
				washer.gloves.clean_blood()		//clean the gloves
			else								//and if they don't,
				washer.clean_blood()			//wash their hands (a mob being bloody means they are 'red handed')
		else
			C.clean_blood()						//other things that can't wear gloves should just wash the mob.
	for(var/mob/V in viewers(src, null))
		V.show_message(text("\blue [M] washes their hands using \the [src]."))

/obj/structure/sink/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(busy)
		user << "\red Someone's already washing here."
		return

	if (istype(O, /obj/item/weapon/reagent_containers/glass/bucket))
		O:reagents.add_reagent("water", 70)
		user.visible_message( \
			"\blue [user] fills the [O] using \the [src].", \
			"\blue You fill the [O] using \the [src].")
		return

	if (istype(O, /obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks))
		O:reagents.add_reagent("water", 10)
		user.visible_message( \
			"\blue [user] fills the [O] using \the [src].", \
			"\blue You fill the [O] using \the [src].")
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

/obj/structure/sink/puddle/attackby(var/obj/item/O as obj, var/mob/user as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"