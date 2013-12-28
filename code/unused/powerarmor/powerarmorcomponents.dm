/*
 * File Updated to match /tg/station code standards on the 28/12/2013 (UK/GMT) by RobRichards
 */

/obj/item/powerarmor
	name = "Generic power armor component"
	desc = "This is the base object, you should never see one."
	var/obj/item/clothing/suit/space/powered/parent //so the component knows which armor it belongs to.
	slowdown = 0 //how much the component slows down the wearer

/obj/item/powerarmor/proc/toggle()
	return
	//The child objects will use this proc


/obj/item/powerarmor/power
	name = "Adminbus power armor power source"
	desc = "Runs on the rare Badminium molecule."

/obj/item/powerarmor/process()
	return

/obj/item/powerarmor/proc/checkpower()
	return 1

/obj/item/powerarmor/power/plasma
	name = "Miniaturized plasma generator"
	desc = "Runs on plasma."
	slowdown = 1
	var/fuel = 0

/obj/item/powerarmor/power/plasma/process()
	if (fuel > 0 && parent.active)
		fuel--
		spawn(50)
			process()
		return
	else if (parent.active)
		parent.powerdown(1)
		return

/obj/item/powerarmor/power/plasma/checkpower()
	return fuel

/obj/item/powerarmor/power/powercell
	name = "Powercell interface"
	desc = "Boring, but reliable."
	var/obj/item/weapon/cell/cell
	slowdown = 0.5

/obj/item/powerarmor/power/powercell/process()
	if (cell && cell.charge > 0 && parent.active)
		cell.use(50)
		spawn(50)
			process()
		return
	else if (parent.active)
		parent.powerdown(1)
		return

/obj/item/powerarmor/power/powercell/checkpower()
	return max(cell.charge, 0)

/obj/item/powerarmor/power/nuclear
	name = "Miniaturized nuclear generator"
	desc = "For all your radioactive needs."
	slowdown = 1.5

/obj/item/powerarmor/power/nuclear/process()
	if(!crit_fail)
		if(prob(src.reliability)) return 1 //No failure
		if(prob(src.reliability))
			for (var/mob/M in range(0,src.parent)) //Only a minor failure, enjoy your radiation.
				if(src.parent in M.contents)
					M << "<span class='danger'>Your armor feels pleasantly warm for a moment.</span>"
				else
					M << "<span class='danger'>You feel a warm sensation.</span>"
				M.radiation += rand(1,40)
		else
			for (var/mob/M in range(rand(1,4),src.parent)) //Big failure, TIME FOR RADIATION BITCHES
				if (src.parent in M.contents)
					M << "<span class='danger'><B>Your armor's reactor overloads!</B></span>"
				M << "<span class='danger'>You feel a wave of heat wash over you.</span>"
				M.radiation += 100
			crit_fail = 1 //broken~
			parent.powerdown(1)
		spawn(50)
			process()

/obj/item/powerarmor/power/nuclear/checkpower()
	return !crit_fail

/obj/item/powerarmor/reactive
	name = "Adminbus power armor reactive plating"
	desc = "Made with the rare Badminium molecule."
	var/list/togglearmor = list(melee = 250, bullet = 100, laser = 100,energy = 100, bomb = 100, bio = 100, rad = 100)
	 //Good lord an active energy axe does 150 damage a swing? Anyway, barring var editing, this armor loadout should be impervious to anything. Enjoy, badmins~ --NEO

/obj/item/powerarmor/reactive/toggle(sudden = 0)
	switch(parent.active)
		if(1)
			if(!sudden)
				usr << "<span class='notice'>Reactive armor systems disengaged.</span>"
		if(0)
			usr << "<span class='notice'>Reactive armor systems engaged.</span>"
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

/obj/item/powerarmor/reactive/Centcom
	name = "Centcom power armor reactive plating"
	desc = "Pretty effective against everything, not perfect though."
	togglearmor = list(melee = 90, bullet = 70, laser = 60,energy = 40, bomb = 75, bio = 75, rad = 75)
	slowdown = 2


/obj/item/powerarmor/servos
	name = "Adminbus power armor movement servos"
	desc = "Made with the rare Badminium molecule."
	var/toggleslowdown = 9

/obj/item/powerarmor/servos/toggle(sudden = 0)
	switch(parent.active)
		if(1)
			if(!sudden)
				usr << "<span class='notice'>Movement assist servos disengaged.</span>"
			parent.slowdown += toggleslowdown
		if(0)
			usr << "<span class='notice'>Movement assist servos engaged.</span>"
			parent.slowdown -= toggleslowdown

/obj/item/powerarmor/atmoseal
	name = "Power armor atmospheric seals"
	desc = "Keeps the bad stuff out."
	slowdown = 1
	var/sealed = 0

/obj/item/powerarmor/atmoseal/toggle(sudden = 0)
	switch(parent.active)
		if(1)
			if(!sudden)
				usr << "<span class='notice'>Atmospheric seals disengaged.</span>"
			parent.gas_transfer_coefficient = 1
			parent.permeability_coefficient = 1
			if(parent.helmrequired)
				parent.helm.gas_transfer_coefficient = 1
				parent.helm.permeability_coefficient = 1
				parent.helm.cold_protection = initial(parent.helm.cold_protection)
				parent.helm.min_cold_protection_temperature = initial(parent.helm.min_cold_protection_temperature)
				parent.helm.heat_protection = initial(parent.helm.heat_protection)
				parent.helm.max_heat_protection_temperature = initial(parent.helm.max_heat_protection_temperature)
			if(parent.glovesrequired)
				parent.gloves.gas_transfer_coefficient = 1
				parent.gloves.permeability_coefficient = 1
				parent.gloves.cold_protection = initial(parent.gloves.cold_protection)
				parent.gloves.min_cold_protection_temperature = initial(parent.gloves.min_cold_protection_temperature)
				parent.gloves.heat_protection = initial(parent.gloves.heat_protection)
				parent.gloves.max_heat_protection_temperature = initial(parent.gloves.max_heat_protection_temperature)
			if(parent.shoesrequired)
				parent.shoes.gas_transfer_coefficient = 1
				parent.shoes.permeability_coefficient = 1
				parent.shoes.cold_protection = initial(parent.shoes.cold_protection)
				parent.shoes.min_cold_protection_temperature = initial(parent.shoes.min_cold_protection_temperature)
				parent.shoes.heat_protection = initial(parent.shoes.heat_protection)
				parent.shoes.max_heat_protection_temperature = initial(parent.shoes.max_heat_protection_temperature)
			sealed = 0

		if(0)
			usr << "<span class='notice'>Atmospheric seals engaged.</span>"
			parent.gas_transfer_coefficient = 0.01
			parent.permeability_coefficient = 0.02
			if(parent.helmrequired)
				parent.helm.gas_transfer_coefficient = 0.01
				parent.helm.permeability_coefficient = 0.02
				parent.helm.cold_protection = HEAD
				parent.helm.min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
				parent.helm.heat_protection = HEAD
				parent.helm.max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
			if(parent.glovesrequired)
				parent.gloves.gas_transfer_coefficient = 0.01
				parent.gloves.permeability_coefficient = 0.02
				parent.gloves.cold_protection = HANDS
				parent.gloves.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
				parent.gloves.heat_protection = HANDS
				parent.gloves.max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
			if(parent.shoesrequired)
				parent.shoes.gas_transfer_coefficient = 0.01
				parent.shoes.permeability_coefficient = 0.02
				parent.shoes.cold_protection = FEET
				parent.shoes.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
				parent.shoes.heat_protection = FEET
				parent.shoes.max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
			sealed = 1

/obj/item/powerarmor/atmoseal/adminbus
	name = "Adminbus power armor atmospheric seals"
	desc = "Made with the rare Badminium molecule."
	slowdown = 0

/obj/item/powerarmor/atmoseal/optional
	name = "Togglable power armor atmospheric seals"
	desc = "Keeps the bad stuff out, but lets you remove your helmet without having to turn the whole suit off."


/obj/item/powerarmor/atmoseal/optional/proc/helmtoggle(sudden = 0, manual = 0)
	var/mob/living/carbon/human/user = usr
	var/obj/item/clothing/head/space/powered/helm
	if(user.head && istype(user.head,/obj/item/clothing/head/space/powered))
		helm = user.head

		if(!sealed)
			user << "<span class='danger'>Unable to initialize helmet seal, armor seals not active.</span>"
			return
		if(!helm.parent)
			user << "<span class='notice'>Helmet locked.</span>"
			helm.canremove = 0
			parent.helm = helm
			helm.parent = parent
			sleep(20)
			parent.helm.gas_transfer_coefficient = 0.01
			parent.helm.permeability_coefficient = 0.02
			parent.helm.cold_protection = HEAD
			parent.helm.min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
			parent.helm.heat_protection = HEAD
			parent.helm.max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT

			user << "<span class='notice'>Helmet atmospheric seals engaged.</span>"
			if(manual)
				for (var/armorvar in helm.armor)
					helm.armor[armorvar] = parent.armor[armorvar]
			return
		else
			if(manual)
				user << "<span class='notice'>Helmet atmospheric seals disengaged.</span>"
			parent.helm.gas_transfer_coefficient = 1
			parent.helm.permeability_coefficient = 1
			parent.helm.cold_protection = initial(parent.helm.cold_protection)
			parent.helm.min_cold_protection_temperature = initial(parent.helm.min_cold_protection_temperature)
			parent.helm.heat_protection = initial(parent.helm.heat_protection)
			parent.helm.max_heat_protection_temperature = initial(parent.helm.max_heat_protection_temperature)
			if(manual)
				for (var/armorvar in helm.armor)
					helm.armor[armorvar] = parent.reactive.togglearmor[armorvar]
			if(!sudden)
				if(manual)
					sleep(20)
					user << "<span class='notice'>Helmet unlocked.</span>"
				helm.canremove = 1
				parent.helm = null
				helm.parent = null



/obj/item/powerarmor/atmoseal/optional/adminbus
	name = "Adminbus togglable power armor atmospheric seals"
	desc = "Made with the rare Badminium molecule."
	slowdown = 0



