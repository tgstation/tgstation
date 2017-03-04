/*Composed of 7 parts :

 3 Particle Emitters
 1 Power Box
 1 Fuel Chamber
 1 End Cap
 1 Control computer

 Setup map

   |EC|
 CC|FC|
   |PB|
 PE|PE|PE

*/
#define PA_CONSTRUCTION_UNSECURED  0
#define PA_CONSTRUCTION_UNWIRED    1
#define PA_CONSTRUCTION_PANEL_OPEN 2
#define PA_CONSTRUCTION_COMPLETE   3

/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	anchored = 0
	density = 1
	obj_integrity = 500
	max_integrity = 500
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 90, acid = 80)

	var/obj/machinery/particle_accelerator/control_box/master = null
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/reference = null
	var/powered = 0
	var/strength = null

/obj/structure/particle_accelerator/examine(mob/user)
	..()

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			user << "Looks like it's not attached to the flooring"
		if(PA_CONSTRUCTION_UNWIRED)
			user << "It is missing some cables"
		if(PA_CONSTRUCTION_PANEL_OPEN)
			user << "The panel is open"

	user << "<span class='notice'>Alt-click to rotate it clockwise.</span>"

/obj/structure/particle_accelerator/Destroy()
	construction_state = PA_CONSTRUCTION_UNSECURED
	if(master)
		master.connected_parts -= src
		master.assembled = 0
		master = null
	return ..()

/obj/structure/particle_accelerator/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (anchored)
		usr << "It is fastened to the floor!"
		return 0
	setDir(turn(dir, -90))
	return 1

/obj/structure/particle_accelerator/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/structure/particle_accelerator/verb/rotateccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (anchored)
		usr << "It is fastened to the floor!"
		return 0
	setDir(turn(dir, 90))
	return 1

/obj/structure/particle_accelerator/attackby(obj/item/W, mob/user, params)
	var/did_something = FALSE

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(istype(W, /obj/item/weapon/wrench) && !isinspace())
				playsound(loc, W.usesound, 75, 1)
				anchored = 1
				user.visible_message("[user.name] secures the [name] to the floor.", \
					"You secure the external bolts.")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
		if(PA_CONSTRUCTION_UNWIRED)
			if(istype(W, /obj/item/weapon/wrench))
				playsound(loc, W.usesound, 75, 1)
				anchored = 0
				user.visible_message("[user.name] detaches the [name] from the floor.", \
					"You remove the external bolts.")
				construction_state = PA_CONSTRUCTION_UNSECURED
				did_something = TRUE
			else if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/CC = W
				if(CC.use(1))
					user.visible_message("[user.name] adds wires to the [name].", \
						"You add some wires.")
					construction_state = PA_CONSTRUCTION_PANEL_OPEN
					did_something = TRUE
		if(PA_CONSTRUCTION_PANEL_OPEN)
			if(istype(W, /obj/item/weapon/wirecutters))//TODO:Shock user if its on?
				user.visible_message("[user.name] removes some wires from the [name].", \
					"You remove some wires.")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
			else if(istype(W, /obj/item/weapon/screwdriver))
				user.visible_message("[user.name] closes the [name]'s access panel.", \
					"You close the access panel.")
				construction_state = PA_CONSTRUCTION_COMPLETE
				did_something = TRUE
		if(PA_CONSTRUCTION_COMPLETE)
			if(istype(W, /obj/item/weapon/screwdriver))
				user.visible_message("[user.name] opens the [name]'s access panel.", \
					"You open the access panel.")
				construction_state = PA_CONSTRUCTION_PANEL_OPEN
				did_something = TRUE

	if(did_something)
		user.changeNext_move(CLICK_CD_MELEE)
		update_state()
		update_icon()
		return

	return ..()


/obj/structure/particle_accelerator/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/structure/particle_accelerator/Move()
	..()
	if(master && master.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it <font color='red'>powered down</font>.","singulo")


/obj/structure/particle_accelerator/update_icon()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED,PA_CONSTRUCTION_UNWIRED)
			icon_state="[reference]"
		if(PA_CONSTRUCTION_PANEL_OPEN)
			icon_state="[reference]w"
		if(PA_CONSTRUCTION_COMPLETE)
			if(powered)
				icon_state="[reference]p[strength]"
			else
				icon_state="[reference]c"

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()

/obj/structure/particle_accelerator/proc/connect_master(obj/O)
	if(O.dir == dir)
		master = O
		return 1
	return 0

///////////
// PARTS //
///////////


/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc = "This is where Alpha particles are generated from \[REDACTED\]"
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/power_box
	name = "Particle Focusing EM Lens"
	desc = "This uses electromagnetic waves to focus the Alpha-Particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "power_box"
	reference = "power_box"

/obj/structure/particle_accelerator/fuel_chamber
	name = "EM Acceleration Chamber"
	desc = "This is where the Alpha particles are accelerated to <b><i>radical speeds</i></b>."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "fuel_chamber"
	reference = "fuel_chamber"
