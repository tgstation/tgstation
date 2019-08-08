//Port from CEV eris
/obj/structure/railing
	name = "railing"
	desc = "A standard steel railing. Prevents stupid people from falling to their doom. Drag yourself onto it to climb over, or click it with an open hand whilst pulling something to dump it over the edge."
	icon = 'icons/obj/railing.dmi'
	density = TRUE
	climbable = TRUE
	anchored = TRUE
	icon_state = "railing0"
	layer = 3.2//Just above doors
	var/check = FALSE
	smooth = FALSE

/obj/structure/railing/attack_hand(mob/user) //Here's my own little addition. Click a railing while pulling something to dump it over. Nukeops, get in that locker, it's time to drop into the captain's office.
	. = ..()
	if(user.pulling)
		to_chat(user, "<span class='warning'>You start to dump [user.pulling] over [src]!</span>")
		if(do_after(user, 50, target = src))
			if(!user.pulling || QDELETED(user.pulling))
				return
			visible_message("<span class='warning'>[user] dumps [user.pulling] over [src]!</span>")
			user.pulling.forceMove(get_step(src, src.dir))

/obj/structure/railing/built //Player constructed
	anchored = FALSE

/obj/structure/railing/attackby(obj/item/I,mob/user)
	if(default_unfasten_wrench(user, I))
		update_icon()
		return FALSE
	. = ..()

/obj/structure/railing/AltClick(mob/user)
	. = ..()
	revrotate() //Rotate clockwise

/obj/structure/railing/Initialize(constructed=0)
	. = ..()
	if(anchored)
		START_PROCESSING(SSobj,src)
		update_icon(0)

/obj/structure/railing/process()
	. = ..()
	update_icon(0)

/obj/structure/railing/Destroy()
	anchored = null
	broken = 1
	for(var/obj/structure/railing/R in oview(src, 1))
		R.update_icon()
	. = ..()

/obj/structure/railing/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!mover)
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/railing/proc/NeighborsCheck(var/UpdateNeighbors = 1)
	check = 0
	//if (!anchored) return
	var/Rturn = turn(src.dir, -90)
	var/Lturn = turn(src.dir, 90)

	for(var/obj/structure/railing/R in src.loc)// Анализ клетки, где находится сам объект
		if ((R.dir == Lturn) && R.anchored)//Проверка левой стороны
			//src.LeftSide[1] = 1
			check |= 32
			if (UpdateNeighbors)
				R.update_icon(0)
		if ((R.dir == Rturn) && R.anchored)//Проверка правой стороны
			//src.RightSide[1] = 1
			check |= 2
			if (UpdateNeighbors)
				R.update_icon(0)

	for (var/obj/structure/railing/R in get_step(src, Lturn))//Анализ левой клетки от направления объекта
		if ((R.dir == src.dir) && R.anchored)
			//src.LeftSide[2] = 1
			check |= 16
			if (UpdateNeighbors)
				R.update_icon(0)
	for (var/obj/structure/railing/R in get_step(src, Rturn))//Анализ правой клетки от направления объекта
		if ((R.dir == src.dir) && R.anchored)
			//src.RightSide[2] = 1
			check |= 1
			if (UpdateNeighbors)
				R.update_icon(0)

	for (var/obj/structure/railing/R in get_step(src, (Lturn + src.dir)))//Анализ передней-левой диагонали относительно направления объекта.
		if ((R.dir == Rturn) && R.anchored)
			check |= 64
			if (UpdateNeighbors)
				R.update_icon(0)
	for (var/obj/structure/railing/R in get_step(src, (Rturn + src.dir)))//Анализ передней-правой диагонали относительно направления объекта.
		if ((R.dir == Lturn) && R.anchored)
			check |= 4
			if (UpdateNeighbors)
				R.update_icon(0)

/obj/structure/railing/update_icon(var/UpdateNeighgors = 1)
	NeighborsCheck(UpdateNeighgors)
	overlays.Cut()
	if (!check || !anchored)//|| !anchored
		icon_state = "railing0"
	else
		icon_state = "railing1"
		//левая сторона
		if (check & 32)
			overlays += image ('icons/obj/railing.dmi', src, "corneroverlay")
		if ((check & 16) || !(check & 32) || (check & 64))
			overlays += image ('icons/obj/railing.dmi', src, "frontoverlay_l")
		if (!(check & 2) || (check & 1) || (check & 4))
			overlays += image ('icons/obj/railing.dmi', src, "frontoverlay_r")
			if(check & 4)
				switch (src.dir)
					if (NORTH)
						overlays += image ('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_x = 32)
					if (SOUTH)
						overlays += image ('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_x = -32)
					if (EAST)
						overlays += image ('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_y = -32)
					if (WEST)
						overlays += image ('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_y = 32)

/obj/structure/railing/verb/rotate()
	set name = "Rotate Railing Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return 0

	if(anchored)
		to_chat(usr,"It is fastened to the floor therefore you can't rotate it!")
		return 0

	setDir(turn(dir, 90))
	update_icon()
	return

/obj/structure/railing/verb/revrotate()
	set name = "Rotate Railing Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return 0

	if(anchored)
		to_chat(usr,"It's fastened to the floor!")
		return 0

	setDir(turn(dir, -90))
	update_icon()
	return

/obj/structure/railing/verb/flip() // This will help push railing to remote places, such as open space turfs
	set name = "Flip Railing"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return 0

	if(anchored)
		to_chat(usr,"It is fastened to the floor therefore you can't flip it!")
		return 0

	src.loc = get_step(src, src.dir)
	setDir(turn(dir, 180))
	update_icon()
	return


/obj/structure/railing/do_climb(var/mob/living/user)
	if(get_turf(user) == get_turf(src))
		usr.forceMove(get_step(src, src.dir))
	else
		usr.forceMove(get_turf(src))

/obj/structure/railing/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1