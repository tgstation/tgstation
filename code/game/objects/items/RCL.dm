/obj/item/twohanded/rcl
	name = "rapid cable layer"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables. Do not use without insulation!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	var/obj/structure/cable/last
	var/obj/item/stack/cable_coil/loaded
	opacity = FALSE
	force = 5 //Plastic is soft
	throwforce = 5
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	var/max_amount = 90
	var/active = FALSE
	actions_types = list(/datum/action/item_action/rcl)
	var/list/colors = list("red", "yellow", "green", "blue", "pink", "orange", "cyan", "white")
	var/current_color_index = 1
	var/ghetto = FALSE
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	var/datum/component/mobhook

/obj/item/twohanded/rcl/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W

		if(!loaded)
			if(!user.transferItemToLoc(W, src))
				to_chat(user, "<span class='warning'>[src] is stuck to your hand!</span>")
				return
			else
				loaded = W //W.loc is src at this point.
				loaded.max_amount = max_amount //We store a lot.
				return

		if(loaded.amount < max_amount)
			var/transfer_amount = min(max_amount - loaded.amount, C.amount)
			C.use(transfer_amount)
			loaded.amount += transfer_amount
		else
			return
		update_icon()
		to_chat(user, "<span class='notice'>You add the cables to [src]. It now contains [loaded.amount].</span>")
	else if(istype(W, /obj/item/screwdriver))
		if(!loaded)
			return
		if(ghetto && prob(10)) //Is it a ghetto RCL? If so, give it a 10% chance to fall apart
			to_chat(user, "<span class='warning'>You attempt to loosen the securing screws on the side, but it falls apart!</span>")
			while(loaded.amount > 30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
				var/diff = loaded.amount % 30
				if(diff)
					loaded.use(diff)
					new /obj/item/stack/cable_coil(get_turf(user), diff)
				else
					loaded.use(30)
					new /obj/item/stack/cable_coil(get_turf(user), 30)
			qdel(src)
			return

		to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
		while(loaded.amount > 30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
			var/diff = loaded.amount % 30
			if(diff)
				loaded.use(diff)
				new /obj/item/stack/cable_coil(get_turf(user), diff)
			else
				loaded.use(30)
				new /obj/item/stack/cable_coil(get_turf(user), 30)
		loaded.max_amount = initial(loaded.max_amount)
		if(!user.put_in_hands(loaded))
			loaded.forceMove(get_turf(user))

		loaded = null
		update_icon()
	else
		..()

/obj/item/twohanded/rcl/examine(mob/user)
	..()
	if(loaded)
		to_chat(user, "<span class='info'>It contains [loaded.amount]/[max_amount] cables.</span>")

/obj/item/twohanded/rcl/Destroy()
	QDEL_NULL(loaded)
	last = null
	setActive(FALSE, null) // setactive(FALSE) removes mobhook
	return ..()

/obj/item/twohanded/rcl/update_icon()
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

/obj/item/twohanded/rcl/proc/is_empty(mob/user, loud = 1)
	update_icon()
	if(!loaded || !loaded.amount)
		if(loud)
			to_chat(user, "<span class='notice'>The last of the cables unreel from [src].</span>")
		if(loaded)
			QDEL_NULL(loaded)
			loaded = null
		unwield(user)
		setActive(wielded, user)
		return TRUE
	return FALSE

/obj/item/twohanded/rcl/dropped(mob/wearer)
	..()
	if(mobhook)
		setActive(FALSE, mobhook.parent)
	last = null

/obj/item/twohanded/rcl/attack_self(mob/user)
	..()
	setActive(wielded, user)
	if(!active)
		last = null
	else if(!last)
		for(var/obj/structure/cable/C in get_turf(user))
			if(C.d1 == FALSE || C.d2 == FALSE)
				last = C
				break

/obj/item/twohanded/rcl/proc/setActive(toggle, mob/user)
	active = toggle
	if (active && user)
		if (mobhook && mobhook.parent != user)
			QDEL_NULL(mobhook)
		if (!mobhook)
			mobhook = user.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED = CALLBACK(src, .proc/trigger)))
	else
		QDEL_NULL(mobhook)

/obj/item/twohanded/rcl/proc/trigger(mob/user)
	if(!isturf(user.loc))
		return
	if(is_empty(user, 0))
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
		return

	if(prob(2) && ghetto) //Give ghetto RCLs a 2% chance to jam, requiring it to be reactviated manually.
		to_chat(user, "<span class='warning'>[src]'s wires jam!</span>")
		setActive(FALSE, user)
		return
	else
		if(last)
			if(get_dist(last, user) == 1) //hacky, but it works
				var/turf/T = get_turf(user)
				if(T.intact || !T.can_have_cabling())
					last = null
					return
				if(get_dir(last, user) == last.d2)
					//Did we just walk backwards? Well, that's the one direction we CAN'T complete a stub.
					last = null
					return
				loaded.cable_join(last, user, FALSE)
				if(is_empty(user))
					return //If we've run out, display message and exit
			else
				last = null
		loaded.item_color	 = colors[current_color_index]
		last = loaded.place_turf(get_turf(src), user, turn(user.dir, 180))
		is_empty(user) //If we've run out, display message
	update_icon()


/obj/item/twohanded/rcl/pre_loaded/Initialize() //Comes preloaded with cable, for testing stuff
	. = ..()
	loaded = new()
	loaded.max_amount = max_amount
	loaded.amount = max_amount
	update_icon()

/obj/item/twohanded/rcl/Initialize()
	. = ..()
	update_icon()

/obj/item/twohanded/rcl/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/rcl))
		current_color_index++;
		if (current_color_index > colors.len)
			current_color_index = 1
		var/cwname = colors[current_color_index]
		to_chat(user, "Color changed to [cwname]!")

/obj/item/twohanded/rcl/ghetto
	actions_types = list()
	max_amount = 30
	name = "makeshift rapid cable layer"
	ghetto = TRUE

/obj/item/twohanded/rcl/ghetto/update_icon()
	if(!loaded)
		icon_state = "rclg-0"
		item_state = "rclg-0"
		return
	switch(loaded.amount)
		if(1 to INFINITY)
			icon_state = "rclg-1"
			item_state = "rcl"
		else
			icon_state = "rclg-1"
			item_state = "rclg-1"
