/**
 * Shower Curtains
 */
/obj/structure/curtain
	name = "curtain"
	desc = "Contains less than 1% mercury."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "bathroom-open"
	color = "#ACD1E9" //Default color, didn't bother hardcoding other colors, mappers can and should easily change it.
	alpha = 200 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	/// used in making the icon state
	var/icon_type = "bathroom"
	var/open = TRUE
	/// if it can be seen through when closed
	var/opaque_closed = FALSE

/obj/structure/curtain/Initialize(mapload)
	// see-through curtains should let emissives shine through
	if(!opaque_closed)
		blocks_emissive = EMISSIVE_BLOCK_NONE
	. = ..()
	ADD_TRAIT(src, TRAIT_INVERTED_DEMOLITION, INNATE_TRAIT)

/obj/structure/curtain/proc/toggle()
	open = !open
	if(open)
		layer = SIGN_LAYER
		set_opacity(FALSE)
	else
		layer = WALL_OBJ_LAYER
		if(opaque_closed)
			set_opacity(TRUE)

	update_appearance()

/obj/structure/curtain/update_icon_state()
	icon_state = "[icon_type]-[open ? "open" : "closed"]"
	return ..()

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/toy/crayon))
		color = input(user,"","Choose Color",color) as color
	else
		return ..()

/obj/structure/curtain/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 5 SECONDS)
	return TRUE

/obj/structure/curtain/wirecutter_act(mob/living/user, obj/item/I)
	..()
	if(anchored)
		return TRUE

	user.visible_message(span_warning("[user] cuts apart [src]."),
		span_notice("You start to cut apart [src]."), span_hear("You hear cutting."))
	if(I.use_tool(src, user, 50, volume=100) && !anchored)
		to_chat(user, span_notice("You cut apart [src]."))
		deconstruct()

	return TRUE


/obj/structure/curtain/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	playsound(loc, 'sound/effects/curtain.ogg', 50, TRUE)
	toggle()

/obj/structure/curtain/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cloth (loc, 2)
	new /obj/item/stack/sheet/plastic (loc, 2)
	new /obj/item/stack/rods (loc, 1)

/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/items/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/tools/welder.ogg', 80, TRUE)

/obj/structure/curtain/bounty
	icon_type = "bounty"
	icon_state = "bounty-open"
	color = null
	alpha = 255
	opaque_closed = TRUE

/obj/structure/curtain/bounty/start_closed
	icon_state = "bounty-closed"

/obj/structure/curtain/bounty/start_closed/Initialize(mapload)
	. = ..()
	if(open)
		toggle()

/obj/structure/curtain/cloth
	color = null
	alpha = 255
	opaque_closed = TRUE

/obj/structure/curtain/cloth/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cloth (loc, 4)
	new /obj/item/stack/rods (loc, 1)

/obj/structure/curtain/cloth/fancy
	icon_type = "cur_fancy"
	icon_state = "cur_fancy-open"

/obj/structure/curtain/cloth/fancy/mechanical
	var/id = null

/obj/structure/curtain/cloth/fancy/mechanical/Destroy()
	GLOB.curtains -= src
	return ..()

/obj/structure/curtain/cloth/fancy/mechanical/Initialize(mapload)
	. = ..()
	GLOB.curtains += src

/obj/structure/curtain/cloth/fancy/mechanical/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.shuttle_id]_[id]"

/obj/structure/curtain/cloth/fancy/mechanical/proc/open()
	icon_state = "[icon_type]-open"
	layer = SIGN_LAYER
	SET_PLANE_IMPLICIT(src, GAME_PLANE)
	set_density(FALSE)
	open = TRUE
	set_opacity(FALSE)

/obj/structure/curtain/cloth/fancy/mechanical/proc/close()
	icon_state = "[icon_type]-closed"
	layer = WALL_OBJ_LAYER
	set_density(TRUE)
	open = FALSE
	if(opaque_closed)
		set_opacity(TRUE)

/obj/structure/curtain/cloth/fancy/mechanical/attack_hand(mob/user, list/modifiers)
	return

/obj/structure/curtain/cloth/fancy/mechanical/start_closed
	icon_state = "cur_fancy-closed"

/obj/structure/curtain/cloth/fancy/mechanical/start_closed/Initialize(mapload)
	. = ..()
	close()
