/obj/item/weapon/twohanded/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables. Do not use without insulation!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	opacity = 0
	force = 5 //Plastic is soft
	throwforce = 5
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "engineering=4;materials=2"
	var/max_amount = 90
	var/active = 0
	var/obj/structure/cable/last = null
	var/obj/item/stack/cable_coil/loaded = null

/obj/item/weapon/twohanded/rcl/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(!loaded)
			if(user.drop_item())
				loaded = W
				loaded.forceMove(src)
				loaded.max_amount = max_amount //We store a lot.
			else
				to_chat(user, "<span class='warning'>[src] is stuck to your hand!</span>")
				return
		else
			if(loaded.amount < max_amount)
				var/amount = min(loaded.amount + C.amount, max_amount)
				C.use(amount - loaded.amount)
				loaded.amount = amount
			else
				return
		update_icon()
		to_chat(user, "<span class='notice'>You add the cables to the [src]. It now contains [loaded.amount].</span>")
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(!loaded)
			return
		to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
		while(loaded.amount > 30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
			var/diff = loaded.amount % 30
			if(diff)
				loaded.use(diff)
				new /obj/item/stack/cable_coil(user.loc, diff)
			else
				loaded.use(30)
				new /obj/item/stack/cable_coil(user.loc, 30)
		loaded.max_amount = initial(loaded.max_amount)
		loaded.forceMove(user.loc)
		user.put_in_hands(loaded)
		loaded = null
		update_icon()
	else
		..()

/obj/item/weapon/twohanded/rcl/examine(mob/user)
	..()
	if(loaded)
		to_chat(user, "<span class='info'>It contains [loaded.amount]/[max_amount] cables.</span>")

/obj/item/weapon/twohanded/rcl/Destroy()
	QDEL_NULL(loaded)
	last = null
	active = 0
	return ..()

/obj/item/weapon/twohanded/rcl/update_icon()
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

/obj/item/weapon/twohanded/rcl/proc/is_empty(mob/user, loud = 1)
	update_icon()
	if(!loaded || !loaded.amount)
		if(loud)
			to_chat(user, "<span class='notice'>The last of the cables unreel from [src].</span>")
		if(loaded)
			qdel(loaded)
			loaded = null
		unwield(user)
		active = wielded
		return 1
	return 0

/obj/item/weapon/twohanded/rcl/dropped(mob/wearer)
	..()
	active = 0
	last = null

/obj/item/weapon/twohanded/rcl/attack_self(mob/user)
	..()
	active = wielded
	if(!active)
		last = null
	else if(!last)
		for(var/obj/structure/cable/C in get_turf(user))
			if(C.d1 == 0 || C.d2 == 0)
				last = C
				break

/obj/item/weapon/twohanded/rcl/on_mob_move(direct, mob/user)
	if(active)
		trigger(user)

/obj/item/weapon/twohanded/rcl/proc/trigger(mob/user)
	var/turf/I = get_turf(user)
	if(!isturf(user.loc))
		return
	if(is_empty(user, 0))
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
		return
	if(last && I.can_have_cabling())
		if(get_dist(last, user) == 1) //hacky, but it works
			var/turf/T = get_turf(user)
			if(!isturf(T) || T.intact || !T.can_have_cabling())
				last = null
				return
			if(get_dir(last, user) == last.d2)
				//Did we just walk backwards? Well, that's the one direction we CAN'T complete a stub.
				last = null
				return
			loaded.cable_join(last, user)
			if(is_empty(user))
				return //If we've run out, display message and exit
		else
			last = null
	last = loaded.place_turf(get_turf(loc), user, turn(user.dir, 180))
	is_empty(user) //If we've run out, display message

/obj/item/weapon/twohanded/rcl/pre_loaded/New() //Comes preloaded with cable, for testing stuff
	..()
	loaded = new()
	loaded.max_amount = max_amount
	loaded.amount = max_amount
	update_icon()