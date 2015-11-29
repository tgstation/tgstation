/obj/item/weapon/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/electronics.dmi', "right_hand" = 'icons/mob/in-hand/right/electronics.dmi')
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
	var/max_amount = 90
	var/active = 0
	var/obj/structure/cable/last = null
	var/obj/item/stack/cable_coil/loaded = null

/obj/item/weapon/rcl/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil))
		if(!loaded)
			loaded = W
			loaded.max_amount = max_amount //We store a lot.
			user.drop_item(W,src)
		else
			loaded.preattack(W,user,1)
		update_icon()
		to_chat(user, "<span class='notice'>You add the cables to the [src]. It now contains [loaded.amount].</span>")
	else if(isscrewdriver(W))
		if(!loaded) return
		to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
		while(loaded.amount>30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
			var/diff = loaded.amount % 30
			if(diff)
				loaded.use(diff)
				getFromPool(/obj/item/stack/cable_coil,user.loc,diff)
			else
				loaded.use(30)
				getFromPool(/obj/item/stack/cable_coil,user.loc,30)
		loaded.max_amount = initial(loaded.max_amount)
		loaded.loc = user.loc
		user.put_in_hands(loaded)
		loaded = null
		update_icon()
	else
		..()

/obj/item/weapon/rcl/examine(mob/user)
	..()
	if(loaded)
		to_chat(user, "<span class='info'>It contains [loaded.amount]/90 cables.</span>")

/obj/item/weapon/rcl/Destroy()
	qdel(loaded)
	loaded = null
	last = null
	..()

/obj/item/weapon/rcl/update_icon()
	if(!loaded)
		icon_state = "rcl-0"
		item_state = "rcl-0"
		return
	switch(loaded.amount)
		if(61 to INFINITY)
			icon_state = "rcl-30"
			item_state = "rcl"
		if(31 to 60)
			icon_state = "rcl-20"
			item_state = "rcl"
		if(1 to 30)
			icon_state = "rcl-10"
			item_state = "rcl"
		else
			icon_state = "rcl-0"
			item_state = "rcl-0"

/obj/item/weapon/rcl/proc/is_empty(mob/user)
	update_icon()
	if(!loaded.amount)
		to_chat(user, "<span class='notice'>The last of the cables unreel from \the [src].</span>")
		returnToPool(loaded)
		loaded = null
		return 1
	return 0

/obj/item/weapon/rcl/dropped(mob/wearer as mob)
	..()
	active = 0

/obj/item/weapon/rcl/attack_self(mob/user as mob)
	active = !active
	to_chat(user, "<span class='notice'>You turn the [src] [active ? "on" : "off"].<span>")
	if(active)
		trigger(user)

/obj/item/weapon/rcl/proc/trigger(mob/user as mob)
	if(!loaded)
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
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
