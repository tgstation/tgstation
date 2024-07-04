#define BRASS_POWER_COST 10
#define REGULAR_POWER_COST (BRASS_POWER_COST / 2)
//how much to add to the creation_delay while the cult lacks a charged anchoring crystal
#define SLOWDOWN_FROM_NO_ANCHOR_CRYSTAL 0.2

/obj/item/clockwork/replica_fabricator
	name = "replica fabricator"
	desc = "A strange, brass device with many twisting cogs and vents."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	lefthand_file = 'monkestation/icons/mob/clock_cult/clockwork_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/clock_cult/clockwork_righthand.dmi'
	icon_state = "replica_fabricator"
	/// List of things that the fabricator can build for the radial menu
	var/static/list/crafting_possibilities = list(
		"floor" = image(icon = 'icons/turf/floors.dmi', icon_state = "clockwork_floor"),
		"wall" = image(icon = 'icons/turf/walls/clockwork_wall.dmi', icon_state = "clockwork_wall-0"),
		"wall gear" = image(icon = 'icons/obj/structures.dmi', icon_state = "wall_gear"),
		"window" = image(icon = 'icons/obj/smooth_structures/clockwork_window.dmi', icon_state = "clockwork_window-0"),
		"airlock" = image(icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi', icon_state = "closed"),
		"glass airlock" = image(icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi', icon_state = "construction"),
	)
	/// List of initialized fabrication datums, created on Initialize
	var/static/list/fabrication_datums = list()
	/// Ref to the datum we have selected currently
	var/datum/replica_fabricator_output/selected_output


/obj/item/clockwork/replica_fabricator/Initialize(mapload)
	. = ..()
	if(!length(fabrication_datums))
		create_fabrication_list()

/obj/item/clockwork/replica_fabricator/Destroy(force)
	selected_output = null
	return ..()

/obj/item/clockwork/replica_fabricator/examine(mob/user)
	. = ..()
	if(IS_CLOCK(user))
		. += span_brass("Current power: [display_power(GLOB.clock_power)]")
		. += span_brass("Use on brass to convert it into power.")
		. += span_brass("Use on other materials to convert them into power, but less efficiently.")
		. += span_brass("<b>Use</b> in-hand to select what to fabricate.")
		. += span_brass("<b>Right Click</b> in-hand to fabricate bronze sheets.")
		. += span_brass("Walls and windows will be built slower while on reebe.")


/obj/item/clockwork/replica_fabricator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_CLOCK(user))
		return

	if(istype(target, /obj/item/stack/sheet)) // If it's an item, handle it seperately
		attempt_convert_materials(target, user)
		return

	if(!selected_output) // Now we handle objects
		return

	if(GLOB.clock_power < selected_output.cost)
		to_chat(user, span_clockyellow("[src] needs at least [selected_output.cost]W of power to create this."))
		return

	var/turf/creation_turf = get_turf(target)
	var/atom/movable/possible_replaced
	if(locate(selected_output.to_create_path) in creation_turf)
		to_chat(user, span_clockyellow("There is already one of these on this tile!"))
		return

	if(selected_output.replace_types_of && istype(selected_output, /datum/replica_fabricator_output/turf_output))
		if(!isopenturf(target) && !(locate(creation_turf) in selected_output.replace_types_of))
			return
	else if(selected_output.replace_types_of)
		for(var/checked_type in selected_output.replace_types_of)
			var/atom/movable/found_replaced = locate(checked_type) in creation_turf
			if(found_replaced)
				possible_replaced = found_replaced
				break
		if(!possible_replaced && !isopenturf(target))
			return
	else if(!isopenturf(target))
		return

	var/calculated_creation_delay = 1
	if(on_reebe(user))
		calculated_creation_delay = selected_output.reebe_mult
		if(!get_charged_anchor_crystals())
			calculated_creation_delay += SLOWDOWN_FROM_NO_ANCHOR_CRYSTAL
		else if(GLOB.clock_ark?.current_state >= ARK_STATE_ACTIVE)
			calculated_creation_delay += (iscogscarab(user) ? 2.5 : 5)
	calculated_creation_delay = selected_output.creation_delay * calculated_creation_delay

	var/obj/effect/temp_visual/ratvar/constructing_effect/effect = new(creation_turf, calculated_creation_delay)
	if(!do_after(user, calculated_creation_delay, target))
		qdel(effect)
		return

	if(GLOB.clock_power < selected_output.cost) // Just in case
		return

	GLOB.clock_power -= selected_output.cost
	var/atom/created
	if(!istype(selected_output, /datum/replica_fabricator_output/turf_output))
		if(possible_replaced)
			qdel(possible_replaced)
		created = new selected_output.to_create_path(creation_turf)

	selected_output.on_create(created, creation_turf, user)


/obj/item/clockwork/replica_fabricator/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!IS_CLOCK(user))
		return

	attempt_convert_materials(attacking_item, user)


/obj/item/clockwork/replica_fabricator/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(!IS_CLOCK(user))
		return

	if(GLOB.clock_power < BRASS_POWER_COST)
		to_chat(user, span_clockyellow("You need at least [BRASS_POWER_COST]W of power to fabricate bronze."))
		return

	var/sheets = tgui_input_number(user, "How many sheets do you want to fabricate?", "Sheet Fabrication", 0, round(GLOB.clock_power / BRASS_POWER_COST), 0)
	if(!sheets)
		return

	GLOB.clock_power -= sheets * BRASS_POWER_COST

	var/obj/item/stack/sheet/bronze/sheet_stack = new(null, sheets)
	user.put_in_hands(sheet_stack)
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, span_clockyellow("You fabricate [sheets] bronze."))


/obj/item/clockwork/replica_fabricator/attack_self(mob/user, modifiers)
	. = ..()
	var/choice = show_radial_menu(user, src, crafting_possibilities, radius = 36, custom_check = PROC_REF(check_menu), require_near = TRUE)

	if(!choice)
		return

	selected_output = fabrication_datums[choice]


/// Standard confirmation for the radial menu proc
/obj/item/clockwork/replica_fabricator/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE

	if(user.incapacitated())
		return FALSE

	return TRUE

/// Attempt to convert the targeted item into power, if it's a sheet item
/obj/item/clockwork/replica_fabricator/proc/attempt_convert_materials(atom/attacking_item, mob/user)
	if(GLOB.clock_power >= GLOB.max_clock_power)
		to_chat(user, span_clockyellow("We are already at maximum power!"))
		return

	if(istype(attacking_item, /obj/item/stack/sheet/bronze))
		var/obj/item/stack/bronze_stack = attacking_item

		if((GLOB.clock_power + bronze_stack.amount * BRASS_POWER_COST) > GLOB.max_clock_power)
			var/amount_to_take = clamp(round((GLOB.max_clock_power - GLOB.clock_power) / BRASS_POWER_COST), 0, bronze_stack.amount)

			if(!amount_to_take)
				to_chat(user, span_clockyellow("[src] can't be powered further using this!"))
				return

			bronze_stack.use(amount_to_take)
			GLOB.clock_power += amount_to_take * BRASS_POWER_COST

		else
			GLOB.clock_power += bronze_stack.amount * BRASS_POWER_COST
			qdel(bronze_stack)

		playsound(src, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_clockyellow("You convert [bronze_stack.amount] bronze into [bronze_stack.amount * BRASS_POWER_COST] watts of power."))

		return TRUE

	else if(istype(attacking_item, /obj/item/stack/sheet))
		var/obj/item/stack/stack = attacking_item

		if((GLOB.clock_power + stack.amount * REGULAR_POWER_COST) > GLOB.max_clock_power)
			var/amount_to_take = clamp(round((GLOB.max_clock_power - GLOB.clock_power) / REGULAR_POWER_COST), 0, stack.amount)

			if(!amount_to_take)
				to_chat(user, span_clockyellow("[src] can't be powered further using this!"))
				return

			stack.use(amount_to_take)
			GLOB.clock_power += amount_to_take * REGULAR_POWER_COST

		else
			GLOB.clock_power += stack.amount * REGULAR_POWER_COST
			qdel(stack)

		playsound(src, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_clockyellow("You convert [stack.amount] [stack.name] into [stack.amount * REGULAR_POWER_COST] watts of power."))

		qdel(attacking_item)
		return TRUE

	return FALSE

/// Creates the list of initialized fabricator datums, done once on init
/obj/item/clockwork/replica_fabricator/proc/create_fabrication_list()
	for(var/type in subtypesof(/datum/replica_fabricator_output))
		var/datum/replica_fabricator_output/output_ref = new type
		fabrication_datums[output_ref.name] = output_ref


/datum/replica_fabricator_output
	/// Name of the output
	var/name = "parent"
	/// Power cost of the output
	var/cost = 0
	/// Typepath to spawn
	var/to_create_path
	/// How long the creation actionbar is
	var/creation_delay = 1 SECONDS
	/// List of objs this output can replace, normal walls for clock walls, windows for clock windows, ETC
	var/list/replace_types_of
	/// Multiplier for creation_delay when used on reebe
	var/reebe_mult = 1

/// Any extra actions that need to be taken when an object is created
/datum/replica_fabricator_output/proc/on_create(atom/created_atom, turf/creation_turf, mob/creator)
	SHOULD_CALL_PARENT(TRUE)
	playsound(creation_turf, 'sound/machines/clockcult/integration_cog_install.ogg', 50, 1) // better sound?
	to_chat(creator, span_clockyellow("You create \an [name] for [cost]W of power."))

/datum/replica_fabricator_output/turf_output/on_create(atom/created_atom, turf/creation_turf, mob/creator)
	creation_turf.ChangeTurf(to_create_path)
	return ..()

/datum/replica_fabricator_output/turf_output/brass_floor
	name = "floor"
	cost = BRASS_POWER_COST * 0.25 // 1/4th the cost, since one sheet = 4 floor tiles
	to_create_path = /turf/open/floor/bronze

/datum/replica_fabricator_output/turf_output/brass_floor/on_create(obj/created_object, turf/creation_turf, mob/creator)
	. = ..()

	new /obj/effect/temp_visual/ratvar/floor(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
/datum/replica_fabricator_output/turf_output/brass_wall
	name = "wall"
	cost = BRASS_POWER_COST * 4
	to_create_path = /turf/closed/wall/clockwork
	creation_delay = 14 SECONDS
	replace_types_of = list(/turf/closed/wall)

/datum/replica_fabricator_output/turf_output/brass_wall/on_create(obj/created_object, turf/creation_turf, mob/creator)
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
/datum/replica_fabricator_output/wall_gear
	name = "wall gear"
	cost = BRASS_POWER_COST * 2
	to_create_path = /obj/structure/girder/bronze
	creation_delay = 5 SECONDS
	replace_types_of = list(/obj/structure/girder)

/datum/replica_fabricator_output/wall_gear/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/gear(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/brass_window
	name = "window"
	cost = BRASS_POWER_COST * 2
	to_create_path = /obj/structure/window/reinforced/clockwork/fulltile
	creation_delay = 10 SECONDS
	replace_types_of = list(/obj/structure/window)
	reebe_mult = 1.2

/datum/replica_fabricator_output/brass_window/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/window(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/pinion_airlock
	name = "airlock"
	cost = BRASS_POWER_COST * 5 // Breaking it only gets 2 but this is the exception to the rule of equivalent exchange, due to all the small parts inside
	to_create_path = /obj/machinery/door/airlock/bronze/clock
	creation_delay = 10 SECONDS

/datum/replica_fabricator_output/pinion_airlock/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/door(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/pinion_airlock/glass
	name = "glass airlock"
	to_create_path = /obj/machinery/door/airlock/bronze/clock/glass

#undef BRASS_POWER_COST
#undef REGULAR_POWER_COST
#undef SLOWDOWN_FROM_NO_ANCHOR_CRYSTAL
