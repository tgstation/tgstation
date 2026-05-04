/// Suck power and shoot it out again
/datum/gizmodes/electric
	possible_active_modes = list(
		/datum/gizpulse/electric/emp = 1,
		/datum/gizpulse/electric/discharge = 1,
		/datum/gizpulse/electric/charge = 1,
		/datum/gizpulse/electric/revive = 1,
	)

	guaranteed_active_gizmodes = list(
		GIZMO_PICK_ONE = list(
			/datum/gizpulse/electric/draw = 1,
			/datum/gizpulse/electric/passive_charge = 1,
		)
	)
	min_modes = 3
	max_modes = 4

	cooldown_time = 6 SECONDS

	/// The internal power cell
	var/obj/item/stock_parts/power_store/battery/gizmo/power

/datum/gizmodes/electric/activate(atom/movable/holder)
	if(!power)
		power = new(holder)

	return ..()

/// Batter used in the gizmo device
/obj/item/stock_parts/power_store/battery/gizmo
	charge = STANDARD_BATTERY_CHARGE * 0.1 //you gotta work for your fun

/// Get the total charge
/datum/gizpulse/electric/proc/get_power(atom/movable/holder, datum/gizmodes/master)
	if(istype(master, /datum/gizmodes/electric))
		var/datum/gizmodes/electric/electromaster = master
		return electromaster.power.charge()
	return 0

/// Use some charge
/datum/gizpulse/electric/proc/use_power(amount, atom/movable/holder, datum/gizmodes/master)
	if(istype(master, /datum/gizmodes/electric))
		var/datum/gizmodes/electric/electromaster = master
		return electromaster.power.use(amount)
	return FALSE

/// Do an EMP blast
/datum/gizpulse/electric/emp
	/// Min power to do an EMP
	var/min_power = STANDARD_CELL_CHARGE

/// Do an EMP blast using the cell of our gizmode
/datum/gizpulse/electric/emp/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/charge = get_power(holder, master)
	if(charge < min_power)
		return
	/// Max charge is 1MJ, standard cell charge is 10kJ. A full charge EMP is 1000 / 10 = 100. 100 / 15 is 6 tiles of light emp range
	empulse(get_turf(holder), floor(charge / STANDARD_CELL_CHARGE / 40), floor(charge / STANDARD_CELL_CHARGE / 15), holder)
	use_power(charge, holder, master)

/// Shoot our current charge away as lightning
/datum/gizpulse/electric/discharge/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/charge = get_power(holder, master)
	if(charge)
		return

	tesla_zap(holder, power = charge, zap_flags = ZAP_GIZMO_FLAGS)
	use_power(charge, holder, master)

/// Look for an object with a cell, and CHARGE IT!!!
/datum/gizpulse/electric/charge/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master

	for(var/atom/movable/power_source in oview(4, holder))
		if(!power_source.get_cell())
			continue

		var/obj/item/stock_parts/power_store/cell = power_source.get_cell()

		var/charge = electromaster.power.charge() - cell.used_charge()
		if(charge <= 0)
			continue

		cell.give(charge)
		electromaster.power.use(charge)

		holder.Beam(power_source, icon_state = "g_beam", time = 5)
		playsound(power_source, 'sound/effects/magic/ethereal_exit.ogg', 40)
		return

/// Revive people in a radius like the revival surgery
/datum/gizpulse/electric/revive
	/// The charge cost for a defibrillation pulse
	var/defib_cost = STANDARD_CELL_CHARGE * 0.5

/datum/gizpulse/electric/revive/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master

	if(electromaster.power.charge() < defib_cost)
		return

	electromaster.power.use(defib_cost)

	for(var/mob/living/dead in orange(holder, 3))
		if(dead.stat & DEAD)
			dead.revive()
			dead.adjust_oxy_loss(-200)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), dead, 'sound/machines/defib/defib_zap.ogg', 60), 3 SECONDS)

	new /obj/effect/temp_visual/circle_wave(get_turf(holder), COLOR_YELLOW)
	playsound(holder, 'sound/machines/defib/defib_charge.ogg', 80)

/// Look for the nearest power-containing object and suck the power out
/datum/gizpulse/electric/draw/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master

	for(var/atom/movable/power_source in oview(4, holder))
		if(!power_source.get_cell())
			continue

		var/obj/item/stock_parts/power_store/cell = power_source.get_cell()

		var/charge = cell.charge() - electromaster.power.used_charge()
		if(charge <= 0)
			continue

		cell.use(charge)
		electromaster.power.give(charge)

		holder.Beam(power_source, icon_state = "r_beam", time = 5)
		playsound(power_source, 'sound/effects/magic/ethereal_exit.ogg', 40)
		return

/// Give a bit of charge, FOR FREE
/datum/gizpulse/electric/passive_charge
	/// How much we magically charge from nothing per pulse
	var/recharge = STANDARD_BATTERY_CHARGE * 0.001

/datum/gizpulse/electric/passive_charge/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master
	electromaster.power.give(recharge)

	playsound(holder, 'sound/effects/magic/charge.ogg', 50, TRUE)
