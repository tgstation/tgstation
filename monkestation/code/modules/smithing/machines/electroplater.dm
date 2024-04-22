/obj/machinery/electroplater
	name = "arc electroplater"
	desc = "An industrial electroplater, using electricity it can coat basically anything in the given materials."

	icon_state = "plater0"
	icon = 'goon/icons/matsci.dmi'

	anchored = TRUE
	density = TRUE

	idle_power_usage = 10
	active_power_usage = 3000
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	circuit = null

	light_outer_range = 2
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE

	///this can either be a worked material or a stack item
	var/obj/item/stored_material
	///this is the item we are plating
	var/obj/item/plating_item
	///this is the max weight class it can be upped to depending on stats
	var/max_weight_increase = WEIGHT_CLASS_BULKY
	///how long it takes to bake
	var/plating_time = 10 SECONDS
	///are we plating right now?
	var/plating = FALSE

/obj/machinery/electroplater/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/electroplater/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if((isstack(held_item) || istype(held_item, /obj/item/merged_material)) && !stored_material)
		context[SCREENTIP_CONTEXT_LMB] = "Add Material Plate."
	if(stored_material && held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Try to plate item."
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/electroplater/attackby(obj/item/attacking_item, mob/living/user, params)
	if(isstack(attacking_item))
		if(stored_material)
			return ..()
		var/obj/item/stack/stack = attacking_item
		if(!stack.material_type)
			return ..()
		if(stack.amount == 1)
			attacking_item.forceMove(src)
			stored_material = attacking_item
			visible_message(span_notice("[user] puts the [attacking_item] into the electoplater."))
			return
		else
			var/obj/item/stack/new_stack = stack.split_stack(user, 1)
			new_stack.forceMove(src)
			stored_material = new_stack
			visible_message(span_notice("[user] puts the [attacking_item] into the electoplater."))
			return

	else if(istype(attacking_item, /obj/item/merged_material))
		if(stored_material)
			return ..()
		attacking_item.forceMove(src)
		stored_material = attacking_item
		visible_message(span_notice("[user] puts the [attacking_item] into the electoplater."))
		return

	if(!stored_material || plating_item || plating)
		return ..()

	if(HAS_TRAIT(attacking_item, TRAIT_NODROP))
		return ..()

	plating_item = attacking_item
	if(attacking_item.forceMove(src))
		try_plate()
		return
	return ..()

/obj/machinery/electroplater/proc/try_plate()
	if(!stored_material || !plating_item)
		return
	plating = TRUE
	icon_state = "plater1"

	machine_do_after_visable(src, plating_time) // glorified sleep go brrr
	if(!plating_item.material_stats)
		if(isstack(stored_material))
			var/obj/item/stack/stack = stored_material
			plating_item.create_stats_from_material(stack.material_type)
		else
			plating_item.create_stats_from_material_stats(stored_material.material_stats)
	else
		plating_item.material_stats.apply_traits_from(stored_material.material_stats)

	plating_item.forceMove(get_turf(src))
	plating_item.name = "[stored_material.material_stats.material_name] plated [plating_item.name]"

	if(istype(plating_item, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/holder = plating_item
		if(!holder.held_mob.material_stats)
			holder.held_mob.create_stats_from_material_stats(holder.material_stats)
		else
			holder.held_mob.material_stats.apply_traits_from(holder.material_stats)
		holder.held_mob.name = "[stored_material.material_stats.material_name] plated [holder.held_mob.name]"

	QDEL_NULL(stored_material)
	plating_item = null
	plating = FALSE
	icon_state = "plater0"
