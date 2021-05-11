/obj/machinery/ore_exit_port
	name = "ore exit port"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/conveyor/auto/no_deconstruct/base_conv

/obj/machinery/ore_exit_port/Initialize()
	. = ..()
	base_conv = new/obj/machinery/conveyor/auto/no_deconstruct(loc, SOUTH)

/obj/machinery/ore_exit_port/Destroy()
	if(base_conv)
		QDEL_NULL(base_conv)
	return ..()

/obj/machinery/ore_exit_port/attackby(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_WRENCH && anchored)
		item.play_tool_sound(src, 50)
		to_chat(user, "<span class='notice'>You rotate the conveyor system.</span>")
		base_conv.setDir(turn(base_conv.dir,-90))
		base_conv.update_move_direction()

/obj/machinery/ore_exit_port/attackby_secondary(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_WRENCH)
		item.play_tool_sound(src, 50)
		set_anchored(!anchored)
		if(!anchored)
			QDEL_NULL(base_conv)
		else
			base_conv = new/obj/machinery/conveyor/auto/no_deconstruct(loc, SOUTH)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/machinery/ore_processing
	name = "ore furnace"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	density = TRUE
	anchored = TRUE
	subsystem_type = /datum/controller/subsystem/processing/fastprocess

	var/input_direction
	var/output_direction
	var/active = FALSE
	var/obj/machinery/conveyor/auto/no_deconstruct/base_conv

/obj/machinery/ore_processing/Initialize()
	. = ..()
	input_direction = turn(dir, 180)
	output_direction = dir
	base_conv = new/obj/machinery/conveyor/auto/no_deconstruct(get_step(loc, input_direction), dir)

/obj/machinery/ore_processing/Destroy()
	if(base_conv)
		QDEL_NULL(base_conv)
	return ..()

/obj/machinery/ore_processing/Bumped(atom/movable/item)
	. = ..()
	if(get_dir(src, item) == input_direction && istype(item, /obj/item/stack))
		pickup_item(item)

/obj/machinery/ore_processing/proc/pickup_item(atom/movable/target)
	return

/obj/machinery/ore_processing/attackby(obj/item/tool, mob/living/user, params)
	if(!active)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
			return
	if(default_change_direction_wrench(user, tool))
		QDEL_NULL(base_conv)
		base_conv = new/obj/machinery/conveyor/auto/no_deconstruct(get_step(loc, input_direction), dir)
		input_direction = turn(dir, 180)
		output_direction = dir
		return
	if(default_deconstruction_crowbar(tool))
		return
	return ..()

/obj/machinery/ore_processing/sheet_input_port
	name = "ore furnace"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	var/datum/component/remote_materials/materials
	var/sheet_multiplier = 1

/obj/machinery/ore_processing/sheet_input_port/Initialize(mapload)
	materials = AddComponent(/datum/component/remote_materials, "sheet_port", mapload, allow_standalone = FALSE, mat_container_flags=BREAKDOWN_FLAGS_EXPORT)
	. = ..()

/obj/machinery/ore_processing/sheet_input_port/Bumped(atom/movable/item)
	if(!materials.silo)
		return
	return ..()

/obj/machinery/ore_processing/sheet_input_port/pickup_item(atom/movable/target)
	var/datum/component/material_container/mat_container = materials.mat_container
	var/obj/item/stack/sheet/sheet_to_insert = target
	mat_container.insert_item(sheet_to_insert, sheet_multiplier)
	qdel(target)
