// -------------------------
//  SmartFridge.  Much todo
// -------------------------
/obj/machinery/smartfridge
	name = "smartfridge"
	desc = "Keeps cold things cold and hot things cold."
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/smartfridge
	/// What path boards used to construct it should build into when dropped. Needed so we don't accidentally have them build variants with items preloaded in them.
	var/base_build_path = /obj/machinery/smartfridge
	/// Maximum number of items that can be loaded into the machine
	var/max_n_of_items = 1500
	/// If the AI is allowed to retrive items within the machine
	var/allow_ai_retrieve = FALSE
	/// List of items that the machine starts with upon spawn
	var/list/initial_contents
	/// If the machine shows an approximate number of its contents on its sprite
	var/visible_contents = TRUE

/obj/machinery/smartfridge/Initialize(mapload)
	. = ..()
	create_reagents(100, NO_REACT)

	if(islist(initial_contents))
		for(var/typekey in initial_contents)
			var/amount = initial_contents[typekey]
			if(isnull(amount))
				amount = 1
			for(var/i in 1 to amount)
				load(new typekey(src))

/obj/machinery/smartfridge/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 1500 * B.rating

/obj/machinery/smartfridge/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: This unit can hold a maximum of <b>[max_n_of_items]</b> items.")

/obj/machinery/smartfridge/update_icon_state()
	if(machine_stat)
		icon_state = "[initial(icon_state)]-off"
		return ..()

	if(!visible_contents)
		icon_state = "[initial(icon_state)]"
		return ..()

	var/list/shown_contents = contents - component_parts
	switch(shown_contents.len)
		if(0)
			icon_state = "[initial(icon_state)]"
		if(1 to 25)
			icon_state = "[initial(icon_state)]1"
		if(26 to 75)
			icon_state = "[initial(icon_state)]2"
		if(76 to INFINITY)
			icon_state = "[initial(icon_state)]3"
	return ..()

/obj/machinery/smartfridge/update_overlays()
	. = ..()
	if(!machine_stat)
		. += emissive_appearance(icon, "smartfridge-light-mask", alpha = src.alpha)

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, O))
		cut_overlays()
		if(panel_open)
			add_overlay("[initial(icon_state)]-panel")
		SStgui.update_uis(src)
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	if(default_deconstruction_crowbar(O))
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
		if(SEND_SIGNAL(O.loc, COMSIG_CONTAINS_STORAGE))
			return SEND_SIGNAL(O.loc, COMSIG_TRY_STORAGE_TAKE, O, src)
		else
			O.forceMove(src)
			return TRUE

///Really simple proc, just moves the object "O" into the hands of mob "M" if able, done so I could modify the proc a little for the organ fridge
/obj/machinery/smartfridge/proc/dispense(obj/item/O, mob/M)
	if(!M.put_in_hands(O))
		O.forceMove(drop_location())
		adjust_item_drop_location(O)

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

/obj/machinery/smartfridge/handle_atom_del(atom/A) // Update the UIs in case something inside gets deleted
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

			if(QDELETED(src) || QDELETED(usr) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)) // Sanity checkin' in case stupid stuff happens while we wait for input()
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

/obj/machinery/smartfridge/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(machine_stat & BROKEN)
		if(!I.tool_start_check(user, amount=0))
			return
		user.visible_message("<span class='notice'>[user] is repairing [src].</span>", \
						"<span class='notice'>You begin repairing [src]...</span>", \
						"<span class='hear'>You hear welding.</span>")
		if(I.use_tool(src, user, 40, volume=50))
			if(!(machine_stat & BROKEN))
				return
			to_chat(user, "<span class='notice'>You repair [src].</span>")
			atom_integrity = max_integrity
			set_machine_stat(machine_stat & ~BROKEN)
			update_icon()
	else
		to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
// ----------------------------
//  Drying Rack 'smartfridge'
// ----------------------------
/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	desc = "A wooden contraption, used to dry plant products, food and hide."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "drying_rack"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 200
	visible_contents = FALSE
	base_build_path = /obj/machinery/smartfridge/drying_rack //should really be seeing this without admin fuckery.
	var/drying = FALSE

/obj/machinery/smartfridge/drying_rack/Initialize(mapload)
	. = ..()

	// Cache the old_parts first, we'll delete it after we've changed component_parts to a new list.
	// This stops handle_atom_del being called on every part when not necessary.
	var/list/old_parts = component_parts.Copy()

	component_parts = null
	circuit = null

	QDEL_LIST(old_parts)
	RefreshParts()

/obj/machinery/smartfridge/drying_rack/on_deconstruction()
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)
	..()

/obj/machinery/smartfridge/drying_rack/RefreshParts()
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
	atmos_spawn_air("TEMP=1000")


// ----------------------------
//  Bar drink smartfridge
// ----------------------------
/obj/machinery/smartfridge/drinks
	name = "drink showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	base_build_path = /obj/machinery/smartfridge/drinks

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(!istype(O, /obj/item/reagent_containers) || (O.item_flags & ABSTRACT) || !O.reagents || !O.reagents.reagent_list.len)
		return FALSE
	if(istype(O, /obj/item/reagent_containers/glass) || istype(O, /obj/item/reagent_containers/food/drinks) || istype(O, /obj/item/reagent_containers/food/condiment))
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

/obj/machinery/smartfridge/organ/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 20 * B.rating
		repair_rate = max(0, STANDARD_ORGAN_HEALING * (B.rating - 1) * 0.5)

/obj/machinery/smartfridge/organ/process(delta_time)
	for(var/obj/item/organ/organ in contents)
		organ.applyOrganDamage(-repair_rate * organ.maxHealth * delta_time)

/obj/machinery/smartfridge/organ/Exited(atom/movable/gone, direction)
	. = ..()
	if(isorgan(gone))
		var/obj/item/organ/O = gone
		O.organ_flags &= ~ORGAN_FROZEN

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
					/obj/item/reagent_containers/glass/bottle,
					/obj/item/reagent_containers/glass/beaker,
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
	if(!istype(O, /obj/item/reagent_containers) || (O.item_flags & ABSTRACT))
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
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/glass/bottle/multiver = 1)

// ----------------------------
// Virology Medical Smartfridge
// ----------------------------
/obj/machinery/smartfridge/chemistry/virology
	name = "smart virus storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	base_build_path = /obj/machinery/smartfridge/chemistry/virology

/obj/machinery/smartfridge/chemistry/virology/preloaded
	initial_contents = list(
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/glass/bottle/cold = 1,
		/obj/item/reagent_containers/glass/bottle/flu_virion = 1,
		/obj/item/reagent_containers/glass/bottle/mutagen = 1,
		/obj/item/reagent_containers/glass/bottle/sugar = 1,
		/obj/item/reagent_containers/glass/bottle/plasma = 1,
		/obj/item/reagent_containers/glass/bottle/synaptizine = 1,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 1)

// ----------------------------
// Disk """fridge"""
// ----------------------------
/obj/machinery/smartfridge/disks
	name = "disk compartmentalizer"
	desc = "A machine capable of storing a variety of disks. Denoted by most as the DSU (disk storage unit)."
	icon_state = "disktoaster"
	pass_flags = PASSTABLE
	visible_contents = FALSE
	base_build_path = /obj/machinery/smartfridge/disks

/obj/machinery/smartfridge/disks/accept_check(obj/item/O)
	if(istype(O, /obj/item/disk/))
		return TRUE
	else
		return FALSE
