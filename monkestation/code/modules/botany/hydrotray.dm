/obj/machinery/growing
	name = "hydroponics tray"
	icon = 'monkestation/icons/obj/machines/hydroponics.dmi'
	icon_state = "hydrotray"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	pixel_z = 8
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	var/maximum_seeds = 1

/obj/machinery/growing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plant_growing, 60, maximum_seeds)


/obj/machinery/growing/tray
	circuit = /obj/item/circuitboard/machine/hydroponics

/obj/machinery/growing/tray/Initialize(mapload)
	AddComponent(/datum/component/plant_tray_overlay, icon, "hydrotray_gaia", "hydrotray_water_", "hydrotray_pests", "hydrotray_harvest", "hydrotray_nutriment", "hydrotray_health", 0, 0)
	. = ..()

/obj/machinery/growing/tray/attackby(obj/item/I, mob/living/user, params)
	if (!(user.istate & ISTATE_HARM))
		// handle opening the panel
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
			return
		if(default_deconstruction_crowbar(I))
			return

	return ..()

/obj/machinery/growing/tray/can_be_unfasten_wrench(mob/user, silent)
	return ..()

/obj/machinery/growing/tray/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/growing/soil
	name = "soil"
	desc = "A patch of dirt."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "soil"
	density = FALSE

/obj/machinery/growing/soil/Initialize(mapload)
	AddComponent(/datum/component/plant_tray_overlay, icon, null, null, null, null, null, null, 0, 0)
	. = ..()

/obj/machinery/growing/multi
	name = "soil"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "soil"
	maximum_seeds = 4
	density = FALSE

/obj/machinery/growing/multi/Initialize(mapload)
	AddComponent(/datum/component/plant_tray_overlay, icon, null, null, null, null, null, null, 0, 0, maximum_seeds, list(list(-4,-4), list(8,-4), list(-4, 4), list(8, 4)))
	. = ..()
