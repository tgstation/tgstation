var/const/max_assembly_amount = 300

/obj/machinery/rust_fuel_compressor
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel_compressor0"
	name = "Fuel Compressor"
	var/list/new_assembly_quantities
	var/compressed_matter = 0
	anchored = 1

	var/opened = 1 //0=closed, 1=opened
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

/obj/machinery/rust_fuel_compressor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/rcd_ammo))
		compressed_matter += 10
		del(W)
		return
	..()

/obj/machinery/rust_fuel_compressor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=fuelcomp")
			return

	var/t = "<B>Reactor Fuel Rod Compressor / Assembler</B><BR>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	if(locked)
		t += "Swipe your ID to unlock this console."
	else
		t += "Compressed matter in storage: [compressed_matter] <A href='?src=\ref[src];eject_matter=1'>\[Eject all\]</a>"
		t += "<A href='?src=\ref[src];activate=1'><b>Activate Fuel Synthesis</b></A><BR> (fuel assemblies require no more than [max_assembly_amount] rods).<br>"
		t += "<hr>"
		t += "- New fuel assembly constituents:- <br>"
		for(var/reagent in new_assembly_quantities)
			t += "	[reagent] rods: [new_assembly_quantities[reagent]] \[<A href='?src=\ref[src];change_reagent=[reagent]'>Modify</A>\]<br>"
	t += "<hr>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"

	user << browse(t, "window=fuelcomp;size=500x300")
	user.set_machine(src)

	//var/locked
	//var/coverlocked

/obj/machinery/rust_fuel_compressor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=fuelcomp")
		usr.machine = null

	if( href_list["eject_matter"] )
		while(compressed_matter > 10)
			new /obj/item/weapon/rcd_ammo(src.loc)
			compressed_matter -= 10
		src.visible_message("\blue \icon[src] [src] ejects some compressed matter units.")

	if( href_list["activate"] )
		//world << "\blue New fuel rod assembly"
		var/obj/item/weapon/fuel_assembly/F = new(src)
		var/fail = 0
		var/old_matter = compressed_matter
		for(var/reagent in new_assembly_quantities)
			var/req_matter = F.rod_quantities[reagent] / 10
			if(req_matter <= compressed_matter)
				F.rod_quantities[reagent] = new_assembly_quantities[reagent]
				compressed_matter -= req_matter
			else
				fail = 1
				break
			//world << "\blue	[reagent]: new_assembly_quantities[reagent]<br>"
		if(fail)
			del(F)
			compressed_matter = old_matter
			src.visible_message("\red \icon[src] [src] flashes red: \'Out of matter.\'")
		else
			F.loc = src.loc
			F.percent_depleted = 0

	if( href_list["change_reagent"] )
		var/cur_reagent = href_list["change_reagent"]
		var/avail_rods = 300
		for(var/rod in new_assembly_quantities)
			avail_rods -= new_assembly_quantities[rod]
		avail_rods += new_assembly_quantities[cur_reagent]
		avail_rods = max(avail_rods, 0)

		var/new_amount = min(input("Enter new [cur_reagent] rod amount (max [avail_rods])", "Fuel Assembly Rod Composition ([cur_reagent])") as num, avail_rods)
		new_assembly_quantities[cur_reagent] = new_amount

	updateDialog()
