/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "extinguisher_closed"
	anchored = 1
	density = 0
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/weapon/extinguisher/stored_extinguisher
	var/opened = 0

/obj/structure/extinguisher_cabinet/New(loc, ndir, building)
	..()
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0
		opened = 1
		icon_state = "extinguisher_empty"
	else
		stored_extinguisher = new /obj/item/weapon/extinguisher(src)

/obj/structure/extinguisher_cabinet/Destroy()
	if(stored_extinguisher)
		qdel(stored_extinguisher)
		stored_extinguisher = null
	return ..()

/obj/structure/extinguisher_cabinet/contents_explosion(severity, target)
	if(stored_extinguisher)
		stored_extinguisher.ex_act(severity, target)

/obj/structure/extinguisher_cabinet/handle_atom_del(atom/A)
	if(A == stored_extinguisher)
		stored_extinguisher = null
		update_icon()

/obj/structure/extinguisher_cabinet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench) && !stored_extinguisher)
		to_chat(user, "<span class='notice'>You start unsecuring [name]...</span>")
		playsound(loc, I.usesound, 50, 1)
		if(do_after(user, 60*I.toolspeed, target = src))
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You unsecure [name].</span>")
			deconstruct(TRUE)
		return

	if(iscyborg(user) || isalien(user))
		return
	if(istype(I, /obj/item/weapon/extinguisher))
		if(!stored_extinguisher && opened)
			if(!user.drop_item())
				return
			contents += I
			stored_extinguisher = I
			to_chat(user, "<span class='notice'>You place [I] in [src].</span>")
			update_icon()
		else
			toggle_cabinet(user)
	else if(user.a_intent != INTENT_HARM)
		toggle_cabinet(user)
	else
		return ..()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(iscyborg(user) || isalien(user))
		return
	if(stored_extinguisher)
		user.put_in_hands(stored_extinguisher)
		to_chat(user, "<span class='notice'>You take [stored_extinguisher] from [src].</span>")
		stored_extinguisher = null
		if(!opened)
			opened = 1
			playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		update_icon()
	else
		toggle_cabinet(user)


/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(stored_extinguisher)
		stored_extinguisher.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove [stored_extinguisher] from [src].</span>")
		stored_extinguisher = null
		opened = 1
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		update_icon()
	else
		toggle_cabinet(user)


/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/extinguisher_cabinet/AltClick(mob/living/user)
	if(user.incapacitated() || !Adjacent(user) || !istype(user))
		return
	toggle_cabinet(user)

/obj/structure/extinguisher_cabinet/proc/toggle_cabinet(mob/user)
	if(opened && broken)
		to_chat(user, "<span class='warning'>[src] is broken open.</span>")
	else
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		opened = !opened
		update_icon()

/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(stored_extinguisher)
		if(istype(stored_extinguisher, /obj/item/weapon/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"

/obj/structure/extinguisher_cabinet/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		broken = 1
		opened = 1
		if(stored_extinguisher)
			stored_extinguisher.forceMove(loc)
			stored_extinguisher = null
		update_icon()


/obj/structure/extinguisher_cabinet/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			new /obj/item/wallframe/extinguisher_cabinet(loc)
		else
			new /obj/item/stack/sheet/metal (loc, 2)
		if(stored_extinguisher)
			stored_extinguisher.forceMove(loc)
			stored_extinguisher = null
	qdel(src)

/obj/item/wallframe/extinguisher_cabinet
	name = "extinguisher cabinet frame"
	desc = "Used for building wall-mounted extinguisher cabinets."
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "extinguisher_frame"
	result_path = /obj/structure/extinguisher_cabinet
