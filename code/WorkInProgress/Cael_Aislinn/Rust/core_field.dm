//the em field is where the fun happens
/*
Deuterium-deuterium fusion : 40 x 10^7 K
Deuterium-tritium fusion: 4.5 x 10^7 K
*/

//#DEFINE MAX_STORED_ENERGY (held_plasma.toxins * held_plasma.toxins * SPECIFIC_HEAT_TOXIN)

/obj/machinery/rust/em_field
	name = "EM Field"
	desc = "A coruscating, barely visible field of energy. It is shaped like a slightly flattened torus."
	icon = 'emfield.dmi'
	icon_state = "emfield_s1"
	density = 0
	layer = 3.1
	anchored = 1
	//
	var/major_radius = 0	//longer radius in meters = field_strength * 0.21875, max = 8.75
	var/minor_radius = 0	//shorter radius in meters = field_strength * 0.2125, max = 8.625
	var/size = 1			//diameter in tiles
	var/volume_covered = 0	//atmospheric volume covered
	//
	var/obj/machinery/rust/core/owned_core
	var/list/dormant_reactant_quantities = new
	luminosity = 1
	//
	var/energy = 0
	var/mega_energy = 0
	var/radiation = 0
	var/frequency = 1
	var/field_strength = 0.01						//in teslas, max is 50T

	var/obj/machinery/rust/rad_source/radiator
	var/datum/gas_mixture/held_plasma = new
	var/particle_catchers[13]

	New()
		..()
		//create radiator
		for(var/obj/machinery/rust/rad_source/rad in range(0))
			radiator = rad
		if(!radiator)
			radiator = new()

		//make sure there's a field generator
		for(var/obj/machinery/rust/core/em_core in loc)
			owned_core = em_core

		if(!owned_core)
			del(src)
		if(!owned_core.on)
			del(src)

		//create the gimmicky things to handle field collisions
		var/obj/machinery/rust/particle_catcher/catcher
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

	process()
		..()
		//make sure the field generator is still intact
		if(!owned_core)
			del(src)
		if(!owned_core.on)
			del(src)

		//handle radiation
		if(!radiator)
			radiator = new /obj/machinery/rust/rad_source()
		radiator.mega_energy += radiation
		radiator.source_alive++
		radiation = 0

		//update values
		var/transfer_ratio = 50 / field_strength
		major_radius = field_strength * 0.21875// max = 8.75
		minor_radius = field_strength * 0.2125// max = 8.625
		volume_covered = PI * major_radius * minor_radius * 2.5 * 2.5 * 2.5 * 7 * 7 * transfer_ratio

		//add plasma from the surrounding environment
		var/datum/gas_mixture/environment = loc.return_air()

/*
		if(air_contents.temperature > 0)
			var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			loc.assume_air(removed)
*/

		//we're going to hack in some stuff to remove plasma from the air because QUANTUM PHYSICS
		//the amount of plasma pulled in each update is relative to the field strength, with 50T (max field strength) = 100% of area covered by the field
		//at minimum strength, 0.25% of the field volume is pulled in per update (?)
		//have a max of 1000 moles suspended
		if(held_plasma.toxins < transfer_ratio * 1000)
			var/moles_covered = environment.return_pressure()*volume_covered/(environment.temperature * R_IDEAL_GAS_EQUATION)
			//
			var/datum/gas_mixture/gas_covered = environment.remove(moles_covered)
			var/datum/gas_mixture/plasma_captured = new /datum/gas_mixture()
			//
			plasma_captured.toxins = round(gas_covered.toxins * transfer_ratio)
			plasma_captured.temperature = gas_covered.temperature
			gas_covered.toxins -= plasma_captured.toxins
			held_plasma.merge(plasma_captured)
			//
			environment.merge(gas_covered)

		//let the particles inside the field react
		React()

		//forcibly radiate any excess energy
		var/energy_max = transfer_ratio * 100000
		if(mega_energy > energy_max)
			var/energy_lost = rand( 1.5 * (mega_energy - energy_max), 2.5 * (mega_energy - energy_max) )
			mega_energy -= energy_lost
			radiation += energy_lost

		//change held plasma temp according to energy levels
		//SPECIFIC_HEAT_TOXIN
		if(mega_energy > 0 && held_plasma.toxins)
			var/heat_capacity = held_plasma.heat_capacity()//200 * number of plasma moles
			if(heat_capacity > MINIMUM_HEAT_CAPACITY)
				held_plasma.temperature = (heat_capacity + mega_energy * 35000)/heat_capacity

		//if there is too much plasma in the field, lose some
		/*if( held_plasma.toxins > (MOLES_CELLSTANDARD * 7) * (50 / field_strength) )
			LosePlasma()*/
		LosePlasma()

		//handle some reactants formatting
		//helium-4 has no use at the moment, but a buttload of it is produced
		if(dormant_reactant_quantities["Helium-4"] > 1000)
			dormant_reactant_quantities["Helium-4"] = rand(0,dormant_reactant_quantities["Helium-4"])
		for(var/reactant in dormant_reactant_quantities)
			if(!dormant_reactant_quantities[reactant])
				dormant_reactant_quantities.Remove(reactant)

		return 1

	Del()
		..()
		//radiate everything in one giant burst
		for(var/obj/machinery/rust/particle_catcher/catcher in particle_catchers)
			del (catcher)
		RadiateAll()

	proc/ChangeFieldStrength(var/new_strength)
		field_strength = new_strength
		var/newsize
		if(new_strength <= 5)
			newsize = 1
		else if(new_strength <= 12)
			newsize = 3
		else if(new_strength <= 25)
			newsize = 5
		else if(new_strength <= 50)
			newsize = 7
		//
		change_size(newsize)

	proc/AddEnergy(var/a_energy, var/a_mega_energy, var/a_frequency)
		var/energy_loss_ratio = abs(a_frequency - src.frequency) / 1e9
		energy += a_energy - a_energy * a_frequency
		mega_energy += a_mega_energy - a_mega_energy * energy_loss_ratio

	proc/AddParticles(var/name, var/quantity = 1)
		if(name in dormant_reactant_quantities)
			dormant_reactant_quantities[name] += quantity
		else if(name != "proton" && name != "electron" && name != "neutron")
			dormant_reactant_quantities.Add(name)
			dormant_reactant_quantities[name] = quantity

	proc/RadiateAll(var/ratio_lost = 1)
		for(var/particle in dormant_reactant_quantities)
			radiation += dormant_reactant_quantities[particle]
			dormant_reactant_quantities.Remove(particle)
		radiation += mega_energy
		mega_energy = 0

		//lose all held plasma back into the air
		var/datum/gas_mixture/environment = loc.return_air()
		environment.merge(held_plasma)

	proc/change_size(var/newsize = 1)
		//
		var/changed = 0
		switch(newsize)
			if(1)
				size = 1
				icon = 'emfield.dmi'
				icon_state = "emfield_s1"
				//
				src.loc = get_turf(owned_core)
				//
				changed = 1
			if(3)
				size = 3
				icon = '96x96.dmi'
				icon_state = "emfield_s3"
				//
				var/turf/newloc = get_turf(owned_core)
				newloc = get_step(newloc, SOUTHWEST)
				src.loc = newloc
				//
				changed = 3
			if(5)
				size = 5
				icon = '160x160.dmi'
				icon_state = "emfield_s5"
				//
				var/turf/newloc = get_turf(owned_core)
				newloc = get_step(newloc, SOUTHWEST)
				newloc = get_step(newloc, SOUTHWEST)
				src.loc = newloc
				//
				changed = 5
			if(7)
				size = 7
				icon = '224x224.dmi'
				icon_state = "emfield_s7"
				//
				var/turf/newloc = get_turf(owned_core)
				newloc = get_step(newloc, SOUTHWEST)
				newloc = get_step(newloc, SOUTHWEST)
				newloc = get_step(newloc, SOUTHWEST)
				src.loc = newloc
				//
				changed = 7

		for(var/obj/machinery/rust/particle_catcher/catcher in particle_catchers)
			catcher.UpdateSize()
		return changed

	proc/LosePlasma()
		if(held_plasma.toxins > 1)
			//lose a random amount of plasma back into the air, increased by the field strength (want to switch this over to frequency eventually)
			var/datum/gas_mixture/environment = loc.return_air()
			var/loss_ratio = rand() * (0.05 + (0.05 * 50 / field_strength))
			//world << "lost [loss_ratio*100]% of held plasma"
			//
			var/datum/gas_mixture/plasma_lost = new
			plasma_lost.temperature = held_plasma.temperature
			//
			plasma_lost.toxins = held_plasma.toxins * loss_ratio
			held_plasma.toxins -= held_plasma.toxins * loss_ratio
			//
			environment.merge(plasma_lost)
			radiation += loss_ratio * mega_energy * 0.1
			mega_energy -= loss_ratio * mega_energy * 0.1
			return 1
		else
			held_plasma.toxins = 0
			return 0

	//the !!fun!! part
	//reactions have to be individually hardcoded, see AttemptReaction() below this
	proc/React()
		//world << "React()"
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

			var/list/produced_reactants = new/list
			//loop through all the reacting reagents, picking out random reactions for them
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
				var/list/possible_reactions = new/list

				//loop through and work out all the possible reactions
				while(possible_secondary_reactants.len)
					var/cur_secondary_reactant = pick(possible_secondary_reactants)
					if(possible_secondary_reactants[cur_secondary_reactant] < 1)
						possible_secondary_reactants.Remove(cur_secondary_reactant)
						continue
					possible_secondary_reactants.Remove(cur_secondary_reactant)
					var/list/reaction_products = AttemptReaction(cur_primary_reactant, cur_secondary_reactant)
					if(reaction_products.len)
						//world << "\blue	secondary reactant: [cur_secondary_reactant], [reaction_products.len]"
						possible_reactions[cur_secondary_reactant] = reaction_products
				//if there are no possible reactions here, abandon this primary reactant and move on
				if(!possible_reactions.len)
					//world << "\blue	no reactions"
					continue

				//split up the reacting atoms between the possible reactions
				//the problem is in this while statement below
				while(possible_reactions.len)
					//pick another substance to react with
					var/cur_secondary_reactant = pick(possible_reactions)
					if(!reactants_reacting_pool[cur_secondary_reactant])
						possible_reactions.Remove(cur_secondary_reactant)
						continue
					var/list/cur_reaction_products = possible_reactions[cur_secondary_reactant]

					//set the randmax to be the lower of the two involved reactants
					var/max_num_reactants = reactants_reacting_pool[cur_primary_reactant] > reactants_reacting_pool[cur_secondary_reactant] ? reactants_reacting_pool[cur_secondary_reactant] : reactants_reacting_pool[cur_primary_reactant]

					//make sure we have enough energy
					if( mega_energy < max_num_reactants*cur_reaction_products["consumption"])
						max_num_reactants = round(mega_energy / cur_reaction_products["consumption"])

					//randomly determined amount to react
					var/amount_reacting = rand(1, max_num_reactants)

					//removing the reacting substances from the list of substances that are primed to react this cycle
					//if there aren't enough of that substance (there should be) then modify the reactant amounts accordingly
					if( reactants_reacting_pool[cur_primary_reactant] - amount_reacting > -1 )
						reactants_reacting_pool[cur_primary_reactant] -= amount_reacting
					else
						amount_reacting = reactants_reacting_pool[cur_primary_reactant]
						reactants_reacting_pool[cur_primary_reactant] = 0
					//
					if( reactants_reacting_pool[cur_secondary_reactant] - amount_reacting > -1 )
						reactants_reacting_pool[cur_secondary_reactant] -= amount_reacting
					else
						reactants_reacting_pool[cur_primary_reactant] += amount_reacting - reactants_reacting_pool[cur_primary_reactant]
						amount_reacting = reactants_reacting_pool[cur_secondary_reactant]
						reactants_reacting_pool[cur_secondary_reactant] = 0

					//remove the consumed energy
					if(cur_reaction_products["consumption"])
						mega_energy -= max_num_reactants * cur_reaction_products["consumption"]
						cur_reaction_products.Remove("consumption")

					//grab any radiation and put it separate
					//var/new_radiation = 0
					if("production" in cur_reaction_products)
						mega_energy += max_num_reactants * cur_reaction_products["production"]
						cur_reaction_products.Remove("production")
						/*for(var/i=0, i<dormant_reactant_quantities["proton_quantity"], i++)
							radiation.Add("proton")
							radiation_charge.Add(dormant_reactant_quantities["proton_charge"])
						dormant_reactant_quantities.Remove("proton_quantity")
						dormant_reactant_quantities.Remove("proton_charge")
						new_radiation = 1*/
					//
					if("radiation" in cur_reaction_products)
						radiation += max_num_reactants * cur_reaction_products["radiation"]
						cur_reaction_products.Remove("radiation")
						/*for(var/i=0, i<dormant_reactant_quantities["neutron_quantity"], i++)
							radiation.Add("neutron")
							radiation_charge.Add(dormant_reactant_quantities["neutron_charge"])
						dormant_reactant_quantities.Remove("neutron_quantity")
						dormant_reactant_quantities.Remove("neutron_charge")
						new_radiation = 1*/

					//create the reaction products
					for(var/reactant in cur_reaction_products)
						if(produced_reactants[reactant])
							produced_reactants[reactant] += cur_reaction_products[reactant] * amount_reacting
						else
							produced_reactants[reactant] = cur_reaction_products[reactant] * amount_reacting

					//this reaction is done, and can't be repeated this sub-cycle
					possible_reactions.Remove(cur_secondary_reactant)

			//
			/*if(new_radiation)
				if(!radiating)
					radiating = 1
					PeriodicRadiate()*/

			//loop through the newly produced reactants and add them to the pool
			//var/list/neutronic_radiation = new
			//var/list/protonic_radiation = new
			for(var/reactant in produced_reactants)
				AddParticles(reactant, dormant_reactant_quantities[reactant])
				//world << "produced: [reactant], [dormant_reactant_quantities[reactant]]"

			//check whether there are reactants left, and add them back to the pool
			for(var/reactant in reactants_reacting_pool)
				AddParticles(reactant, reactants_reacting_pool[reactant])
				//world << "retained: [reactant], [reactants_reacting_pool[reactant]]"

//default fuel assembly quantities
/*
//new_assembly_quantities["Helium-3"] = 0
//new_assembly_quantities["Deuterium"] = 200
//new_assembly_quantities["Tritium"] = 100
//new_assembly_quantities["Lithium-6"] = 0
//new_assembly_quantities["Silver"] = 0
*/

//reactions involving D-T (hydrogen) need 0.1 MeV of core energy
//reactions involving helium require 0.4 MeV of energy
//reactions involving lithium require 0.6 MeV of energy
//reactions involving boron require 1 MeV of energy
//returns a list of products, or an empty list if no reaction possible
	proc/AttemptReaction(var/reactant_one, var/reactant_two)
		//any charge on the atomic reactants / protons produced is abstracted away to enter the core energy pool straightaway
		//atomic products remain in the core and produce more reactions next cycle
		//any charged neutrons escape as radiation
		var/check = 1
		recheck_reactions:
		var/list/products = new/list
		switch(reactant_one)
			if("Tritium")
				switch(reactant_two)
					if("Tritium")
						if(mega_energy > 0.1)
							products["Helium-4"] = 1
							//
							products["production"] = 11.3
							products["radiation"] = 1
							/*products["photon"] = 11.3
							//
							products["neutron_quantity"] = 1
							products["neutron_charge"] = 0*/
							//
							mega_energy -= 0.1
					if("Deuterium")
						if(mega_energy > 0.1)
							products["Helium-4"] = 1
							//
							products["production"] = 3.5
							products["radiation"] = 14.1
							/*products["photon"] = 3.5
							//
							products["neutron_quantity"] = 1
							products["neutron_charge"] = 14.1
							//
							products["consumption"] = 0.1*/
					if("Helium-3")
						if(mega_energy > 0.4)
							if(prob(51))
								products["Helium-4"] = 1
								//
								products["production"] = 13.1
								products["radiation"] = 1
								/*products["photon"] = 12.1
								//
								products["proton_quantity"] = 1
								products["proton_charge"] = 0
								//
								products["neutron_quantity"] = 1
								products["neutron_charge"] = 0*/
							else if (prob(43))
								products["Helium-4"] = 1
								products["Deuterium"] = 1
								//
								products["production"] = 14.3
								/*products["photon"] = 4.8 + 9.5//14.3
								*/
							else
								products["Helium-4"] = 1
								products["production"] = 2.4
								products["radiation"] = 11.9
								/*products["photon"] = 0.5//12.4
								//
								products["proton_quantity"] = 1
								products["proton_charge"] = 1.9
								//
								products["neutron_quantity"] = 1
								products["neutron_charge"] = 11.9*/
							//
							products["consumption"] = 0.4
			if("Deuterium")
				switch(reactant_two)
					if("Deuterium")
						if(mega_energy > 0.1)
							if(prob(50))
								products["Tritium"] = 1
								//
								products["production"] = 4.03
								/*products["photon"] = 1.01
								//
								products["proton_quantity"] = 1
								products["proton_charge"] = 3.02*/
							else
								products["Helium-3"] = 1
								//
								products["production"] = 0.82
								products["radiation"] = 2.45
								/*products["photon"] = 0.82
								//
								products["neutron_quantity"] = 1
								products["neutron_charge"] = 2.45*/
							//
							products["consumption"] = 0.1
					if("Helium-3")
						if(mega_energy > 0.4)
							products["Helium-4"] = 1
							//
							products["production"] = 18.3
							/*products["photon"] = 3.6
							//
							products["proton_quantity"] = 1
							products["proton_charge"] = 14.7*/
							//
							products["consumption"] = 0.4
					if("Lithium-6")
						if(mega_energy > 0.6)
							if(prob(25))
								products["Helium-4"] = 2
								products["production"] = 1
								/*products["photon"] = 22.4*/
							else if(prob(33))
								products["Helium-3"] = 1
								products["Helium-4"] = 1
								//
								products["radiation"] = 1
								/*products["neutron_quantity"] = 1
								products["neutron_charge"] = 0*/
							else if(prob(50))
								products["Lithium-7"] = 1
								//
								products["production"] = 1
								/*products["proton_quantity"] = 1
								products["proton_charge"] = 0*/
							else
								products["Beryllium-7"] = 1
								products["production"] = 3.4
								products["radiation"] = 1
								/*products["photon"] = 3.4
								//
								products["neutron_quantity"] = 1
								products["neutron_charge"] = 0*/
							//
							products["consumption"] = 0.6
			if("Helium-3")
				switch(reactant_two)
					if("Helium-3")
						if(mega_energy > 0.4)
							products["Helium-4"] = 1
							products["production"] = 14.9
							/*products["photon"] = 12.9
							//
							products["proton_quantity"] = 2
							products["proton_charge"] = 0*/
							//
							products["consumption"] = 0.4
					if("Lithium-6")
						if(mega_energy > 0.6)
							products["Helium-4"] = 2
							//
							products["production"] = 17.9
							/*products["photon"] = 16.9
							//
							products["proton_quantity"] = 1
							products["proton_charge"] = 0*/
							//
							products["consumption"] = 0.6
			/*
			if("proton")
				switch(reactant_two)
					if("Lithium-6")
						if(mega_energy > 0.6)
							products["Helium-4"] = 1
							products["Helium-3"] = 1
							products["photon"] = 4
							//
							mega_energy -= 0.6
					if("Boron-11")
						if(mega_energy > 1)
							products["Helium-4"] = 3
							products["photon"] = 8.7
							//
							mega_energy -= 1
			*/

		//if no reaction happened, switch the two reactants and try again
		if(!products.len && check)
			check = 0
			var/temp = reactant_one
			reactant_one = reactant_two
			reactant_two = temp
			goto recheck_reactions
		/*if(products.len)
			world << "\blue	[reactant_one] + [reactant_two] reaction occured"
			for(var/reagent in products)
				world << "\blue	[reagent]: [products[reagent]]"*/
		/*if(products["neutron"])
			products -= "neutron"
		if(products["proton"])
			products -= "proton"
		if(products["photon"])
			products -= "photon"
		if(products["radiated charge"])
			products -= "radiated charge"*/
		return products
