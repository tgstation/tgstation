
/obj/machinery/power/rust_fuel_injector
	name = "Fuel Injector"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "injector0"

	density = 1
	anchored = 0
	var/locked = 0
	req_access = list(access_engine)

	var/obj/item/weapon/fuel_assembly/cur_assembly
	var/fuel_usage = 0.0001			//percentage of available fuel to use per cycle
	var/id_tag = "One"
	var/injecting = 0
	var/trying_to_swap_fuel = 0

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 500
	directwired = 0
	var/remote_access_enabled = 1
	var/cached_power_avail = 0
	var/emergency_insert_ready = 0

	machine_flags = WRENCHMOVE | FIXED2WORK | WELD_FIXED | EMAGGABLE

/obj/machinery/power/rust_fuel_injector/process()
	if(injecting)
		if(stat & (BROKEN|NOPOWER))
			StopInjecting()
		else
			Inject()

	cached_power_avail = avail()

/obj/machinery/power/rust_fuel_injector/wrenchAnchor(mob/user)
	if(injecting)
		user << "Turn off the [src] first."
		return -1
	return ..()

/obj/machinery/power/rust_fuel_injector/weldToFloor(var/obj/item/weapon/weldingtool/WT, mob/user)
	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		return 1
	return -1

/obj/machinery/power/rust_fuel_injector/emag(mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags the [src.name].","\red You short out the lock.")
		return 1
	return -1
/obj/machinery/power/rust_fuel_injector/attackby(obj/item/W, mob/user)
	if(..())
		return 1

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			user << "\red The lock seems to be broken"
			return
		if(src.allowed(user))
			src.locked = !src.locked
			user << "The controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."
		return

	if(istype(W, /obj/item/weapon/fuel_assembly) && !cur_assembly)
		if(emergency_insert_ready)
			cur_assembly = W
			user.drop_item()
			W.loc = src
			emergency_insert_ready = 0
			return

	..()
	return

/obj/machinery/power/rust_fuel_injector/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/power/rust_fuel_injector/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/power/rust_fuel_injector/interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine()
		user << browse(null, "window=fuel_injector")
		return
	if(get_dist(src, user) > 1 )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=fuel_injector")
			return

	var/dat = ""
	if (stat & NOPOWER || locked || state != 2)
		dat += "<i>The console is dark and nonresponsive.</i>"
	else

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\fuel_injector.dm:149: dat += "<B>Reactor Core Fuel Injector</B><hr>"
		dat += {"<B>Reactor Core Fuel Injector</B><hr>
			<b>Device ID tag:</b> [id_tag] <a href='?src=\ref[src];modify_tag=1'>\[Modify\]</a><br>
			<b>Status:</b> [injecting ? "<font color=green>Active</font> <a href='?src=\ref[src];toggle_injecting=1'>\[Disable\]</a>" : "<font color=blue>Standby</font> <a href='?src=\ref[src];toggle_injecting=1'>\[Enable\]</a>"]<br>
			<b>Fuel usage:</b> [fuel_usage*100]% <a href='?src=\ref[src];fuel_usage=1'>\[Modify\]</a><br>
			<b>Fuel assembly port:</b>
			<a href='?src=\ref[src];fuel_assembly=1'>\[[cur_assembly ? "Eject assembly to port" : "Draw assembly from port"]\]</a> "}
		// END AUTOFIX
		if(cur_assembly)
			dat += "<a href='?src=\ref[src];emergency_fuel_assembly=1'>\[Emergency eject\]</a><br>"
		else
			dat += "<a href='?src=\ref[src];emergency_fuel_assembly=1'>\[[emergency_insert_ready ? "Cancel emergency insertion" : "Emergency insert"]\]</a><br>"
		var/font_colour = "green"
		if(cached_power_avail < active_power_usage)
			font_colour = "red"
		else if(cached_power_avail < active_power_usage * 2)
			font_colour = "orange"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\fuel_injector.dm:164: dat += "<b>Power status:</b> <font color=[font_colour]>[active_power_usage]/[cached_power_avail] W</font><br>"
		dat += {"<b>Power status:</b> <font color=[font_colour]>[active_power_usage]/[cached_power_avail] W</font><br>
			<a href='?src=\ref[src];toggle_remote=1'>\[[remote_access_enabled ? "Disable remote access" : "Enable remote access"]\]</a><br>
			<hr>
			<A href='?src=\ref[src];refresh=1'>Refresh</A>
			<A href='?src=\ref[src];close=1'>Close</A><BR>"}
		// END AUTOFIX
	user << browse(dat, "window=fuel_injector;size=500x300")
	onclose(user, "fuel_injector")
	user.set_machine(src)

/obj/machinery/power/rust_fuel_injector/Topic(href, href_list)
	..()

	if( href_list["modify_tag"] )
		id_tag = input("Enter new ID tag", "Modifying ID tag") as text|null

	if( href_list["fuel_assembly"] )
		attempt_fuel_swap()

	if( href_list["emergency_fuel_assembly"] )
		if(cur_assembly)
			cur_assembly.loc = src.loc
			cur_assembly = null
			//irradiate!
		else
			emergency_insert_ready = !emergency_insert_ready

	if( href_list["toggle_injecting"] )
		if(injecting)
			StopInjecting()
		else
			BeginInjecting()

	if( href_list["toggle_remote"] )
		remote_access_enabled = !remote_access_enabled

	if( href_list["fuel_usage"] )
		var/new_usage = text2num(input("Enter new fuel usage (0.01% - 100%)", "Modifying fuel usage", fuel_usage * 100))
		if(!new_usage)
			usr << "\red That's not a valid number."
			return
		new_usage = max(new_usage, 0.01)
		new_usage = min(new_usage, 100)
		fuel_usage = new_usage / 100
		active_power_usage = 500 + 1000 * fuel_usage

	if( href_list["update_extern"] )
		var/obj/machinery/computer/rust_fuel_control/C = locate(href_list["update_extern"])
		if(C)
			C.updateDialog()

	if( href_list["close"] )
		usr << browse(null, "window=fuel_injector")
		usr.unset_machine()

	updateDialog()

/obj/machinery/power/rust_fuel_injector/proc/BeginInjecting()
	if(!injecting && cur_assembly)
		icon_state = "injector1"
		injecting = 1
		use_power = 1

/obj/machinery/power/rust_fuel_injector/proc/StopInjecting()
	if(injecting)
		injecting = 0
		icon_state = "injector0"
		use_power = 0

/obj/machinery/power/rust_fuel_injector/proc/Inject()
	if(!injecting)
		return
	if(cur_assembly)
		var/amount_left = 0
		for(var/reagent in cur_assembly.rod_quantities)
			//world << "checking [reagent]"
			if(cur_assembly.rod_quantities[reagent] > 0)
				//world << "	rods left: [cur_assembly.rod_quantities[reagent]]"
				var/amount = cur_assembly.rod_quantities[reagent] * fuel_usage
				var/numparticles = round(amount * 1000)
				if(numparticles < 1)
					numparticles = 1
				//world << "	amount: [amount]"
				//world << "	numparticles: [numparticles]"
				//

				var/obj/effect/accelerated_particle/A = new/obj/effect/accelerated_particle(get_turf(src), dir)
				A.particle_type = reagent
				A.additional_particles = numparticles - 1
				//A.target = target_field
				//
				cur_assembly.rod_quantities[reagent] -= amount
				amount_left += cur_assembly.rod_quantities[reagent]
		cur_assembly.percent_depleted = amount_left / 300
		flick("injector-emitting",src)
	else
		StopInjecting()

/obj/machinery/power/rust_fuel_injector/proc/attempt_fuel_swap()
	var/rev_dir = reverse_direction(dir)
	var/turf/mid = get_step(src, rev_dir)
	var/success = 0
	for(var/obj/machinery/rust_fuel_assembly_port/check_port in get_step(mid, rev_dir))
		if(cur_assembly)
			if(!check_port.cur_assembly)
				check_port.cur_assembly = cur_assembly
				cur_assembly.loc = check_port
				cur_assembly = null
				check_port.icon_state = "port1"
				success = 1
		else
			if(check_port.cur_assembly)
				cur_assembly = check_port.cur_assembly
				cur_assembly.loc = src
				check_port.cur_assembly = null
				check_port.icon_state = "port0"
				success = 1

		break
	if(success)
		src.visible_message("\blue \icon[src] a green light flashes on [src].")
		updateDialog()
	else
		src.visible_message("\red \icon[src] a red light flashes on [src].")

/obj/machinery/power/rust_fuel_injector/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, 90)

/obj/machinery/power/rust_fuel_injector/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, -90)