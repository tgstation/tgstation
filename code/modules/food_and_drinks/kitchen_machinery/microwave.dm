//Microwaving doesn't use recipes, instead it calls the microwave_act of the objects. For food, this creates something based on the food's cooked_type

/obj/machinery/microwave
	name = "microwave oven"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/microwave
	pass_flags = PASSTABLE
	light_color = LIGHT_COLOR_YELLOW
	light_power = 3
	var/wire_disabled = FALSE // is its internal wire cut?
	var/operating = FALSE
	var/dirty = 0 // 0 to 100 // Does it need cleaning?
	var/dirty_anim_playing = FALSE
	var/broken = 0 // 0, 1 or 2 // How broken is it???
	var/max_n_of_items = 10
	var/efficiency = 0
	var/datum/looping_sound/microwave/soundloop
	var/list/ingredients = list() // may only contain /atom/movables

	var/static/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	var/static/radial_use = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_use")

	// we show the button even if the proc will not work
	var/static/list/radial_options = list("eject" = radial_eject, "use" = radial_use)
	var/static/list/ai_radial_options = list("eject" = radial_eject, "use" = radial_use, "examine" = radial_examine)

/obj/machinery/microwave/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/microwave(src)
	create_reagents(100)
	soundloop = new(src, FALSE)

/obj/machinery/microwave/Destroy()
	eject()
	if(wires)
		QDEL_NULL(wires)
	QDEL_NULL(soundloop)
	. = ..()

/obj/machinery/microwave/RefreshParts()
	efficiency = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		efficiency += M.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		max_n_of_items = 10 * M.rating
		break

/obj/machinery/microwave/examine(mob/user)
	. = ..()
	if(!operating)
		. += span_notice("Right-click [src] to turn it on.")

	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return
	if(operating)
		. += span_notice("\The [src] is operating.")
		return

	if(length(ingredients))
		if(issilicon(user))
			. += span_notice("\The [src] camera shows:")
		else
			. += span_notice("\The [src] contains:")
		var/list/items_counts = new
		for(var/i in ingredients)
			if(istype(i, /obj/item/stack))
				var/obj/item/stack/S = i
				items_counts[S.name] += S.amount
			else
				var/atom/movable/AM = i
				items_counts[AM.name]++
		for(var/O in items_counts)
			. += span_notice("- [items_counts[O]]x [O].")
	else
		. += span_notice("\The [src] is empty.")

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "[span_notice("The status display reads:")]\n"+\
		"[span_notice("- Capacity: <b>[max_n_of_items]</b> items.")]\n"+\
		span_notice("- Cook time reduced by <b>[(efficiency - 1) * 25]%</b>.")

/obj/machinery/microwave/update_icon_state()
	if(broken)
		icon_state = "mwb"
		return ..()
	if(dirty_anim_playing)
		icon_state = "mwbloody1"
		return ..()
	if(dirty == 100)
		icon_state = "mwbloody"
		return ..()
	if(operating)
		icon_state = "mw1"
		return ..()
	if(panel_open)
		icon_state = "mw-o"
		return ..()
	icon_state = "mw"
	return ..()

/obj/machinery/microwave/attackby(obj/item/O, mob/living/user, params)
	if(operating)
		return
	if(default_deconstruction_crowbar(O))
		return

	if(dirty < 100)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, O) || default_unfasten_wrench(user, O))
			update_appearance()
			return

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(broken > 0)
		if(broken == 2 && O.tool_behaviour == TOOL_WIRECUTTER) // If it's broken and they're using a screwdriver
			user.visible_message(span_notice("[user] starts to fix part of \the [src]."), span_notice("You start to fix part of \the [src]..."))
			if(O.use_tool(src, user, 20))
				user.visible_message(span_notice("[user] fixes part of \the [src]."), span_notice("You fix part of \the [src]."))
				broken = 1 // Fix it a bit
		else if(broken == 1 && O.tool_behaviour == TOOL_WELDER) // If it's broken and they're doing the wrench
			user.visible_message(span_notice("[user] starts to fix part of \the [src]."), span_notice("You start to fix part of \the [src]..."))
			if(O.use_tool(src, user, 20))
				user.visible_message(span_notice("[user] fixes \the [src]."), span_notice("You fix \the [src]."))
				broken = 0
				update_appearance()
				return FALSE //to use some fuel
		else
			to_chat(user, span_warning("It's broken!"))
			return TRUE
		return

	if(istype(O, /obj/item/reagent_containers/spray))
		var/obj/item/reagent_containers/spray/clean_spray = O
		if(clean_spray.reagents.has_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this))
			clean_spray.reagents.remove_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this,1)
			playsound(loc, 'sound/effects/spray3.ogg', 50, TRUE, -6)
			user.visible_message(span_notice("[user] cleans \the [src]."), span_notice("You clean \the [src]."))
			dirty = 0
			update_appearance()
		else
			to_chat(user, span_warning("You need more space cleaner!"))
		return TRUE

	if(istype(O, /obj/item/soap) || istype(O, /obj/item/reagent_containers/glass/rag))
		var/cleanspeed = 50
		if(istype(O, /obj/item/soap))
			var/obj/item/soap/used_soap = O
			cleanspeed = used_soap.cleanspeed
		user.visible_message(span_notice("[user] starts to clean \the [src]."), span_notice("You start to clean \the [src]..."))
		if(do_after(user, cleanspeed, target = src))
			user.visible_message(span_notice("[user] cleans \the [src]."), span_notice("You clean \the [src]."))
			dirty = 0
			update_appearance()
		return TRUE

	if(dirty == 100) // The microwave is all dirty so can't be used!
		to_chat(user, span_warning("\The [src] is dirty!"))
		return TRUE

	if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/T = O
		var/loaded = 0
		for(var/obj/S in T.contents)
			if(!IS_EDIBLE(S))
				continue
			if(ingredients.len >= max_n_of_items)
				to_chat(user, span_warning("\The [src] is full, you can't put anything in!"))
				return TRUE
			if(SEND_SIGNAL(T, COMSIG_TRY_STORAGE_TAKE, S, src))
				loaded++
				ingredients += S
		if(loaded)
			to_chat(user, span_notice("You insert [loaded] items into \the [src]."))
		return

	if(O.atom_size <= WEIGHT_CLASS_NORMAL && !istype(O, /obj/item/storage) && !user.combat_mode)
		if(ingredients.len >= max_n_of_items)
			to_chat(user, span_warning("\The [src] is full, you can't put anything in!"))
			return TRUE
		if(!user.transferItemToLoc(O, src))
			to_chat(user, span_warning("\The [O] is stuck to your hand!"))
			return FALSE

		ingredients += O
		user.visible_message(span_notice("[user] adds \a [O] to \the [src]."), span_notice("You add [O] to \the [src]."))
		return

	..()

/obj/machinery/microwave/attack_hand_secondary(mob/user, list/modifiers)
	if(user.canUseTopic(src, !issilicon(usr)))
		cook()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/microwave/ui_interact(mob/user)
	. = ..()

	if(operating || panel_open || !anchored || !user.canUseTopic(src, !issilicon(user)))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	if(!length(ingredients))
		if(isAI(user))
			examine(user)
		else
			to_chat(user, span_warning("\The [src] is empty."))
		return

	var/choice = show_radial_menu(user, src, isAI(user) ? ai_radial_options : radial_options, require_near = !issilicon(user))

	// post choice verification
	if(operating || panel_open || !anchored || !user.canUseTopic(src, !issilicon(user)))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	usr.set_machine(src)
	switch(choice)
		if("eject")
			eject()
		if("use")
			cook()
		if("examine")
			examine(user)

/obj/machinery/microwave/proc/eject()
	for(var/i in ingredients)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	ingredients.Cut()

/obj/machinery/microwave/proc/cook()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(operating || broken > 0 || panel_open || !anchored || dirty == 100)
		return

	if(wire_disabled)
		audible_message("[src] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	if(prob(max((5 / efficiency) - 5, dirty * 5))) //a clean unupgraded microwave has no risk of failure
		muck()
		return
	for(var/obj/O in ingredients)
		if(istype(O, /obj/item/reagent_containers/food) || istype(O, /obj/item/grown))
			continue
		if(prob(min(dirty * 5, 100)))
			start_can_fail()
			return
		break
	start()

/obj/machinery/microwave/proc/wzhzhzh()
	visible_message(span_notice("\The [src] turns on."), null, span_hear("You hear a microwave humming."))
	operating = TRUE

	set_light(1.5)
	soundloop.start()
	update_appearance()

/obj/machinery/microwave/proc/spark()
	visible_message(span_warning("Sparks fly around [src]!"))
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()

#define MICROWAVE_NORMAL 0
#define MICROWAVE_MUCK 1
#define MICROWAVE_PRE 2

/obj/machinery/microwave/proc/start()
	wzhzhzh()
	loop(MICROWAVE_NORMAL, 10)

/obj/machinery/microwave/proc/start_can_fail()
	wzhzhzh()
	loop(MICROWAVE_PRE, 4)

/obj/machinery/microwave/proc/muck()
	wzhzhzh()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, TRUE)
	dirty_anim_playing = TRUE
	update_appearance()
	loop(MICROWAVE_MUCK, 4)

/obj/machinery/microwave/proc/loop(type, time, wait = max(12 - 2 * efficiency, 2)) // standard wait is 10
	if((machine_stat & BROKEN) && type == MICROWAVE_PRE)
		pre_fail()
		return
	if(!time)
		switch(type)
			if(MICROWAVE_NORMAL)
				loop_finish()
			if(MICROWAVE_MUCK)
				muck_finish()
			if(MICROWAVE_PRE)
				pre_success()
		return
	time--
	use_power(500)
	addtimer(CALLBACK(src, .proc/loop, type, time, wait), wait)

/obj/machinery/microwave/power_change()
	. = ..()
	if((machine_stat & NOPOWER) && operating)
		pre_fail()
		eject()

/obj/machinery/microwave/proc/loop_finish()
	operating = FALSE

	var/metal = 0
	for(var/obj/item/O in ingredients)
		O.microwave_act(src)
		if(LAZYLEN(O.custom_materials))
			if(O.custom_materials[GET_MATERIAL_REF(/datum/material/iron)])
				metal += O.custom_materials[GET_MATERIAL_REF(/datum/material/iron)]

	if(metal)
		spark()
		broken = 2
		if(prob(max(metal / 2, 33)))
			explosion(src, heavy_impact_range = 1, light_impact_range = 2)
	else
		dump_inventory_contents()

	after_finish_loop()

/obj/machinery/microwave/dump_inventory_contents()
	. = ..()
	ingredients.Cut()

/obj/machinery/microwave/proc/pre_fail()
	broken = 2
	operating = FALSE
	spark()
	after_finish_loop()

/obj/machinery/microwave/proc/pre_success()
	loop(MICROWAVE_NORMAL, 10)

/obj/machinery/microwave/proc/muck_finish()
	visible_message(span_warning("\The [src] gets covered in muck!"))

	dirty = 100
	dirty_anim_playing = FALSE
	operating = FALSE

	after_finish_loop()

/obj/machinery/microwave/proc/after_finish_loop()
	set_light(0)
	soundloop.stop()
	update_appearance()

#undef MICROWAVE_NORMAL
#undef MICROWAVE_MUCK
#undef MICROWAVE_PRE
