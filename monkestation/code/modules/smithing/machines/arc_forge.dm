/obj/machinery/arc_forge
	name = "arc forge"
	desc = "A bulky machine that can smelt practically any material in existence."
	icon = 'monkestation/code/modules/smithing/icons/3x3.dmi'
	icon_state = "arc_forge"
	bound_width = 96
	bound_height = 96
	anchored = TRUE
	max_integrity = 1000
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 3000
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	circuit = null
	light_outer_range = 5
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE

	///the item in our first slot for merging
	var/atom/movable/slot_one_item
	///the item in our second slot for merging
	var/atom/movable/slot_two_item


/obj/machinery/arc_forge/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/arc_forge/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if((!slot_one_item || !slot_two_item) && (isstack(held_item) || istype(held_item, /obj/item/merged_material)))
		context[SCREENTIP_CONTEXT_LMB] = "Add material to alloy."
	if(slot_one_item && slot_two_item)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Alloy Materials."
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/arc_forge/attackby(obj/item/attacking_item, mob/living/user, params)
	if(isstack(attacking_item))
		var/obj/item/stack/stack = attacking_item
		if(!stack.material_type)
			return
		if(stack.amount > 1)
			attacking_item = stack.split_stack(user, 1)

		if(try_add_to_buffer(attacking_item))
			visible_message(span_notice("[user] adds [attacking_item] into the arc forge."))
			return
	if(istype(attacking_item, /obj/item/merged_material))
		if(try_add_to_buffer(attacking_item))
			visible_message(span_notice("[user] adds [attacking_item] into the arc forge."))
			return
	return ..()

/obj/machinery/arc_forge/proc/try_add_to_buffer(obj/item/adder)
	if(!slot_one_item)
		slot_one_item = adder
		adder.forceMove(src)
		return TRUE
	if(!slot_two_item)
		slot_two_item = adder
		adder.forceMove(src)
		return TRUE
	return FALSE

/obj/machinery/arc_forge/AltClick(mob/user)
	if(attempt_material_forge())
		return TRUE
	. = ..()

/obj/machinery/arc_forge/proc/attempt_material_forge()
	if(!slot_one_item || !slot_two_item)
		return FALSE

	var/obj/item/merged_material/new_material = new(get_turf(src))
	if(isstack(slot_one_item))
		var/obj/item/stack/stack = slot_one_item
		new_material.create_stats_from_material(stack.material_type)
	else
		new_material.create_stats_from_material_stats(slot_one_item.material_stats)

	new_material.combine_material_stats(slot_two_item)

	new_material.name = "[new_material.material_stats.material_name] Ingot"

	QDEL_NULL(slot_one_item)
	QDEL_NULL(slot_two_item)
	return TRUE
