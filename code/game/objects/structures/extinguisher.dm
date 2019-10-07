/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "extinguisher_closed"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/stored_object
	var/opened = FALSE
	//item sprites
	var/spawneditem = new /obj/item/extinguisher //sets spawned item when mapped in or spawned.
	var/alloweditem = /obj/item/extinguisher //set allowed item to determine what item is allowed inside
	var/altitem =  /obj/item/extinguisher/mini //sets the item that will present an alt sprite when placed inside.
	//sprite vars. Set icon state here.
	var/emptycabinet = "extinguisher_empty"
	var/closedcabinet = "extinguisher_closed"
	var/cabinetfilled = "extinguisher_full"
	var/cabinetalt =  "extinguisher_mini"

//mapcode
/obj/structure/extinguisher_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0
		opened = TRUE
		icon_state = emptycabinet
	else
		stored_object = spawneditem

/obj/structure/extinguisher_cabinet/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to [opened ? "close":"open"] it.</span>"

/obj/structure/extinguisher_cabinet/Destroy()
	if(stored_object)
		qdel(stored_object)
		stored_object = null
	return ..()

//explosion handling
/obj/structure/extinguisher_cabinet/contents_explosion(severity, target)
	if(stored_object)
		stored_object.ex_act(severity, target)

/obj/structure/extinguisher_cabinet/handle_atom_del(atom/A)
	if(A == stored_object)
		stored_object = null
		update_icon()

//deconstruct and add item code
/obj/structure/extinguisher_cabinet/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && !stored_object)
		to_chat(user, "<span class='notice'>You start unsecuring [name]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			to_chat(user, "<span class='notice'>You unsecure [name].</span>")
			deconstruct(TRUE)
		return

	if(iscyborg(user) || isalien(user))
		return
	if(istype(I, alloweditem))
		if(!stored_object && opened)
			if(!user.transferItemToLoc(I, src))
				return
			stored_object = I
			to_chat(user, "<span class='notice'>You place [I] in [src].</span>")
			update_icon()
			return TRUE
		else
			toggle_cabinet(user)
	else if(user.a_intent != INTENT_HARM)
		toggle_cabinet(user)
	else
		return ..()

//remove item from cabinet
/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(stored_object)
		user.put_in_hands(stored_object)
		to_chat(user, "<span class='notice'>You take [stored_object] from [src].</span>")
		stored_object = null
		if(!opened)
			opened = 1
			playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		update_icon()
	else
		toggle_cabinet(user)


/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(stored_object)
		stored_object.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove [stored_object] from [src].</span>")
		stored_object = null
		opened = 1
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		update_icon()
	else
		toggle_cabinet(user)


/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/extinguisher_cabinet/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	toggle_cabinet(user)

/obj/structure/extinguisher_cabinet/proc/toggle_cabinet(mob/user)
	if(opened && broken)
		to_chat(user, "<span class='warning'>[src] is broken open.</span>")
	else
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		opened = !opened
		update_icon()
//sprite stuff
/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = closedcabinet
		return
	if(stored_object)
		if(istype(stored_object, altitem))
			icon_state = cabinetalt
		else
			icon_state = cabinetfilled
	else
		icon_state = emptycabinet

/obj/structure/extinguisher_cabinet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		broken = 1
		opened = 1
		if(stored_object)
			stored_object.forceMove(loc)
			stored_object = null
		update_icon()


/obj/structure/extinguisher_cabinet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new /obj/item/wallframe/extinguisher_cabinet(loc)
		else
			new /obj/item/stack/sheet/metal (loc, 2)
		if(stored_object)
			stored_object.forceMove(loc)
			stored_object = null
	qdel(src)

/obj/item/wallframe/extinguisher_cabinet
	name = "extinguisher cabinet frame"
	desc = "Used for building wall-mounted extinguisher cabinets."
	icon_state = "extinguisher"
	result_path = /obj/structure/extinguisher_cabinet

//wall mounted medkits
/obj/structure/extinguisher_cabinet/medkit
	name = "medkit cabinet"
	desc = "A small wall mounted cabinet designed to hold a first aid kit."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "medkit_closed"
	//item variables
	spawneditem = new /obj/item/storage/firstaid/regular //sets spawned item
	alloweditem = /obj/item/storage/firstaid //sets allowed item for the cabinet. Setting it to main type will allow subtypes.
	//sprite variables
	emptycabinet = "medkit_empty"
	closedcabinet = "medkit_closed"
	cabinetfilled = "medkit_white"
	cabinetalt =  null
	var/obj/item/storage/firstaid/regular/stored_medkit

//wallframe
/obj/item/wallframe/extinguisher_cabinet/medkit
	name = "medkit cabinet frame"
	desc = "Used for building wall-mounted medkit cabinets."
	icon_state = "medkit"
	result_path = /obj/structure/extinguisher_cabinet/medkit
