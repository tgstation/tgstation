//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ICE CREAM MACHINE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/icemachine
	name = "Cream-Master Deluxe"
	density = 1
	anchored = 1
	icon = 'icons/obj/vending.dmi'
	icon_state = "icecream"
	use_power = 1
	idle_power_usage = 20
	var/beaker = null
	var/useramount = 15 // Last used amount

/obj/machinery/icemachine/proc/generate_name(var/reagent_name)
	var/name_prefix = pick("Mr.","Mrs.","Super","Happy","Whippy")
	var/name_suffix = pick(" Whippy "," Slappy "," Creamy "," Dippy "," Swirly "," Swirl ")
	var/cone_name = null //Heart failiure prevention.
	cone_name += name_prefix
	cone_name += name_suffix
	cone_name += "[reagent_name] "
	return cone_name

/obj/machinery/icemachine/New()
	var/datum/reagents/R = new/datum/reagents(30)
	reagents = R
	R.my_atom = src

/obj/machinery/icemachine/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			user << "A container is already inside the Cream-Master"
			return
		src.beaker = B
		user.drop_item()
		B.loc = src
		user << "You add the container to the Cream-Master!"
		src.updateUsrDialog()
	return

/obj/machinery/icemachine/proc/validexchange(var/reag)
	if(reag == "sprinkles" | reag == "cola" | reag == "kahlua" | reag == "dr_gibb" | reag == "vodka" | reag == "space_up" | reag == "rum" | reag == "spacemountainwind" | reag == "gin" | reag == "cream" | reag == "water")
		return 0
	else
		return 1

/obj/machinery/icemachine/Topic(href, href_list)
	if(..()) return

	src.add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["close"])
		usr << browse(null, "window=cream_master")
		usr.unset_machine()
		return

	var/obj/item/weapon/reagent_containers/glass/A = null
	var/datum/reagents/R = null

	if(beaker)
		A = beaker
		R = A.reagents

	if (href_list["add"])
		if(href_list["amount"])
			var/id = href_list["add"]
			var/amount = text2num(href_list["amount"])
			if(validexchange(id))
				R.trans_id_to(src, id, amount)

	else if (href_list["remove"])
		if(href_list["amount"])
			var/id = href_list["remove"]
			var/amount = text2num(href_list["amount"])
			if(beaker == null)
				reagents.remove_reagent(id,amount)
			else
				if(validexchange(id))
					reagents.trans_id_to(A, id, amount)
				else
					reagents.remove_reagent(id,amount)

	else if (href_list["main"])
		attack_hand(usr)
		return

	else if (href_list["eject"])
		if(beaker)
			A.loc = src.loc
			beaker = null
			reagents.trans_to(A,reagents.total_volume)

	else if (href_list["synthcond"])
		if(href_list["type"])
			var/ID = text2num(href_list["type"])
			if(ID == 1)
				reagents.add_reagent("sprinkles",1)
			else if(ID == 2 | ID == 3)
				var/brand = pick(1,2,3,4)
				if(brand == 1)
					if(ID == 2)
						reagents.add_reagent("cola",5)
					else
						reagents.add_reagent("kahlua",5)
				else if(brand == 2)
					if(ID == 2)
						reagents.add_reagent("dr_gibb",5)
					else
						reagents.add_reagent("vodka",5)
				else if(brand == 3)
					if(ID == 2)
						reagents.add_reagent("space_up",5)
					else
						reagents.add_reagent("rum",5)
				else if(brand == 4)
					if(ID == 2)
						reagents.add_reagent("spacemountainwind",5)
					else
						reagents.add_reagent("gin",5)
			else if(ID == 4)
				if(reagents.total_volume <= 30 & reagents.total_volume >= 15)
					reagents.add_reagent("cream",(30 - reagents.total_volume))
				else if (reagents.total_volume <= 15)
					reagents.add_reagent("cream",(15 - reagents.total_volume))
			else if(ID == 5)
				if(reagents.total_volume <= 30 & reagents.total_volume >= 15)
					reagents.add_reagent("water",(30 - reagents.total_volume))
				else if (reagents.total_volume <= 15)
					reagents.add_reagent("water",(15 - reagents.total_volume))

	else if (href_list["createcup"])
		var/name = generate_name(reagents.get_master_reagent_name())
		name += "Cup"
		var/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup/C
		C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup(src.loc)
		C.name = "[name]"
		C.pixel_x = rand(-8, 8)
		C.pixel_y = -16
		reagents.trans_to(C,30)
		reagents.clear_reagents()

	else if (href_list["createcone"])
		var/name = generate_name(reagents.get_master_reagent_name())
		name += "Cone"
		var/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone/C
		C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone(src.loc)
		C.name = "[name]"
		C.pixel_x = rand(-8, 8)
		C.pixel_y = -16
		reagents.trans_to(C,15)

	src.updateUsrDialog()
	return

/obj/machinery/icemachine/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/icemachine/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/icemachine/proc/show_toppings()
	var/dat = ""
	if(reagents.total_volume <= 30)
		dat += "<HR>"
		if(reagents.get_reagent_amount("sprinkles") == 0)
			dat += "<BR><A href='?src=\ref[src];synthcond=1;type=1'>Add Sprinkles (1 unit)</A><BR>"
		if((reagents.total_volume + 5) != 30)
			dat += "<A href='?src=\ref[src];synthcond=1;type=2'>Add Soda (5 units)</A><BR>"
			dat += "<A href='?src=\ref[src];synthcond=1;type=3'>Add Alcohol (5 units)</A><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=4'>Finish with Cream (Fills Cup)</A><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=5'>Finish with Water (Fills Cup)</A><BR>"
		dat += "<A href='?src=\ref[src];createcup=1'>Create Cup (Holds 30 Units)</A><BR>"
		if(reagents.total_volume <= 15)
			dat += "<A href='?src=\ref[src];createcone=1'>Create Cone (Holds 15 Units)</A><BR>"
		else
			dat += "The Machine has too many reagents to create a cone!<BR>"
	return dat

/obj/machinery/icemachine/proc/show_reagents(var/container)
	//1 = beaker / 2 = internal
	var/dat = ""
	if(container == 1)
		var/obj/item/weapon/reagent_containers/glass/A = beaker
		var/datum/reagents/R = A.reagents
		dat += "The container has:<BR>"
		for(var/datum/reagent/G in R.reagent_list)
			dat += "[G.volume] unit(s) of [G.name] | "
			dat += "<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A> "
			dat += "<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A> "
			dat += "<A href='?src=\ref[src];add=[G.id];amount=15'>(15)</A> "
			dat += "<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A>"
			dat += "<BR>"
	else if(container == 2)
		dat += "<BR>The Cream-Master has:<BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.volume] unit(s) of [N.name] | "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=15'>(15)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A>"
				dat += "<BR>"
		else
			dat += "<BR>Nothing loaded into the machine!<BR>"
	else
		dat += "<BR>SOMEONE ENTERED AN INVALID REAGENT CONTAINER; QUICK, BUG REPORT!<BR>"
	return dat

/obj/machinery/icemachine/attack_hand(mob/user as mob)
	if(..()) return
	user.set_machine(src)
	var/dat = ""
	if(!beaker)
		dat += "No container is loaded into the machine, external transfer offline.<BR>"
		dat += show_reagents(2)
		dat += show_toppings()
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/obj/item/weapon/reagent_containers/glass/A = beaker
		var/datum/reagents/R = A.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject container and end transfer.</A><BR>"
		if(!R.total_volume)
			dat += "Container is empty.<BR><HR>"
		else
			dat += show_reagents(1)
		dat += show_reagents(2)
		dat += show_toppings()
	user << browse("<TITLE>Cream-Master Deluxe</TITLE>Cream-Master Deluxe menu:<BR><BR>[dat]", "window=cream_master;size=700x600")
	onclose(user, "cream_master")
	return