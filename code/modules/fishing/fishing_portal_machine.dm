/obj/machinery/fishing_portal_generator
	name = "fish-porter 3000"
	desc = "fishing anywhere, anytime, anyway what was i talking about"

	icon = 'icons/obj/fishing.dmi'
	icon_state = "portal_off"

	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2

	anchored = FALSE
	density = TRUE

	var/fishing_source = /datum/fish_source/portal
	var/datum/component/fishing_spot/active

/obj/machinery/fishing_portal_generator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/fishing_portal_generator/interact(mob/user, special_state)
	. = ..()
	if(active)
		deactivate()
	else
		activate()

/obj/machinery/fishing_portal_generator/update_icon(updates)
	. = ..()
	if(active)
		icon_state = "portal_on"
	else
		icon_state = "portal_off"

/obj/machinery/fishing_portal_generator/proc/activate()
	active = AddComponent(/datum/component/fishing_spot, fishing_source)
	use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/fishing_portal_generator/proc/deactivate()
	QDEL_NULL(active)
	use_power = IDLE_POWER_USE
	update_icon()

/obj/machinery/fishing_portal_generator/on_set_is_operational(old_value)
	if(old_value)
		deactivate()
