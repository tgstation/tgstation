
/obj/item/integrated_circuit/passive/power
	name = "power thingy"
	desc = "Does power stuff."
	complexity = 5
	category_text = "Power - Passive"

/obj/item/integrated_circuit/passive/power/proc/make_energy()
	return

// For calculators.
/obj/item/integrated_circuit/passive/power/solar_cell
	name = "tiny photovoltaic cell"
	desc = "It's a very tiny solar cell, generally used in calculators."
	extended_desc = "This cell generates 1 W of power in optimal lighting conditions. Less light will result in less power being generated."
	icon_state = "solar_cell"
	complexity = 8
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/max_power = 30

/obj/item/integrated_circuit/passive/power/solar_cell/make_energy()
	var/turf/T = get_turf(src)
	var/light_amount = T ? T.get_lumcount() : 0
	var/adjusted_power = max(max_power * light_amount, 0)
	adjusted_power = round(adjusted_power, 0.1)
	if(adjusted_power)
		if(assembly)
			assembly.give_power(adjusted_power)

/obj/item/integrated_circuit/passive/power/starter
	name = "starter"
	desc = "This tiny circuit will send a pulse right after the device is turned on, or when power is restored to it."
	icon_state = "led"
	complexity = 1
	activators = list("pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/is_charge = FALSE

/obj/item/integrated_circuit/passive/power/starter/make_energy()
	if(assembly.battery)
		if(assembly.battery.charge)
			if(!is_charge)
				activate_pin(1)
			is_charge = TRUE
		else
			is_charge = FALSE
	else
		is_charge=FALSE
	return FALSE

// For fat machines that need fat power, like drones.
/obj/item/integrated_circuit/passive/power/relay
	name = "tesla power relay"
	desc = "A seemingly enigmatic device which connects to nearby APCs wirelessly and draws power from them."
	w_class = WEIGHT_CLASS_SMALL
	extended_desc = "The siphon drains 50 W of power from an APC in the same room as it as long as it has charge remaining. It will always drain \
	from the 'equipment' power channel."
	icon_state = "power_relay"
	complexity = 7
	spawn_flags = IC_SPAWN_RESEARCH
	var/power_amount = 50


/obj/item/integrated_circuit/passive/power/relay/make_energy()
	if(!assembly)
		return
	var/area/A = get_area(src)
	if(A && A.powered(EQUIP) && assembly.give_power(power_amount))
		A.use_power(power_amount, EQUIP)
		// give_power() handles CELLRATE on its own.


// For really fat machines.
/obj/item/integrated_circuit/passive/power/relay/large
	name = "large tesla power relay"
	desc = "A seemingly enigmatic device which connects to nearby APCs wirelessly and draws power from them, now in industrial size!"
	w_class = WEIGHT_CLASS_BULKY
	extended_desc = "The siphon drains 2 kW of power from an APC in the same room as it as long as it has charge remaining. It will always drain \
 	from the 'equipment' power channel."
	icon_state = "power_relay"
	complexity = 15
	spawn_flags = IC_SPAWN_RESEARCH
	power_amount = 1000


//fuel cell
/obj/item/integrated_circuit/passive/power/chemical_cell
	name = "fuel cell"
	desc = "Produces electricity from chemicals."
	icon_state = "chemical_cell"
	extended_desc = "This is effectively an internal beaker. It will consume and produce power from plasma, slime jelly, welding fuel, carbon,\
	 ethanol, nutriment, and blood in order of decreasing efficiency. It will consume fuel only if the battery can take more energy."
	container_type = OPENCONTAINER
	complexity = 4
	inputs = list()
	outputs = list("volume used" = IC_PINTYPE_NUMBER, "self reference" = IC_PINTYPE_SELFREF)
	activators = list("push ref" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/volume = 60
	var/list/fuel = list("plasma" = 50000, "welding_fuel" = 15000, "carbon" = 10000, "ethanol" = 10000, "nutriment" = 8000)
	var/multi = 1
	var/lfwb =TRUE

/obj/item/integrated_circuit/passive/power/chemical_cell/New()
	..()
	create_reagents(volume)
	extended_desc +="But no fuel can be compared with blood of living human."


/obj/item/integrated_circuit/passive/power/chemical_cell/interact(mob/user)
	set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
	push_data()
	..()

/obj/item/integrated_circuit/passive/power/chemical_cell/on_reagent_change(changetype)
	set_pin_data(IC_OUTPUT, 1, reagents.total_volume)
	push_data()

/obj/item/integrated_circuit/passive/power/chemical_cell/make_energy()
	if(assembly)
		if(assembly.battery)
			var/bp = 5000
			if(reagents.get_reagent_amount("blood")) //only blood is powerful enough to power the station(c)
				var/datum/reagent/blood/B = locate() in reagents.reagent_list
				if(lfwb)
					if(B && B.data["cloneable"])
						var/mob/M = B.data["donor"]
						if(M && (M.stat != DEAD) && (M.client))
							bp = 500000
				if((assembly.battery.maxcharge-assembly.battery.charge) / GLOB.CELLRATE > bp)
					if(reagents.remove_reagent("blood", 1))
						assembly.give_power(bp)
			for(var/I in fuel)
				if((assembly.battery.maxcharge-assembly.battery.charge) / GLOB.CELLRATE > fuel[I])
					if(reagents.remove_reagent(I, 1))
						assembly.give_power(fuel[I]*multi)

/obj/item/integrated_circuit/passive/power/chemical_cell/do_work()
	set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
	push_data()
