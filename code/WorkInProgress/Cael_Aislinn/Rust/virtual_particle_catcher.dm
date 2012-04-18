
//gimmicky hack to collect particles and direct them into the field
//byond multitiles are basically... shit
/obj/machinery/rust/particle_catcher
	invisibility = 101
	icon = 'effects.dmi'
	icon_state = "energynet"
	density = 0
	var/obj/machinery/rust/em_field/parent
	var/mysize = 0

	/*New()
		for(var/obj/machinery/rust/em_field/field in range(6))
			parent = field
		if(!parent)
			del(src)*/

	proc/SetSize(var/newsize)
		name = "collector [newsize]"
		mysize = newsize
		UpdateSize()

	proc/AddParticles(var/name, var/quantity = 1)
		if(parent && parent.size >= mysize)
			parent.AddParticles(name, quantity)
			return 1
		return 0

	proc/AddEnergy(var/energy, var/mega_energy)
		if(parent && parent.size >= mysize)
			parent.energy += energy
			parent.mega_energy += mega_energy
			return 1
		return 0

	proc/UpdateSize()
		if(parent.size >= mysize)
			density = 1
			//invisibility = 101
			name = "collector [mysize] ON"
		else
			density = 0
			name = "collector [mysize] OFF"
			//invisibility = 101

	bullet_act(var/obj/item/projectile/Proj)
		if(Proj.flag != "bullet")
			AddEnergy(0, Proj.damage / 600)
		return 0

	process()
		..()
		if(!parent)
			del(src)
