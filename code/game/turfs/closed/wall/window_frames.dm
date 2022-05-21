/obj/structure/window_frame
	name = "window frame"
	desc = "A frame section to place a window on top."
	icon = 'icons/turf/walls/low_walls/low_wall_normal.dmi'
	icon_state = "low_wall_normal-0"
	base_icon_state = "low_wall_normal"
	plane = OVER_TILE_PLANE //otherwise they will mask windows
	smoothing_flags = SMOOTH_BITMASK|SMOOTH_OBJ
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FRAMES)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FRAMES)
	opacity = FALSE
	density = TRUE
	rad_insulation = null
	frill_icon = null // we dont have a frill, our window does
	armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 100, BOMB = 10, BIO = 100, RAD = 100, FIRE = 0, ACID = 0)
	max_integrity = 50
	anchored = TRUE

	///whether we currently have a grille
	var/has_grille = FALSE
	///whether we spawn a window structure with us on mapload
	var/start_with_window = FALSE
	///Icon used by grilles for this window frame
	var/grille_icon = 'icons/obj/smooth_structures/window_grille.dmi'
	///Icon state used by grilles for this window frame
	var/grille_icon_state = "window_grille"

	///whether or not this window is reinforced and thus doesnt use the default attackby() behavior
	var/is_reinforced = FALSE

	///typepath. creates a corresponding window for this frame.
	///is either a material sheet typepath (eg /obj/item/stack/sheet/glass) or a fulltile window typepath (eg /obj/structure/window/fulltile)
	var/window_type = /obj/item/stack/sheet/glass

	var/sheet_type = /obj/item/stack/sheet/iron
	var/sheet_amount = 2

/obj/structure/window_frame/Initialize(mapload)
	. = ..()

	update_appearance()
	AddElement(/datum/element/climbable)

	if(mapload && start_with_window)
		create_structure_window(window_type, TRUE)

///helper proc to check if we already have a window
/obj/structure/window_frame/proc/has_window()
	SHOULD_BE_PURE(TRUE)

	for(var/obj/structure/window/window in loc)
		if(window.fulltile)
			return TRUE

	return FALSE

///creates a window from the typepath given from window_type, which is either a glass sheet typepath or a /obj/structure/window subtype
/obj/structure/window_frame/proc/create_structure_window(window_material_type, start_anchored = TRUE)
	var/obj/structure/window/our_window

	if(ispath(window_material_type, /obj/structure/window))
		our_window = new window_material_type(loc)
		if(!our_window.fulltile)
			stack_trace("Window frames can't use non fulltile windows!")

	//window_material_type isnt a window typepath, so check if its a material typepath
	if(ispath(window_material_type, /obj/item/stack/sheet/glass))
		our_window = new /obj/structure/window/fulltile(loc)

	if(ispath(window_material_type, /obj/item/stack/sheet/rglass))
		our_window = new /obj/structure/window/reinforced/fulltile(loc)

	if(ispath(window_material_type, /obj/item/stack/sheet/plasmaglass))
		our_window = new /obj/structure/window/plasma/fulltile(loc)

	if(ispath(window_material_type, /obj/item/stack/sheet/plasmarglass))
		our_window = new /obj/structure/window/reinforced/plasma/fulltile(loc)

	if(ispath(window_material_type, /obj/item/stack/sheet/titaniumglass))
		our_window = new /obj/structure/window/reinforced/shuttle(loc)

	if(ispath(window_material_type, /obj/item/stack/sheet/plastitaniumglass))
		our_window = new /obj/structure/window/reinforced/plasma/plastitanium(loc)

	if(ispath(window_material_type, /obj/item/stack/sheet/paperframes))
		our_window = new /obj/structure/window/paperframe(loc)

	if(!start_anchored)
		our_window.set_anchored(FALSE)
		our_window.state = WINDOW_OUT_OF_FRAME

	our_window.update_appearance()

/obj/structure/window_frame/attackby(obj/item/attacking_item, mob/living/user, params)

	add_fingerprint(user)

	if(attacking_item.tool_behaviour == TOOL_WELDER)
		if(atom_integrity < max_integrity)
			if(!attacking_item.tool_start_check(user, amount = 0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(!attacking_item.use_tool(src, user, 40, volume = 50))
				return

			atom_integrity = max_integrity
			to_chat(user, span_notice("You repair [src]."))
			update_appearance()
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

	else if(attacking_item.tool_behaviour == TOOL_WIRECUTTER)
		if(has_grille)

			if(!attacking_item.use_tool(src, user, 0, volume = 50))
				return

			to_chat(user, "<span class='notice'>You cut the grille on [src].</span>")

			has_grille = FALSE
			update_appearance()
			return

	else if(isstack(attacking_item))
		var/obj/item/stack/adding_stack = attacking_item
		var/stack_name = "[adding_stack]" // in case the stack gets deleted after use()

		if(is_glass_sheet(adding_stack) && !(has_window()) && adding_stack.use(sheet_amount))
			to_chat(user, "<span class='notice'>You start to add [stack_name] to [src].")
			if(!do_after(user, 2 SECONDS, src))
				return

			to_chat(user, "<span class='notice'>You add [stack_name] to [src].")
			create_structure_window(adding_stack.type, FALSE)

		else if(istype(adding_stack, /obj/item/stack/rods) && !has_grille && adding_stack.use(sheet_amount))
			has_grille = TRUE
			to_chat(user, "<span class='notice'>You add [stack_name] to [src]")
			update_appearance()

	return ..()

/obj/structure/window_frame/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = NONE)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/window_frame/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/window_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/obj/structure/window_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		to_chat(user, "<span class='notice'>You deconstruct the window frame.</span>")
		qdel(src)
		return TRUE
	return FALSE

/obj/structure/window_frame/examine(mob/user)
	. = ..()
	if(has_window() && has_grille)
		. += "<span class='notice'>The window is fully constructed.</span>"
	else if(has_window())
		. += "<span class='notice'>The window set into the frame has no reinforcement.</span>"
	else if(has_grille)
		. += "<span class='notice'>The window frame only has a grille set into it.</span>"
	else
		. += "<span class='notice'>The window frame is empty</span>"

///delightfully devilous seymour
/obj/structure/window_frame/set_smoothed_icon_state(new_junction)
	. = ..()
	update_icon()

/obj/structure/window_frame/update_overlays()
	. = ..()
	if(has_grille)
		. += mutable_appearance(grille_icon, "[grille_icon_state]-[smoothing_junction]")

/obj/structure/window_frame/grille
	has_grille = TRUE

/obj/structure/window_frame/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/reinforced
	name = "reinforced window frame"
	window_type = /obj/item/stack/sheet/rglass
	armor = list(MELEE = 80, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	max_integrity = 150
	damage_deflection = 11

/obj/structure/window_frame/reinforced/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/titanium
	name = "shuttle window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_shuttle.dmi'
	icon_state = "low_wall_shuttle-0"
	base_icon_state = "low_wall_shuttle"
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	window_type = /obj/item/stack/sheet/titaniumglass
	custom_materials = list(/datum/material/titanium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/titanium/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/plastitanium
	name = "plastitanium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_plastitanium.dmi'
	icon_state = "low_wall_plastitanium-0"
	base_icon_state = "low_wall_plastitanium"
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	window_type = /obj/item/stack/sheet/plastitaniumglass
	custom_materials = list(/datum/material/alloy/plastitanium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/plastitanium/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/wood
	name = "wooden platform"
	icon = 'icons/turf/walls/low_walls/low_wall_wood.dmi'
	icon_state = "low_wall_wood-0"
	base_icon_state = "low_wall_wood"
	sheet_type = /obj/item/stack/sheet/mineral/wood
	custom_materials = list(/datum/material/wood = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/uranium
	name = "uranium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_uranium.dmi'
	icon_state = "low_wall_uranium-0"
	base_icon_state = "low_wall_uranium"
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	custom_materials = list(/datum/material/uranium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/iron
	name = "rough iron window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_iron.dmi'
	icon_state = "low_wall_iron-0"
	base_icon_state = "low_wall_iron"
	sheet_type = /obj/item/stack/sheet/iron
	custom_materials = list(/datum/material/iron = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/silver
	name = "silver window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_silver.dmi'
	icon_state = "low_wall_silver-0"
	base_icon_state = "low_wall_silver"
	sheet_type = /obj/item/stack/sheet/mineral/silver
	custom_materials = list(/datum/material/silver = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/gold
	name = "gold window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_gold.dmi'
	icon_state = "low_wall_gold-0"
	base_icon_state = "low_wall_gold"
	sheet_type = /obj/item/stack/sheet/mineral/gold
	custom_materials = list(/datum/material/gold = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/bronze
	name = "clockwork window mount"
	icon = 'icons/turf/walls/low_walls/low_wall_bronze.dmi'
	icon_state = "low_wall_bronze-0"
	base_icon_state = "low_wall_bronze"
	sheet_type = /obj/item/stack/sheet/bronze
	custom_materials = list(/datum/material/bronze = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/cult
	name = "rune-scarred window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_cult.dmi'
	icon_state = "low_wall_cult-0"
	base_icon_state = "low_wall_cult"
	sheet_type = /obj/item/stack/sheet/runed_metal
	custom_materials = list(/datum/material/runedmetal = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/hotel
	name = "hotel window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_hotel.dmi'
	icon_state = "low_wall_hotel-0"
	base_icon_state = "low_wall_hotel"
	sheet_type = /obj/item/stack/sheet/mineral/wood
	custom_materials = list(/datum/material/wood = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/material
	name = "material window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_material.dmi'
	icon_state = "low_wall_material-0"
	base_icon_state = "low_wall_material"
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/structure/window_frame/rusty
	name = "rusty window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_rusty.dmi'
	icon_state = "low_wall_rusty-0"
	base_icon_state = "low_wall_rusty"
	sheet_type = /obj/item/stack/sheet/iron
	custom_materials = list(/datum/material/iron = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/sandstone
	name = "sandstone plinth"
	icon = 'icons/turf/walls/low_walls/low_wall_sandstone.dmi'
	icon_state = "low_wall_sandstone-0"
	base_icon_state = "low_wall_sandstone"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	custom_materials = list(/datum/material/sandstone = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/bamboo
	name = "bamboo platform"
	icon = 'icons/turf/walls/low_walls/low_wall_bamboo.dmi'
	icon_state = "low_wall_bamboo-0"
	base_icon_state = "low_wall_bamboo"
	sheet_type = /obj/item/stack/sheet/mineral/bamboo
	custom_materials = list(/datum/material/bamboo = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/paperframe
	name = "japanese window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_paperframe.dmi'
	icon_state = "low_wall_paperframe-0"
	base_icon_state = "low_wall_paperframe"
	sheet_type = /obj/item/stack/sheet/paperframes
	custom_materials = list(/datum/material/paper = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)
