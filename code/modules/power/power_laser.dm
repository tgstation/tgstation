//Power laser, a laser that converts energy to money by sending said energy to centcom through a fat laser beam.
//Protip, don't get in said laserbeam, unless you're a masochist.

#define ENERGY2MONEY 0.01 // 1 credit each 100 W transferred
#define ENERGY2DAMAGE 10000// energy/thisdefine=damage
/obj/machinery/power/power_laser
	name = "power laser"
	icon = 'goon/icons/obj/pt_laser.dmi' // huge thanks to goon for the sprite!
	icon_state = "ptl" // Especially Gannets!
	desc = "A really big device capable of converting energy in photons and compressing them enough to make a laser beam out of them, capable of travelling enormous distances through space.\
			This one is used to send this energy to Centcom, to be converted into money that goes inside the station's budget."
	anchored = TRUE
	density = TRUE
	bound_width = 96
	bound_height = 96
	speed_process = TRUE
	use_power = NO_POWER_USE // We deal with it ourself
	stat = POWEROFF // starts offline
	layer = FLY_LAYER
	var/amount_emitting = 0
	var/max_amount_emitted = 50000
	var/total_energy_sent = 0
	var/turf/turf_to_sell_power_to
	var/datum/beam/pl_beam/beam

/obj/machinery/power/power_laser/Initialize()
	. = ..()
	connect_to_network()
	turf_to_sell_power_to = get_edge_target_turf(src, dir)

/obj/machinery/power/power_laser/Destroy()
	QDEL_NULL(beam)
	return ..()

/obj/machinery/power/power_laser/process()
	if(!(stat & POWEROFF) && beam)
		if(beam.target == turf_to_sell_power_to)
			use_power()
		else
			damage(beam.target)

/obj/machinery/power/power_laser/proc/damage(atom/target)
	if(istype(target, /turf/closed/wall))
		var/turf/closed/wall/W = target
		var/damseverity = (amount_emitting >= max_amount_emitted/2) ? 2 : 3
		W.ex_act(damseverity)
	else if(isobj(target))
		var/obj/O = target
		O.take_damage(amount_emitting/ENERGY2DAMAGE, damage_type = BURN)
	else if(isliving(target))
		var/mob/living/M = target
		M.apply_damage(damage = amount_emitting/ENERGY2DAMAGE, damagetype = BURN)

/obj/machinery/power/power_laser/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return
	else
		..()

/obj/machinery/power/power_laser/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/weapon/screwdriver/S)
	..()
	if(panel_open)
		stat |= MAINT
	else
		stat &= ~MAINT
	update_stat()

/obj/machinery/power/power_laser/use_power()
	if(powernet)
		var/drained = min(amount_emitting, powernet.avail)
		powernet.load += drained
		total_energy_sent += drained

/obj/machinery/power/power_laser/proc/emit_beam()
	var/turf/turfStart = get_starting_turf()
	var/turf/turfEnd = get_edge_target_turf(src, dir)
	var/list/turflist = getline(turfStart, turfEnd) - turfStart
	var/target
	for(var/i in turflist)
		var/turf/T = i
		if(T.density)
			target = T
			break
		else
			for(var/j in T)
				var/atom/A = j
				if(A.density)
					target = A
					break
	if(!target)
		target = turfEnd
	beam = Beam(turfStart, target, icon = 'goon/icons/obj/ptlbeam.dmi', icon_state = "ptl_beam",maxdistance=INFINITY,btype = /obj/effect/ebeam/ptl, beam_sleep_time=1)

/obj/machinery/power/power_laser/proc/get_starting_turf()
	switch(dir)
		if(NORTH)
			return locate(x+1, y+2, z)
		if(SOUTH)
			return locate(x+1, y, z)
		if(EAST)
			return locate(x+2, y+1, z)
		if(WEST)
			return locate(x, y+1, z)

/obj/machinery/power/power_laser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																	datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "power_laser", name, 400, 550, master_ui, state)
		ui.open()

/obj/machinery/power/power_laser/ui_data()
	var/list/data = list()
	data["power"] = stat & POWEROFF ? FALSE : TRUE
	data["amount_emitting"] = amount_emitting
	data["max_amount_emitted"] = max_amount_emitted
	data["total_energy_sent"] = total_energy_sent
	return data

/obj/machinery/power/power_laser/ui_act(action, params)
	if(..() || !is_operational())
		return
	switch(action)
		if("power")
			stat ^= POWEROFF
			update_stat()
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New input target (0-[max_amount_emitted]):", name, amount_emitting) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = max_amount_emitted
				. = TRUE
			else if(adjust)
				target = amount_emitting + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				amount_emitting = Clamp(target, 0, max_amount_emitted)
	log_ptl(usr.ckey)

/obj/machinery/power/power_laser/proc/log_ptl(user = "")
	investigate_log("Power laser input: [amount_emitting]/[max_amount_emitted];Active: [stat & POWEROFF ? "OFF" : "ON"]; by [user]", INVESTIGATE_SINGULO)


/obj/machinery/power/power_laser/Beam(atom/BeamOrigin, atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time=50, maxdistance=10,btype=/obj/effect/ebeam,beam_sleep_time = 3, newDir = dir)
	var/datum/beam/pl_beam/newbeam = new(BeamOrigin,BeamTarget,icon,icon_state,time,maxdistance,btype,beam_sleep_time, newDir)
	INVOKE_ASYNC(newbeam, /datum/beam/.proc/Start)
	return newbeam

/obj/machinery/power/power_laser/proc/update_stat()
	if(is_operational())
		if(stat & POWEROFF)
			STOP_PROCESSING(SSfastprocess, src)
			QDEL_NULL(beam)
		else
			emit_beam()

/obj/machinery/power/power_laser/setDir(newDir)
	..()
	turf_to_sell_power_to = get_edge_target_turf(src, dir)

#define LOW_ENERGY 10000
#define MEDIUM_ENERGY 20000
#define LARGE_ENERGY 30000
#define ENORMOUS_ENERGY 40000
/datum/beam/pl_beam
	icon = 'goon/icons/obj/ptlbeam.dmi'
	icon_state = "ptl_beam"
	var/dir = SOUTH

/datum/beam/pl_beam/New(beam_origin,beam_target,beam_icon='icons/effects/beam.dmi',beam_icon_state="b_beam",time=50,maxdistance=10,btype = /obj/effect/ebeam,beam_sleep_time=3, newDir)
	dir = newDir
	..()
	static_beam = FALSE //this shit keeps becoming 1 for some shitty reason fuck you

/datum/beam/pl_beam/End()
	return // It's permanent!

/datum/beam/pl_beam/recalculate()
	calculate_target()
	..()

/datum/beam/pl_beam/proc/calculate_target()
	var/turf/turfEnd = get_edge_target_turf(origin, dir)
	var/list/turflist = getline(origin, turfEnd) - origin
	var/tempTarget
	for(var/i in turflist)
		var/turf/T = i
		if(T.density)
			tempTarget = T
			break
		else
			for(var/j in T)
				var/atom/A = j
				if(A.density)
					tempTarget = A
					break
	if(!tempTarget)
		tempTarget = turfEnd
	target = tempTarget
/*
/datum/beam/pl_beam/proc/update_icon()
	var/beam_thickness = "_1"
	if(energy < LOW_ENERGY)
		beam_thickness = "_1"
	else if((energy >= LOW_ENERGY) && (energy < MEDIUM_ENERGY))
		beam_thickness = "_2"
	else if((energy >= MEDIUM_ENERGY) && (energy < LARGE_ENERGY))
		beam_thickness = "_3"
	else if((energy >= LARGE_ENERGY) && (energy < ENORMOUS_ENERGY))
		beam_thickness = "_4"
	else if(energy >= ENORMOUS_ENERGY)
		beam_thickness = "_5"
	icon_state = "[initial(icon_state)][beam_thickness]"
*/
/obj/effect/ebeam/ptl
	name = "concentrated energy"
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/ebeam/ptl/Crossed(atom/movable/AM)
	if(AM.density)
		owner.target = AM
  owner.recalculate()
