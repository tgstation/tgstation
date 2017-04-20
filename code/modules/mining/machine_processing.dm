#define PROCESSING_UNIT_CAPACITY 300000

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
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

	var/datum/browser/popup = new(user, "processing", "Smelting Console", 600, 600)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["material"])
		machine.selected_material = href_list["material"]

	if(href_list["set_on"])
		machine.on = (href_list["set_on"] == "on")

	updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/CONSOLE = null
	var/datum/material_container/materials
	var/on = FALSE
	var/selected_material = MAT_METAL

/obj/machinery/mineral/processing_unit/Initialize()
	. = ..()
	proximity_monitor = new(src, 1)
	materials = new(src, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE),PROCESSING_UNIT_CAPACITY)

/obj/machinery/mineral/processing_unit/Destroy()
	qdel(materials)
	return ..()

/obj/machinery/mineral/processing_unit/HasProximity(atom/movable/AM)
	if(istype(AM, /obj/item/weapon/ore) && AM.loc == get_step(src, input_dir))
		process_ore(AM)

/obj/machinery/mineral/processing_unit/proc/process_ore(obj/item/weapon/ore/O)
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
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		dat += "<span class=\"res_name\">[M.name]: </span>[M.amount] cm&sup3;"
		if (selected_material == mat_id)
			dat += "Smelting"
		else
			dat += "<A href='?src=\ref[CONSOLE];material=[mat_id]'><b>Not Smelting</b></A> "
		dat += "<br>"

	dat += "<br>"
	//On or off
	dat += "Machine is currently "
	if (on)
		dat += "<A href='?src=\ref[CONSOLE];set_on=off'>On</A> "
	else
		dat += "<A href='?src=\ref[CONSOLE];set_on=on'>Off</A> "

	return dat

/obj/machinery/mineral/processing_unit/process()
	if (on)
		var/datum/material/mat = materials.materials[selected_material]
		if(mat)
			var/sheets_to_remove = (mat.amount >= (MINERAL_MATERIAL_AMOUNT * 10) ) ? 10 : round(mat.amount /  MINERAL_MATERIAL_AMOUNT)
			if(!sheets_to_remove)
				on = FALSE
			else
				var/out = get_step(src, output_dir)
				materials.retrieve_sheets(sheets_to_remove, selected_material, out)

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
					on = 0
				continue
			if (selected_glass == 0 && selected_gold == 0 && selected_silver == 1 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
				if (ore_silver >= 1 && ore_plasma >= 3)
					ore_silver -= 1
					ore_plasma -= 3
					generate_mineral(/obj/item/stack/sheet/mineral/mythril)
				else
					on = 0
				continue*/


/obj/machinery/mineral/processing_unit/proc/generate_mineral(P)
	var/O = new P(src)
	unload_mineral(O)

/obj/machinery/mineral/processing_unit/on_deconstruction()
	materials.retrieve_all()
	..()

#undef PROCESSING_UNIT_CAPACITY