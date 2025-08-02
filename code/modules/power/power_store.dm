#define ETHEREAL_CELL_DRAIN_TIME (3.5 SECONDS)
#define ETHEREAL_CELL_POWER_DRAIN (0.75 * STANDARD_CELL_CHARGE)
/// The factor by which we multiply drain to get how much we gain
#define ETHEREAL_CELL_POWER_GAIN_FACTOR 0.08

/**
 * # Power store abstract type
 *
 * Abstract type for a stock part that holds power.
 */
/obj/item/stock_parts/power_store
	name = "power store abstract"
	/// The size icon overlay prefix.
	var/cell_size_prefix = "cell"
	///Current charge in cell units
	var/charge = 0
	/// Standard cell charge used for rating
	var/rating_base = STANDARD_CELL_CHARGE
	///Maximum charge in cell units
	var/maxcharge = STANDARD_CELL_CHARGE
	///If the cell has been booby-trapped by injecting it with plasma. Chance on use() to explode.
	var/rigged = FALSE
	///If the power cell was damaged by an explosion, chance for it to become corrupted and function the same as rigged.
	var/corrupted = FALSE
	///How much power is given per second in a recharger.
	var/chargerate = STANDARD_CELL_RATE * 0.05
	///If true, the cell will state it's maximum charge in it's description
	var/ratingdesc = TRUE
	///If it's a grown that acts as a battery, add a wire overlay to it.
	var/grown_battery = FALSE
	///What charge lige sprite to use, null if no light
	var/charge_light_type = "standard"
	///What connector sprite to use when in a cell charger, null if no connectors
	var/connector_type = "standard"
	///Does the cell start without any charge?
	var/empty = FALSE

/obj/item/stock_parts/power_store/get_cell()
	return src

/obj/item/stock_parts/power_store/get_save_vars()
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, rigged)
	return .

/obj/item/stock_parts/power_store/Initialize(mapload, override_maxcharge)
	. = ..()
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	rating = max(round(maxcharge / (rating_base * 10), 1), 1)
	if(!charge)
		charge = maxcharge
	if(empty)
		charge = 0
	if(ratingdesc)
		desc += " This one has a rating of [display_energy(maxcharge)][prob(10) ? ", and you should not swallow it" : ""]." //joke works better if it's not on every cell
	update_appearance()

	RegisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED, PROC_REF(on_magic_charge))
	var/static/list/loc_connections = list(
		COMSIG_ITEM_MAGICALLY_CHARGED = PROC_REF(on_magic_charge),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/stock_parts/power_store/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!isturf(old_loc))
		update_appearance()


/**
 * Signal proc for [COMSIG_ITEM_MAGICALLY_CHARGED]
 *
 * If we, or the item we're located in, is subject to the charge spell, gain some charge back
 */
/obj/item/stock_parts/power_store/proc/on_magic_charge(datum/source, datum/action/cooldown/spell/charge/spell, mob/living/caster)
	SIGNAL_HANDLER

	// This shouldn't be running if we're not being held by a mob,
	// or if we're not within an object being held by a mob, but just in case...
	if(!ismovable(loc))
		return

	. = COMPONENT_ITEM_CHARGED

	if(prob(80))
		maxcharge -= rating_base * 0.2

	if(maxcharge <= 1) // Div by 0 protection
		maxcharge = 1
		. |= COMPONENT_ITEM_BURNT_OUT

	charge = maxcharge
	update_appearance()

	// Guns need to process their chamber when we've been charged
	if(isgun(loc))
		var/obj/item/gun/gun_loc = loc
		gun_loc.process_chamber()

	// The thing we're in might have overlays or icon states for whether the cell is charged
	if(!ismob(loc))
		loc.update_appearance()

	return .

/obj/item/stock_parts/power_store/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))

/obj/item/stock_parts/power_store/update_overlays()
	. = ..()
	if(grown_battery)
		. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "grown_wires")
	if((charge < 0.01) || !charge_light_type)
		return
	. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "[cell_size_prefix]-[charge_light_type]-o[(percent() >= 99.5) ? 2 : 1]")

/obj/item/stock_parts/power_store/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, charge))
		charge = clamp(vval, 0, maxcharge)
		return TRUE
	if(vname == NAMEOF(src, maxcharge))
		if(charge > vval)
			charge = vval
	if(vname == NAMEOF(src, corrupted) && vval && !corrupted)
		corrupt(TRUE)
		return TRUE
	return ..()


/**
 * Returns the percentage of the cell's charge.
 */
/obj/item/stock_parts/power_store/proc/percent() // return % charge of cell
	return 100 * charge / maxcharge

/**
 * Returns the maximum charge of the cell.
 */
/obj/item/stock_parts/power_store/proc/max_charge()
	return maxcharge

/**
 * Returns the current charge of the cell.
 */
/obj/item/stock_parts/power_store/proc/charge()
	return charge

/**
 * Returns the amount of charge used on the cell.
 */
/obj/item/stock_parts/power_store/proc/used_charge()
	return maxcharge - charge

/// Use power from the cell.
/// Args:
/// - used: Amount of power in joules to use.
/// - force: If true, uses the remaining power from the cell if there isn't enough power to supply the demand.
/// Returns: The power used from the cell in joules.
/obj/item/stock_parts/power_store/use(used, force = FALSE)
	var/power_used = min(used, charge)
	if(rigged && power_used > 0)
		explode()
		return 0 // The cell decided to explode so we won't be able to use it.
	if(!force && charge < used)
		return 0
	charge -= power_used
	if(!istype(loc, /obj/machinery/power/apc))
		SSblackbox.record_feedback("tally", "cell_used", 1, type)
	return power_used

/// Recharge the cell.
/// Args:
/// - amount: The amount of energy to give to the cell in joules.
/// Returns: The power given to the cell in joules.
/obj/item/stock_parts/power_store/proc/give(amount)
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	if(rigged && amount > 0)
		explode()
	return power_used

/**
 * Changes the charge of the cell.
 * Args:
 * - amount: The energy to give to the cell (can be negative).
 * Returns: The energy that was given to the cell (can be negative).
 */
/obj/item/stock_parts/power_store/proc/change(amount)
	var/energy_used = clamp(amount, -charge, maxcharge - charge)
	charge += energy_used
	if(rigged && energy_used)
		explode()
	return energy_used

/obj/item/stock_parts/power_store/examine(mob/user)
	. = ..()
	if(rigged)
		. += span_danger("This [name] seems to be faulty!")
	else if(!isnull(charge_light_type))
		. += "The charge meter reads [CEILING(percent(), 0.1)]%." //so it doesn't say 0% charge when the overlay indicates it still has charge

/obj/item/stock_parts/power_store/proc/on_reagent_change(datum/reagents/holder)
	SIGNAL_HANDLER

	rigged = corrupted || !!holder.has_reagent(/datum/reagent/toxin/plasma, 5) //has_reagent returns the reagent datum

/obj/item/stock_parts/power_store/proc/explode()
	if(!charge)
		return
	var/range_devastation = -1
	var/range_heavy = round(sqrt(charge / (3.6 * rating_base)))
	var/range_light = round(sqrt(charge / (0.9 * rating_base)))
	var/range_flash = range_light
	if(!range_light)
		rigged = FALSE
		corrupt()
		return

	message_admins("[ADMIN_LOOKUPFLW(usr)] has triggered a rigged/corrupted power cell explosion at [AREACOORD(loc)].")
	usr?.log_message("triggered a rigged/corrupted power cell explosion", LOG_GAME)
	usr?.log_message("triggered a rigged/corrupted power cell explosion", LOG_VICTIM, log_globally = FALSE)

	explosion(src, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash)
	qdel(src)

/obj/item/stock_parts/power_store/proc/corrupt(force)
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (force || prob(10))
		rigged = TRUE //broken batterys are dangerous
		corrupted = TRUE

/obj/item/stock_parts/power_store/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	use(STANDARD_CELL_CHARGE / severity, force = TRUE)

/obj/item/stock_parts/power_store/ex_act(severity, target)
	. = ..()
	if(QDELETED(src))
		return FALSE

	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				corrupt()
		if(EXPLODE_LIGHT)
			if(prob(25))
				corrupt()

	return TRUE

/obj/item/stock_parts/power_store/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	do_sparks(2, TRUE, user)
	var/eating_success = do_after(user, 5 SECONDS, src)
	if(QDELETED(user))
		return SHAME
	if(!eating_success || QDELETED(src) || charge == 0)
		user.visible_message(span_suicide("[user] chickens out!"))
		return SHAME
	playsound(user, 'sound/effects/sparks/sparks1.ogg', charge / maxcharge)
	var/damage = charge / (1 KILO JOULES)
	var/discharged_energy = charge
	user.electrocute_act(damage, src, 1, SHOCK_IGNORE_IMMUNITY|SHOCK_DELAY_STUN|SHOCK_NOGLOVES)
	charge = 0
	update_appearance()
	if(user.stat != DEAD)
		to_chat(user, span_suicide("There's not enough charge in [src] to kill you!"))
		return SHAME
	addtimer(CALLBACK(src, PROC_REF(gib_user), user, discharged_energy), 3 SECONDS)
	return MANUAL_SUICIDE

/obj/item/stock_parts/power_store/proc/gib_user(mob/living/user, discharged_energy)
	if(QDELETED(user))
		return
	if(discharged_energy < STANDARD_BATTERY_CHARGE)
		return
	user.dropItemToGround(src)
	user.dust(just_ash = TRUE)
	playsound(src, 'sound/effects/magic/lightningshock.ogg', 50, TRUE, 10)
	tesla_zap(source = src, zap_range = 10, power = discharged_energy)

/obj/item/stock_parts/power_store/attack_self(mob/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/stomach/ethereal/user_stomach = human_user.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!istype(user_stomach))
		return
	if(user_stomach.drain_time > world.time)
		return

	ethereal_drain(human_user, user_stomach)

/// Handles letting an ethereal drain our charge into their stomach
/obj/item/stock_parts/power_store/proc/ethereal_drain(mob/living/carbon/human/user, obj/item/organ/stomach/ethereal/used_stomach)
	if(charge() <= 0)
		balloon_alert(user, "out of charge!")
		return

	var/obj/item/stock_parts/power_store/stomach_cell = used_stomach.cell
	used_stomach.drain_time = world.time + ETHEREAL_CELL_DRAIN_TIME
	to_chat(user, span_notice("You begin clumsily channeling power from [src] into your body."))

	while(do_after(user, ETHEREAL_CELL_DRAIN_TIME, target = src))
		if(isnull(used_stomach) || (used_stomach != user.get_organ_slot(ORGAN_SLOT_STOMACH)))
			balloon_alert(user, "stomach removed!?")
			return

		var/our_charge = charge()
		var/scaled_stomach_used_charge = stomach_cell.used_charge() / ETHEREAL_CELL_POWER_GAIN_FACTOR
		var/potential_charge = min(our_charge, scaled_stomach_used_charge)
		var/to_drain = min(ETHEREAL_CELL_POWER_DRAIN, potential_charge)
		var/energy_drained = use(to_drain, force = TRUE)
		used_stomach.adjust_charge(energy_drained * ETHEREAL_CELL_POWER_GAIN_FACTOR)
		update_appearance(UPDATE_OVERLAYS)

		if(stomach_cell.used_charge() <= 0)
			balloon_alert(user, "your charge is full!")
			return
		if(charge() <= 0)
			balloon_alert(user, "out of charge!")
			return

/obj/item/stock_parts/power_store/blob_act(obj/structure/blob/B)
	SSexplosions.high_mov_atom += src

/obj/item/stock_parts/power_store/proc/get_electrocute_damage()
	return ELECTROCUTE_DAMAGE(charge / max(0.001 * STANDARD_CELL_CHARGE, 1)) // Wouldn't want it to consider more energy than whatever is actually in the cell if for some strange reason someone set the STANDARD_CELL_CHARGE to below 1kJ.

/obj/item/stock_parts/power_store/get_part_rating()
	return maxcharge * 10 + charge

#undef ETHEREAL_CELL_DRAIN_TIME
#undef ETHEREAL_CELL_POWER_DRAIN
#undef ETHEREAL_CELL_POWER_GAIN_FACTOR
