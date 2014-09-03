//the em field is where the fun happens
/*
Deuterium-deuterium fusion : 40 x 10^7 K
Deuterium-tritium fusion: 4.5 x 10^7 K
*/

//#DEFINE MAX_STORED_ENERGY (held_plasma.toxins * held_plasma.toxins * SPECIFIC_HEAT_TOXIN)

/obj/effect/rust_em_field
	name = "EM Field"
	desc = "A coruscating, barely visible field of energy. It is shaped like a slightly flattened torus."
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "emfield_s1"
	//
	var/major_radius = 0	//longer radius in meters = field_strength * 0.21875, max = 8.75
	var/minor_radius = 0	//shorter radius in meters = field_strength * 0.2125, max = 8.625
	var/size = 1			//diameter in tiles
	var/volume_covered = 0	//atmospheric volume covered
	//
	var/obj/machinery/power/rust_core/owned_core
	var/list/dormant_reactant_quantities = new
	//luminosity = 1
	layer = 3.1
	//
	var/energy = 0
	var/mega_energy = 0
	var/radiation = 0
	var/frequency = 1
	var/field_strength = 0.01						//in teslas, max is 50T

	var/obj/machinery/rust/rad_source/radiator
	var/datum/gas_mixture/held_plasma = new
	var/particle_catchers[13]

	var/emp_overload = 0

/obj/effect/rust_em_field/New()
	..()
	//create radiator
	for(var/obj/machinery/rust/rad_source/rad in range(0))
		radiator = rad
	if(!radiator)
		radiator = new()

	//make sure there's a field generator
	for(var/obj/machinery/power/rust_core/core in loc)
		owned_core = core

	if(!owned_core)
		del(src)

	//create the gimmicky things to handle field collisions
	var/obj/effect/rust_particle_catcher/catcher
	//
	catcher = new (locate(src.x,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(1)
	particle_catchers.Add(catcher)
	//
	catcher = new (locate(src.x-1,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x+1,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y+1,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y-1,src.z))
	catcher.parent = src
	catcher.SetSize(3)
	particle_catchers.Add(catcher)
	//
	catcher = new (locate(src.x-2,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x+2,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y+2,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y-2,src.z))
	catcher.parent = src
	catcher.SetSize(5)
	particle_catchers.Add(catcher)
	//
	catcher = new (locate(src.x-3,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x+3,src.y,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y+3,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)
	catcher = new (locate(src.x,src.y-3,src.z))
	catcher.parent = src
	catcher.SetSize(7)
	particle_catchers.Add(catcher)

	//init values
	major_radius = field_strength * 0.21875// max = 8.75
	minor_radius = field_strength * 0.2125// max = 8.625
	volume_covered = PI * major_radius * minor_radius * 2.5 * 2.5 * 1000

	processing_objects.Add(src)

/obj/effect/rust_em_field/process()
	//make sure the field generator is still intact
	if(!owned_core)
		del(src)

	//handle radiation
	if(!radiator)
		radiator = new /obj/machinery/rust/rad_source()
	radiator.mega_energy += radiation
	radiator.source_alive++
	radiation = 0

	//update values
	var/transfer_ratio = field_strength / 50			//higher field strength will result in faster plasma aggregation
	major_radius = field_strength * 0.21875// max = 8.75m
	minor_radius = field_strength * 0.2125// max = 8.625m
	volume_covered = PI * major_radius * minor_radius * 2.5 * 2.5 * 2.5 * 7 * 7 * transfer_ratio	//one tile = 2.5m*2.5m*2.5m

	//add plasma from the surrounding environment
	var/datum/gas_mixture/environment = loc.return_air()

	//hack in some stuff to remove plasma from the air because SCIENCE
	//the amount of plasma pulled in each update is relative to the field strength, with 50T (max field strength) = 100% of area covered by the field
	//at minimum strength, 0.25% of the field volume is pulled in per update (?)
	//have a max of 1000 moles suspended
	if(held_plasma.toxins < transfer_ratio * 1000)
		var/moles_covered = environment.return_pressure()*volume_covered/(environment.temperature * R_IDEAL_GAS_EQUATION)
		//world << "\blue moles_covered: [moles_covered]"
		//
		var/datum/gas_mixture/gas_covered = environment.remove(moles_covered)
		var/datum/gas_mixture/plasma_captured = new /datum/gas_mixture()
		//
		plasma_captured.toxins = round(gas_covered.toxins * transfer_ratio)
		//world << "\blue[plasma_captured.toxins] moles of plasma captured"
		plasma_captured.temperature = gas_covered.temperature
		plasma_captured.update_values()
		//
		gas_covered.toxins -= plasma_captured.toxins
		gas_covered.update_values()
		//
		held_plasma.merge(plasma_captured)
		//
		environment.merge(gas_covered)

	//let the particles inside the field react
	React()

	//forcibly radiate any excess energy
	/*var/energy_max = transfer_ratio * 100000
	if(mega_energy > energy_max)
		var/energy_lost = rand( 1.5 * (mega_energy - energy_max), 2.5 * (mega_energy - energy_max) )
		mega_energy -= energy_lost
		radiation += energy_lost*/

	//change held plasma temp according to energy levels
	//SPECIFIC_HEAT_TOXIN
	if(mega_energy > 0 && held_plasma.toxins)
		var/heat_capacity = held_plasma.heat_capacity()//200 * number of plasma moles
		if(heat_capacity > 0.0003)	//formerly MINIMUM_HEAT_CAPACITY
			held_plasma.temperature = (heat_capacity + mega_energy * 35000)/heat_capacity

	//if there is too much plasma in the field, lose some
	/*if( held_plasma.toxins > (MOLES_CELLSTANDARD * 7) * (50 / field_strength) )
		LosePlasma()*/
	if(held_plasma.toxins > 1)
		//lose a random amount of plasma back into the air, increased by the field strength (want to switch this over to frequency eventually)
		var/loss_ratio = rand() * (0.05 + (0.05 * 50 / field_strength))
		//world << "lost [loss_ratio*100]% of held plasma"
		//
		var/datum/gas_mixture/plasma_lost = new
		plasma_lost.temperature = held_plasma.temperature
		//
		plasma_lost.toxins = held_plasma.toxins * loss_ratio
		//plasma_lost.update_values()
		held_plasma.toxins -= held_plasma.toxins * loss_ratio
		//held_plasma.update_values()
		//
		environment.merge(plasma_lost)
		radiation += loss_ratio * mega_energy * 0.1
		mega_energy -= loss_ratio * mega_energy * 0.1
	else
		held_plasma.toxins = 0
		//held_plasma.update_values()

	//handle some reactants formatting
	for(var/reactant in dormant_reactant_quantities)
		var/amount = dormant_reactant_quantities[reactant]
		if(amount < 1)
			dormant_reactant_quantities.Remove(reactant)
		else if(amount >= 1000000)
			var/radiate = rand(3 * amount / 4, amount / 4)
			dormant_reactant_quantities[reactant] -= radiate
			radiation += radiate

	return 1

/obj/effect/rust_em_field/proc/ChangeFieldStrength(var/new_strength)
	var/calc_size = 1
	emp_overload = 0
	if(new_strength <= 50)
		calc_size = 1
	else if(new_strength <= 200)
		calc_size = 3
	else if(new_strength <= 500)
		calc_size = 5
	else
		calc_size = 7
		if(new_strength > 900)
			emp_overload = 1
	//
	field_strength = new_strength
	change_size(calc_size)

/obj/effect/rust_em_field/proc/ChangeFieldFrequency(var/new_frequency)
	frequency = new_frequency

/obj/effect/rust_em_field/proc/AddEnergy(var/a_energy, var/a_mega_energy, var/a_frequency)
	var/energy_loss_ratio = 0
	if(a_frequency != src.frequency)
		energy_loss_ratio = 1 / abs(a_frequency - src.frequency)
	energy += a_energy - a_energy * energy_loss_ratio
	mega_energy += a_mega_energy - a_mega_energy * energy_loss_ratio

	while(energy > 100000)
		energy -= 100000
		mega_energy += 0.1

/obj/effect/rust_em_field/proc/AddParticles(var/name, var/quantity = 1)
	if(name in dormant_reactant_quantities)
		dormant_reactant_quantities[name] += quantity
	else if(name != "proton" && name != "electron" && name != "neutron")
		dormant_reactant_quantities.Add(name)
		dormant_reactant_quantities[name] = quantity

/obj/effect/rust_em_field/proc/RadiateAll(var/ratio_lost = 1)
	for(var/particle in dormant_reactant_quantities)
		radiation += dormant_reactant_quantities[particle]
		dormant_reactant_quantities.Remove(particle)
	radiation += mega_energy
	mega_energy = 0

	//lose all held plasma back into the air
	var/datum/gas_mixture/environment = loc.return_air()
	environment.merge(held_plasma)

/obj/effect/rust_em_field/proc/change_size(var/newsize = 1)
	//
	var/changed = 0
	switch(newsize)
		if(1)
			size = 1
			icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
			icon_state = "emfield_s1"
			pixel_x = 0
			pixel_y = 0
			//
			changed = 1
		if(3)
			size = 3
			icon = 'icons/effects/96x96.dmi'
			icon_state = "emfield_s3"
			pixel_x = -32
			pixel_y = -32
			//
			changed = 3
		if(5)
			size = 5
			icon = 'icons/effects/160x160.dmi'
			icon_state = "emfield_s5"
			pixel_x = -64
			pixel_y = -64
			//
			changed = 5
		if(7)
			size = 7
			icon = 'icons/effects/224x224.dmi'
			icon_state = "emfield_s7"
			pixel_x = -96
			pixel_y = -96
			//
			changed = 7

	for(var/obj/effect/rust_particle_catcher/catcher in particle_catchers)
		catcher.UpdateSize()
	return changed

//the !!fun!! part
/obj/effect/rust_em_field/proc/React()
	//loop through the reactants in random order
	var/list/reactants_reacting_pool = dormant_reactant_quantities.Copy()
	/*
	for(var/reagent in dormant_reactant_quantities)
		world << "	before: [reagent]: [dormant_reactant_quantities[reagent]]"
		*/

	//cant have any reactions if there aren't any reactants present
	if(reactants_reacting_pool.len)
		//determine a random amount to actually react this cycle, and remove it from the standard pool
		//this is a hack, and quite nonrealistic :(
		for(var/reactant in reactants_reacting_pool)
			reactants_reacting_pool[reactant] = rand(0,reactants_reacting_pool[reactant])
			dormant_reactant_quantities[reactant] -= reactants_reacting_pool[reactant]
			if(!reactants_reacting_pool[reactant])
				reactants_reacting_pool -= reactant

		//loop through all the reacting reagents, picking out random reactions for them
		var/list/produced_reactants = new/list
		var/list/primary_reactant_pool = reactants_reacting_pool.Copy()
		while(primary_reactant_pool.len)
			//pick one of the unprocessed reacting reagents randomly
			var/cur_primary_reactant = pick(primary_reactant_pool)
			primary_reactant_pool.Remove(cur_primary_reactant)
			//world << "\blue	primary reactant chosen: [cur_primary_reactant]"

			//grab all the possible reactants to have a reaction with
			var/list/possible_secondary_reactants = reactants_reacting_pool.Copy()
			//if there is only one of a particular reactant, then it can not react with itself so remove it
			possible_secondary_reactants[cur_primary_reactant] -= 1
			if(possible_secondary_reactants[cur_primary_reactant] < 1)
				possible_secondary_reactants.Remove(cur_primary_reactant)

			//loop through and work out all the possible reactions
			var/list/possible_reactions = new/list
			for(var/cur_secondary_reactant in possible_secondary_reactants)
				if(possible_secondary_reactants[cur_secondary_reactant] < 1)
					continue
				var/datum/fusion_reaction/cur_reaction = get_fusion_reaction(cur_primary_reactant, cur_secondary_reactant)
				if(cur_reaction)
					//world << "\blue	secondary reactant: [cur_secondary_reactant], [reaction_products.len]"
					possible_reactions.Add(cur_reaction)

			//if there are no possible reactions here, abandon this primary reactant and move on
			if(!possible_reactions.len)
				//world << "\blue	no reactions"
				continue

			//split up the reacting atoms between the possible reactions
			while(possible_reactions.len)
				//pick a random substance to react with
				var/datum/fusion_reaction/cur_reaction = pick(possible_reactions)
				possible_reactions.Remove(cur_reaction)

				//set the randmax to be the lower of the two involved reactants
				var/max_num_reactants = reactants_reacting_pool[cur_reaction.primary_reactant] > reactants_reacting_pool[cur_reaction.secondary_reactant] ? \
				reactants_reacting_pool[cur_reaction.secondary_reactant] : reactants_reacting_pool[cur_reaction.primary_reactant]
				if(max_num_reactants < 1)
					continue

				//make sure we have enough energy
				if(mega_energy < max_num_reactants * cur_reaction.energy_consumption)
					max_num_reactants = round(mega_energy / cur_reaction.energy_consumption)
					if(max_num_reactants < 1)
						continue

				//randomly determined amount to react
				var/amount_reacting = rand(1, max_num_reactants)

				//removing the reacting substances from the list of substances that are primed to react this cycle
				//if there aren't enough of that substance (there should be) then modify the reactant amounts accordingly
				if( reactants_reacting_pool[cur_reaction.primary_reactant] - amount_reacting >= 0 )
					reactants_reacting_pool[cur_reaction.primary_reactant] -= amount_reacting
				else
					amount_reacting = reactants_reacting_pool[cur_reaction.primary_reactant]
					reactants_reacting_pool[cur_reaction.primary_reactant] = 0
				//same again for secondary reactant
				if( reactants_reacting_pool[cur_reaction.secondary_reactant] - amount_reacting >= 0 )
					reactants_reacting_pool[cur_reaction.secondary_reactant] -= amount_reacting
				else
					reactants_reacting_pool[cur_reaction.primary_reactant] += amount_reacting - reactants_reacting_pool[cur_reaction.primary_reactant]
					amount_reacting = reactants_reacting_pool[cur_reaction.secondary_reactant]
					reactants_reacting_pool[cur_reaction.secondary_reactant] = 0

				//remove the consumed energy
				mega_energy -= max_num_reactants * cur_reaction.energy_consumption

				//add any produced energy
				mega_energy += max_num_reactants * cur_reaction.energy_production

				//add any produced radiation
				radiation += max_num_reactants * cur_reaction.radiation

				//create the reaction products
				for(var/reactant in cur_reaction.products)
					var/success = 0
					for(var/check_reactant in produced_reactants)
						if(check_reactant == reactant)
							produced_reactants[reactant] += cur_reaction.products[reactant] * amount_reacting
							success = 1
							break
					if(!success)
						produced_reactants[reactant] = cur_reaction.products[reactant] * amount_reacting

				//this reaction is done, and can't be repeated this sub-cycle
				possible_reactions.Remove(cur_reaction.secondary_reactant)

		//
		/*if(new_radiation)
			if(!radiating)
				radiating = 1
				PeriodicRadiate()*/

		//loop through the newly produced reactants and add them to the pool
		//var/list/neutronic_radiation = new
		//var/list/protonic_radiation = new
		for(var/reactant in produced_reactants)
			AddParticles(reactant, produced_reactants[reactant])
			//world << "produced: [reactant], [dormant_reactant_quantities[reactant]]"

		//check whether there are reactants left, and add them back to the pool
		for(var/reactant in reactants_reacting_pool)
			AddParticles(reactant, reactants_reacting_pool[reactant])
			//world << "retained: [reactant], [reactants_reacting_pool[reactant]]"

/obj/effect/rust_em_field/Destroy()
	//radiate everything in one giant burst
	for(var/obj/effect/rust_particle_catcher/catcher in particle_catchers)
		del (catcher)
	RadiateAll()

	processing_objects.Remove(src)
	..()
