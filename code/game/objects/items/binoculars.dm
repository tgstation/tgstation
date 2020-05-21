/obj/item/binoculars
	name = "binoculars"
	desc = "Used for long-distance surveillance."
	item_state = "binoculars"
	icon_state = "binoculars"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/mob/listeningTo
	var/zoom_out_amt = 6
	var/zoom_amt = 10

/obj/item/binoculars/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/binoculars/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=8, force_wielded=12)

/obj/item/binoculars/Destroy()
	listeningTo = null
	return ..()

/obj/item/binoculars/proc/on_wield(obj/item/source, mob/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_walk)
	RegisterSignal(user, COMSIG_ATOM_DIR_CHANGE, .proc/rotate)
	listeningTo = user
	user.visible_message("<span class='notice'>[user] holds [src] up to [user.p_their()] eyes.</span>", "<span class='notice'>You hold [src] up to your eyes.</span>")
	item_state = "binoculars_wielded"
	zoom(user, user.dir)

/obj/item/binoculars/proc/rotate(atom/thing, old_dir, new_dir)
	listeningTo.client.view_size.add(-zoom_out_amt)
	zoom(listeningTo, new_dir)

/obj/item/binoculars/proc/zoom(mob/user, direction)
	user.regenerate_icons()
	if(!user?.client)
		return
	var/client/C = user.client
	var/_x = 0
	var/_y = 0
	switch(direction)
		if(NORTH)
			_y = zoom_amt
		if(EAST)
			_x = zoom_amt
		if(SOUTH)
			_y = -zoom_amt
		if(WEST)
			_x = -zoom_amt
	//Ready for this one?
	C.view_size.add(zoom_out_amt)
	C.pixel_x = world.icon_size*_x
	C.pixel_y = world.icon_size*_y

/obj/item/binoculars/proc/on_walk()
	attack_self(listeningTo) //Yes I have sinned, why do you ask?

/obj/item/binoculars/proc/on_unwield(obj/item/source, mob/user)
	if(listeningTo)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(user, COMSIG_ATOM_DIR_CHANGE)
		listeningTo = null
	user.visible_message("<span class='notice'>[user] lowers [src].</span>", "<span class='notice'>You lower [src].</span>")
	item_state = "binoculars"
	user.regenerate_icons()
	if(user && user.client)
		user.regenerate_icons()
		var/client/C = user.client
		C.view_size.add(-zoom_out_amt)
		user.client.pixel_x = 0
		user.client.pixel_y = 0
