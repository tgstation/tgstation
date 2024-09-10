#define RADIAL_CHOICE_USE "use"
#define RADIAL_CHOICE_EJECT "eject"

#define ARC_FURNACE_ORE_MULTIPLIER 1.5

/obj/machinery/arc_furnace
	name = "arc furnace"
	desc = "An arc furnace, a specialist machine that can rapidly smelt ores using, as the name implies, massive \
		amounts of electricity. While not nearly as fast and efficient as other ore refining methods, the arc furnace is \
		capable of returning <b>larger amounts of refined material</b> than a standard refining process can. \
		A sticker on the side notes that this may <b>exhaust waste gasses to the air</b> during operation."
	icon = 'modular_doppler/colony_fabricator/icons/machines.dmi'
	icon_state = "arc_furnace"
	base_icon_state = "arc_furnace"
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = null
	light_color = LIGHT_COLOR_BRIGHT_YELLOW
	light_power = 10
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 10 // This baby consumes so much power
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine/arc_furnace
	/// If the furnace is currently working on smelting something
	var/operating = FALSE
	/// Image for the radial eject button
	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	/// Image for the radial use button
	var/static/radial_use = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_use")
	/// Radial options for using the arc furnace
	var/static/list/radial_options = list(RADIAL_CHOICE_EJECT = radial_eject, RADIAL_CHOICE_USE = radial_use)
	/// Soundloop for while we are smelting ores
	var/datum/looping_sound/arc_furnace_running/soundloop

/obj/machinery/arc_furnace/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	if(!mapload)
		flick("arc_furnace_deploy", src)

/obj/machinery/arc_furnace/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("It has <b>[contents[1]]</b> sitting in it.")

// formerly NO_DECONSTRUCTION
/obj/machinery/arc_furnace/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/arc_furnace/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/arc_furnace/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/arc_furnace/on_deconstruction(disassembled)
	eject_contents()

/obj/machinery/arc_furnace/update_appearance()
	. = ..()
	cut_overlays()

	if(length(contents))
		var/image/overlayed_item = image(icon = contents[1].icon, icon_state = contents[1].icon_state)
		overlayed_item.transform = matrix(, 0, 0, 0, 0.8, 0)
		add_overlay(overlayed_item)

	var/image/furnace_front_overlay = image(icon = icon, icon_state = "[operating ? "[base_icon_state]_overlay_active" : "[base_icon_state]_overlay"]")
	add_overlay(furnace_front_overlay)

/obj/machinery/arc_furnace/attackby(obj/item/attacking_item, mob/living/user, params)
	if(operating)
		balloon_alert(user, "furnace busy")
		return TRUE

	if(length(contents))
		balloon_alert(user, "furnace full")
		return TRUE

	if(istype(attacking_item, /obj/item/stack/ore))
		attacking_item.forceMove(src)
		balloon_alert(user, "ore added")
		update_appearance()
		return TRUE

	return ..()

/obj/machinery/arc_furnace/ui_interact(mob/user)
	. = ..()

	if(operating || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	if(!length(contents))
		balloon_alert(user, "it's empty!")
		return

	var/choice = show_radial_menu(user, src, radial_options, require_near = !issilicon(user))

	// post choice verification
	if(operating || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	switch(choice)
		if(RADIAL_CHOICE_EJECT)
			eject_contents()
		if(RADIAL_CHOICE_USE)
			smelt_it_up(user)

/// Removes the first item in the contents list which should only ever be ore and if it's not, we have problems
/obj/machinery/arc_furnace/proc/eject_contents()
	if(operating)
		return

	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)

	if(!length(contents))
		return

	var/atom/movable/thing_inside = contents[1]
	thing_inside.forceMove(drop_location())
	update_appearance()

/// Starts the smelting process, checking if the machine has power or if it's broken at all
/obj/machinery/arc_furnace/proc/smelt_it_up(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		balloon_alert(user, "button doesn't respond")
		return
	if(operating)
		balloon_alert(user, "already smelting")
		return

	var/obj/item/stack/ore/ore_to_smelt = contents[1]
	if(!istype(ore_to_smelt))
		balloon_alert(user, "nothing to smelt")

	operating = TRUE
	/// How long the smelting is going to take based off the stack size
	var/smelting_time = ore_to_smelt.amount * 1 SECONDS
	loop(smelting_time)

	soundloop.start()
	set_light(l_range = 1.5)

	update_appearance()

/// The smelting loop for checking if we're done smelting or not. If we are, then we succeed smelting. If we have to stop for whatever reason, we stop.
/obj/machinery/arc_furnace/proc/loop(time)
	if(machine_stat & (NOPOWER|BROKEN))
		end_smelting()
		return

	if(!length(contents))
		end_smelting()
		return

	if(time <= 0)
		succeed_smelting()
		return

	time -= 1 SECONDS
	use_energy(active_power_usage)

	var/turf/where_we_spawn_air = get_turf(src)
	var/obj/item/stack/ore/ore_stack_to_check = contents[1]
	switch(ore_stack_to_check.refined_type)
		if(/obj/item/stack/sheet/mineral/silver)
			where_we_spawn_air.atmos_spawn_air("n2=10;TEMP=1200")
		if(/obj/item/stack/sheet/mineral/uranium)
			where_we_spawn_air.atmos_spawn_air("co2=50;TEMP=1200")
		if(/obj/item/stack/sheet/mineral/titanium)
			where_we_spawn_air.atmos_spawn_air("n2=10;co2=10;TEMP=1200")
		if(/obj/item/stack/sheet/mineral/plasma)
			where_we_spawn_air.atmos_spawn_air("co2=75;TEMP=2000")
		else
			where_we_spawn_air.atmos_spawn_air("co2=20;TEMP=1200")

	addtimer(CALLBACK(src, PROC_REF(loop), time), 1 SECONDS)

/// Takes the ore contained and turns it into an equal stack amount of its smelt result
/obj/machinery/arc_furnace/proc/succeed_smelting()
	var/obj/item/stack/ore/ore_to_smelt = contents[1]
	if(!istype(ore_to_smelt))
		end_smelting()

	// We collect how many sheets of material we will need to spawn with the multiplier, whole sheets only!
	var/how_much_material_to_spawn = round(ore_to_smelt.amount * ARC_FURNACE_ORE_MULTIPLIER)
	// We also grab what the resulting refined type will be
	var/obj/item/stack/ore_refined_type = ore_to_smelt.refined_type

	// While the materials to spawn are greater than or equal to the max stack amount of the product, we can just safely spawn the max amount
	// Variable with the max stack amount just for futureproofing, because why not?
	while(how_much_material_to_spawn >= ore_refined_type.max_amount)
		new ore_refined_type(drop_location(), ore_refined_type.max_amount)
		how_much_material_to_spawn -= ore_refined_type.max_amount

	// Now, we spawn a stack with whatever's left, if there is anything left
	if(how_much_material_to_spawn)
		new ore_refined_type(drop_location(), how_much_material_to_spawn)

	qdel(ore_to_smelt)
	end_smelting()

/// Turns the arc furnace off, removing its lights, sounds, so on.
/obj/machinery/arc_furnace/proc/end_smelting()
	operating = FALSE
	soundloop.stop()
	set_light(l_range = 0)
	update_appearance()

// Item for creating the arc furnace or carrying it around

/obj/item/flatpacked_machine/arc_furnace
	name = "flat-packed arc furnace"
	icon_state = "arc_furnace_folded"
	type_to_deploy = /obj/machinery/arc_furnace
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
	)

#undef RADIAL_CHOICE_USE
#undef RADIAL_CHOICE_EJECT

#undef ARC_FURNACE_ORE_MULTIPLIER
