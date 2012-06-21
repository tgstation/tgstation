//the core [tokamaka generator] big funky solenoid, it generates an EM field

/*
when the core is turned on, it generates [creates] an electromagnetic field
the em field attracts plasma, and suspends it in a controlled torus (doughnut) shape, oscillating around the core

the field strength is directly controllable by the user
field strength = sqrt(energy used by the field generator)

the size of the EM field = field strength / k
(k is an arbitrary constant to make the calculated size into tilewidths)

1 tilewidth = below 5T
3 tilewidth = between 5T and 12T
5 tilewidth = between 10T and 25T
7 tilewidth = between 20T and 50T
(can't go higher than 40T)

energy is added by a gyrotron, and lost when plasma escapes
energy transferred from the gyrotron beams is reduced by how different the frequencies are (closer frequencies = more energy transferred)

frequency = field strength * (stored energy / stored moles of plasma) * x
(where x is an arbitrary constant to make the frequency something realistic)
the gyrotron beams' frequency and energy are hardcapped low enough that they won't heat the plasma much

energy is generated in considerable amounts by fusion reactions from injected particles
fusion reactions only occur when the existing energy is above a certain level, and it's near the max operating level of the gyrotron. higher energy reactions only occur at higher energy levels
a small amount of energy constantly bleeds off in the form of radiation

the field is constantly pulling in plasma from the surrounding [local] atmosphere
at random intervals, the field releases a random percentage of stored plasma in addition to a percentage of energy as intense radiation

the amount of plasma is a percentage of the field strength, increased by frequency
*/

/*
- VALUES -

max volume of plasma storeable by the field = the total volume of a number of tiles equal to the (field tilewidth)^2

*/

/obj/machinery/rust/core
	name = "Tokamak core"
	desc = "Enormous solenoid for generating extremely high power electromagnetic fields"
	icon = 'core.dmi'
	icon_state = "core0"
	anchored = 1
	var/on = 0
	var/obj/machinery/rust/em_field/owned_field
	var/field_strength = 0.01
	//
	req_access = list(ACCESS_ENGINE)
	//
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300


	Topic(href, href_list)
		..()
		if( href_list["startup"] )
			Startup()
			return
		if( href_list["shutdown"] )
			Shutdown()
			return
		if( href_list["modify_field_strength"] )
			var/new_field_str = text2num(input("Enter new field strength", "Modifying field strength", owned_field.field_strength))
			if(!new_field_str)
				usr << "\red That's not a valid number."
				return
			field_strength = max(new_field_str,0.1)
			field_strength = min(new_field_str,50)
			if(owned_field)
				owned_field.ChangeFieldStrength(field_strength)
			return

	proc/Startup()
		if(owned_field)
			return
		on = 1
		owned_field = new(src.loc)
		if(owned_field)
			owned_field.ChangeFieldStrength(field_strength)
			icon_state = "core1"
		luminosity = 1
		return 1

	proc/Shutdown()
		icon_state = "core0"
		on = 0
		del(owned_field)
		luminosity = 0

	proc/AddParticles(var/name, var/quantity = 1)
		if(owned_field)
			owned_field.AddParticles(name, quantity)
			return 1
		return 0

	process()
		..()
		use_power(100 * field_strength + 500)
		if(on && !owned_field)
			Shutdown()
		return
		//
		luminosity = round(owned_field.field_strength/10)
		luminosity = max(luminosity,1)
		//
		if(stat & (NOPOWER|BROKEN))
			Shutdown()

	bullet_act(var/obj/item/projectile/Proj)
		if(Proj.flag != "bullet" && owned_field)
			var/obj/item/projectile/beam/laserbeam = Proj
			owned_field.AddEnergy(0, laserbeam.damage / 5000, laserbeam.frequency)
		return 0
