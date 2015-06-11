#define RCLMAX 30

/obj/item/weapon/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	opacity = 0
	flags = FPRINT
	siemens_coefficient = 1 //Not quite as conductive as working with cables themselves
	force = 5.0 //Plastic is soft
	throwforce = 5.0
	throw_speed = 1
	throw_range = 10
	w_class = 3.0
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = "engineering=2;materials=4"
	//var/active = 0 Depreciated; Leaving it because it is a useful framework tool if you want to make it automagically place on movement
	var/obj/structure/cable/last = null
	var/obj/item/stack/cable_coil/loaded = null

/obj/item/weapon/rcl/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil))
		if(!loaded)
			loaded = W
			user.drop_item(W,src)
		else
			loaded.preattack(W,user,1)
		update_icon()
		user << "<span class='notice'>You add the cables to the [src]. It now contains [loaded.amount].</span>"
	else
		..()

/obj/item/weapon/rcl/examine(mob/user)
	..()
	user << "<span class='info'>It contains [loaded.amount]/30 cables.</span>"

/obj/item/weapon/rcl/update_icon()
	if(!loaded)
		icon_state = "rcl-0"
		item_state = "rcl-0"
		return
	switch(loaded.amount)
		if(21 to INFINITY)
			icon_state = "rcl-30"
			item_state = "rcl"
		if(11 to 20)
			icon_state = "rcl-20"
			item_state = "rcl"
		if(1 to 10)
			icon_state = "rcl-10"
			item_state = "rcl"
		else
			icon_state = "rcl-0"
			item_state = "rcl-0"

/obj/item/weapon/rcl/proc/is_empty(mob/user)
	update_icon()
	if(!loaded.amount)
		user << "<span class='notice'>The last of the cables unreel from the [src].</span>"
		loaded = null
		return 1
	return 0

/*/obj/item/weapon/rcl/dropped(mob/wearer as mob)
	..()
	active = 0*/

/obj/item/weapon/rcl/attack_ai(mob/user as mob)
	user << "<span class='warning'>\The [src] slips out of your utility claw!<span class='warning'>"
	return //MoMMIs can't hold this

/obj/item/weapon/rcl/attack_self(mob/user as mob)
	if(!loaded)
		user << "<span class='warning'>The [src] is empty!</span>"
		return
	if(last)
		if(get_dist(last, user) == 0) //hacky, but it works
			last = null
		else if(get_dist(last, user) == 1)
			if(get_dir(last, user)==last.d2)
				//Did we just walk backwards? Well, that's the one direction we CAN'T complete a stub.
				last = null
				return
			loaded.cable_join(last,user)
			if(is_empty(user)) return //If we've run out, display message and exit
		else
			last = null
	last = loaded.turf_place(get_turf(src.loc),user,turn(user.dir,180))
	is_empty(user) //If we've run out, display message


/obj/item/weapon/rcl/verb/eject()
	set name = "Eject wires"
	set category = "Object"
	set src in view(0)
	usr << "<span class='notice'>You pull out the wires.</span>"
	loaded.loc = usr.loc
	usr.put_in_hands(loaded)
	loaded = null
	update_icon()
