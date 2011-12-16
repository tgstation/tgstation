//NOTE:
//This file contains the worst code ive ever written.
//I dont fucking care. It looks pretty awesome.

//////////////////////////////////////////////////////////
/obj/effect/dummy/liquid
	name = "water"
	icon = 'effects.dmi'
	icon_state = "nothing"
	invisibility = 101
	var/canmove = 1
	density = 0
	anchored = 1

/obj/item/weapon/vial
	name = "glass vial"
	icon = 'chemical.dmi'
	desc = "a glass vial filled with a strange liquid"
	icon_state = "vialgreen"
	item_state = "vialgreen"
	throwforce = 3.0
	throw_speed = 1
	throw_range = 8
	force = 3.0
	w_class = 1.0

/obj/item/weapon/vial/green
	name = "glass vial"
	icon = 'chemical.dmi'
	desc = "a glass vial filled with a strange green liquid"
	icon_state = "vialgreen"
	item_state = "vialgreen"

/obj/item/weapon/vial/blue
	name = "glass vial"
	icon = 'chemical.dmi'
	desc = "a glass vial filled with a shimmering blue liquid"
	icon_state = "vialblue"
	item_state = "vialblue"
//////////////////////////////////////////////////////////

///////////////////////////////////////////////////////***
/obj/item/weapon/vial/attack(target as mob, mob/user as mob)
	if(target == user) return attack_self(user)
	user << "\blue The vial shatters."
	src.shatter()
/obj/item/weapon/vial/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	user << "\blue The vial shatters."
	src.shatter()
/obj/item/weapon/vial/attack_self(mob/user as mob)
	user << "\blue You uncork the vial and drink the liquid."
	src.drink(user)
/obj/item/weapon/vial/proc/shatter()
	return
/obj/item/weapon/vial/proc/drink(user)
	return
///////////////////////////////////////////////////////***

/////////////////////////////////////////////////////green
/obj/item/weapon/vial/green/drink(mob/living/user as mob)
	var/A = src
	src = null
	del(A)
	switch(pick(1,2,3))
		if(1)
			spawn(300)
				user.gib()
		if(2)
			user.Weaken(5)
			user.contract_disease(new /datum/disease/gbs,1)
		if(3)
			spawn(200)
				user.contract_disease(new /datum/disease/gbs,1)

/obj/item/weapon/vial/green/shatter()
	var/A = src
	var/atom/sourceloc = get_turf(src.loc)
	src = null
	del(A)
	var/obj/effect/overlay/O = new /obj/effect/overlay( sourceloc )
	var/obj/effect/overlay/O2 = new /obj/effect/overlay( sourceloc )
	O.name = "green liquid"
	O.density = 0
	O.anchored = 1
	O.icon = 'effects.dmi'
	O.icon_state = "greenshatter"
	O2.name = "broken bits of glass"
	O2.density = 0
	O2.anchored = 1
	O2.icon = 'objects.dmi'
	O2.icon_state = "shards"
	for(var/mob/living/carbon/human/H in view(5, sourceloc))
		H.contract_disease(new /datum/disease/gbs,1)
	var/i
	for(i=0, i<5, i++)
		for(var/mob/living/carbon/human/H in view(5, sourceloc))
			H.contract_disease(new /datum/disease/gbs,1)
		sleep(20)
	flick("greenshatter2",O)
	O.icon_state = "nothing"
	sleep(5)
	del(O)
/////////////////////////////////////////////////////green

/////////////////////////////////////////////////////blue
/obj/item/weapon/vial/blue/drink(user)
	var/A = src
	var/atom/sourceloc = get_turf(src.loc)
	src = null
	del(A)

	var/obj/effect/overlay/O = new /obj/effect/overlay( sourceloc )
	var/obj/effect/overlay/O2 = new /obj/effect/overlay( sourceloc )

	O.name = "green liquid"
	O.density = 0
	O.anchored = 1
	O.icon = 'effects.dmi'
	O.icon_state = "blueshatter"
	O2.name = "broken bits of glass"
	O2.density = 0
	O2.anchored = 1
	O2.icon = 'objects.dmi'
	O2.icon_state = "shards"

	liquify(user)

	sleep(20)
	flick("blueshatter2",O)
	O.icon_state = "nothing"
	sleep(5)
	del(O)

/obj/item/weapon/vial/blue/shatter()

	var/A = src
	var/atom/sourceloc = get_turf(src.loc)
	src = null
	del(A)

	var/obj/effect/overlay/O = new /obj/effect/overlay( sourceloc )
	var/obj/effect/overlay/O2 = new /obj/effect/overlay( sourceloc )

	O.name = "green liquid"
	O.density = 0
	O.anchored = 1
	O.icon = 'effects.dmi'
	O.icon_state = "blueshatter"
	O2.name = "broken bits of glass"
	O2.density = 0
	O2.anchored = 1
	O2.icon = 'objects.dmi'
	O2.icon_state = "shards"

	for(var/mob/living/carbon/human/H in view(1, sourceloc))
		liquify(H)

	sleep(20)
	flick("blueshatter2",O)
	O.icon_state = "nothing"
	sleep(5)

	del(O)

/proc/liquify(var/mob/H, time = 150)

	if(H.stat) return
	spawn(0)
		var/mobloc = get_turf(H.loc)
		var/obj/effect/dummy/liquid/holder = new /obj/effect/dummy/liquid( mobloc )
		var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		flick("liquify",animation)
		H.canmove = 0
		sleep(4)
		H.loc = holder
		H.canmove = 1
		H.client.eye = holder
		spawn(0)
			var/i
			for(i=0, i<10, i++)
				spawn(0)
					var/obj/effect/effect/water/water1 = new /obj/effect/effect/water( mobloc )
					var/direction = pick(alldirs)
					water1.name = "water"
					water1.density = 0
					water1.icon = 'water.dmi'
					water1.icon_state = "extinguish"
					for(i=0, i<pick(1,2,3), i++)
						sleep(5)
						step(water1,direction)
					spawn(20)
						del(water1)

		sleep(time)
		H.canmove = 0
		mobloc = get_turf(H.loc)
		animation.loc = mobloc
		var/b
		for(b=0, b<10, b++)
			spawn(0)
				var/turf = mobloc
				var/direction = pick(alldirs)
				var/c
				for(c=0, c<pick(1,2,3), c++)
					turf = get_step(turf,direction)
				var/obj/effect/effect/water/water2 = new /obj/effect/effect/water( turf )
				water2.name = "water"
				water2.icon = 'water.dmi'
				water2.icon_state = "extinguish"
				walk_to(water2,mobloc,-1,5)
				sleep(20)
				del(water2)

		sleep(20)
		flick("reappear",animation)
		sleep(5)
		H.loc = mobloc
		H.canmove = 1
		H.client.eye = H
		del(animation)
		del(holder)


/obj/effect/dummy/liquid/relaymove(var/mob/user, direction)
	if (!src.canmove) return
	//writing my own movement because step is broken.
	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x--
	src.canmove = 0
	spawn(20) canmove = 1

/obj/effect/dummy/liquid/ex_act(blah)
	return
/obj/effect/dummy/liquid/bullet_act(blah,blah)
	return


///atom/relaymove - change to obj to restore

/obj/relaymove(var/mob/user, direction) //testing something
	//if(anchored) return
	//step(src, direction)

/proc/possess(obj/O as obj in world)
	set name = "Possess Obj"
	set category = "Object"

	if(istype(O,/obj/machinery/singularity))
		if(config.forbid_singulo_possession)
			usr << "It is forbidden to possess singularities."
			return

	var/turf/T = get_turf(O)

	if(T)
		log_admin("[key_name(usr)] has possessed [O] ([O.type]) at ([T.x], [T.y], [T.z])")
		message_admins("[key_name(usr)] has possessed [O] ([O.type]) at ([T.x], [T.y], [T.z])", 1)
	else
		log_admin("[key_name(usr)] has possessed [O] ([O.type]) at an unknown location")
		message_admins("[key_name(usr)] has possessed [O] ([O.type]) at an unknown location", 1)

	if(!usr.control_object) //If you're not already possessing something...
		usr.name_archive = usr.real_name

	usr.loc = O
	usr.real_name = O.name
	usr.name = O.name
	usr.client.eye = O
	usr.control_object = O

/proc/release(obj/O as obj in world)
	set name = "Release Obj"
	set category = "Object"
	//usr.loc = get_turf(usr)

	if(usr.control_object && usr.name_archive) //if you have a name archived and if you are actually relassing an object
		usr.real_name = usr.name_archive
		usr.name = usr.real_name
		usr.update_clothing() //So the name is updated properly

	usr.loc = O.loc // Appear where the object you were controlling is -- TLE
	usr.client.eye = usr
	usr.control_object = null


/proc/givetestverbs(mob/M as mob in world)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"
	M.verbs += /proc/possess
	M.verbs += /proc/release

/////////////////////////////////////////////////////blue