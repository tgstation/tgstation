/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
<<<<<<< HEAD
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = 2
	origin_tech = "syndicate=4;magnets=4"
	var/can_use = 1
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_appearance = null

/obj/item/device/chameleon/New()
	..()
	var/obj/item/weapon/cigbutt/butt = /obj/item/weapon/cigbutt
	saved_appearance = initial(butt.appearance)

/obj/item/device/chameleon/dropped()
	..()
	disrupt()
=======
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	origin_tech = "syndicate=4;magnets=4"
	var/cham_proj_scan = 1 //Scanning function starts on
	var/can_use = 1
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_item = /obj/item/weapon/cigbutt
	var/saved_icon = 'icons/obj/clothing/masks.dmi'
	var/saved_icon_state = "cigbutt"
	var/saved_overlays

/obj/item/device/chameleon/dropped()
	spawn() //So the chammy project is dropped into the dummy before the dummy empties itself out
		disrupt()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/device/chameleon/equipped()
	disrupt()

/obj/item/device/chameleon/attack_self()
	toggle()

<<<<<<< HEAD
/obj/item/device/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity) return
	if(!active_dummy)
		if(istype(target,/obj/item) && !istype(target, /obj/item/weapon/disk/nuclear))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			user << "<span class='notice'>Scanned [target].</span>"
			var/obj/temp = new/obj()
			temp.appearance = target.appearance
			temp.layer = initial(target.layer) // scanning things in your inventory
			saved_appearance = temp.appearance

/obj/item/device/chameleon/proc/toggle()
	if(!can_use || !saved_appearance) return
	if(active_dummy)
		eject_all()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		qdel(active_dummy)
		active_dummy = null
		usr << "<span class='notice'>You deactivate \the [src].</span>"
		PoolOrNew(/obj/effect/overlay/temp/emp/pulse, get_turf(src))
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(usr.loc)
		C.activate(usr, saved_appearance, src)
		usr << "<span class='notice'>You activate \the [src].</span>"
		PoolOrNew(/obj/effect/overlay/temp/emp/pulse, get_turf(src))

/obj/item/device/chameleon/proc/disrupt(delete_dummy = 1)
	if(active_dummy)
		for(var/mob/M in active_dummy)
			M << "<span class='danger'>Your chameleon-projector deactivates.</span>"
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
=======
/obj/item/device/chameleon/verb/toggle_scaning()
	set name = "Toggle Chameleon Projector Scanning"
	set category = "Object"

	if(usr.isUnconscious())
		return

	cham_proj_scan = !cham_proj_scan
	to_chat(usr, "You [cham_proj_scan ? "activate":"deactivate"] [src]'s scanning function")

/obj/item/device/chameleon/preattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!cham_proj_scan) //Is scanning disabled ?
		return
	if(!active_dummy)
		if(istype(target, /obj/item) && !istype(target, /obj/item/weapon/disk/nuclear) || istype(target, /mob))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			saved_item = target.type
			saved_icon = target.icon
			saved_icon_state = target.icon_state
			saved_overlays = target.overlays
			return 1

/obj/item/device/chameleon/proc/toggle()
	if(!can_use || !saved_item)
		return
	if(active_dummy)
		eject_all()
		//playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		del(active_dummy)
		active_dummy = null
		to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)
		can_use = 0
		spawn(20) //Stop spamming this shit
			can_use = 1
	else
		//playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/O = new saved_item(src)
		if(!O)
			return
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(usr.loc)
		C.activate(O, usr, saved_icon, saved_icon_state, saved_overlays, src)
		qdel(O)
		O = null
		to_chat(usr, "<span class='notice'>You activate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)
		can_use = 0
		spawn(20) //Stop spamming this shit
			can_use = 1

/obj/item/device/chameleon/proc/disrupt(var/delete_dummy = 1)
	if(active_dummy)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start()
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = 0
<<<<<<< HEAD
		spawn(50) can_use = 1
=======
		spawn(50)
			can_use = 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/device/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.loc = active_dummy.loc
		if(ismob(A))
			var/mob/M = A
<<<<<<< HEAD
			M.reset_perspective(null)
=======
			M.reset_view(null)
			M.layer = MOB_LAYER //Reset the mob's layer
			M.plane = PLANE_MOB
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = 0
<<<<<<< HEAD
	var/can_move = 1
	var/obj/item/device/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(mob/M, saved_appearance, obj/item/device/chameleon/C)
	appearance = saved_appearance
	M.loc = src
=======
	anchored = 0
	var/can_move = 1
	var/obj/item/device/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(var/obj/O, var/mob/M, new_icon, new_iconstate, new_overlays, var/obj/item/device/chameleon/C)
	name = O.name
	desc = O.desc
	icon = new_icon
	icon_state = new_iconstate
	overlays = new_overlays
	dir = O.dir
	M.loc = src
	M.layer = OBJ_LAYER //Needed for some things, notably lockers
	M.plane = PLANE_OBJ
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	master = C
	master.active_dummy = src

/obj/effect/dummy/chameleon/attackby()
<<<<<<< HEAD
	master.disrupt()

/obj/effect/dummy/chameleon/attack_hand()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_animal()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_slime()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_alien()
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act(S, T)
	contents_explosion(S, T)
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	..()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(mob/user, direction)
	if(istype(loc, /turf/open/space) || !direction)
		return //No magical space movement!
=======
	for(var/mob/M in src)
		to_chat(M, "<span class='warning'>Your chameleon-projector deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/attack_hand()
	for(var/mob/M in src)
		to_chat(M, "<span class='warning'>Your chameleon-projector deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act()
	for(var/mob/M in src)
		to_chat(M, "<span class='warning'>Your chameleon-projector deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	for(var/mob/M in src)
		to_chat(M, "<span class='warning'>Your chameleon-projector deactivates.</span>")
	..()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(var/mob/user, direction)
	if(istype(loc, /turf/space)) return //No magical space movement!
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	if(can_move)
		can_move = 0
		switch(user.bodytemperature)
			if(300 to INFINITY)
<<<<<<< HEAD
				spawn(10) can_move = 1
			if(295 to 300)
				spawn(13) can_move = 1
			if(280 to 295)
				spawn(16) can_move = 1
			if(260 to 280)
				spawn(20) can_move = 1
			else
				spawn(25) can_move = 1
=======
				spawn(8)
					can_move = 1
			if(295 to 300)
				spawn(11)
					can_move = 1
			if(280 to 295)
				spawn(14)
					can_move = 1
			if(260 to 280)
				spawn(18)
					can_move = 1
			else
				spawn(23)
					can_move = 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
<<<<<<< HEAD
	return ..()
=======
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
