// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light-open"
	anchored = 1.0
	var/on = 1
	var/area/area = null
	var/otherarea = null
	var/opened = 0 //0=closed, 1=opened
	var/wired = 1
	var/tdir = null
	var/datum/effect/effect/system/spark_spread/spark_system // the spark system, used for generating... sparks?
	//	luminosity = 1

/obj/machinery/light_switch/New(turf/loc, var/ndir, var/building=0)
	..()

	if (building)
		// offset 24 pixels in direction of dir
		// this allows the APC to be embedded in a wall, yet still inside an area
		dir = ndir
		src.tdir = dir		// to fix Vars bug
		dir = SOUTH

		pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
		pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0
		opened = 1
		wired = 0
		on = 0
	else
		icon_state = "light1"

	// Sets up a spark system
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spawn(5)
		src.area = src.loc.loc

		if(otherarea)
			src.area = locate(text2path("/area/[otherarea]"))

		if(!name)
			name = "light switch ([area.name])"

		src.on = src.area.lightswitch
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		updateicon()


/obj/machinery/light_switch/proc/updateicon()
	if(!opened)
		if(stat & NOPOWER)
			icon_state = "light-p"
			return
		else if(on && wired)
			icon_state = "light1"
			return
		icon_state = "light0"
		return
	else
		icon_state = "light-open"
		if(wired)
			icon_state = "light-open-1"

/obj/machinery/light_switch/examine()
	set src in oview(1)
	if(usr && !usr.stat)
		usr << "A light switch. It is [on? "on" : "off"]."


/obj/machinery/light_switch/attack_paw(mob/user)
	src.attack_hand(user)

/obj/machinery/light_switch/attack_hand(mob/user)
	if(!opened && wired)
		on = !on

		for(var/area/A in area.master.related)
			A.lightswitch = on
			A.updateicon()

			for(var/obj/machinery/light_switch/L in A)
				L.on = on
				L.updateicon()

		area.master.power_change()
	else
		if(opened)
			user << "[src] cover must be closed to use."
		else
			if(wired)
				user << "Nothing happens..."

/obj/machinery/light_switch/attackby(obj/item/W, mob/user)
	src.add_fingerprint(usr)
	var/mob/living/carbon/human/U = user
	if (istype(W, /obj/item/weapon/screwdriver))
		//close unit
		user.visible_message(\
			"[user] has [opened? "closed" : "opened"] the [src]",\
			"You [opened? "close" : "open"] the [src].")
		opened = !opened
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		updateicon()
	else if(istype(W, /obj/item/weapon/cable_coil))
		if(opened && !wired)
			//add wires
			var/obj/item/weapon/cable_coil/C = W
			if(C.amount < 1)
				user << "\red You need more wires."
				return
			C.use(1)
			wired = 1
			on = 0;

			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message(\
				"[user] has wired the [src]",\
				"You wire the [src].")
			updateicon()
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(opened && wired)
			if(on)
				var/siemens_coeff = 1
				if(!istype(user))
					return

				if(!(stat & (NOPOWER|BROKEN)))
					src.spark_system.start() // creates some sparks because they look cool

				//Has gloves?
				if(U.gloves)
					var/obj/item/clothing/gloves/G = U.gloves
					siemens_coeff = G.siemens_coefficient

				if((siemens_coeff > 0) && !(stat & (NOPOWER|BROKEN)))
					U.electrocute_act(10, src,1,1)//The last argument is a safety for the human proc that checks for gloves.

					return
			//remove wires
			wired = 0
			user.visible_message(\
				"[user] has unwired the [src]",\
				"You unwire the [src].")
			playsound(src.loc, 'sound/items/wirecutter.ogg', 50, 1)
			updateicon()
			new /obj/item/weapon/cable_coil( get_turf(src.loc), 1 )

/obj/machinery/light_switch/power_change()

	if(!otherarea)
		if(powered(LIGHT))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER

		updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)