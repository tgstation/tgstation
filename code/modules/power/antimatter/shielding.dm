//like orange but only checks north/south/east/west for one step
proc/cardinalrange(var/center)
	var/list/things = list()
	for(var/direction in cardinal)
		var/turf/T = get_step(center, direction)
		if(!T) continue
		things += T.contents
	return things

/obj/machinery/am_shielding
	name = "antimatter reactor section"
	desc = "This device was built using a plasma life-form that seems to increase plasma's natural ability to react with neutrinos while reducing the combustibility."

	icon = 'antimatter.dmi'
	icon_state = "shield"
	anchored = 1
	density = 1
	dir = 1
	use_power = 0//Living things generally dont use power
	idle_power_usage = 0
	active_power_usage = 0

	var/obj/machinery/power/am_control_unit/control_unit = null
	var/processing = 0//To track if we are in the update list or not, we need to be when we are damaged and if we ever
	var/stability = 100//If this gets low bad things tend to happen
	var/efficiency = 1//How many cores this core counts for when doing power processing, plasma in the air and stability could affect this

	New(var/l)
		..(l)
		spawn(10)
			controllerscan()
		return


	proc/controllerscan(var/priorscan = 0)
		//Make sure we are the only one here
		if(!istype(src.loc, /turf))
			del(src)
			return
		for(var/obj/machinery/am_shielding/AMS in loc.contents)
			if(AMS == src) continue
			spawn(0)
				del(src)
			return

		//Search for shielding first
		for(var/obj/machinery/am_shielding/AMS in cardinalrange(src))
			if(AMS && AMS.control_unit && link_control(AMS.control_unit))
				break

		if(!control_unit)//No other guys nearby look for a control unit
			for(var/direction in cardinal)
			for(var/obj/machinery/power/am_control_unit/AMC in cardinalrange(src))
				if(AMC.add_shielding(src))
					break

		if(!control_unit)
			if(!priorscan)
				spawn(20)
					controllerscan(1)//Last chance
				return
			spawn(0)
				del(src)
		return


	Del()
		if(control_unit)	control_unit.remove_shielding(src)
		if(processing)	shutdown_core()
		visible_message("\red The [src.name] melts!")
		//Might want to have it leave a mess on the floor but no sprites for now
		..()
		return


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0))	return 1
		return 0


	process()
		if(!processing) ..()
		//TODO: core functions and stability
		//TODO: think about checking the airmix for plasma and increasing power output
		return


	emp_act()//Immune due to not really much in the way of electronics.
		return 0


	blob_act()
		stability -= 20
		if(prob(100-stability))
			if(prob(10))//Might create a node
				new /obj/effect/blob/node(src.loc,150)
			else
				new /obj/effect/blob(src.loc,60)
			spawn(0)
				del(src)
			return
		check_stability()
		return


	ex_act(severity)
		switch(severity)
			if(1.0)
				stability -= 80
			if(2.0)
				stability -= 40
			if(3.0)
				stability -= 20
		check_stability()
		return


	bullet_act(var/obj/item/projectile/Proj)
		if(Proj.flag != "bullet")
			stability -= Proj.force/2
		return 0


	update_icon()
		overlays = null
		for(var/direction in alldirs)
			var/machine = locate(/obj/machinery, get_step(loc, direction))
			if((istype(machine, /obj/machinery/am_shielding) && machine:control_unit == control_unit)||(istype(machine, /obj/machinery/power/am_control_unit) && machine == control_unit))
				overlays += "shield_[direction]"

		if(core_check())
			overlays += "core"
			if(!processing) setup_core()
		else if(processing) shutdown_core()


	attackby(obj/item/W, mob/user)
		if(!istype(W) || !user) return
		if(W.force > 10)
			stability -= W.force/2
			check_stability()
		..()
		return



	//Call this to link a detected shilding unit to the controller
	proc/link_control(var/obj/machinery/power/am_control_unit/AMC)
		if(!istype(AMC))	return 0
		if(control_unit && control_unit != AMC) return 0//Already have one
		control_unit = AMC
		control_unit.add_shielding(src,1)
		return 1


	//Scans cards for shields or the control unit and if all there it
	proc/core_check()
		for(var/direction in alldirs)
			var/machine = locate(/obj/machinery, get_step(loc, direction))
			if(!machine) return 0//Need all for a core
			if(!istype(machine, /obj/machinery/am_shielding) && !istype(machine, /obj/machinery/power/am_control_unit))	return 0
		return 1


	proc/setup_core()
		processing = 1
		machines.Add(src)
		if(!control_unit)	return
		control_unit.linked_cores.Add(src)
		control_unit.reported_core_efficiency += efficiency
		return


	proc/shutdown_core()
		processing = 0
		machines.Remove(src)
		if(!control_unit)	return
		control_unit.linked_cores.Remove(src)
		control_unit.reported_core_efficiency -= efficiency
		return


	proc/check_stability(var/injecting_fuel = 0)
		if(stability > 0) return
		if(injecting_fuel)
			explosion(get_turf(src),8,12,18,12)
		if(src)
			del(src)
		return


	proc/recalc_efficiency(var/new_efficiency)//tbh still not 100% sure how I want to deal with efficiency so this is likely temp
		if(!control_unit || !processing) return
		if(stability < 50)
			new_efficiency /= 2
		control_unit.reported_core_efficiency += (new_efficiency - efficiency)
		efficiency = new_efficiency
		return



/obj/item/device/am_shielding_container
	name = "packaged antimatter reactor section"
	desc = "A small storage unit containing an antimatter reactor section.  To use place near an antimatter control unit or deployed antimatter reactor section and use a multitool to activate this package."
	icon = 'antimatter.dmi'
	icon_state = "box"
	item_state = "electronic"
	w_class = 4.0
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 100
	w_amt = 2000

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/device/multitool) && istype(src.loc,/turf))
			new/obj/machinery/am_shielding(src.loc)
			del(src)
			return
		..()
		return