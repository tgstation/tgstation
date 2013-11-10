var/const/SAFETY_COOLDOWN = 100

/obj/machinery/recycler
	name = "crusher"
	desc = "A large crushing machine which is used to recycle small items ineffeciently; there are lights on the side of it."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/grinding = 0
	var/icon_name = "grinder-o"
	var/blood = 0
	var/eat_from = WEST

/obj/machinery/recycler/New()
	// On us
	..()
	update_icon()

/obj/machinery/recycler/examine()
	set src in view()
	..()
	usr << "The power light is [(stat & NOPOWER) ? "off" : "on"]."
	usr << "The safety-mode light is [safety_mode ? "on" : "off"]."
	usr << "The safety-sensors status light is [emagged ? "off" : "on"]."

/obj/machinery/recycler/power_change()
	..()
	update_icon()

/obj/machinery/recycler/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		emagged = 1
		if(safety_mode)
			safety_mode = 0
			update_icon()
		playsound(src.loc, "sparks", 75, 1, -1)
	else
		..()

/obj/machinery/recycler/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end

/obj/machinery/recycler/Bumped(var/atom/movable/AM)

	// Crossed didn't like people lying down.
	if(stat & (BROKEN|NOPOWER))
		return
	if(safety_mode)
		return
	// If we're not already grinding something.
	if(!grinding)
		grinding = 1
		spawn(1)
			grinding = 0
	else
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_from)
		if(isliving(AM))
			if(emagged)
				eat(AM)
			else
				stop(AM)
		else if(istype(AM, /obj/item))
			recycle(AM)
		else // Can't recycle
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.loc = src.loc

/obj/machinery/recycler/proc/recycle(var/obj/item/I)
	I.loc = src.loc
	if(!istype(I, /obj/item/weapon/disk/nuclear))
		del(I)
		if(prob(15))
			new /obj/item/stack/sheet/metal(loc)
		if(prob(10))
			new /obj/item/stack/sheet/glass(loc)
		if(prob(2))
			new /obj/item/stack/sheet/plasteel(loc)
		if(prob(1))
			new /obj/item/stack/sheet/rglass(loc)
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)


/obj/machinery/recycler/proc/stop(var/mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/recycler/proc/eat(var/mob/living/L)

	L.loc = src.loc
	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	if(ishuman(L))
		L.say("ARRRRRRRRRRRGH!!!")

	L.gib()

	if(!blood)
		blood = 1
		update_icon()


/obj/item/weapon/paper/recycler
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"