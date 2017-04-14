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

/obj/machinery/mineral/processing_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
		if (machine)
			machine.CONSOLE = src
		else
			qdel(src)

/obj/machinery/mineral/processing_unit_console/attack_hand(mob/user)

	var/dat = "<b>Smelter control console</b><br><br>"
	//iron
	if(machine.ore_iron || machine.ore_glass || machine.ore_plasma || machine.ore_uranium || machine.ore_gold || machine.ore_silver || machine.ore_diamond || machine.ore_clown || machine.ore_adamantine)
		if(machine.ore_iron)
			if (machine.selected_iron==1)
				dat += "<A href='?src=\ref[src];sel_iron=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_iron=yes'><font color='red'>Not smelting</font></A> "
			dat += "Iron: [machine.ore_iron]<br>"
		else
			machine.selected_iron = 0

		//sand - glass
		if(machine.ore_glass)
			if (machine.selected_glass==1)
				dat += "<A href='?src=\ref[src];sel_glass=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_glass=yes'><font color='red'>Not smelting</font></A> "
			dat += "Sand: [machine.ore_glass]<br>"
		else
			machine.selected_glass = 0

		//plasma
		if(machine.ore_plasma)
			if (machine.selected_plasma==1)
				dat += "<A href='?src=\ref[src];sel_plasma=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_plasma=yes'><font color='red'>Not smelting</font></A> "
			dat += "Plasma: [machine.ore_plasma]<br>"
		else
			machine.selected_plasma = 0

		//uranium
		if(machine.ore_uranium)
			if (machine.selected_uranium==1)
				dat += "<A href='?src=\ref[src];sel_uranium=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_uranium=yes'><font color='red'>Not smelting</font></A> "
			dat += "Uranium: [machine.ore_uranium]<br>"
		else
			machine.selected_uranium = 0

		//gold
		if(machine.ore_gold)
			if (machine.selected_gold==1)
				dat += "<A href='?src=\ref[src];sel_gold=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_gold=yes'><font color='red'>Not smelting</font></A> "
			dat += "Gold: [machine.ore_gold]<br>"
		else
			machine.selected_gold = 0

		//silver
		if(machine.ore_silver)
			if (machine.selected_silver==1)
				dat += "<A href='?src=\ref[src];sel_silver=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_silver=yes'><font color='red'>Not smelting</font></A> "
			dat += "Silver: [machine.ore_silver]<br>"
		else
			machine.selected_silver = 0

		//diamond
		if(machine.ore_diamond)
			if (machine.selected_diamond==1)
				dat += "<A href='?src=\ref[src];sel_diamond=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_diamond=yes'><font color='red'>Not smelting</font></A> "
			dat += "Diamond: [machine.ore_diamond]<br>"
		else
			machine.selected_diamond = 0

		//bananium
		if(machine.ore_clown)
			if (machine.selected_clown==1)
				dat += "<A href='?src=\ref[src];sel_clown=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_clown=yes'><font color='red'>Not smelting</font></A> "
			dat += "Bananium: [machine.ore_clown]<br>"
		else
			machine.selected_clown = 0

		//titanium
		if(machine.ore_titanium)
			if (machine.selected_titanium==1)
				dat += "<A href='?src=\ref[src];sel_titanium=no'><font color='green'>Smelting</font></A> "
			else
				dat += "<A href='?src=\ref[src];sel_titanium=yes'><font color='red'>Not smelting</font></A> "
			dat += "Titanium: [machine.ore_titanium]<br>"
		else
			machine.selected_titanium = 0


		//On or off
		dat += text("Machine is currently ")
		if (machine.on==1)
			dat += text("<A href='?src=\ref[src];set_on=off'>On</A> ")
		else
			dat += text("<A href='?src=\ref[src];set_on=on'>Off</A> ")
	else
		dat+="---No Materials Loaded---"


	user << browse(dat, "window=console_processing_unit")



/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
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
	if(href_list["sel_titanium"])
		if (href_list["sel_titanium"] == "yes")
			machine.selected_titanium = 1
		else
			machine.selected_titanium = 0
	if(href_list["set_on"])
		if (href_list["set_on"] == "on")
			machine.on = 1
		else
			machine.on = 0
	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = 1
	anchored = 1
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
	var/ore_titanium = 0;
	var/selected_gold = 0
	var/selected_silver = 0
	var/selected_diamond = 0
	var/selected_glass = 0
	var/selected_plasma = 0
	var/selected_uranium = 0
	var/selected_iron = 0
	var/selected_clown = 0
	var/selected_titanium = 0
	var/on = 0 //0 = off, 1 =... oh you know!

/obj/machinery/mineral/processing_unit/process()
	for(var/i in 1 to 10)
		if (on)
			if (selected_glass && !selected_gold && !selected_silver && !selected_diamond && !selected_plasma && !selected_uranium && !selected_iron && !selected_clown && !selected_titanium)
				if (ore_glass > 0)
					ore_glass--
					generate_mineral(/obj/item/stack/sheet/glass)
				else
					on = 0
				continue
			if (selected_glass && !selected_gold && !selected_silver && !selected_diamond && !selected_plasma && !selected_uranium && selected_iron && !selected_clown && !selected_titanium)
				if (ore_glass > 0 && ore_iron > 0)
					ore_glass--
					ore_iron--
					generate_mineral(/obj/item/stack/sheet/rglass)
				else
					on = 0
				continue
			if (!selected_glass && selected_gold && !selected_silver && !selected_diamond && !selected_plasma && !selected_uranium && !selected_iron && !selected_clown && !selected_titanium)
				if (ore_gold > 0)
					ore_gold--
					generate_mineral(/obj/item/stack/sheet/mineral/gold)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && selected_silver && !selected_diamond && !selected_plasma && !selected_uranium && !selected_iron && !selected_clown && !selected_titanium)
				if (ore_silver > 0)
					ore_silver--
					generate_mineral(/obj/item/stack/sheet/mineral/silver)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && selected_diamond && !selected_plasma && !selected_uranium && !selected_iron && !selected_clown && !selected_titanium)
				if (ore_diamond > 0)
					ore_diamond--
					generate_mineral(/obj/item/stack/sheet/mineral/diamond)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && !selected_diamond && selected_plasma && !selected_uranium && !selected_iron && !selected_clown && !selected_titanium)
				if (ore_plasma > 0)
					ore_plasma--
					generate_mineral(/obj/item/stack/sheet/mineral/plasma)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && !selected_diamond && !selected_plasma && selected_uranium && !selected_iron && !selected_clown && !selected_titanium)
				if (ore_uranium > 0)
					ore_uranium--
					generate_mineral(/obj/item/stack/sheet/mineral/uranium)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && !selected_diamond && !selected_plasma && !selected_uranium && selected_iron && !selected_clown && !selected_titanium)
				if (ore_iron > 0)
					ore_iron--
					generate_mineral(/obj/item/stack/sheet/metal)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && !selected_diamond && selected_plasma && !selected_uranium && selected_iron && !selected_clown && !selected_titanium)
				if (ore_iron > 0 && ore_plasma > 0)
					ore_iron--
					ore_plasma--
					generate_mineral(/obj/item/stack/sheet/plasteel)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && !selected_diamond && !selected_plasma && !selected_uranium && !selected_iron && selected_clown && !selected_titanium)
				if (ore_clown > 0)
					ore_clown--
					generate_mineral(/obj/item/stack/sheet/mineral/bananium)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && !selected_diamond && !selected_plasma && !selected_uranium && !selected_iron && !selected_clown && selected_titanium)
				if (ore_titanium > 0)
					ore_titanium--
					generate_mineral(/obj/item/stack/sheet/mineral/titanium)
				else
					on = 0
				continue
			if (!selected_glass && !selected_gold && !selected_silver && !selected_diamond && selected_plasma && !selected_uranium && !selected_iron && !selected_clown && selected_titanium)
				if (ore_titanium > 0)
					ore_titanium--
					ore_plasma--
					generate_mineral(/obj/item/stack/sheet/mineral/plastitanium)
				else
					on = 0
				continue
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
				generate_mineral(/obj/item/weapon/ore/slag)
				on = 0
			else
				on = 0
				break
			break
		else
			break
	var/turf/T = get_step(src,input_dir)
	if(T)
		var/n = 0
		for(var/obj/item/O in T)
			n++
			if(n>10)
				break
			if (istype(O,/obj/item/weapon/ore/iron))
				ore_iron++;
				O.loc = null
				continue
			if (istype(O,/obj/item/weapon/ore/glass))
				ore_glass++;
				O.loc = null
				continue
			if (istype(O,/obj/item/weapon/ore/diamond))
				ore_diamond++;
				O.loc = null
				continue
			if (istype(O,/obj/item/weapon/ore/plasma))
				ore_plasma++
				O.loc = null
				continue
			if (istype(O,/obj/item/weapon/ore/gold))
				ore_gold++
				O.loc = null
				continue
			if (istype(O,/obj/item/weapon/ore/silver))
				ore_silver++
				O.loc = null
				continue
			if (istype(O,/obj/item/weapon/ore/uranium))
				ore_uranium++
				O.loc = null
				continue
			if (istype(O,/obj/item/weapon/ore/bananium))
				ore_clown++
				O.loc = null
				continue
			unload_mineral(O)


/obj/machinery/mineral/processing_unit/proc/generate_mineral(P)
	var/O = new P(src)
	unload_mineral(O)
