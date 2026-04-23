/// Suck power and shoot it out again
/datum/gizmodes/electric
	possible_active_modes = list(
		/datum/gizpulse/electric/emp = 1,
		/datum/gizpulse/electric/discharge = 1,
	)

	guaranteed_active_gizmodes = list(
		GIZMO_PICK_ONE = list(
			/datum/gizpulse/electric/charge = 1,
		)
	)

	cooldown_time = 6 SECONDS

	/// The internal power cell
	var/obj/item/stock_parts/power_store/battery/power

/datum/gizmodes/electric/activate(atom/movable/holder)
	if(!power)
		power = new(holder)

	return ..()

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

/// Look for the nearest power-containing object and suck the power out
/datum/gizpulse/electric/charge/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
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

		holder.Beam(power_source, icon_state = "g_beam", time = 5)
		playsound(power_source, 'sound/effects/magic/ethereal_exit.ogg', 40)
		return
