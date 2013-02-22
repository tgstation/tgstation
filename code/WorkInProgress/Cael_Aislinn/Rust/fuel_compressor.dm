var/const/max_assembly_amount = 300

/obj/machinery/rust_fuel_compressor
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel_compressor0"
	name = "Fuel Compressor"
	var/list/new_assembly_quantities
	var/compressed_matter = 100
	anchored = 1

	var/opened = 1 //0=closed, 1=opened
	var/coverlocked = 0
	var/locked = 0
	var/has_electronics = 0 // 0 - none, bit 1 - circuitboard, bit 2 - wires

/obj/machinery/rust_fuel_compressor/New()
	new_assembly_quantities = new/list
	spawn(0)
		new_assembly_quantities["Deuterium"] = 200
		new_assembly_quantities["Tritium"] = 100
		//
		new_assembly_quantities["Helium-3"] = 0
		new_assembly_quantities["Lithium-6"] = 0
		new_assembly_quantities["Silver"] = 0

/obj/machinery/rust_fuel_compressor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/rust_fuel_compressor/attack_hand(mob/user)
	add_fingerprint(user)
	/*if(stat & (BROKEN|NOPOWER))
		return*/
	interact(user)

/*/obj/machinery/rust_fuel_compressor/power_change()
	if(stat & BROKEN)
		icon_state = "broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER*/

/obj/machinery/rust_fuel_compressor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=fuelcomp")
		usr.machine = null
		return
	//
	for(var/reagent in new_assembly_quantities)
		if(href_list[reagent])
			var/new_amount = text2num(input("Enter new rod amount", "Fuel Assembly Rod Composition ([reagent])", new_assembly_quantities[reagent]) as text|null)
			if(!new_amount)
				usr << "\red That's not a valid number."
				return
			var/sum_reactants = new_amount - new_assembly_quantities[reagent]
			for(var/rod in new_assembly_quantities)
				sum_reactants += new_assembly_quantities[rod]
			if(sum_reactants > max_assembly_amount)
				usr << "\red You have entered too many rods."
			else
				new_assembly_quantities[reagent] = new_amount
			updateDialog()
			return
	if( href_list["activate"] )
		var/obj/item/weapon/fuel_assembly/F = new(src)
		//world << "\blue New fuel rod assembly"
		for(var/reagent in new_assembly_quantities)
			F.rod_quantities[reagent] = new_assembly_quantities[reagent]
			//world << "\blue	[reagent]: new_assembly_quantities[reagent]<br>"
		F.loc = src.loc
		F.percent_depleted = 0
		return

/obj/machinery/rust_fuel_compressor/interact(mob/user)
	/*if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=fuelcomp")
			return*/
	var/t = "<B>Reactor Fuel Rod Compressor / Assembler</B><BR>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	t += "<A href='?src=\ref[src];activate=1'><b>Activate Fuel Synthesis</b></A><BR> (fuel assemblies require no more than [max_assembly_amount] rods).<br>"
	t += "<hr>"
	t += "- New fuel assembly constituents:- <br>"
	for(var/reagent in new_assembly_quantities)
		t += "	[reagent] rods: [new_assembly_quantities[reagent]] \[<A href='?src=\ref[src];reagent=1'>Modify</A>\]<br>"
	t += "<hr>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	user << browse(t, "window=fuelcomp;size=500x300")
	user.machine = src
