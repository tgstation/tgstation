/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
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

/obj/item/device/chameleon/equipped()
	..()
	disrupt()

/obj/item/device/chameleon/attack_self()
	toggle()

/obj/item/device/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity) return
	if(!check_sprite(target))
		return
	if(!active_dummy)
		if(istype(target,/obj/item) && !istype(target, /obj/item/weapon/disk/nuclear))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			var/obj/temp = new/obj()
			temp.appearance = target.appearance
			temp.layer = initial(target.layer) // scanning things in your inventory
			temp.plane = initial(target.plane)
			saved_appearance = temp.appearance

/obj/item/device/chameleon/proc/check_sprite(atom/target)
	if(target.icon_state in icon_states(target.icon))
		return TRUE
	return FALSE

/obj/item/device/chameleon/proc/toggle()
	if(!can_use || !saved_appearance) return
	if(active_dummy)
		eject_all()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		qdel(active_dummy)
		active_dummy = null
		to_chat(usr, "<span class='notice'>You deactivate \the [src].</span>")
		new /obj/effect/overlay/temp/emp/pulse(get_turf(src))
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(usr.loc)
		C.activate(usr, saved_appearance, src)
		to_chat(usr, "<span class='notice'>You activate \the [src].</span>")
		new /obj/effect/overlay/temp/emp/pulse(get_turf(src))

/obj/item/device/chameleon/proc/disrupt(delete_dummy = 1)
	if(active_dummy)
		for(var/mob/M in active_dummy)
			to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start()
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = 0
		spawn(50) can_use = 1

/obj/item/device/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.loc = active_dummy.loc
		if(ismob(A))
			var/mob/M = A
			M.reset_perspective(null)

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = 0
	var/can_move = 1
	var/obj/item/device/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(mob/M, saved_appearance, obj/item/device/chameleon/C)
	appearance = saved_appearance
	M.loc = src
	master = C
	master.active_dummy = src

/obj/effect/dummy/chameleon/attackby()
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
	if(isspaceturf(loc) || !direction)
		return //No magical space movement!

	if(can_move)
		can_move = 0
		switch(user.bodytemperature)
			if(300 to INFINITY)
				spawn(10) can_move = 1
			if(295 to 300)
				spawn(13) can_move = 1
			if(280 to 295)
				spawn(16) can_move = 1
			if(260 to 280)
				spawn(20) can_move = 1
			else
				spawn(25) can_move = 1
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
	return ..()
