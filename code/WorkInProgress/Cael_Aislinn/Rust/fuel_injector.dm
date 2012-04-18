
/obj/machinery/rust/fuel_injector
	name = "Fuel Injector"
	icon = 'fuel_injector.dmi'
	icon_state = "injector-on"
	anchored = 1
	density = 0
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

	//transfer fuel wirelessly for now :P
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

	proc/BeginInjecting()
		if(!injecting)
			injecting = 1
			spawn(rate)
				Inject()
			return 1
		return 0

	proc/StopInjecting()
		if(injecting)
			injecting = 0
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
					//world << "	rods left: [owned_assembly_port.cur_assembly.rod_quantities[reagent]]]
					var/amount = owned_assembly_port.cur_assembly.rod_quantities[reagent] * fuel_usage
					var/numparticles = round(amount * 1000)
					if(numparticles < 1)
						numparticles = 1
					//world << "	amount: [amount]"
					//world << "	numparticles: [numparticles]"
					for(var/i=0, i<numparticles, i++)
						var/obj/effect/accelerated_particle/particle = new(src.loc, src.dir)
						particle.particle_type = reagent
						particle.energy = 0
						particle.icon_state = "particle_single"
						particle.pixel_x = rand(-10,10)
						particle.pixel_y = rand(-10,10)
						var/extra_particles = round(rand(0, numparticles - i - 1))
						//world << "[extra_particles + 1] [reagent] particles"
						particle.additional_particles = extra_particles
						particle.target = target_field
						i += extra_particles
						//world << "[reagent] particle injected"
					owned_assembly_port.cur_assembly.rod_quantities[reagent] -= amount
					amount_left += owned_assembly_port.cur_assembly.rod_quantities[reagent]
			owned_assembly_port.cur_assembly.amount_depleted = amount_left / 300
			if(injecting)
				spawn(rate)
					Inject()
		else
			injecting = 0

	process()
		..()
		//
