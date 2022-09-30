///base consturctino console subtype for the mining aux base
/obj/machinery/computer/camera_advanced/base_construction/aux
	name = "aux base construction console"
	circuit = /obj/item/circuitboard/computer/base_construction/aux
	structures = list("fans" = 0, "turrets" = 0)
	allowed_area = /area/shuttle/auxiliary_base

/obj/machinery/computer/camera_advanced/base_construction/aux/Initialize(mapload)
	internal_rcd = new(src)
	return ..()

/obj/machinery/computer/camera_advanced/base_construction/aux/restock_materials()
	internal_rcd.matter = internal_rcd.max_matter
	structures["fans"] = 4
	structures["turrets"] = 4

/obj/machinery/computer/camera_advanced/base_construction/aux/populate_actions_list()
	construction_actions = list()
	construction_actions.Add(new /datum/action/innate/construction/switch_mode())//Action for switching the RCD's build modes
	construction_actions.Add(new /datum/action/innate/construction/build()) //Action for using the RCD
	construction_actions.Add(new /datum/action/innate/construction/airlock_type()) //Action for setting the airlock type
	construction_actions.Add(new /datum/action/innate/construction/window_type()) //Action for setting the window type
	construction_actions.Add(new /datum/action/innate/construction/place_structure/fan()) //Action for spawning fans
	construction_actions.Add(new /datum/action/innate/construction/place_structure/turret()) //Action for spawning turrets

/obj/machinery/computer/camera_advanced/base_construction/aux/find_spawn_spot()
	//Aux base controller. Where the eyeobj will spawn.
	var/obj/machinery/computer/auxiliary_base/aux_controller
	for(var/obj/machinery/computer/auxiliary_base/potential_aux_console in GLOB.machines)
		if(istype(get_area(potential_aux_console), allowed_area))
			aux_controller = potential_aux_console
			break
	if(!aux_controller)
		say("ERROR: Unable to locate auxiliary base controller!")
		return null
	return aux_controller
