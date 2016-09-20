/obj/item/device/modular_computer/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	var/component_probability = min(50, max(damage_amount*0.1, 1 - health/maxhealth))
	switch(damage_flag)
		if("bullet")
			component_probability = damage_amount * 0.5
		if("laser")
			component_probability = damage_amount * 0.66
	if(component_probability)
		for(var/I in all_components)
			var/obj/item/weapon/computer_hardware/H = I
			if(prob(component_probability))
				H.take_damage(round(damage_amount*0.5), damage_type, damage_flag, 0)


/obj/item/device/modular_computer/obj_destruction()
	break_apart()

/obj/item/device/modular_computer/proc/break_apart()
	physical.visible_message("\The [src] breaks apart!")
	var/turf/newloc = get_turf(src)
	new /obj/item/stack/sheet/metal(newloc, round(steel_sheet_cost/2))
	for(var/C in all_components)
		var/obj/item/weapon/computer_hardware/H = C
		uninstall_component(H)
		H.forceMove(newloc)
		if(prob(25))
			H.take_damage(rand(10,30), BRUTE, 0, 0)
	relay_qdel()
	qdel(src)
