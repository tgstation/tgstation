/obj/machinery/aug_manipulator
	name = "\improper augment manipulator"
	desc = "A machine for custom fitting augmentations, with in-built spraypainter."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = 1
	anchored = 1
	var/obj/item/bodypart/storedpart = null
	var/initial_icon_state = null
	var/static/list/style_list_icons = list("standard" = 'icons/mob/augmentation/augments.dmi', "engineer" = 'icons/mob/augmentation/augments_engineer.dmi', "security" = 'icons/mob/augmentation/augments_security.dmi', "mining" = 'icons/mob/augmentation/augments_mining.dmi')
	obj_integrity = 200
	max_integrity = 200

/obj/machinery/aug_manipulator/Initialize()
    initial_icon_state = initial(icon_state)
    return ..()

/obj/machinery/aug_manipulator/update_icon()
	cut_overlays()

	if(stat & BROKEN)
		icon_state = "[initial_icon_state]-broken"
		return

	if(storedpart)
		add_overlay("[initial_icon_state]-closed")

	if(powered())
		icon_state = initial_icon_state
	else
		icon_state = "[initial_icon_state]-off"

/obj/machinery/aug_manipulator/Destroy()
	if(storedpart)
		qdel(storedpart)
		storedpart = null
	return ..()

/obj/machinery/aug_manipulator/on_deconstruction()
	if(storedpart)
		storedpart.forceMove(loc)
		storedpart = null

/obj/machinery/aug_manipulator/contents_explosion(severity, target)
	if(storedpart)
		storedpart.ex_act(severity, target)

/obj/machinery/aug_manipulator/handle_atom_del(atom/A)
	if(A == storedpart)
		storedpart = null
		update_icon()

/obj/machinery/aug_manipulator/attackby(obj/item/O, mob/user, params)
	if(default_unfasten_wrench(user, O))
		power_change()
		return

	else if(istype(O, /obj/item/bodypart))
		if(storedpart)
			to_chat(user, "<span class='warning'>There is already something inside!</span>")
			return
		else
			var/obj/item/bodypart/P = user.get_active_held_item()
			if(istype(P))
				if(!user.drop_item())
					return
				storedpart = P
				P.loc = src
				P.add_fingerprint(user)
				update_icon()

	else if(istype(O, /obj/item/weapon/weldingtool) && user.a_intent != INTENT_HARM)
		var/obj/item/weapon/weldingtool/WT = O
		if(stat & BROKEN)
			if(WT.remove_fuel(0,user))
				user.visible_message("[user] is repairing [src].", \
								"<span class='notice'>You begin repairing [src]...</span>", \
								"<span class='italics'>You hear welding.</span>")
				playsound(loc, WT.usesound, 40, 1)
				if(do_after(user,40*WT.toolspeed, 1, target = src))
					if(!WT.isOn() || !(stat & BROKEN))
						return
					to_chat(user, "<span class='notice'>You repair [src].</span>")
					playsound(loc, 'sound/items/welder2.ogg', 50, 1)
					stat &= ~BROKEN
					obj_integrity = max_integrity
					update_icon()
		else
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
	else
		return ..()

/obj/machinery/aug_manipulator/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			stat |= BROKEN
			update_icon()

/obj/machinery/aug_manipulator/attack_hand(mob/user)
	if(!..())
		add_fingerprint(user)

		if(storedpart)
			var/augstyle = input(user, "Select style.", "Augment Custom Fitting") as null|anything in style_list_icons
			if(!augstyle)
				return
			if(!in_range(src, user))
				return
			if(!storedpart)
				return
			storedpart.icon = style_list_icons[augstyle]
			ejectpart()

		else
			to_chat(user, "<span class='notice'>\The [src] is empty.</span>")


/obj/machinery/aug_manipulator/verb/ejectpart()
	set name = "Eject Part"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || usr.restrained() || !usr.canmove)
		return

	if(storedpart)
		storedpart.forceMove(get_turf(src))
		storedpart = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/aug_manipulator/power_change()
	..()
	update_icon()
