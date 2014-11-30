#define FLA_FAB_WIDTH 1000
#define FLA_FAB_HEIGHT 600

#define FLA_FAB_BASETIME 100

/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker
	name = "Flatpack Fabricator"
	desc = "A machine used to produce flatpacks from blueprint designs."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "flatpacker"

	nano_file = "flatpacker.tmpl"

	design_types = list("machine" = 1, "item" = 0)

	var/build_parts =  list(
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/scanning_module = 1
		)

	part_sets = list(	"Machines" = list(),
						"Computers" = list(),
						"Misc" = list()
		)

/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/flatpacker,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker/build_part(var/datum/design/mechanic_design/part)
	if(!part)
		return

	for(var/M in part.materials)
		if(!check_mat(part, M))
			src.visible_message("<font color='blue'>The [src.name] beeps, \"Not enough materials to complete item.\"</font>")
			stopped=1
			return 0
		if(copytext(M,1,2) == "$")
			var/matID=copytext(M,2)
			var/datum/material/material=materials[matID]
			material.stored = max(0, (material.stored-part.materials[M]))
			materials[matID]=material
		else
			reagents.remove_reagent(M, part.materials[M])

	src.being_built = new part.build_path(src)

	src.busy = 1
	src.overlays += "[base_state]_ani"
	src.use_power = 2
	src.updateUsrDialog()
	//message_admins("We're going building with [get_construction_time_w_coeff(part)]")
	sleep(get_construction_time_w_coeff(part))
	src.use_power = 1
	src.overlays -= "[base_state]_ani"
	if(being_built)
		var/obj/structure/closet/crate/flatpack/FP = new
		being_built.loc = FP
		FP.name += " ([being_built.name])"
		FP.machine = being_built
		FP.loc = get_turf(output)
		src.visible_message("\icon [src] \The [src] beeps: \"Succesfully completed \the [being_built.name].\"")
		src.being_built = null

		//blueprint stuff
		if(uses_list[part] > 0)
			uses_list[part]--
			if(uses_list[part] == 0)
				uses_list -= part
				remove_part_from_set(part.category, part)
	src.updateUsrDialog()
	src.busy = 0
	return 1

/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (O.is_open_container())
		return 1