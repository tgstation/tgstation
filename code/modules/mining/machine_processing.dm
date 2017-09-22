#define SMELT_AMOUNT 10

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST
	speed_process = 1

/obj/machinery/mineral/processing_unit_console/Initialize()
	. = ..()
	machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
	if (machine)
		machine.CONSOLE = src
	else
		qdel(src)

/obj/machinery/mineral/processing_unit_console/attack_hand(mob/user)

	if(!machine)
		return

	var/dat = machine.get_machine_data()

	var/datum/browser/popup = new(user, "processing", "Smelting Console", 300, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["material"])
		machine.selected_material = href_list["material"]
		machine.selected_alloy = null

	if(href_list["alloy"])
		machine.selected_material = null
		machine.selected_alloy = href_list["alloy"]

	if(href_list["set_on"])
		machine.on = (href_list["set_on"] == "on")

	updateUsrDialog()
	return

/obj/machinery/mineral/processing_unit_console/Destroy()
	machine = null
	return ..()


/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/mineral/CONSOLE = null
	var/on = FALSE
	var/selected_material = MAT_METAL
	var/selected_alloy = null
	var/datum/research/files

/obj/machinery/mineral/processing_unit/Initialize()
	. = ..()
	proximity_monitor = new(src, 1)
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE), INFINITY)
	files = new /datum/research/smelter(src)

/obj/machinery/mineral/processing_unit/Destroy()
	CONSOLE = null
	QDEL_NULL(files)
	return ..()

/obj/machinery/mineral/processing_unit/HasProximity(atom/movable/AM)
	if(istype(AM, /obj/item/ore) && AM.loc == get_step(src, input_dir))
		process_ore(AM)

/obj/machinery/mineral/processing_unit/proc/process_ore(obj/item/ore/O)
	GET_COMPONENT(materials, /datum/component/material_container)
	var/material_amount = materials.get_item_material_amount(O)
	if(!materials.has_space(material_amount))
		unload_mineral(O)
	else
		materials.insert_item(O)
		qdel(O)
		if(CONSOLE)
			CONSOLE.updateUsrDialog()

/obj/machinery/mineral/processing_unit/proc/get_machine_data()
	var/dat = "<b>Smelter control console</b><br><br>"
	GET_COMPONENT(materials, /datum/component/material_container)
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		dat += "<span class=\"res_name\">[M.name]: </span>[M.amount] cm&sup3;"
		if (selected_material == mat_id)
			dat += " <i>Smelting</i>"
		else
			dat += " <A href='?src=\ref[CONSOLE];material=[mat_id]'><b>Not Smelting</b></A> "
		dat += "<br>"

	dat += "<br><br>"
	dat += "<b>Smelt Alloys</b><br>"

	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		dat += "<span class=\"res_name\">[D.name] "
		if (selected_alloy == D.id)
			dat += " <i>Smelting</i>"
		else
			dat += " <A href='?src=\ref[CONSOLE];alloy=[D.id]'><b>Not Smelting</b></A> "
		dat += "<br>"

	dat += "<br><br>"
	//On or off
	dat += "Machine is currently "
	if (on)
		dat += "<A href='?src=\ref[CONSOLE];set_on=off'>On</A> "
	else
		dat += "<A href='?src=\ref[CONSOLE];set_on=on'>Off</A> "

	return dat

/obj/machinery/mineral/processing_unit/process()
	if (on)
		if(selected_material)
			smelt_ore()

		else if(selected_alloy)
			smelt_alloy()


		if(CONSOLE)
			CONSOLE.updateUsrDialog()


			//THESE TWO ARE CODED FOR URIST TO USE WHEN HE GETS AROUND TO IT.
			//They were coded on 18 Feb 2012. If you're reading this in 2015, then firstly congratulations on the world not ending on 21 Dec 2012 and secondly, Urist is apparently VERY lazy. ~Errorage
			//Even in the dark year of 2016, where /tg/ is dead, Urist still hasn't finished this -Bawhoppennn
			/*if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 1 && selected_plasma == 0 && selected_uranium == 1 && selected_iron == 0 && selected_clown == 0)
				if (ore_uranium >= 2 && ore_diamond >= 1)
					ore_uranium -= 2
					ore_diamond -= 1
					generate_mineral(/obj/item/stack/sheet/mineral/adamantine)
				else
					on = FALSE
				continue
			if (selected_glass == 0 && selected_gold == 0 && selected_silver == 1 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
				if (ore_silver >= 1 && ore_plasma >= 3)
					ore_silver -= 1
					ore_plasma -= 3
					generate_mineral(/obj/item/stack/sheet/mineral/mythril)
				else
					on = FALSE
				continue*/

/obj/machinery/mineral/processing_unit/proc/smelt_ore()
	GET_COMPONENT(materials, /datum/component/material_container)
	var/datum/material/mat = materials.materials[selected_material]
	if(mat)
		var/sheets_to_remove = (mat.amount >= (MINERAL_MATERIAL_AMOUNT * SMELT_AMOUNT) ) ? SMELT_AMOUNT : round(mat.amount /  MINERAL_MATERIAL_AMOUNT)
		if(!sheets_to_remove)
			on = FALSE
		else
			var/out = get_step(src, output_dir)
			materials.retrieve_sheets(sheets_to_remove, selected_material, out)


/obj/machinery/mineral/processing_unit/proc/smelt_alloy()
	var/datum/design/alloy = files.FindDesignByID(selected_alloy) //check if it's a valid design
	if(!alloy)
		on = FALSE
		return

	var/amount = can_smelt(alloy)

	if(!amount)
		on = FALSE
		return

	GET_COMPONENT(materials, /datum/component/material_container)
	materials.use_amount(alloy.materials, amount)

	generate_mineral(alloy.build_path)

/obj/machinery/mineral/processing_unit/proc/can_smelt(datum/design/D)
	if(D.make_reagents.len)
		return 0

	var/build_amount = SMELT_AMOUNT

	GET_COMPONENT(materials, /datum/component/material_container)

	for(var/mat_id in D.materials)
		var/M = D.materials[mat_id]
		var/datum/material/smelter_mat  = materials.materials[mat_id]

		if(!M || !smelter_mat)
			return 0

		build_amount = min(build_amount, round(smelter_mat.amount / M))

	return build_amount

/obj/machinery/mineral/processing_unit/proc/generate_mineral(P)
	var/O = new P(src)
	unload_mineral(O)

/obj/machinery/mineral/processing_unit/on_deconstruction()
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	..()

#undef SMELT_AMOUNT