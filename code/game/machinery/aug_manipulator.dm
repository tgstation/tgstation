/obj/machinery/aug_manipulator
	name = "\improper augment manipulator"
	desc = "A machine for custom fitting augmentations, with in-built spraypainter."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	base_icon_state = "pdapainter"
	density = TRUE
	obj_integrity = 200
	max_integrity = 200
	var/obj/item/bodypart/storedpart
	var/static/list/style_list_icons = list("standard" = 'icons/mob/augmentation/augments.dmi', "engineer" = 'icons/mob/augmentation/augments_engineer.dmi', "security" = 'icons/mob/augmentation/augments_security.dmi', "mining" = 'icons/mob/augmentation/augments_mining.dmi')

/obj/machinery/aug_manipulator/examine(mob/user)
	. = ..()
	if(storedpart)
		. += "<span class='notice'>Alt-click to eject the limb.</span>"

/obj/machinery/aug_manipulator/Initialize()
	if(!base_icon_state)
		base_icon_state = initial(icon_state)
	return ..()

/obj/machinery/aug_manipulator/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]-broken"
		return ..()
	icon_state = "[base_icon_state][powered() ? null : "-off"]"
	return ..()

/obj/machinery/aug_manipulator/update_overlays()
	. = ..()
	if(storedpart)
		. += "[base_icon_state]-closed"

/obj/machinery/aug_manipulator/Destroy()
	QDEL_NULL(storedpart)
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
		update_appearance()

/obj/machinery/aug_manipulator/attackby(obj/item/O, mob/living/user, params)
	if(default_unfasten_wrench(user, O))
		power_change()
		return

	else if(istype(O, /obj/item/bodypart))
		var/obj/item/bodypart/B = O
		if(B.status != BODYPART_ROBOTIC)
			to_chat(user, "<span class='warning'>The machine only accepts cybernetics!</span>")
			return
		if(storedpart)
			to_chat(user, "<span class='warning'>There is already something inside!</span>")
			return
		else
			O = user.get_active_held_item()
			if(!user.transferItemToLoc(O, src))
				return
			storedpart = O
			O.add_fingerprint(user)
			update_appearance()

	else if(O.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(obj_integrity < max_integrity)
			if(!O.tool_start_check(user, amount=0))
				return

			user.visible_message("<span class='notice'>[user] begins repairing [src].</span>", \
				"<span class='notice'>You begin repairing [src]...</span>", \
				"<span class='hear'>You hear welding.</span>")

			if(O.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				set_machine_stat(machine_stat & ~BROKEN)
				obj_integrity = max(obj_integrity, max_integrity)
				update_appearance()
		else
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
	else
		return ..()

/obj/machinery/aug_manipulator/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)

	if(storedpart)
		var/list/skins = list()
		for(var/skin_option in style_list_icons)
			var/image/part_image = image(icon = style_list_icons[skin_option], icon_state = storedpart.icon_state)
			skins += list("[skin_option]" = part_image)
		var/choice = show_radial_menu(user, src, skins, custom_check = CALLBACK(src, .proc/check_menu, user, storedpart), require_near = TRUE)
		if(!choice)
			return
		storedpart.icon = style_list_icons[choice]
		eject_part(user)
	else
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with the menu
 * * part The body part that is being customized
 */
/obj/machinery/aug_manipulator/proc/check_menu(mob/living/user, obj/item/bodypart/part)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(QDELETED(part))
		return FALSE
	if(part != storedpart)
		return FALSE
	return TRUE

/obj/machinery/aug_manipulator/proc/eject_part(mob/living/user)
	if(storedpart)
		storedpart.forceMove(get_turf(src))
		storedpart = null
		update_appearance()
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

/obj/machinery/aug_manipulator/AltClick(mob/living/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	else
		eject_part(user)
