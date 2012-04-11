/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	var/id = ""
	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST

/obj/machinery/mineral/processing_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/processing_unit_console/attack_hand(user as mob)

	var/dat = "<b>Smelter control console</b><br><br>"
	//iron
	if(machine.ore_iron || machine.ore_glass || machine.ore_plasma || machine.ore_uranium || machine.ore_gold || machine.ore_silver || machine.ore_diamond || machine.ore_clown || machine.ore_adamantine)
		if(machine.ore_iron)
			if (machine.selected_iron==1)
				dat += text("<A href='?src=\ref[src];sel_iron=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_iron=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Iron: [machine.ore_iron]<br>")
		else
			machine.selected_iron = 0

		//sand - glass
		if(machine.ore_glass)
			if (machine.selected_glass==1)
				dat += text("<A href='?src=\ref[src];sel_glass=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_glass=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Sand: [machine.ore_glass]<br>")
		else
			machine.selected_glass = 0

		//plasma
		if(machine.ore_plasma)
			if (machine.selected_plasma==1)
				dat += text("<A href='?src=\ref[src];sel_plasma=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_plasma=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Plasma: [machine.ore_plasma]<br>")
		else
			machine.selected_plasma = 0

		//uranium
		if(machine.ore_uranium)
			if (machine.selected_uranium==1)
				dat += text("<A href='?src=\ref[src];sel_uranium=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_uranium=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Uranium: [machine.ore_uranium]<br>")
		else
			machine.selected_uranium = 0

		//gold
		if(machine.ore_gold)
			if (machine.selected_gold==1)
				dat += text("<A href='?src=\ref[src];sel_gold=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_gold=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Gold: [machine.ore_gold]<br>")
		else
			machine.selected_gold = 0

		//silver
		if(machine.ore_silver)
			if (machine.selected_silver==1)
				dat += text("<A href='?src=\ref[src];sel_silver=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_silver=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Silver: [machine.ore_silver]<br>")
		else
			machine.selected_silver = 0

		//diamond
		if(machine.ore_diamond)
			if (machine.selected_diamond==1)
				dat += text("<A href='?src=\ref[src];sel_diamond=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_diamond=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Diamond: [machine.ore_diamond]<br>")
		else
			machine.selected_diamond = 0

		//bananium
		if(machine.ore_clown)
			if (machine.selected_clown==1)
				dat += text("<A href='?src=\ref[src];sel_clown=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_clown=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Bananium: [machine.ore_clown]<br>")
		else
			machine.selected_clown = 0

		//adamantine
		if(machine.ore_adamantine)
			if (machine.selected_adamantine==1)
				dat += text("<A href='?src=\ref[src];sel_adamantine=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_adamantine=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Adamantine: [machine.ore_adamantine]<br>")
		else
			machine.selected_adamantine = 0


		//On or off
		dat += text("Machine is currently ")
		if (machine.on==1)
			dat += text("<A href='?src=\ref[src];set_on=off'>On</A> ")
		else
			dat += text("<A href='?src=\ref[src];set_on=on'>Off</A> ")
	else
		dat+="---No Materials Loaded---"


	user << browse("[dat]", "window=console_processing_unit")



/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["sel_iron"])
		if (href_list["sel_iron"] == "yes")
			machine.selected_iron = 1
		else
			machine.selected_iron = 0
	if(href_list["sel_glass"])
		if (href_list["sel_glass"] == "yes")
			machine.selected_glass = 1
		else
			machine.selected_glass = 0
	if(href_list["sel_plasma"])
		if (href_list["sel_plasma"] == "yes")
			machine.selected_plasma = 1
		else
			machine.selected_plasma = 0
	if(href_list["sel_uranium"])
		if (href_list["sel_uranium"] == "yes")
			machine.selected_uranium = 1
		else
			machine.selected_uranium = 0
	if(href_list["sel_gold"])
		if (href_list["sel_gold"] == "yes")
			machine.selected_gold = 1
		else
			machine.selected_gold = 0
	if(href_list["sel_silver"])
		if (href_list["sel_silver"] == "yes")
			machine.selected_silver = 1
		else
			machine.selected_silver = 0
	if(href_list["sel_diamond"])
		if (href_list["sel_diamond"] == "yes")
			machine.selected_diamond = 1
		else
			machine.selected_diamond = 0
	if(href_list["sel_clown"])
		if (href_list["sel_clown"] == "yes")
			machine.selected_clown = 1
		else
			machine.selected_clown = 0
	if(href_list["sel_adamantine"])
		if (href_list["sel_adamantine"] == "yes")
			machine.selected_adamantine = 1
		else
			machine.selected_adamantine =0
	if(href_list["set_on"])
		if (href_list["set_on"] == "on")
			machine.on = 1
		else
			machine.on = 0
	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "Furnace"
	icon = 'mining_machines.dmi'
	icon_state = "furnace"
	density = 1
	anchored = 1.0
	var/id = ""
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/CONSOLE = null
	var/ore_gold = 0;
	var/ore_silver = 0;
	var/ore_diamond = 0;
	var/ore_glass = 0;
	var/ore_plasma = 0;
	var/ore_uranium = 0;
	var/ore_iron = 0;
	var/ore_clown = 0;
	var/ore_adamantine = 0;
	var/selected_gold = 0
	var/selected_silver = 0
	var/selected_diamond = 0
	var/selected_glass = 0
	var/selected_plasma = 0
	var/selected_uranium = 0
	var/selected_iron = 0
	var/selected_clown = 0
	var/selected_adamantine = 0
	var/on = 0 //0 = off, 1 =... oh you know!

/obj/machinery/mineral/processing_unit/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_objects.Add(src)
		return
	return

/obj/machinery/mineral/processing_unit/process()
	if (src.output && src.input)
		var/i
		for (i = 0; i < 10; i++)
			if (on)
				if (selected_glass == 1 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_glass > 0)
						ore_glass--;
						new /obj/item/stack/sheet/glass(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 1 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_glass > 0 && ore_iron > 0)
						ore_glass--;
						ore_iron--;
						new /obj/item/stack/sheet/rglass(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 1 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_gold > 0)
						ore_gold--;
						new /obj/item/stack/sheet/gold(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 1 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_silver > 0)
						ore_silver--;
						new /obj/item/stack/sheet/silver(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 1 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_diamond > 0)
						ore_diamond--;
						new /obj/item/stack/sheet/diamond(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_plasma > 0)
						ore_plasma--;
						new /obj/item/stack/sheet/plasma(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 1 && selected_iron == 0 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_uranium > 0)
						ore_uranium--;
						new /obj/item/stack/sheet/uranium(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_iron > 0)
						ore_iron--;
						new /obj/item/stack/sheet/metal(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0 && selected_adamantine == 0)
					if (ore_iron > 0 && ore_plasma > 0)
						ore_iron--;
						ore_plasma--;
						new /obj/item/stack/sheet/plasteel(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 1 && selected_adamantine == 0)
					if (ore_clown > 0)
						ore_clown--;
						new /obj/item/stack/sheet/clown(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_adamantine == 1)
					if (ore_adamantine > 0)
						ore_adamantine--;
						new /obj/item/stack/sheet/adamantine(output.loc)
					else
						on = 0
					continue

				//if a non valid combination is selected

				var/b = 1 //this part checks if all required ores are available

				if (!(selected_gold || selected_silver ||selected_diamond || selected_uranium | selected_plasma || selected_iron || selected_iron))
					b = 0

				if (selected_gold == 1)
					if (ore_gold <= 0)
						b = 0
				if (selected_silver == 1)
					if (ore_silver <= 0)
						b = 0
				if (selected_diamond == 1)
					if (ore_diamond <= 0)
						b = 0
				if (selected_uranium == 1)
					if (ore_uranium <= 0)
						b = 0
				if (selected_plasma == 1)
					if (ore_plasma <= 0)
						b = 0
				if (selected_iron == 1)
					if (ore_iron <= 0)
						b = 0
				if (selected_glass == 1)
					if (ore_glass <= 0)
						b = 0
				if (selected_clown == 1)
					if (ore_clown <= 0)
						b = 0
				if (selected_adamantine == 1)
					if (ore_adamantine <= 0)
						b = 0

				if (b) //if they are, deduct one from each, produce slag and shut the machine off
					if (selected_gold == 1)
						ore_gold--
					if (selected_silver == 1)
						ore_silver--
					if (selected_diamond == 1)
						ore_diamond--
					if (selected_uranium == 1)
						ore_uranium--
					if (selected_plasma == 1)
						ore_plasma--
					if (selected_iron == 1)
						ore_iron--
					if (selected_clown == 1)
						ore_clown--
					if (selected_adamantine == 1)
						ore_adamantine--
					new /obj/item/weapon/ore/slag(output.loc)
					on = 0
				else
					on = 0
					break
				break
			else
				break
		for (i = 0; i < 10; i++)
			var/obj/item/O
			O = locate(/obj/item, input.loc)
			if (O)
				if (istype(O,/obj/item/weapon/ore/iron))
					ore_iron++;
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/glass))
					ore_glass++;
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/diamond))
					ore_diamond++;
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/plasma))
					ore_plasma++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/gold))
					ore_gold++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/silver))
					ore_silver++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/uranium))
					ore_uranium++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/clown))
					ore_clown++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/adamantine))
					ore_adamantine++
					del(O)
					continue
				O.loc = src.output.loc
			else
				break
	return