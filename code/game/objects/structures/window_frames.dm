/obj/structure/window_frame
	name = "window frame"
	desc = "A frame section to place a window on top."
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_normal.dmi'
	icon_state = "window_frame_normal-0"
	base_icon_state = "window_frame_normal"
	smoothing_flags = SMOOTH_BITMASK|SMOOTH_OBJ
	smoothing_groups = SMOOTH_GROUP_WINDOW_FRAMES
	canSmoothWith = SMOOTH_GROUP_WINDOW_FRAMES
	pass_flags_self = PASSTABLE | LETPASSTHROW | PASSGRILLE | PASSWINDOW
	opacity = FALSE
	density = TRUE
	rad_insulation = null
	armor_type = /datum/armor/window_frame
	max_integrity = 50
	anchored = TRUE

	///whether we currently have a grille
	var/has_grille = FALSE
	///whether we spawn a window structure with us on mapload
	var/start_with_window = FALSE
	///Icon used by grilles for this window frame
	var/grille_icon = 'icons/obj/structures/smooth/window_grille.dmi'

	var/grille_black_icon = 'icons/obj/structures/smooth/window_grille_black.dmi'
	///Icon state used by grilles for this window frame.
	var/grille_icon_state = "window_grille"

	var/frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_normal.dmi'

	///whether or not this window is reinforced and thus doesnt use the default attackby() behavior
	var/is_reinforced = FALSE

	///typepath. creates a corresponding window for this frame.
	///is either a material sheet typepath (eg /obj/item/stack/sheet/glass) or a fulltile window typepath (eg /obj/structure/window/fulltile)
	var/window_type = /obj/item/stack/sheet/glass

	var/sheet_type = /obj/item/stack/sheet/iron
	var/sheet_amount = 2

	/// Whether or not we're disappearing but dramatically
	var/dramatically_disappearing = FALSE

/datum/armor/window_frame
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10
	bio = 100
	fire = 0
	acid = 0

/obj/structure/window_frame/Initialize(mapload)
	. = ..()

	update_appearance()
	AddComponent(/datum/component/climb_walkable)
	AddElement(/datum/element/climbable, on_try_climb_procpath = TYPE_PROC_REF(/obj/structure/window_frame, on_try_climb))

	if(mapload && start_with_window)
		create_structure_window(window_type)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

///helper proc to check if we already have a window
/obj/structure/window_frame/proc/has_window()
	SHOULD_BE_PURE(TRUE)

	for(var/obj/structure/window/window in loc)
		if(window.fulltile)
			return TRUE

	return FALSE

///Called by the climbable element if you try climb up. Better hope you're well protected against shocks! XD
/obj/structure/window_frame/proc/on_try_climb(mob/climber)
	try_shock(climber, 100)

///Gives the user a shock if they get unlucky (Based on shock chance)
/obj/structure/window_frame/proc/try_shock(mob/user, shock_chance)
	var/turf/my_turf = get_turf(src)
	var/obj/structure/cable/underlaying_cable = my_turf.get_cable_node()
	if(!has_grille) // no grille? dont shock.
		return FALSE
	if(!underlaying_cable)
		return FALSE
	if(!prob(shock_chance))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	if(electrocute_mob(user, underlaying_cable, src, 1, TRUE))
		var/datum/effect_system/spark_spread/spark_effect = new /datum/effect_system/spark_spread
		spark_effect.set_up(3, 1, src)
		spark_effect.start()
		return TRUE
	return FALSE

/obj/structure/window_frame/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!isliving(AM))
		return
	var/mob/living/potential_victim = AM
	if(potential_victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return
	try_shock(potential_victim, 100)


/obj/structure/window_frame/attack_animal(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(!try_shock(user, 70) && !QDELETED(src)) //Last hit still shocks but shouldn't deal damage to the grille
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/window_frame/attack_hulk(mob/living/carbon/human/user)
	if(try_shock(user, 70))
		return
	. = ..()

/obj/structure/window_frame/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(span_warning("[user] hits [src]."), null, null, COMBAT_MESSAGE_RANGE)
	log_combat(user, src, "hit")
	if(!try_shock(user, 70))
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/window_frame/attack_alien(mob/living/user, list/modifiers)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_warning("[user] mangles [src]."), null, null, COMBAT_MESSAGE_RANGE)
	if(!try_shock(user, 70))
		take_damage(20, BRUTE, MELEE, 1)

/obj/structure/window_frame/wirecutter_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	if(try_shock(user, 100))
		return
	if(!has_grille)
		return
	if(!tool.use_tool(src, user, 0, volume = 50))
		return
	tool.play_tool_sound(src, 100)
	balloon_alert(user, "grille cut!")
	has_grille = FALSE
	update_appearance()
	return ITEM_INTERACT_SUCCESS


/obj/structure/window_frame/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()

	add_fingerprint(user)

	if(!tool.tool_start_check(user, amount = 0, heat_required = HIGH_TEMPERATURE_REQUIRED))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "cutting...")
	if(!tool.use_tool(src, user, 70, volume = 50))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "deconstructed")
	deconstruct(TRUE)

	return ITEM_INTERACT_SUCCESS

/obj/structure/window_frame/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	add_fingerprint(user)

	if(atom_integrity >= max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return ITEM_INTERACT_BLOCKING
	if(!tool.tool_start_check(user, amount = 0))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "repairing...")
	if(!tool.use_tool(src, user, 40, volume = 50))
		return ITEM_INTERACT_BLOCKING

	atom_integrity = max_integrity
	balloon_alert(user, "repaired!")
	update_appearance()
	return ITEM_INTERACT_SUCCESS

///creates a window from the typepath given from window_type, which is either a glass sheet typepath or a /obj/structure/window subtype
/obj/structure/window_frame/proc/create_structure_window(window_material_type)
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

	our_window.update_appearance()
	return our_window

/obj/structure/window_frame/attackby(obj/item/attacking_item, mob/living/user, params)
	add_fingerprint(user)
	if(isstack(attacking_item))
		var/obj/item/stack/adding_stack = attacking_item
		var/stack_name = "[adding_stack]" // in case the stack gets deleted after use()

		if(is_glass_sheet(adding_stack) && !(has_window()) && adding_stack.use(sheet_amount))
			to_chat(user, "<span class='notice'>You start to add [stack_name] to [src].")
			if(!do_after(user, 2 SECONDS, src))
				return

			to_chat(user, "<span class='notice'>You add [stack_name] to [src].")
			var/obj/structure/window/our_window = create_structure_window(adding_stack.type)
			our_window.state = WINDOW_OUT_OF_FRAME
			our_window.set_anchored(FALSE)

		else if(istype(adding_stack, /obj/item/stack/rods) && !has_grille && adding_stack.use(sheet_amount))
			has_grille = TRUE
			to_chat(user, "<span class='notice'>You add [stack_name] to [src]")
			update_appearance()

	else if((attacking_item.obj_flags & CONDUCTS_ELECTRICITY) && try_shock(user, 70))
		return

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
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
		if(RCD_WINDOWGRILLE)
			var/cost = 0
			var/delay = 0

			if(!has_grille)
				return rcd_result_with_memory(
					list("delay" = 2 SECONDS, "cost" = 2),
					get_turf(src), RCD_MEMORY_WINDOWGRILLE
				)

			var/obj/structure/window/window_path = the_rcd.rcd_design_path
			if(!ispath(window_path))
				stack_trace("invalid window path passed to rcd_vals: [window_path]")
				return FALSE

			if(initial(window_path.fulltile))
				cost = 8
				delay = 3 SECONDS
			else
				cost = 4
				delay = 2 SECONDS

			if(initial(window_path.reinf))
				cost *= 1.5
				delay *= 1.5

			if(!cost)
				return FALSE

			return rcd_result_with_memory(
				list("delay" = delay, "cost" = cost),
				get_turf(src), RCD_MEMORY_WINDOWGRILLE
			)

	return FALSE

/obj/structure/window_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_DECONSTRUCT)
			var/turf/home = get_turf(src)
			// No thing to display on if we get deleted
			home.balloon_alert(user, "deconstructed!")
			qdel(src)
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(!isturf(loc))
				return FALSE

			if(!has_grille)
				balloon_alert(user, "grill added!")
				has_grille = TRUE
				update_appearance()
				return TRUE

			var/obj/structure/window/window_path = rcd_data["[RCD_DESIGN_PATH]"]
			if(!ispath(window_path))
				CRASH("Invalid window path type in RCD: [window_path]")

			if(!initial(window_path.fulltile))
				if(!valid_build_direction(loc, user.dir, is_fulltile = FALSE))
					balloon_alert(user, "window already here!")
					return FALSE

			var/obj/structure/window/window = new window_path(loc, user.dir)
			window.set_anchored(TRUE)
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

/// if this frame has a grill, creates both the overlay for the grill (that goes over cables) and the black overlay beneath it (goes over us, but not cables)
/obj/structure/window_frame/proc/create_grill_overlays(list/return_list)
	if(!has_grille || !return_list)
		return

	return_list += mutable_appearance(grille_black_icon, "[grille_icon_state]_black-[smoothing_junction]")
	return_list += mutable_appearance(grille_icon, "[grille_icon_state]-[smoothing_junction]")

/// if this frame has a valid frame icon, creates it. this is what obscures the cable if it goes through the frame
/obj/structure/window_frame/proc/create_frame_overlay(list/return_list)
	if(!frame_icon || !return_list)
		return
	return_list += mutable_appearance(frame_icon, "[base_icon_state]-[smoothing_junction]", appearance_flags = KEEP_APART)

/obj/structure/window_frame/update_overlays()
	. = ..()
	create_grill_overlays(.)
	create_frame_overlay(.)

/obj/structure/window_frame/proc/temporary_shatter(time_to_go = 0 SECONDS, time_to_return = 4 SECONDS)
	if(dramatically_disappearing)
		return

	//dissapear in 1 second
	dramatically_disappearing = TRUE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, moveToNullspace)), time_to_go) //woosh

	// come back in 1 + 4 seconds
	addtimer(VARSET_CALLBACK(src, atom_integrity, atom_integrity), time_to_go + time_to_return) //set the health back (icon is updated on move)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, forceMove), loc), time_to_go + time_to_return) //we back boys
	addtimer(VARSET_CALLBACK(src, dramatically_disappearing, FALSE), time_to_go + time_to_return) //also set the var back

/// Do some very specific checks to see if we *would* get shocked. Returns TRUE if it's shocked
/obj/structure/window_frame/proc/is_shocked()
	var/turf/turf = get_turf(src)
	var/obj/structure/cable/cable = turf.get_cable_node()
	var/list/powernet_info = get_powernet_info_from_source(cable)

	if(!powernet_info)
		return FALSE

	var/datum/powernet/powernet = powernet_info["powernet"]
	return !!powernet.get_electrocute_damage()

/obj/structure/window_frame/grille
	has_grille = TRUE

/obj/structure/window_frame/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/reinforced
	name = "reinforced window frame"
	window_type = /obj/item/stack/sheet/rglass
	armor_type = /datum/armor/window_frame_reinforced
	max_integrity = 150
	damage_deflection = 11

/datum/armor/window_frame_reinforced
	melee = 80
	bomb = 25
	bio = 100
	fire = 80
	acid = 100

/obj/structure/window_frame/reinforced/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/reinforced/damaged
	var/integrity_min_factor = 0.2
	var/integrity_max_factor = 0.8

/obj/structure/window_frame/reinforced/damaged/Initialize(mapload)
	. = ..()
	var/obj/structure/window/our_window = locate() in get_turf(src)
	if(!our_window)
		return

	our_window.update_integrity(rand(max_integrity * integrity_min_factor, max_integrity * integrity_max_factor))

/obj/structure/window_frame/reinforced/damaged/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/titanium
	name = "shuttle window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_shuttle.dmi'
	icon_state = "window_frame_shuttle-0"
	base_icon_state = "window_frame_shuttle"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_shuttle.dmi'
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	window_type = /obj/item/stack/sheet/titaniumglass
	custom_materials = list(/datum/material/titanium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/titanium/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/titanium/grille
	has_grille = TRUE

/obj/structure/window_frame/plastitanium
	name = "plastitanium window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_plastitanium.dmi'
	icon_state = "window_frame_plastitanium-0"
	base_icon_state = "window_frame_plastitanium"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_plastitanium.dmi'
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	window_type = /obj/item/stack/sheet/plastitaniumglass
	custom_materials = list(/datum/material/alloy/plastitanium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/plastitanium/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE

/obj/structure/window_frame/wood
	name = "wooden platform"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_wood.dmi'
	icon_state = "window_frame_wood-0"
	base_icon_state = "window_frame_wood"
	frame_icon = null //no walls above the center
	sheet_type = /obj/item/stack/sheet/mineral/wood
	custom_materials = list(/datum/material/wood = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/uranium
	name = "uranium window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_uranium.dmi'
	icon_state = "window_frame_uranium-0"
	base_icon_state = "window_frame_uranium"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_uranium.dmi'
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	custom_materials = list(/datum/material/uranium = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/iron
	name = "rough iron window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_iron.dmi'
	icon_state = "window_frame_iron-0"
	base_icon_state = "window_frame_iron"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_iron.dmi'
	sheet_type = /obj/item/stack/sheet/iron
	custom_materials = list(/datum/material/iron = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/silver
	name = "silver window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_silver.dmi'
	icon_state = "window_frame_silver-0"
	base_icon_state = "window_frame_silver"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_silver.dmi'
	sheet_type = /obj/item/stack/sheet/mineral/silver
	custom_materials = list(/datum/material/silver = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/gold
	name = "gold window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_gold.dmi'
	icon_state = "window_frame_gold-0"
	base_icon_state = "window_frame_gold"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_gold.dmi'
	sheet_type = /obj/item/stack/sheet/mineral/gold
	custom_materials = list(/datum/material/gold = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/bronze
	name = "clockwork window mount"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_bronze.dmi'
	icon_state = "window_frame_bronze-0"
	base_icon_state = "window_frame_bronze"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_bronze.dmi'
	sheet_type = /obj/item/stack/sheet/bronze
	custom_materials = list(/datum/material/bronze = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/cult
	name = "rune-scarred window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_cult.dmi'
	icon_state = "window_frame_cult-0"
	base_icon_state = "window_frame_cult"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_cult.dmi'
	sheet_type = /obj/item/stack/sheet/runed_metal
	custom_materials = list(/datum/material/runedmetal = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/hotel
	name = "hotel window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_hotel.dmi'
	icon_state = "window_frame_hotel-0"
	base_icon_state = "window_frame_hotel"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_hotel.dmi'
	sheet_type = /obj/item/stack/sheet/mineral/wood
	custom_materials = list(/datum/material/wood = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/material
	name = "material window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_material.dmi'
	icon_state = "window_frame_material-0"
	base_icon_state = "window_frame_material"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_material.dmi'
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/structure/window_frame/rusty
	name = "rusty window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_rusty.dmi'
	icon_state = "window_frame_rusty-0"
	base_icon_state = "window_frame_rusty"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_rusty.dmi'
	sheet_type = /obj/item/stack/sheet/iron
	custom_materials = list(/datum/material/iron = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/sandstone
	name = "sandstone plinth"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_sandstone.dmi'
	icon_state = "window_frame_sandstone-0"
	base_icon_state = "window_frame_sandstone"
	frame_icon = null //no walls above center
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	custom_materials = list(/datum/material/sandstone = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/bamboo
	name = "bamboo platform"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_bamboo.dmi'
	icon_state = "window_frame_bamboo-0"
	base_icon_state = "window_frame_bamboo"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_bamboo.dmi'
	sheet_type = /obj/item/stack/sheet/mineral/bamboo
	custom_materials = list(/datum/material/bamboo = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/paperframe
	name = "japanese window frame"
	icon = 'icons/obj/structures/smooth/window_frames/window_frame_paperframe.dmi'
	icon_state = "window_frame_paperframe-0"
	base_icon_state = "window_frame_paperframe"
	frame_icon = 'icons/obj/structures/smooth/window_frames/frame_faces/window_frame_paperframe.dmi'
	sheet_type = /obj/item/stack/sheet/paperframes
	window_type = /obj/item/stack/sheet/paperframes
	custom_materials = list(/datum/material/paper = WINDOW_FRAME_BASE_MATERIAL_AMOUNT)

/obj/structure/window_frame/paperframe/grille_and_window
	has_grille = TRUE
	start_with_window = TRUE
