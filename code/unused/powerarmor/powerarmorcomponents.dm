/obj/item/powerarmor
	name = "Generic power armor component"
	desc = "This is the base object, you should never see one."
	var/obj/item/clothing/suit/powered/parent //so the component knows which armor it belongs to.
	var/slowdown = 0 //how much the component slows down the wearer

	proc/toggle()
		return
		//The child objects will use this proc



/obj/item/powerarmor/power
	name = "Adminbus power armor power source"
	desc = "Runs on the rare Badminium molecule."

	process()
		return

	proc/checkpower()
		return 1

	plasma
		name = "Miniaturized plasma generator"
		desc = "Runs on plasma."
		slowdown = 1
		var/fuel = 0

		process()
			if (fuel > 0 && parent.active)
				fuel--
				spawn(50)
					process()
				return
			else if (parent.active)
				parent.powerdown(1)
				return

		checkpower()
			return fuel

	powercell
		name = "Powercell interface"
		desc = "Boring, but reliable."
		var/obj/item/weapon/cell/cell
		slowdown = 0.5

		process()
			if (cell && cell.charge > 0 && parent.active)
				cell.use(50)
				spawn(50)
					process()
				return
			else if (parent.active)
				parent.powerdown(1)
				return

		checkpower()
			return max(cell.charge, 0)

	nuclear
		name = "Miniaturized nuclear generator"
		desc = "For all your radioactive needs."
		slowdown = 1.5

		process()
			if(!crit_fail)
				if (prob(src.reliability)) return 1 //No failure
				if (prob(src.reliability))
					for (var/mob/M in range(0,src.parent)) //Only a minor failure, enjoy your radiation.
						if (src.parent in M.contents)
							M << "\red Your armor feels pleasantly warm for a moment."
						else
							M << "\red You feel a warm sensation."
						M.radiation += rand(1,40)
				else
					for (var/mob/M in range(rand(1,4),src.parent)) //Big failure, TIME FOR RADIATION BITCHES
						if (src.parent in M.contents)
							M << "\red Your armor's reactor overloads!"
						M << "\red You feel a wave of heat wash over you."
						M.radiation += 100
					crit_fail = 1 //broken~
					parent.powerdown(1)
				spawn(50)
					process()

		checkpower()
			return !crit_fail

/obj/item/powerarmor/reactive
	name = "Adminbus power armor reactive plating"
	desc = "Made with the rare Badminium molecule."
	var/list/togglearmor = list(melee = 250, bullet = 100, laser = 100,energy = 100, bomb = 100, bio = 100, rad = 100)
	 //Good lord an active energy axe does 150 damage a swing? Anyway, barring var editing, this armor loadout should be impervious to anything. Enjoy, badmins~ --NEO

	toggle(sudden = 0)
		switch(parent.active)
			if(1)
				if(!sudden)
					usr << "\blue Reactive armor systems disengaged."
			if(0)
				usr << "\blue Reactive armor systems engaged."
		var/list/switchover = list()
		for (var/armorvar in parent.armor)
			switchover[armorvar] = togglearmor[armorvar]
			togglearmor[armorvar] = parent.armor[armorvar]
			parent.armor[armorvar] = switchover[armorvar]
			//Probably not the most elegant way to have the vars switch over, but it works. Also propagates the values to the other objects.
			if(parent.helm)
				parent.helm.armor[armorvar] = parent.armor[armorvar]
			if(parent.gloves)
				parent.gloves.armor[armorvar] = parent.armor[armorvar]
			if(parent.shoes)
				parent.shoes.armor[armorvar] = parent.armor[armorvar]

	centcomm
		name = "CentComm power armor reactive plating"
		desc = "Pretty effective against everything, not perfect though."
		togglearmor = list(melee = 90, bullet = 70, laser = 60,energy = 40, bomb = 75, bio = 75, rad = 75)
		slowdown = 2


/obj/item/powerarmor/servos
	name = "Adminbus power armor movement servos"
	desc = "Made with the rare Badminium molecule."
	var/toggleslowdown = 9

	toggle(sudden = 0)
		switch(parent.active)
			if(1)
				if(!sudden)
					usr << "\blue Movement assist servos disengaged."
				parent.slowdown += toggleslowdown
			if(0)
				usr << "\blue Movement assist servos engaged."
				parent.slowdown -= toggleslowdown

/obj/item/powerarmor/atmoseal
	name = "Power armor atmospheric seals"
	desc = "Keeps the bad stuff out."
	slowdown = 1
	var/sealed = 0

	toggle(sudden = 0)
		switch(parent.active)
			if(1)
				if(!sudden)
					usr << "\blue Atmospheric seals disengaged."
				parent.gas_transfer_coefficient = 1
				parent.permeability_coefficient = 1
				parent.heat_transfer_coefficient = 1
				parent.flags &= ~SUITSPACE
				if(parent.helmrequired)
					parent.helm.gas_transfer_coefficient = 1
					parent.helm.permeability_coefficient = 1
					parent.helm.heat_transfer_coefficient = 1
					parent.helm.flags &= ~HEADSPACE
				if(parent.glovesrequired)
					parent.gloves.gas_transfer_coefficient = 1
					parent.gloves.permeability_coefficient = 1
					parent.gloves.heat_transfer_coefficient = 1
				if(parent.shoesrequired)
					parent.shoes.gas_transfer_coefficient = 1
					parent.shoes.permeability_coefficient = 1
					parent.shoes.heat_transfer_coefficient = 1
				sealed = 0

			if(0)
				usr << "\blue Atmospheric seals engaged."
				parent.gas_transfer_coefficient = 0.01
				parent.permeability_coefficient = 0.02
				parent.heat_transfer_coefficient = 0.02
				parent.flags |= SUITSPACE
				if(parent.helmrequired)
					parent.helm.gas_transfer_coefficient = 0.01
					parent.helm.permeability_coefficient = 0.02
					parent.helm.heat_transfer_coefficient = 0.02
					parent.helm.flags |= HEADSPACE
				if(parent.glovesrequired)
					parent.gloves.gas_transfer_coefficient = 0.01
					parent.gloves.permeability_coefficient = 0.02
					parent.gloves.heat_transfer_coefficient = 0.02
				if(parent.shoesrequired)
					parent.shoes.gas_transfer_coefficient = 0.01
					parent.shoes.permeability_coefficient = 0.02
					parent.shoes.heat_transfer_coefficient = 0.02
				sealed = 1

	adminbus
		name = "Adminbus power armor atmospheric seals"
		desc = "Made with the rare Badminium molecule."
		slowdown = 0

	optional
		name = "Togglable power armor atmospheric seals"
		desc = "Keeps the bad stuff out, but lets you remove your helmet without having to turn the whole suit off."

		proc/helmtoggle(sudden = 0, manual = 0)
			var/mob/living/carbon/human/user = usr
			var/obj/item/clothing/head/powered/helm
			if(user.head && istype(user.head,/obj/item/clothing/head/powered))
				helm = user.head

				if(!sealed)
					user << "\red Unable to initialize helmet seal, armor seals not active."
					return
				if(!helm.parent)
					user << "\blue Helmet locked."
					helm.canremove = 0
					parent.helm = helm
					helm.parent = parent
					sleep(20)
					parent.helm.gas_transfer_coefficient = 0.01
					parent.helm.permeability_coefficient = 0.02
					parent.helm.heat_transfer_coefficient = 0.02
					parent.helm.flags |= HEADSPACE
					user << "\blue Helmet atmospheric seals engaged."
					if(manual)
						for (var/armorvar in helm.armor)
							helm.armor[armorvar] = parent.armor[armorvar]
					return
				else
					if(manual)
						user << "\blue Helmet atmospheric seals disengaged."
					parent.helm.gas_transfer_coefficient = 1
					parent.helm.permeability_coefficient = 1
					parent.helm.heat_transfer_coefficient = 1
					parent.helm.flags &= ~HEADSPACE
					if(manual)
						for (var/armorvar in helm.armor)
							helm.armor[armorvar] = parent.reactive.togglearmor[armorvar]
					if(!sudden)
						if(manual)
							sleep(20)
							user << "\blue Helmet unlocked."
						helm.canremove = 1
						parent.helm = null
						helm.parent = null

		adminbus
			name = "Adminbus togglable power armor atmospheric seals"
			desc = "Made with the rare Badminium molecule."
			slowdown = 0



