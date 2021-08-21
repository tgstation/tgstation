/turf/closed/wall/window_frame
	name = "window frame"
	desc = "A frame section to place a window on top."
	icon = 'icons/turf/walls/low_walls/low_wall_normal.dmi'
	icon_state = "low_wall_normal-0"
	base_icon_state = "low_wall_normal"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOWS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOWS)
	opacity = FALSE
	density = TRUE
	blocks_air = FALSE
	flags_1 = RAD_NO_CONTAMINATE_1 | ALLOW_DARK_PAINTS_1
	rad_insulation = null
	frill_icon = 'icons/effects/frills/windows/window_normal_frill.dmi'
	///Bitflag to hold state on what other objects we have
	var/window_state = NONE
	///what step in the construction procedure we are in
	var/construction_state = WINDOW_FRAME_EMPTY
	///Icon used by grilles for this window frame
	var/grille_icon = 'icons/turf/walls/low_walls/window_grille.dmi'
	///Icon state used by grilles for this window frame
	var/grille_icon_state = "window_grille"
	///Icon used by windows for this window frame
	var/window_icon = 'icons/turf/walls/low_walls/windows/window_normal.dmi'
	///Icon state used by windows for this window frame
	var/window_icon_state = "window_normal"
	///Frill used for window frame
	var/has_frill = TRUE

	///what glass sheet type our window is made out of
	var/glass_material = /obj/item/stack/sheet/glass

	//custom_materials = list(/datum/material/iron = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

	var/break_sound = "shatter"
	var/knock_sound = 'sound/effects/Glassknock.ogg'
	var/bash_sound = 'sound/effects/Glassbash.ogg'
	var/hit_sound = 'sound/effects/Glasshit.ogg'

/turf/closed/wall/window_frame/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	update_icon()

	RegisterSignal(src, COMSIG_OBJ_PAINTED, .proc/on_painted)

	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		air_update_turf(TRUE, TRUE)

	if(sheet_type == null || glass_material == null)
		stack_trace("[src.type] was initialized with null materials! frame: [sheet_type], glass: [glass_material]")

	if(window_state & WINDOW_FRAME_WITH_GRILLES)
		construction_state = max(construction_state, WINDOW_FRAME_GRILLE_ADDED)
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		construction_state = max(construction_state, WINDOW_FRAME_WINDOW_SECURED)

/turf/closed/wall/window_frame/attackby(obj/item/attacking_item, mob/living/user, params)

	add_fingerprint(user)

	if(attacking_item.tool_behaviour == TOOL_WELDER)
		//if(window_state & WINDOW_FRAME_WITH_WINDOW && construction_state == WINDOW_FRAME_WINDOW_SECURED)
			//TODOKYLER: implement repair of the window

	else if(attacking_item.tool_behaviour == TOOL_WIRECUTTER)
		if(construction_state == WINDOW_FRAME_GRILLE_ADDED)

			if(!attacking_item.use_tool(src, user, 0, volume = 50))
				return

			to_chat(user, "<span class='notice'>You cut the grille on [src].</span>")

			construction_state = WINDOW_FRAME_EMPTY
			window_state &= ~WINDOW_FRAME_WITH_GRILLES
			update_appearance()
			AddElement(/datum/element/climbable)
			return

	else if(attacking_item.tool_behaviour == TOOL_WRENCH)
		if(construction_state == WINDOW_FRAME_WINDOW_UNSECURED)
			if(!attacking_item.use_tool(src, user, 40, volume = 50))
				return

			to_chat(user, "<span class='notice'>You secure the window glass to the frame.</span>")

			construction_state = WINDOW_FRAME_COMPLETE
			return

		else if(construction_state == WINDOW_FRAME_WINDOW_SECURED)
			if(!attacking_item.tool_start_check(user, amount = 0))
				return

			to_chat(user, "<span class='notice'>You begin unwrenching the window glass from the frame.</span>")
			if(!attacking_item.use_tool(src, user, 40, volume = 50))
				return

			construction_state = WINDOW_FRAME_WINDOW_UNSECURED
			return

	else if(isstack(attacking_item))
		var/obj/item/stack/adding_stack = attacking_item
		var/stack_name = "[adding_stack]" // in case the stack gets deleted after use()

		if(is_glass_sheet(adding_stack) && !(window_state & WINDOW_FRAME_WITH_WINDOW) && adding_stack.use(sheet_amount))
			glass_material = adding_stack.type
			window_state |= WINDOW_FRAME_WITH_WINDOW
			construction_state = WINDOW_FRAME_WINDOW_UNSECURED
			//var/list/new_materials = custom_materials.Copy()
			//LAZYADDASSOC(new_materials, GET_MATERIAL_REF(glass_material), WINDOW_FRAME_BASE_MATERIAL_AMOUNT)
			//set_custom_materials(new_materials)

			to_chat(user, "<span class='notice'>You add [stack_name] to [src].")
			update_appearance()
			RemoveElement(/datum/element/climbable) //cant climb through us anymore

		else if(istype(adding_stack, /obj/item/stack/rods) && construction_state == WINDOW_FRAME_EMPTY && adding_stack.use(sheet_amount))
			window_state |= WINDOW_FRAME_WITH_GRILLES
			construction_state = WINDOW_FRAME_GRILLE_ADDED
			to_chat(user, "<span class='notice'>You add [stack_name] to [src]")
			update_appearance()
			RemoveElement(/datum/element/climbable)

	return ..()

//turf/closed/wall/try_decon(obj/item/used_item, mob/user, turf/user_turf)

/turf/closed/wall/window_frame/attack_hand(mob/living/user, list/modifiers)
	user.changeNext_move(CLICK_CD_MELEE)

	if(!user.combat_mode)
		if(construction_state == WINDOW_FRAME_WINDOW_UNSECURED)
			construction_state = (window_state & WINDOW_FRAME_WITH_GRILLES) ? WINDOW_FRAME_GRILLE_ADDED : WINDOW_FRAME_EMPTY
			window_state &= ~WINDOW_FRAME_WITH_WINDOW
			//var/list/new_materials = custom_materials.Copy()

			to_chat(user, "<span class='notice'>You take the unsecured glass out of [src].</span>")

			//var/datum/material/our_glass = GET_MATERIAL_REF(glass_material)
			//LAZYREMOVEASSOC(new_materials, our_glass, WINDOW_FRAME_BASE_MATERIAL_AMOUNT)
			new glass_material(src, sheet_amount)
			//set_custom_materials(new_materials)

			update_appearance()
			AddElement(/datum/element/climbable)
			return

		user.visible_message("<span class='notice'>[user] knocks on [src].</span>", \
			"<span class='notice'>You knock on [src].</span>")
		playsound(src, knock_sound, 50, TRUE)
		return
	else
		user.visible_message("<span class='warning'>[user] bashes [src]!</span>", \
			"<span class='warning'>You bash [src]!</span>")
		playsound(src, bash_sound, 100, TRUE)
		return

	//return ..()

/turf/closed/wall/window_frame/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	add_fingerprint(user)
	playsound(src, knock_sound, 50, TRUE)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/turf/closed/wall/window_frame/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/closed/wall/window_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/turf/closed/wall/window_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		to_chat(user, "<span class='notice'>You deconstruct the window.</span>")
		qdel(src)
		return TRUE
	return FALSE

/turf/closed/wall/window_frame/proc/set_glass_icon()
	if(!is_glass_sheet(glass_material))
		CRASH("set_glass_icon() on [src.type] was called when glass_material was not a glass sheet type! [glass_material]")

	switch(glass_material)
		if(/obj/item/stack/sheet/glass)
			window_icon = 'icons/turf/walls/low_walls/windows/window_normal.dmi'
			window_icon_state = "window_normal"
			frill_icon = 'icons/effects/frills/windows/window_normal_frill.dmi'

		if(/obj/item/stack/sheet/rglass)
			window_icon = 'icons/turf/walls/low_walls/windows/window_reinforced.dmi'
			window_icon_state = "window_reinforced"
			frill_icon = 'icons/effects/frills/windows/window_reinforced_frill.dmi'

		if(/obj/item/stack/sheet/plasmaglass)
			window_icon = 'icons/turf/walls/low_walls/windows/window_plasma.dmi'
			window_icon_state = "window_plasma"
			frill_icon = 'icons/effects/frills/windows/window_plasma_frill.dmi'

		if(/obj/item/stack/sheet/plasmarglass)
			window_icon = 'icons/turf/walls/low_walls/windows/window_plasma_reinforced.dmi'
			window_icon_state = "window_plasma_reinforced"
			frill_icon = 'icons/effects/frills/windows/window_reinforced_plasma_frill.dmi'

		if(/obj/item/stack/sheet/titaniumglass)
			window_icon = 'icons/turf/walls/low_walls/windows/window_titanium.dmi'
			window_icon_state = "window_titanium"
			frill_icon = 'icons/effects/frills/windows/window_titanium_frill.dmi'

		if(/obj/item/stack/sheet/plastitaniumglass)
			window_icon = 'icons/turf/walls/low_walls/windows/window_plastitanium.dmi'
			window_icon_state = "window_plastitanium"
			frill_icon = 'icons/effects/frills/windows/window_plastitanium_frill.dmi'



/turf/closed/wall/window_frame/examine(mob/user)
	. = ..()
	if(window_state & (WINDOW_FRAME_WITH_WINDOW|WINDOW_FRAME_WITH_GRILLES))
		. += "<span class='notice'>The window is fully constructed.</span>"
	else if(window_state & WINDOW_FRAME_WITH_WINDOW)
		. += "<span class='notice'>The window set into the frame has no reinforcement.</span>"
	else if(window_state & WINDOW_FRAME_WITH_GRILLES)
		. += "<span class='notice'>The window frame only has a grille set into it.</span>"
	else
		. += "<span class='notice'>The window frame is empty</span>"
	/*
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += "<span class='notice'>The window is <b>screwed</b> to the frame.</span>"
		else if(anchored && state == WINDOW_IN_FRAME)
			. += "<span class='notice'>The window is <i>unscrewed</i> but <b>pried</b> into the frame.</span>"
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += "<span class='notice'>The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.</span>"
		else if(!anchored)
			. += "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>"
	else
		if(anchored)
			. += "<span class='notice'>The window is <b>screwed</b> to the floor.</span>"
		else
			. += "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>"
	*/

/turf/closed/wall/window_frame/proc/on_painted(is_dark_color)
	SIGNAL_HANDLER

	if (is_dark_color) //Opaque directional windows restrict vision even in directions they are not placed in, please don't do this
		set_opacity(255)
	else
		set_opacity(initial(opacity))

///delightfully devilous seymour
/turf/closed/wall/window_frame/set_smoothed_icon_state(new_junction)
	. = ..()
	update_icon()

/turf/closed/wall/window_frame/update_appearance(updates)
	set_glass_icon()
	. = ..()
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		set_frill(TRUE)
	else
		set_frill(FALSE)


/turf/closed/wall/window_frame/proc/set_frill(on)
	if(!on)
		if(has_frill)
			RemoveElement(/datum/element/frill, frill_icon)
			has_frill = FALSE
	else
		if(!has_frill)
			AddElement(/datum/element/frill, frill_icon)
			has_frill = TRUE

/turf/closed/wall/window_frame/update_overlays()
	. = ..()
	if(window_state & WINDOW_FRAME_WITH_GRILLES)
		. += mutable_appearance(grille_icon, "[grille_icon_state]-[smoothing_junction]")
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		. += mutable_appearance(window_icon, "[window_icon_state]-[smoothing_junction]")

/turf/closed/wall/window_frame/grille
	window_state = WINDOW_FRAME_WITH_GRILLES

/turf/closed/wall/window_frame/grille_and_window
	window_state = WINDOW_FRAME_COMPLETE

/turf/closed/wall/window_frame/titanium
	name = "shuttle window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_shuttle.dmi'
	icon_state = "low_wall_shuttle-0"
	base_icon_state = "low_wall_shuttle"
	sheet_type = /datum/material/titanium
	custom_materials = list(/datum/material/titanium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/plastitanium
	name = "plastitanium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_plastitanium.dmi'
	icon_state = "low_wall_plastitanium-0"
	base_icon_state = "low_wall_plastitanium"
	sheet_type = /datum/material/alloy/plastitanium
	custom_materials = list(/datum/material/alloy/plastitanium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/wood
	name = "wooden platform"
	icon = 'icons/turf/walls/low_walls/low_wall_wood.dmi'
	icon_state = "low_wall_wood-0"
	base_icon_state = "low_wall_wood"
	sheet_type = /datum/material/wood
	custom_materials = list(/datum/material/wood = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/uranium
	name = "uranium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_uranium.dmi'
	icon_state = "low_wall_uranium-0"
	base_icon_state = "low_wall_uranium"
	sheet_type = /datum/material/uranium
	custom_materials = list(/datum/material/uranium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/iron
	name = "rough iron window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_iron.dmi'
	icon_state = "low_wall_iron-0"
	base_icon_state = "low_wall_iron"
	sheet_type = /datum/material/iron
	custom_materials = list(/datum/material/iron = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/silver
	name = "silver window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_silver.dmi'
	icon_state = "low_wall_silver-0"
	base_icon_state = "low_wall_silver"
	sheet_type = /datum/material/silver
	custom_materials = list(/datum/material/silver = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/gold
	name = "gold window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_gold.dmi'
	icon_state = "low_wall_gold-0"
	base_icon_state = "low_wall_gold"
	sheet_type = /datum/material/gold
	custom_materials = list(/datum/material/gold = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/bronze
	name = "clockwork window mount"
	icon = 'icons/turf/walls/low_walls/low_wall_bronze.dmi'
	icon_state = "low_wall_bronze-0"
	base_icon_state = "low_wall_bronze"
	sheet_type = /datum/material/bronze
	custom_materials = list(/datum/material/bronze = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/cult
	name = "rune-scarred window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_cult.dmi'
	icon_state = "low_wall_cult-0"
	base_icon_state = "low_wall_cult"
	sheet_type = /datum/material/runedmetal
	custom_materials = list(/datum/material/runedmetal = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/hotel
	name = "hotel window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_hotel.dmi'
	icon_state = "low_wall_hotel-0"
	base_icon_state = "low_wall_hotel"
	sheet_type = /datum/material/wood
	custom_materials = list(/datum/material/wood = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/material
	name = "material window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_material.dmi'
	icon_state = "low_wall_material-0"
	base_icon_state = "low_wall_material"
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/closed/wall/window_frame/rusty
	name = "rusty window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_rusty.dmi'
	icon_state = "low_wall_rusty-0"
	base_icon_state = "low_wall_rusty"
	sheet_type = /datum/material/iron
	custom_materials = list(/datum/material/iron = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/sandstone
	name = "sandstone plinth"
	icon = 'icons/turf/walls/low_walls/low_wall_sandstone.dmi'
	icon_state = "low_wall_sandstone-0"
	base_icon_state = "low_wall_sandstone"
	sheet_type = /datum/material/sandstone
	custom_materials = list(/datum/material/sandstone = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/bamboo
	name = "bamboo platform"
	icon = 'icons/turf/walls/low_walls/low_wall_bamboo.dmi'
	icon_state = "low_wall_bamboo-0"
	base_icon_state = "low_wall_bamboo"
	sheet_type = /datum/material/bamboo
	custom_materials = list(/datum/material/bamboo = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/turf/closed/wall/window_frame/paperframe
	name = "japanese window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_paperframe.dmi'
	icon_state = "low_wall_paperframe-0"
	base_icon_state = "low_wall_paperframe"
	sheet_type = /datum/material/paper
	custom_materials = list(/datum/material/paper = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)
