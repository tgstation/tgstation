//like orange but only checks north/south/east/west for one step
/proc/cardinalrange(var/center)
	var/list/things = list()
	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(center, direction)
		if(!T) continue
		things += T.contents
	return things

/obj/machinery/am_shielding
	name = "antimatter reactor section"
	desc = "This device was built using a plasma life-form that seems to increase plasma's natural ability to react with neutrinos while reducing the combustibility."

	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "shield"
	anchored = 1
	density = 1
	dir = NORTH
	use_power = 0//Living things generally dont use power
	idle_power_usage = 0
	active_power_usage = 0

	var/obj/machinery/power/am_control_unit/control_unit = null
	var/processing = 0//To track if we are in the update list or not, we need to be when we are damaged and if we ever
	var/stability = 100//If this gets low bad things tend to happen
	var/efficiency = 1//How many cores this core counts for when doing power processing, plasma in the air and stability could affect this
	var/coredirs = 0
	var/dirs = 0


/obj/machinery/am_shielding/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/controllerscan), 10)


/obj/machinery/am_shielding/proc/controllerscan(priorscan = 0)
	//Make sure we are the only one here
	if(!istype(src.loc, /turf))
		qdel(src)
		return
	for(var/obj/machinery/am_shielding/AMS in loc.contents)
		if(AMS == src)
			continue
		qdel(src)
		return

	//Search for shielding first
	for(var/obj/machinery/am_shielding/AMS in cardinalrange(src))
		if(AMS && AMS.control_unit && link_control(AMS.control_unit))
			break

	if(!control_unit)//No other guys nearby look for a control unit
		for(var/direction in GLOB.cardinal)
		for(var/obj/machinery/power/am_control_unit/AMC in cardinalrange(src))
			if(AMC.add_shielding(src))
				break

	if(!control_unit)
		if(!priorscan)
			addtimer(CALLBACK(src, .proc/controllerscan, 1), 20)
			return
		qdel(src)


/obj/machinery/am_shielding/Destroy()
	if(control_unit)
		control_unit.remove_shielding(src)
	if(processing)
		shutdown_core()
	visible_message("<span class='danger'>The [src.name] melts!</span>")
	//Might want to have it leave a mess on the floor but no sprites for now
	return ..()


/obj/machinery/am_shielding/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	return 0


/obj/machinery/am_shielding/process()
	if(!processing)
		. = PROCESS_KILL
	//TODO: core functions and stability
	//TODO: think about checking the airmix for plasma and increasing power output
	return


/obj/machinery/am_shielding/emp_act()//Immune due to not really much in the way of electronics.
	return 0

/obj/machinery/am_shielding/ex_act(severity, target)
	stability -= (80 - (severity * 20))
	check_stability()
	return


/obj/machinery/am_shielding/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(Proj.flag != "bullet")
		stability -= Proj.force/2
		check_stability()


/obj/machinery/am_shielding/update_icon()
	dirs = 0
	coredirs = 0
	cut_overlays()
	for(var/direction in GLOB.alldirs)
		var/turf/T = get_step(loc, direction)
		for(var/obj/machinery/machine in T)
			if(istype(machine, /obj/machinery/am_shielding))
				var/obj/machinery/am_shielding/shield = machine
				if(shield.control_unit == control_unit)
					if(shield.processing)
						coredirs |= direction
					if(direction in GLOB.cardinal)
						dirs |= direction

			else
				if(istype(machine, /obj/machinery/power/am_control_unit) && (direction in GLOB.cardinal))
					var/obj/machinery/power/am_control_unit/control = machine
					if(control == control_unit)
						dirs |= direction


	var/prefix = ""
	var/icondirs=dirs

	if(coredirs)
		prefix="core"

	icon_state = "[prefix]shield_[icondirs]"

	if(core_check())
		add_overlay("core[control_unit && control_unit.active]")
		if(!processing)
			setup_core()
	else if(processing)
		shutdown_core()


/obj/machinery/am_shielding/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage_amount)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	if(damage_amount >= 10)
		stability -= damage_amount/2
		check_stability()


//Call this to link a detected shilding unit to the controller
/obj/machinery/am_shielding/proc/link_control(obj/machinery/power/am_control_unit/AMC)
	if(!istype(AMC))
		return 0
	if(control_unit && control_unit != AMC)
		return 0//Already have one
	control_unit = AMC
	control_unit.add_shielding(src,1)
	return 1


//Scans cards for shields or the control unit and if all there it
/obj/machinery/am_shielding/proc/core_check()
	for(var/direction in GLOB.alldirs)
		var/found_am_device=0
		for(var/obj/machinery/machine in get_step(loc, direction))
		//var/machine = locate(/obj/machinery, get_step(loc, direction))
			if(!machine)
				continue//Need all for a core
			if(istype(machine, /obj/machinery/am_shielding) || istype(machine, /obj/machinery/power/am_control_unit))
				found_am_device = 1
				break
		if(!found_am_device)
			return 0
	return 1


/obj/machinery/am_shielding/proc/setup_core()
	processing = 1
	GLOB.machines |= src
	START_PROCESSING(SSmachines, src)
	if(!control_unit)
		return
	control_unit.linked_cores.Add(src)
	control_unit.reported_core_efficiency += efficiency
	return


/obj/machinery/am_shielding/proc/shutdown_core()
	processing = 0
	if(!control_unit)
		return
	control_unit.linked_cores.Remove(src)
	control_unit.reported_core_efficiency -= efficiency
	return


/obj/machinery/am_shielding/proc/check_stability(injecting_fuel = 0)
	if(stability > 0)
		return
	if(injecting_fuel && control_unit)
		control_unit.exploding = 1
	if(src)
		qdel(src)
	return


/obj/machinery/am_shielding/proc/recalc_efficiency(new_efficiency)//tbh still not 100% sure how I want to deal with efficiency so this is likely temp
	if(!control_unit || !processing)
		return
	if(stability < 50)
		new_efficiency /= 2
	control_unit.reported_core_efficiency += (new_efficiency - efficiency)
	efficiency = new_efficiency
	return



/obj/item/device/am_shielding_container
	name = "packaged antimatter reactor section"
	desc = "A small storage unit containing an antimatter reactor section.  To use place near an antimatter control unit or deployed antimatter reactor section and use a multitool to activate this package."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "box"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	materials = list(MAT_METAL=100)

/obj/item/device/am_shielding_container/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool) && istype(src.loc,/turf))
		new/obj/machinery/am_shielding(src.loc)
		qdel(src)
	else
		return ..()
