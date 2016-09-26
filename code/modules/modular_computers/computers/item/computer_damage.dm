/obj/item/device/modular_computer/proc/take_damage(amount, component_probability, damage_casing = 1, randomize = 1)
	if(randomize)
		// 75%-125%, rand() works with integers, apparently.
		amount *= (rand(75, 125) / 100.0)
	amount = round(amount)
	if(damage_casing)
		damage += amount
		damage = max(0,min(max_damage,damage))

	if(component_probability)
		for(var/I in all_components)
			var/obj/item/weapon/computer_hardware/H = all_components[I]
			if(prob(component_probability))
				H.take_damage(round(amount / 2))

	if(damage >= max_damage)
		break_apart()

// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
/obj/item/device/modular_computer/ex_act(severity)
	take_damage(rand(100,200)/severity, component_probability = 30/severity)

// EMPs are similar to explosions, but don't cause physical damage to the casing. Instead they screw up the components
/obj/item/device/modular_computer/emp_act(severity)
	take_damage(rand(100,200)/severity, component_probability = 50/severity, damage_casing = 0)

// "Stun" weapons can cause minor damage to components (short-circuits?)
// "Burn" damage is equally strong against internal components and exterior casing
// "Brute" damage mostly damages the casing.
/obj/item/device/modular_computer/bullet_act(obj/item/projectile/Proj)
	switch(Proj.damage_type)
		if(BRUTE)
			take_damage(Proj.damage, component_probability = Proj.damage/2)
		if(BURN)
			take_damage(Proj.damage, component_probability = Proj.damage/1.5)

/obj/item/device/modular_computer/proc/break_apart()
	physical.visible_message("\The [src] breaks apart!")
	var/turf/newloc = get_turf(src)
	new /obj/item/stack/sheet/metal(newloc, round(steel_sheet_cost/2))
	for(var/C in all_components)
		var/obj/item/weapon/computer_hardware/H = all_components[C]
		uninstall_component(H)
		H.forceMove(newloc)
		if(prob(25))
			H.take_damage(rand(10,30))
	relay_qdel()
	qdel()
