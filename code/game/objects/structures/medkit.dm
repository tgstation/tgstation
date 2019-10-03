///Reuses fire extinguisher cabinet wall mount code to create an equivalent for medkits.


//structure code
/obj/structure/medkit_cabinet
	name = "Medkit Cabinet"
	desc = "A small wall mounted cabinet designed to hold a medical kit."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "medkit_closed"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/storage/firstaid/regular/stored_medkit
	var/opened = FALSE

/obj/structure/medkit_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0
		opened = TRUE
		icon_state = "medkit_empty"
	else
		stored_medkit = new /obj/item/storage/firstaid/regular(src)

/obj/structure/medkit_cabinet/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to [opened ? "close":"open"] it.</span>")

/obj/structure/medkit_cabinet/Destroy()
	if(stored_medkit)
		qdel(stored_medkit)
		stored_medkit = null
	return ..()

//passes explosion to contets.
obj/structure/medkit_cabinet/contents_explosion(severity, target)
	if(stored_medkit)
		stored_medkit.ex_act(severity, target)

/obj/structure/medkit_cabinet/handle_atom_del(atom/A)
	if(A == stored_medkit)
		stored_medkit = null
		update_icon()

//disassembly code
/obj/structure/medkit_cabinet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wrench) && !stored_medkit)
		to_chat(user, "<span class='notice'>You start unsecuring [name]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You unsecure [name].</span>")
			deconstruct(TRUE)
		return

	if(iscyborg(user) || isalien(user))
		return
	if(istype(I, /obj/item/storage/firstaid))
		if(!stored_medkit && opened)
			if(!user.transferItemToLoc(I, src))
				return
			stored_medkit = I
			to_chat(user, "<span class='notice'>You place [I] in [src].</span>")
			update_icon()
			return TRUE
		else
			toggle_cabinet(user)
	else if(user.a_intent != INTENT_HARM)
		toggle_cabinet(user)
	else
		return ..()

//storing and removing medkits.
/obj/structure/medkit_cabinet/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(stored_medkit)
		user.put_in_hands(stored_medkit)
		to_chat(user, "<span class='notice'>You take [stored_medkit] from [src].</span>")
		stored_medkit = null
		if(!opened)
			opened = 1
			playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		update_icon()
	else
		toggle_cabinet(user)

//player interaction
/obj/structure/medkit_cabinet/attack_tk(mob/user)
	if(stored_medkit)
		stored_medkit.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove [stored_medkit] from [src].</span>")
		stored_medkit = null
		opened = 1
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		update_icon()
	else
		toggle_cabinet(user)

//I think this is for simple mobs or monkeys.
/obj/structure/medkit_cabinet/attack_paw(mob/user)
	return attack_hand(user)

//closes it
/obj/structure/medkit_cabinet/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	toggle_cabinet(user)

/obj/structure/medkit_cabinet/proc/toggle_cabinet(mob/user)
	if(opened && broken)
		to_chat(user, "<span class='warning'>[src] is broken open.</span>")
	else
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		opened = !opened
		update_icon()

//sprite code. Leaving it as is in case someone wants to make sprites to match medkit color in the future or something and also to avoid breaking stuff.
/obj/structure/medkit_cabinet/update_icon()
	if(!opened)
		icon_state = "medkit_closed"
		return
	if(stored_medkit)
		if(istype(stored_medkit, /obj/item/storage/firstaid))
			icon_state = "medkit_white"
		else
			icon_state = "medkit_white"
	else
		icon_state = "medkit_empty"

//drops medkit when busted
/obj/structure/medkit_cabinet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		broken = 1
		opened = 1
		if(stored_medkit)
			stored_medkit.forceMove(loc)
			stored_medkit = null
		update_icon()

//Pretty sure this sets what mats you get out of deconstructing the cabinet
/obj/structure/medkit_cabinet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new /obj/item/wallframe/medkit_cabinet(loc)
		else
			new /obj/item/stack/sheet/metal (loc, 2)
		if(stored_medkit)
			stored_medkit.forceMove(loc)
			stored_medkit = null
	qdel(src)

//wall mount to put it on a wall
/obj/item/wallframe/medkit_cabinet
	name = "Medkit wall frame."
	desc = "Used for building wall-mounted medkit cabinets."
	icon_state = "medkit"
	result_path = /obj/structure/medkit_cabinet
