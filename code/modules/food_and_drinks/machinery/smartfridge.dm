// -------------------------
//  SmartFridge.  Much todo
// -------------------------
/obj/machinery/smartfridge
	name = "smartfridge"
	desc = "Keeps cold things cold and hot things cold."
	icon = 'icons/obj/machines/smartfridge.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/smartfridge
	light_power = 1
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	integrity_failure = 0.5
	can_atmos_pass = ATMOS_PASS_NO
	/// What path boards used to construct it should build into when dropped. Needed so we don't accidentally have them build variants with items preloaded in them.
	var/base_build_path = /obj/machinery/smartfridge
	/// Maximum number of items that can be loaded into the machine
	var/max_n_of_items = 1500
	/// If the AI is allowed to retrieve items within the machine
	var/allow_ai_retrieve = FALSE
	/// List of items that the machine starts with upon spawn
	var/list/initial_contents
	/// If the machine shows an approximate number of its contents on its sprite
	var/visible_contents = TRUE
	/// Is this smartfridge going to have a glowing screen? (Drying Racks are not)
	var/has_emissive = TRUE
	/// Whether the smartfridge is welded down to the floor disabling unwrenching
	var/welded_down = FALSE

/obj/machinery/smartfridge/Initialize(mapload)
	. = ..()
	create_reagents(100, NO_REACT)
	air_update_turf(TRUE, TRUE)
	register_context()
	if(mapload && !istype(src, /obj/machinery/smartfridge/drying_rack))
		welded_down = TRUE

	if(islist(initial_contents))
		for(var/typekey in initial_contents)
			var/amount = initial_contents[typekey]
			if(isnull(amount))
				amount = 1
			for(var/i in 1 to amount)
				load(new typekey(src))

/obj/machinery/smartfridge/Move(atom/newloc, direct, glide_size_override, update_dir)
	var/turf/old_loc = loc
	. = ..()
	move_update_air(old_loc)

/obj/machinery/smartfridge/can_be_unfasten_wrench(mob/user, silent)
	if(welded_down)
		to_chat(user, span_warning("[src] is welded to the floor!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/smartfridge/set_anchored(anchorvalue)
	. = ..()
	if(!anchored && welded_down) //make sure they're keep in sync in case it was forcibly unanchored by badmins or by a megafauna.
		welded_down = FALSE
	can_atmos_pass = anchorvalue ? ATMOS_PASS_NO : ATMOS_PASS_YES
	air_update_turf(TRUE, anchorvalue)

/obj/machinery/smartfridge/welder_act(mob/living/user, obj/item/tool)
	..()
	if(istype(src, /obj/machinery/smartfridge/drying_rack))
		return FALSE
	if(welded_down)
		if(!tool.tool_start_check(user, amount=2))
			return TRUE
		user.visible_message(
			span_notice("[user.name] starts to cut the [name] free from the floor."),
			span_notice("You start to cut [src] free from the floor..."),
			span_hear("You hear welding."),
		)
		if(!tool.use_tool(src, user, delay=100, volume=100))
			return FALSE
		welded_down = FALSE
		to_chat(user, span_notice("You cut [src] free from the floor."))
		return TRUE
	if(!anchored)
		to_chat(user, span_warning("[src] needs to be wrenched to the floor!"))
		return TRUE
	if(!tool.tool_start_check(user, amount=2))
		return TRUE
	user.visible_message(
		span_notice("[user.name] starts to weld the [name] to the floor."),
		span_notice("You start to weld [src] to the floor..."),
		span_hear("You hear welding."),
	)
	if(!tool.use_tool(src, user, delay=100, volume=100))
		balloon_alert(user, "cancelled!")
		return FALSE
	welded_down = TRUE
	to_chat(user, span_notice("You weld [src] to the floor."))
	return TRUE

/obj/machinery/smartfridge/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(istype(src, /obj/machinery/smartfridge/drying_rack))
		return FALSE
	if(machine_stat & BROKEN)
		if(!tool.tool_start_check(user, amount=1))
			return FALSE
		user.visible_message(
			span_notice("[user] is repairing [src]."),
			span_notice("You begin repairing [src]..."),
			span_hear("You hear welding."),
		)
		if(tool.use_tool(src, user, delay=40, volume=50))
			if(!(machine_stat & BROKEN))
				return FALSE
			balloon_alert(user, "repaired")
			atom_integrity = max_integrity
			set_machine_stat(machine_stat & ~BROKEN)
			update_icon()
			return TRUE
	else
		balloon_alert(user, "no repair needed!")
		return FALSE

/obj/machinery/smartfridge/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	var/tool_tip_set = FALSE
	if(held_item.tool_behaviour == TOOL_WELDER && !istype(src, /obj/machinery/smartfridge/drying_rack))
		if(welded_down)
			context[SCREENTIP_CONTEXT_LMB] = "Unweld"
			tool_tip_set = TRUE
		else if (!welded_down && anchored)
			context[SCREENTIP_CONTEXT_LMB] = "Weld down"
			tool_tip_set = TRUE
		if(machine_stat & BROKEN)
			context[SCREENTIP_CONTEXT_RMB] = "Repair"
			tool_tip_set = TRUE

	return tool_tip_set ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/machinery/smartfridge/RefreshParts()
	. = ..()
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_n_of_items = 1500 * matter_bin.tier

/obj/machinery/smartfridge/examine(mob/user)
	. = ..()

	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: This unit can hold a maximum of <b>[max_n_of_items]</b> items.")

	if(welded_down)
		. += span_info("It's moored firmly to the floor. You can unsecure its moorings with a <b>welder</b>.")
	else if(anchored)
		. += span_info("It's currently anchored to the floor. You can secure its moorings with a <b>welder</b>, or remove it with a <b>wrench</b>.")
	else
		. += span_info("It's not anchored to the floor. You can secure it in place with a <b>wrench</b>.")

/obj/machinery/smartfridge/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & BROKEN)
		set_light(0)
		return
	set_light(powered() ? MINIMUM_USEFUL_LIGHT_RANGE : 0)

/obj/machinery/smartfridge/update_icon_state()
	icon_state = "[initial(icon_state)]"
	if(machine_stat & BROKEN)
		icon_state += "-broken"
	else if(!powered())
		icon_state += "-off"
	return ..()

/obj/machinery/smartfridge/update_overlays()
	. = ..()

	var/list/shown_contents = contents - component_parts
	if(visible_contents && shown_contents.len > 0)
		var/contents_icon_state = "[initial(icon_state)]"
		switch(base_build_path)
			if(/obj/machinery/smartfridge/extract)
				contents_icon_state += "-slime"
			if(/obj/machinery/smartfridge/food)
				contents_icon_state += "-food"
			if(/obj/machinery/smartfridge/drinks)
				contents_icon_state += "-drink"
			if(/obj/machinery/smartfridge/organ)
				contents_icon_state += "-organ"
			if(/obj/machinery/smartfridge/petri)
				contents_icon_state += "-petri"
			if(/obj/machinery/smartfridge/chemistry)
				contents_icon_state += "-chem"
			if(/obj/machinery/smartfridge/chemistry/virology)
				contents_icon_state += "-viro"
			else
				contents_icon_state += "-plant"
		switch(shown_contents.len)
			if(1 to 25)
				contents_icon_state += "-1"
			if(26 to 50)
				contents_icon_state += "-2"
			if(31 to INFINITY)
				contents_icon_state += "-3"
		. += mutable_appearance(icon, contents_icon_state)

	. += mutable_appearance(icon, "[initial(icon_state)]-glass[(machine_stat & BROKEN) ? "-broken" : ""]")

	if(!machine_stat && has_emissive)
		. += emissive_appearance(icon, "[initial(icon_state)]-light-mask", src, alpha = src.alpha)

/obj/machinery/smartfridge/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_unfasten_wrench(user, tool))
		power_change()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/smartfridge/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/smartfridge/atom_break(damage_flag)
	playsound(src, SFX_SHATTER, 50, TRUE)
	return ..()

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, O))
		if(panel_open)
			add_overlay("[initial(icon_state)]-panel")
		else
			cut_overlay("[initial(icon_state)]-panel")
		SStgui.update_uis(src)
		return

	if(default_pry_open(O, close_after_pry = TRUE))
		return

	if(!welded_down && default_deconstruction_crowbar(O))
		SStgui.update_uis(src)
		return

	if(!machine_stat)
		var/list/shown_contents = contents - component_parts
		if(shown_contents.len >= max_n_of_items)
			to_chat(user, span_warning("\The [src] is full!"))
			return FALSE

		if(accept_check(O))
			load(O)
			user.visible_message(span_notice("[user] adds \the [O] to \the [src]."), span_notice("You add \the [O] to \the [src]."))
			SStgui.update_uis(src)
			if(visible_contents)
				update_appearance()
			return TRUE

		if(istype(O, /obj/item/storage/bag))
			var/obj/item/storage/P = O
			var/loaded = 0
			for(var/obj/G in P.contents)
				if(shown_contents.len >= max_n_of_items)
					break
				if(accept_check(G))
					load(G)
					loaded++
			SStgui.update_uis(src)

			if(loaded)
				if(shown_contents.len >= max_n_of_items)
					user.visible_message(span_notice("[user] loads \the [src] with \the [O]."), \
						span_notice("You fill \the [src] with \the [O]."))
				else
					user.visible_message(span_notice("[user] loads \the [src] with \the [O]."), \
						span_notice("You load \the [src] with \the [O]."))
				if(O.contents.len > 0)
					to_chat(user, span_warning("Some items are refused."))
				if (visible_contents)
					update_appearance()
				return TRUE
			else
				to_chat(user, span_warning("There is nothing in [O] to put in [src]!"))
				return FALSE

	if(!user.combat_mode)
		to_chat(user, span_warning("\The [src] smartly refuses [O]."))
		SStgui.update_uis(src)
		return FALSE
	else
		return ..()

/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(istype(O, /obj/item/food/grown/) || istype(O, /obj/item/seeds/) || istype(O, /obj/item/grown/) || istype(O, /obj/item/graft/))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/proc/load(obj/item/O)
	if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.transferItemToLoc(O, src))
			to_chat(usr, span_warning("\the [O] is stuck to your hand, you cannot put it in \the [src]!"))
			return FALSE
		else
			return TRUE
	else
		if(O.loc.atom_storage)
			return O.loc.atom_storage.attempt_remove(O, src, silent = TRUE)
		else
			O.forceMove(src)
			return TRUE

///Really simple proc, just moves the object "O" into the hands of mob "M" if able, done so I could modify the proc a little for the organ fridge
/obj/machinery/smartfridge/proc/dispense(obj/item/O, mob/M)
	if(!M.put_in_hands(O))
		O.forceMove(drop_location())
		adjust_item_drop_location(O)
	use_power(active_power_usage)

/obj/machinery/smartfridge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartVend", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/smartfridge/ui_data(mob/user)
	. = list()

	var/listofitems = list()
	for (var/I in src)
		// We do not vend our own components.
		if(I in component_parts)
			continue

		var/atom/movable/O = I
		if (!QDELETED(O))
			var/md5name = md5(O.name) // This needs to happen because of a bug in a TGUI component, https://github.com/ractivejs/ractive/issues/744
			if (listofitems[md5name]) // which is fixed in a version we cannot use due to ie8 incompatibility
				listofitems[md5name]["amount"]++ // The good news is, #30519 made smartfridge UIs non-auto-updating
			else
				listofitems[md5name] = list("name" = O.name, "type" = O.type, "amount" = 1)
	sort_list(listofitems)

	.["contents"] = listofitems
	.["name"] = name
	.["isdryer"] = FALSE

/obj/machinery/smartfridge/Exited(atom/movable/gone, direction) // Update the UIs in case something inside is removed
	. = ..()
	SStgui.update_uis(src)

/obj/machinery/smartfridge/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("Release")
			var/desired = 0

			if(!allow_ai_retrieve && isAI(usr))
				to_chat(usr, span_warning("[src] does not seem to be configured to respect your authority!"))
				return

			if (params["amount"])
				desired = text2num(params["amount"])
			else
				desired = tgui_input_number(usr, "How many items would you like to take out?", "Release", max_value = 50)
				if(!desired)
					return FALSE

			if(QDELETED(src) || QDELETED(usr) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH)) // Sanity checkin' in case stupid stuff happens while we wait for input()
				return FALSE

			for(var/obj/item/dispensed_item in src)
				if(desired <= 0)
					break
				// Grab the first item in contents which name matches our passed name.
				// format_text() is used here to strip \improper and \proper from both names,
				// which is required for correct string comparison between them.
				if(format_text(dispensed_item.name) == format_text(params["name"]))
					if(dispensed_item in component_parts)
						CRASH("Attempted removal of [dispensed_item] component_part from smartfridge via smartfridge interface.")
					dispense(dispensed_item, usr)
					desired--

			if (visible_contents)
				update_appearance()
			return TRUE

	return FALSE

// ----------------------------
//  Drying Rack 'smartfridge'
// ----------------------------
/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	desc = "A wooden contraption, used to dry plant products, food and hide."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "drying_rack"
	resistance_flags = FLAMMABLE
	visible_contents = FALSE
	base_build_path = /obj/machinery/smartfridge/drying_rack //should really be seeing this without admin fuckery.
	use_power = NO_POWER_USE
	idle_power_usage = 0
	has_emissive = FALSE
	can_atmos_pass = ATMOS_PASS_YES
	var/drying = FALSE

/obj/machinery/smartfridge/drying_rack/on_deconstruction()
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)

	//remove all component parts inherited from smartfridge cause they were not required in crafting
	var/obj/item/circuitboard/machine/smartfridge/board = locate() in component_parts
	component_parts -= board
	qdel(board)
	component_parts.Cut()

	return ..()

/obj/machinery/smartfridge/drying_rack/default_deconstruction_screwdriver()
/obj/machinery/smartfridge/drying_rack/exchange_parts()
/obj/machinery/smartfridge/drying_rack/spawn_frame()

/obj/machinery/smartfridge/drying_rack/default_deconstruction_crowbar(obj/item/crowbar/C, ignore_panel = 1)
	..()

/obj/machinery/smartfridge/drying_rack/ui_data(mob/user)
	. = ..()
	.["isdryer"] = TRUE
	.["verb"] = "Take"
	.["drying"] = drying


/obj/machinery/smartfridge/drying_rack/ui_act(action, params)
	. = ..()
	if(.)
		update_appearance() // This is to handle a case where the last item is taken out manually instead of through drying pop-out
		return
	switch(action)
		if("Dry")
			toggle_drying(FALSE)
			return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/powered()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/smartfridge/drying_rack/power_change()
	. = ..()
	if(!powered())
		toggle_drying(TRUE)

/obj/machinery/smartfridge/drying_rack/load(obj/item/dried_object) //For updating the filled overlay
	. = ..()
	update_appearance()

/obj/machinery/smartfridge/drying_rack/update_overlays()
	. = ..()
	if(drying)
		. += "drying_rack_drying"
	var/list/shown_contents = contents - component_parts
	if(shown_contents.len)
		. += "drying_rack_filled"

/obj/machinery/smartfridge/drying_rack/process()
	..()
	if(drying)
		for(var/obj/item/item_iterator in src)
			if(!accept_check(item_iterator))
				continue
			rack_dry(item_iterator)

		SStgui.update_uis(src)
		update_appearance()
		use_power(active_power_usage)

/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O)
	if(HAS_TRAIT(O, TRAIT_DRYABLE)) //set on dryable element
		return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/proc/toggle_drying(forceoff)
	if(drying || forceoff)
		drying = FALSE
		update_use_power(IDLE_POWER_USE)
	else
		drying = TRUE
		update_use_power(ACTIVE_POWER_USE)
	update_appearance()

/obj/machinery/smartfridge/drying_rack/proc/rack_dry(obj/item/target)
	SEND_SIGNAL(target, COMSIG_ITEM_DRIED)

/obj/machinery/smartfridge/drying_rack/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	atmos_spawn_air("[TURF_TEMPERATURE(1000)]")


// ----------------------------
//  Bar drink smartfridge
// ----------------------------
/obj/machinery/smartfridge/drinks
	name = "drink showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	base_build_path = /obj/machinery/smartfridge/drinks

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(!is_reagent_container(O) || (O.item_flags & ABSTRACT) || !O.reagents || !O.reagents.reagent_list.len)
		return FALSE
	if(istype(O, /obj/item/reagent_containers/cup) || istype(O, /obj/item/reagent_containers/cup/glass) || istype(O, /obj/item/reagent_containers/condiment))
		return TRUE

// ----------------------------
//  Food smartfridge
// ----------------------------
/obj/machinery/smartfridge/food
	desc = "A refrigerated storage unit for food."
	base_build_path = /obj/machinery/smartfridge/food

/obj/machinery/smartfridge/food/accept_check(obj/item/O)
	if(IS_EDIBLE(O))
		return TRUE
	return FALSE

// -------------------------------------
// Xenobiology Slime-Extract Smartfridge
// -------------------------------------
/obj/machinery/smartfridge/extract
	name = "smart slime extract storage"
	desc = "A refrigerated storage unit for slime extracts."
	base_build_path = /obj/machinery/smartfridge/extract

/obj/machinery/smartfridge/extract/accept_check(obj/item/O)
	if(istype(O, /obj/item/slime_extract))
		return TRUE
	if(istype(O, /obj/item/slime_scanner))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/extract/preloaded
	initial_contents = list(/obj/item/slime_scanner = 2)

// -------------------------------------
// Cytology Petri Dish Smartfridge
// -------------------------------------
/obj/machinery/smartfridge/petri
	name = "smart petri dish storage"
	desc = "A refrigerated storage unit for petri dishes."
	base_build_path = /obj/machinery/smartfridge/petri

/obj/machinery/smartfridge/petri/accept_check(obj/item/O)
	if(istype(O, /obj/item/petri_dish))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/petri/preloaded
	initial_contents = list(/obj/item/petri_dish = 5)

// -------------------------
// Organ Surgery Smartfridge
// -------------------------
/obj/machinery/smartfridge/organ
	name = "smart organ storage"
	desc = "A refrigerated storage unit for organ storage."
	max_n_of_items = 20 //vastly lower to prevent processing too long
	base_build_path = /obj/machinery/smartfridge/organ
	var/repair_rate = 0

/obj/machinery/smartfridge/organ/accept_check(obj/item/O)
	if(isorgan(O) || isbodypart(O))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/organ/load(obj/item/O)
	. = ..()
	if(!.) //if the item loads, clear can_decompose
		return
	if(isorgan(O))
		var/obj/item/organ/organ = O
		organ.organ_flags |= ORGAN_FROZEN
	if(isbodypart(O))
		var/obj/item/bodypart/bodypart = O
		for(var/obj/item/organ/stored in bodypart.contents)
			stored.organ_flags |= ORGAN_FROZEN

/obj/machinery/smartfridge/organ/RefreshParts()
	. = ..()
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_n_of_items = 20 * matter_bin.tier
		repair_rate = max(0, STANDARD_ORGAN_HEALING * (matter_bin.tier - 1) * 0.5)

/obj/machinery/smartfridge/organ/process(seconds_per_tick)
	for(var/obj/item/organ/target_organ in contents)
		if(!target_organ.damage)
			continue

		target_organ.apply_organ_damage(-repair_rate * target_organ.maxHealth * seconds_per_tick, required_organ_flag = ORGAN_ORGANIC)

/obj/machinery/smartfridge/organ/Exited(atom/movable/gone, direction)
	. = ..()
	if(isorgan(gone))
		var/obj/item/organ/O = gone
		O.organ_flags &= ~ORGAN_FROZEN
	if(isbodypart(gone))
		var/obj/item/bodypart/bodypart = gone
		for(var/obj/item/organ/stored in bodypart.contents)
			stored.organ_flags &= ~ORGAN_FROZEN

// -----------------------------
// Chemistry Medical Smartfridge
// -----------------------------
/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for medicine storage."
	base_build_path = /obj/machinery/smartfridge/chemistry

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O)
	var/static/list/chemfridge_typecache = typecacheof(list(
					/obj/item/reagent_containers/syringe,
					/obj/item/reagent_containers/cup/tube,
					/obj/item/reagent_containers/cup/bottle,
					/obj/item/reagent_containers/cup/beaker,
					/obj/item/reagent_containers/spray,
					/obj/item/reagent_containers/medigel,
					/obj/item/reagent_containers/chem_pack
	))

	if(istype(O, /obj/item/storage/pill_bottle))
		if(O.contents.len)
			for(var/obj/item/I in O)
				if(!accept_check(I))
					return FALSE
			return TRUE
		return FALSE
	if(!is_reagent_container(O) || (O.item_flags & ABSTRACT))
		return FALSE
	if(istype(O, /obj/item/reagent_containers/pill)) // empty pill prank ok
		return TRUE
	if(!O.reagents || !O.reagents.reagent_list.len) // other empty containers not accepted
		return FALSE
	if(is_type_in_typecache(O, chemfridge_typecache))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/chemistry/preloaded
	initial_contents = list(
		/obj/item/reagent_containers/pill/epinephrine = 12,
		/obj/item/reagent_containers/pill/multiver = 5,
		/obj/item/reagent_containers/cup/bottle/epinephrine = 1,
		/obj/item/reagent_containers/cup/bottle/multiver = 1)

// ----------------------------
// Virology Medical Smartfridge
// ----------------------------
/obj/machinery/smartfridge/chemistry/virology
	name = "smart virus storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	base_build_path = /obj/machinery/smartfridge/chemistry/virology

/obj/machinery/smartfridge/chemistry/virology/preloaded
	initial_contents = list(
		/obj/item/storage/pill_bottle/sansufentanyl = 2,
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/cup/bottle/cold = 1,
		/obj/item/reagent_containers/cup/bottle/flu_virion = 1,
		/obj/item/reagent_containers/cup/bottle/mutagen = 1,
		/obj/item/reagent_containers/cup/bottle/sugar = 1,
		/obj/item/reagent_containers/cup/bottle/plasma = 1,
		/obj/item/reagent_containers/cup/bottle/synaptizine = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1)

// ----------------------------
// Disk """fridge"""
// ----------------------------
/obj/machinery/smartfridge/disks
	name = "disk compartmentalizer"
	desc = "A machine capable of storing a variety of disks. Denoted by most as the DSU (disk storage unit)."
	icon_state = "disktoaster"
	icon = 'icons/obj/machines/vending.dmi'
	pass_flags = PASSTABLE
	can_atmos_pass = ATMOS_PASS_YES
	visible_contents = FALSE
	base_build_path = /obj/machinery/smartfridge/disks

/obj/machinery/smartfridge/disks/accept_check(obj/item/O)
	if(istype(O, /obj/item/disk/))
		return TRUE
	else
		return FALSE
