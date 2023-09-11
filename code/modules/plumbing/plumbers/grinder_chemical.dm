#define GRIND 1
#define JUICE 0

/obj/machinery/plumbing/grinder_chemical
	name = "chemical grinder"
	desc = "Chemical grinder. Can either grind or juice stuff you put in"
	icon_state = "grinder_chemical"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE

	reagent_flags = TRANSPARENT | DRAINABLE
	buffer = 400
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2
	/// Operation mode
	var/operation_mode = GRIND
	/// Radial menu to change operating mode
	var/static/list/operations

/obj/machinery/plumbing/grinder_chemical/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)

	if(!length(operations))
		operations = list(
			"grind" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_grind"),
			"juice" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_juice")
		)

/obj/machinery/plumbing/grinder_chemical/examine(mob/user)
	. = ..()
	var/text_mode = operation_mode == GRIND ? "grind" : "juice"
	. += span_notice("Its currently in [EXAMINE_HINT(text_mode)] mode")

/obj/machinery/plumbing/grinder_chemical/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH) || !anchored)
		return

	var/choice = show_radial_menu(user, src, operations, require_near = !issilicon(user))
	if(!choice)
		return

	switch(choice)
		if("grind")
			operation_mode = GRIND
		else
			operation_mode = JUICE

	to_chat(user, "operating mode changed to [operation_mode = GRIND ? "grind" : "juice"]")

/obj/machinery/plumbing/grinder_chemical/attackby(obj/item/weapon, mob/user, params)
	. = TRUE

	if(!anchored)
		return
	if(machine_stat & NOPOWER)
		return
	if(reagents.holder_full())
		to_chat(user, span_warning("[src] has no more space."))
		return

	if(operation_mode == GRIND)
		to_chat(user, span_notice("[src] attempts to grind [weapon]."))
		if(weapon.grind_results)
			use_power(active_power_usage)
			if(weapon.grind(reagents, user))
				to_chat(user, span_green("[src] succeeds in grinding [weapon]."))
				qdel(weapon)
			else
				if(isstack(weapon))
					to_chat(user, span_notice("[src] grinds as many pieces of [weapon] as possible."))
				else
					to_chat(user, span_warning("[src] failed to grind [weapon]."))
		else
			to_chat(user, span_warning("[src] is unable to grind [weapon]."))

	else
		to_chat(user, span_notice("[src] attempts to juice [weapon]."))
		if(weapon.juice_typepath)
			use_power(active_power_usage)
			if(weapon.juice(reagents, user))
				to_chat(user, span_green("[src] succeeds in juicing [weapon]."))
				qdel(weapon)
			else
				to_chat(user, span_warning("[src] failed to juice [weapon]."))
		else
			to_chat(user, span_warning("[src] is unable to juice [weapon]."))

#undef GRIND
#undef JUICE
