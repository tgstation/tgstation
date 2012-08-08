
/obj/machinery/rust/fuel_injector
	name = "Fuel Injector"
	icon = 'fuel_injector.dmi'
	icon_state = "injector0"
	anchored = 1
	density = 1
	var/obj/machinery/rust/fuel_assembly_port/owned_assembly_port
	//var/list/stageone_assemblyports
	//var/list/stagetwo_assemblyports
	//var/list/scram_assemblyports
	var/obj/machinery/rust/reactor_vessel/Vessel = null
	var/rate = 10									//microseconds between each cycle
	var/fuel_usage = 0.0001							//percentage of available fuel to use per cycle
	var/on = 1
	var/remote_enabled = 1
	var/injecting = 0
	var/stage = "One"
	var/targetting_field = 0
	layer = 4
	//
	req_access = list(ACCESS_ENGINE)
	//
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300

	//fuel assembly should be embedded into the wall behind the injector
	New()
		..()
		name = "Stage [stage] Fuel Injector"
		//pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		//pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		/*
		stageone_assemblyports = new/list()
		stagetwo_assemblyports = new/list()
		scram_assemblyports = new/list()
		spawn(1)
			Vessel = locate() in range(6,src)
			for(var/obj/machinery/rust/fuel_assembly_port/S in range(6,src))
				switch(S.stage)
					if("One")
						stageone_assemblyports.Add(S)
					if("Two")
						stagetwo_assemblyports.Add(S)
					if("SCRAM")
						scram_assemblyports.Add(S)
		*/
		spawn(1)
			var/rev_dir = reverse_direction(dir)
			var/turf/mid = get_step(src, rev_dir)
			for(var/obj/machinery/rust/fuel_assembly_port/port in get_step(mid, rev_dir))
				owned_assembly_port = port
		//

	Topic(href, href_list)
		..()
		if( href_list["close"] )
			usr << browse(null, "window=fuel_injector")
			usr.machine = null
			return
		if( href_list["begin_injecting"] )
			BeginInjecting()
			updateDialog()
			return
		if( href_list["end_injecting"] )
			StopInjecting()
			updateDialog()
			return
		if( href_list["cyclerate"] )
			var/new_rate = text2num(input("Enter new injection rate (0.1 - 10 sec)", "Modifying injection rate", rate/10))
			if(!new_rate)
				usr << "\red That's not a valid number."
				return
			new_rate = min(new_rate,0.1)
			new_rate = max(new_rate,10)
			rate = new_rate * 10
			updateDialog()
			return
		if( href_list["fuel_usage"] )
			var/new_rate = text2num(input("Enter new fuel usage (1 - 100%)", "Modifying fuel usage", rate/10))
			if(!new_rate)
				usr << "\red That's not a valid number."
				return
			new_rate = min(new_rate,0.1)
			new_rate = max(new_rate,10)
			rate = new_rate * 10
			updateDialog()
			return

	attack_ai(mob/user)
		attack_hand(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		/*if(stat & (BROKEN|NOPOWER))
			return*/
		interact(user)

	proc
		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=fuel_injector")
					return
			var/t = "<B>Reactor Core Fuel Injector</B><hr>"
			t += "<b>Stage:</b> <font color=blue>[stage]</font><br>"
			t += "<b>Status:</b> [injecting ? "<font color=green>Active</font> <a href='?src=\ref[src];end_injecting=1'>\[Disable\]</a>" : "<font color=blue>Standby</font> <a href='?src=\ref[src];begin_injecting=1'>\[Enable\]</a>"]<br>"
			t += "<b>Interval (sec):</b> <font color=blue>[rate/10]</font> <a href='?src=\ref[src];cyclerate=1'>\[Modify\]</a><br>"
			t += "<b>Fuel usage:</b> [fuel_usage*100]% <a href='?src=\ref[src];fuel_usage=1'>\[Modify\]</a><br>"
			/*
			var/t = "<B>Reactor Core Fuel Control</B><BR>"
			t += "Current fuel injection stage: [active_stage]<br>"
			if(active_stage == "Cooling")
				//t += "<a href='?src=\ref[src];restart=1;'>Restart injection cycle</a><br>"
				t += "----<br>"
			else
				t += "<a href='?src=\ref[src];cooldown=1;'>Enter cooldown phase</a><br>"
			t += "Fuel depletion announcement: "
			t += "[announce_fueldepletion ? 		"<a href='?src=\ref[src];disable_fueldepletion=1'>Disable</a>" : "<b>Disabled</b>"] "
			t += "[announce_fueldepletion == 1 ? 	"<b>Announcing</b>" : "<a href='?src=\ref[src];announce_fueldepletion=1'>Announce</a>"] "
			t += "[announce_fueldepletion == 2 ? 	"<b>Broadcasting</b>" : "<a href='?src=\ref[src];broadcast_fueldepletion=1'>Broadcast</a>"]<br>"
			t += "Stage progression announcement: "
			t += "[announce_stageprogression ? 		"<a href='?src=\ref[src];disable_stageprogression=1'>Disable</a>" : "<b>Disabled</b>"] "
			t += "[announce_stageprogression == 1 ? 	"<b>Announcing</b>" : "<a href='?src=\ref[src];announce_stageprogression=1'>Announce</a>"] "
			t += "[announce_stageprogression == 2 ? 	"<b>Broadcasting</b>" : "<a href='?src=\ref[src];broadcast_stageprogression=1'>Broadcast</a>"] "
			t += "<hr>"
			t += "<table border=1><tr>"
			t += "<td><b>Injector Status</b></td>"
			t += "<td><b>Injection interval (sec)</b></td>"
			t += "<td><b>Assembly consumption per injection</b></td>"
			t += "<td><b>Fuel Assembly Port</b></td>"
			t += "<td><b>Assembly depletion percentage</b></td>"
			t += "</tr>"
			for(var/stage in fuel_injectors)
				var/list/cur_stage = fuel_injectors[stage]
				t += "<tr><td colspan=5><b>Fuel Injection Stage:</b> <font color=blue>[stage]</font> [active_stage == stage ? "<font color=green> (Currently active)</font>" : "<a href='?src=\ref[src];beginstage=[stage]'>Activate</a>"]</td></tr>"
				for(var/obj/machinery/rust/fuel_injector/Injector in cur_stage)
					t += "<tr>"
					t += "<td>[Injector.on && Injector.remote_enabled ? "<font color=green>Operational</font>" : "<font color=red>Unresponsive</font>"]</td>"
					t += "<td>[Injector.rate/10] <a href='?src=\ref[Injector];cyclerate=1'>Modify</a></td>"
					t += "<td>[Injector.fuel_usage*100]% <a href='?src=\ref[Injector];fuel_usage=1'>Modify</a></td>"
					t += "<td>[Injector.owned_assembly_port ? "[Injector.owned_assembly_port.cur_assembly ? "<font color=green>Loaded</font>": "<font color=blue>Empty</font>"]" : "<font color=red>Disconnected</font>" ]</td>"
					t += "<td>[Injector.owned_assembly_port && Injector.owned_assembly_port.cur_assembly ? "[100 - Injector.owned_assembly_port.cur_assembly.amount_depleted*100]%" : ""]</td>"
					t += "</tr>"
			t += "</table>"
			*/
			t += "<hr>"
			t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
			user << browse(t, "window=fuel_injector;size=500x800")
			user.machine = src

	proc/BeginInjecting()
		if(!injecting && owned_assembly_port && owned_assembly_port.cur_assembly)
			icon_state = "injector1"
			injecting = 1
			spawn(rate)
				Inject()
			return 1
		return 0

	proc/StopInjecting()
		if(injecting)
			injecting = 0
			icon_state = "injector0"
			return 1
		return 0

	proc/Inject()
		if(!injecting)
			return
		if(owned_assembly_port.cur_assembly)
			var/obj/machinery/rust/em_field/target_field
			if(targetting_field)
				for(var/obj/machinery/rust/em_field/field in range(15))
					target_field = field
			var/amount_left = 0
			for(var/reagent in owned_assembly_port.cur_assembly.rod_quantities)
				//world << "checking [reagent]"
				if(owned_assembly_port.cur_assembly.rod_quantities[reagent] > 0)
					//world << "	rods left: [owned_assembly_port.cur_assembly.rod_quantities[reagent]]"
					var/amount = owned_assembly_port.cur_assembly.rod_quantities[reagent] * fuel_usage
					var/numparticles = round(amount * 1000)
					if(numparticles < 1)
						numparticles = 1
					//world << "	amount: [amount]"
					//world << "	numparticles: [numparticles]"
					//
					var/obj/effect/accelerated_particle/particle = new/obj/effect/accelerated_particle(src.loc, src.dir)
					particle.particle_type = reagent
					particle.energy = 0
					particle.icon_state = "particle"
					particle.additional_particles = numparticles - 1
					particle.target = target_field
					//
					owned_assembly_port.cur_assembly.rod_quantities[reagent] -= amount
					amount_left += owned_assembly_port.cur_assembly.rod_quantities[reagent]
			owned_assembly_port.cur_assembly.percent_depleted = amount_left / 300
			flick("injector-emitting",src)
			use_power(fuel_usage * 10000 + 100)		//0.0001
			if(injecting)
				spawn(rate)
					Inject()
		else
			injecting = 0

	process()
		..()
		updateDialog()
		//
