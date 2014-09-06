
//**************************************************************
//
// Ice Cream Machine
// ---------------------
// Original code by Sawu of Sawustation.
//
//**************************************************************

// Base ////////////////////////////////////////////////////////

/obj/machinery/cooking/icemachine
	name = "Cream-Master Deluxe"
	icon_state = "icecream_vat"

	var/obj/item/weapon/reagent_containers/glass/beaker = null

/obj/machinery/cooking/icemachine/New()
	src.reagents = new/datum/reagents(500)
	src.reagents.my_atom = src
	return ..()

// Utilities ///////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/proc/generateName(reagentName)
	. = pick("Mr. ","Mrs. ","Super ","Happy ","Whippy ")
	. += pick("Whippy ","Slappy ","Creamy ","Dippy ","Swirly ","Swirl ")
	. += reagentName
	return

// Processing //////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/takeIngredient(var/obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/glass))
		if(!src.beaker)
			user.drop_item()
			src.beaker = I
			I.loc = src
			. = 1
			user << "<span class='notice'>You add the [I.name] to the [src.name].</span>"
			src.updateUsrDialog()
		else user << "<span class='warning'>The [src.name] already has a beaker.</span>"
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/icecream))
		if(!I.reagents.has_reagent("sprinkles"))
			I.reagents.add_reagent("sprinkles",1)
			I.overlays += image('icons/obj/kitchen.dmi',src,"sprinkles")
			I.name += " with sprinkles"
			I.desc += " It has sprinkles on top."
			. = 1
		else . = "<span class='warning'>The [I.name] already has sprinkles.</span>"
	return

// Interactions ////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/cooking/icemachine/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/cooking/icemachine/attack_hand(mob/user)
	if(istype(user,/mob/dead/observer))	user << "Your ghostly hand goes straight through."
	user.set_machine(src)
	var/dat = ""
	if(src.beaker)
		dat += "<A href='?src=\ref[src];eject=1'>Eject container and end transfer.</A><BR>"
		if(!src.beaker.reagents.total_volume) dat += "Container is empty.<BR><HR>"
		else dat += src.showReagents(1)
		dat += src.showReagents(2)
		dat += src.showToppings()
	else
		dat += "No container is loaded into the machine, external transfer offline.<BR>"
		dat += src.showReagents(2)
		dat += src.showToppings()
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	var/datum/browser/popup = new(user,"cream_master","Cream-Master Deluxe",700,400,src)
	popup.set_content(dat)
	popup.open()
	return

// HTML Menu ///////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/Topic(href,href_list)
	if(..()) return
	src.add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["close"])
		usr << browse(null,"window=cream_master")
		usr.unset_machine()

	else if(href_list["add"] && href_list["amount"] && src.beaker)
		var/id = href_list["add"]
		var/amount = text2num(href_list["amount"])
		if(amount > 0) src.beaker.reagents.trans_id_to(src,id,amount)

	else if(href_list["remove"] && href_list["amount"])
		var/id = href_list["remove"]
		var/amount = text2num(href_list["amount"])
		if(src.reagents.has_reagent(id))
			if(src.beaker)	reagents.trans_id_to(src.beaker,id,amount)
			else			reagents.remove_reagent(id,amount)

	else if(href_list["main"]) src.attack_hand(usr)

	else if(href_list["eject"] && src.beaker)
		src.reagents.trans_to(src.beaker,src.reagents.total_volume)
		src.beaker.loc = src.loc
		src.beaker = null

	else if(href_list["synthcond"] && href_list["type"])
		switch(text2num(href_list["type"]))
			if(2) . = pick("cola","dr_gibb","space_up","spacemountainwind")
			if(3) . = pick("kahlua","vodka","rum","gin")
			if(4) . = "cream"
			if(5) . = "water"
		src.reagents.add_reagent(.,5)

	else if(href_list["createcup"] || href_list["createcone"])
		var/obj/item/weapon/reagent_containers/food/C
		if(href_list["createcup"]) C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup(src.loc)
		else C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone(src.loc)
		C.name = "[src.generateName(src.reagents.get_master_reagent_name())] [C.name]"
		C.pixel_x = rand(-8,8)
		C.pixel_y = -16
		src.reagents.trans_to(C,30)
		src.reagents.clear_reagents()
		C.update_icon()

	src.updateUsrDialog()
	return

/obj/machinery/cooking/icemachine/proc/showToppings()
	var/dat = ""
	if(src.reagents.total_volume <= 500)
		dat += "<HR>"
		dat += "<strong>Add fillings:</strong><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=2'>Soda</A><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=3'>Alcohol</A><BR>"
		dat += "<strong>Finish With:</strong><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=4'>Cream</A><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=5'>Water</A><BR>"
		dat += "<strong>Dispense in:</strong><BR>"
		dat += "<A href='?src=\ref[src];createcup=1'>Chocolate Cone</A><BR>"
		dat += "<A href='?src=\ref[src];createcone=1'>Cone</A><BR>"
	dat += "</center>"
	return dat

/obj/machinery/cooking/icemachine/proc/showReagents(container)
	//1 = beaker / 2 = internal
	var/dat = ""
	if(container == 1)
		dat += "The container has:<BR>"
		for(var/datum/reagent/R in src.beaker.reagents.reagent_list)
			dat += "[R.volume] unit(s) of [R.name] | "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=5'>(5)</A> "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=10'>(10)</A> "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=15'>(15)</A> "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=[R.volume]'>(All)</A>"
			dat += "<BR>"
	else if(container == 2)
		dat += "<BR>The Cream-Master has:<BR>"
		if(src.reagents.total_volume)
			for(var/datum/reagent/R in src.reagents.reagent_list)
				dat += "[R.volume] unit(s) of [R.name] | "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=15'>(15)</A> "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=[R.volume]'>(All)</A>"
				dat += "<BR>"
		else dat += "No reagents. <BR>"
	else dat += "<BR>INVALID REAGENT CONTAINER. Make a bug report.<BR>"
	return dat
