/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'hippiestation/icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	w_class = 2
	var/structuretype = /obj/structure/inflatable

/obj/item/inflatable/attack_self(mob/user)
	if(locate(/obj/structure/inflatable) in user.loc)
		to_chat(user, "<span class='warning'>You cannot place inflatable walls upon eachother!</span>")
		return
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	if(do_mob(user, src, 10))
		var/obj/structure/inflatable/R = new structuretype(user.loc)
		transfer_fingerprints_to(R)
		R.add_fingerprint(user)
		qdel(src)

/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	density = 1
	anchored = 1
	opacity = 0
	icon = 'hippiestation/icons/obj/inflatable.dmi'
	icon_state = "wall"
	var/health = 20
	var/torntype = /obj/item/inflatable/torn
	var/itemtype = /obj/item/inflatable

/obj/structure/inflatable/Initialize(location)
	. = ..()
	air_update_turf(1)

/obj/structure/inflatable/Destroy()
	air_update_turf(1)
	return ..()

/obj/structure/inflatable/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 0

/obj/structure/inflatable/CanAtmosPass(turf/T)
	return !density

/obj/structure/inflatable/bullet_act(var/obj/item/projectile/Proj)
	..()
	hit(Proj.damage)

/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			deflate(1)
			return
		if(3)
			if(prob(50))
				deflate(1)
				return

/obj/structure/inflatable/blob_act()
	deflate(1)

/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)
	..()

/obj/structure/inflatable/attack_generic(mob/user, damage as num)
	health -= damage
	if(health <= 0)
		user.visible_message("<span class='danger'>[user] tears open [src]!</span>")
		deflate(1)
	else
		user.visible_message("<span class='danger'>[user] tears at [src]!</span>")

/obj/structure/inflatable/attack_alien(mob/user)
	if(islarva(user))
		return
	attack_generic(user, 15)

/obj/structure/inflatable/attack_animal(mob/user)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/inflatable/attack_slime(mob/user)
	attack_generic(user, rand(10, 15))

/obj/structure/inflatable/attackby(obj/item/weapon/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!istype(W))
		return
	if(W.is_sharp())
		visible_message("<span class='danger'><b>[user] pierces [src] with [W]!</b></span>")
		deflate(1)
	if(W.damtype == BRUTE || W.damtype == BURN)
		hit(W.force)
		..()

/obj/structure/inflatable/proc/hit(damage, sound_effect = TRUE)
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	if(health <= 0)
		deflate(1)

/obj/structure/inflatable/AltClick()
	if(usr.stat || usr.restrained())
		return
	if(!Adjacent(usr))
		return
	deflate()

/obj/structure/inflatable/proc/deflate(violent)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	var/obj/item/inflatable/R
	if(violent)
		visible_message("<span class='danger'>[src] rapidly deflates!</span>")
		R = new torntype(loc)
	else
		visible_message("<span class='danger'>[src] slowly deflates.</span>")
		sleep(50)
		R = new itemtype(loc)
	transfer_fingerprints_to(R)
	density = 0
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || usr.restrained())
		return
	deflate()

/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon = 'hippiestation/icons/obj/inflatable.dmi'
	icon_state = "folded_door"
	structuretype = /obj/structure/inflatable/door

/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"
	density = 1
	anchored = 1
	opacity = 0
	icon = 'hippiestation/icons/obj/inflatable.dmi'
	icon_state = "door_closed"
	torntype = /obj/item/inflatable/torn/door
	itemtype = /obj/item/inflatable/door
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0

/obj/structure/inflatable/door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group)
		return state
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/CanAtmosPass(turf/T)
	return !density

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/mecha))
		SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()
	air_update_turf(1)

/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = 1
	flick("door_opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = 1
	flick("door_closing",src)
	sleep(10)
	density = 1
	opacity = 0
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/structure/inflatable/door/deflate(violent)
	..()
	air_update_turf(1)

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon = 'hippiestation/icons/obj/inflatable.dmi'
	icon_state = "folded_wall_torn"
	var/fixedtype = /obj/item/inflatable

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='warning'>The inflatable wall is too torn to be inflated, fix it with something!</span>")
	add_fingerprint(user)

/obj/item/inflatable/torn/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/ducttape))
		var/obj/item/stack/ducttape/T = I
		if(T.amount < 2)
			to_chat(user, "<span class='danger'>There is not enough tape!</span>")
			return
		to_chat(user, "<span class='notice'>You begin fixing the [src]!</span>")
		playsound(user, 'hippiestation/sound/misc/ducttape1.ogg', 50, 1)
		if(do_mob(user, src, 20))
			to_chat(user, "<span class='notice'>You fix the [src] using the ducttape!</span>")
			T.use(2)
			new fixedtype(user.loc)
			qdel(src)

/obj/item/inflatable/torn/door
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon = 'hippiestation/icons/obj/inflatable.dmi'
	icon_state = "folded_door_torn"
	fixedtype = /obj/item/inflatable/door

/obj/item/weapon/storage/inflatable
	icon = 'hippiestation/icons/obj/storage.dmi'
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf"
	item_state = "syringe_kit"
	max_combined_w_class = 21
	w_class = 3

/obj/item/weapon/storage/inflatable/Initialize()
	..()
	for(var/i = 0, i < 8, i++)
		new /obj/item/inflatable/door(src)
	for(var/i = 0, i < 16, i ++)
		new /obj/item/inflatable(src)

/obj/item/inflatable/suicide_act(mob/living/user)
	visible_message(user, "<span class='danger'>[user] starts shoving the [src] up his ass! It looks like hes going to pull the cord, oh shit!</span>")
	playsound(user.loc, 'sound/machines/hiss.ogg', 75, 1)
	new structuretype(user.loc)
	user.gib()
	return BRUTELOSS