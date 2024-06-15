#define CELL_DRAIN_TIME 35
#define CELL_POWER_GAIN (0.06 * STANDARD_CELL_CHARGE)
#define CELL_POWER_DRAIN (0.75 * STANDARD_CELL_CHARGE)

/**
 * # Power cell
 *
 * Batteries.
 */
/obj/item/stock_parts/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cell"
	inhand_icon_state = "cell"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*7, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)
	grind_results = list(/datum/reagent/lithium = 15, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	///Current charge in cell units
	var/charge = 0
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

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/item/stock_parts/cell/Initialize(mapload, override_maxcharge)
	. = ..()
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	rating = max(round(maxcharge / (STANDARD_CELL_CHARGE * 10), 1), 1)
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

/**
 * Signal proc for [COMSIG_ITEM_MAGICALLY_CHARGED]
 *
 * If we, or the item we're located in, is subject to the charge spell, gain some charge back
 */
/obj/item/stock_parts/cell/proc/on_magic_charge(datum/source, datum/action/cooldown/spell/charge/spell, mob/living/caster)
	SIGNAL_HANDLER

	// This shouldn't be running if we're not being held by a mob,
	// or if we're not within an object being held by a mob, but just in case...
	if(!ismovable(loc))
		return

	. = COMPONENT_ITEM_CHARGED

	if(prob(80))
		maxcharge -= STANDARD_CELL_CHARGE * 0.2

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

/obj/item/stock_parts/cell/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_QDELETING, PROC_REF(on_reagents_del))

/// Handles properly detaching signal hooks.
/obj/item/stock_parts/cell/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_QDELETING))
	return NONE

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "grown_wires")
	if((charge < 0.01) || !charge_light_type)
		return
	. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "cell-[charge_light_type]-o[(percent() >= 99.5) ? 2 : 1]")

/obj/item/stock_parts/cell/vv_edit_var(vname, vval)
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
/obj/item/stock_parts/cell/proc/percent() // return % charge of cell
	return 100 * charge / maxcharge

/**
 * Returns the maximum charge of the cell.
 */
/obj/item/stock_parts/cell/proc/max_charge()
	return maxcharge

/**
 * Returns the current charge of the cell.
 */
/obj/item/stock_parts/cell/proc/charge()
	return charge

/**
 * Returns the amount of charge used on the cell.
 */
/obj/item/stock_parts/cell/proc/used_charge()
	return maxcharge - charge

/// Use power from the cell.
/// Args:
/// - used: Amount of power in joules to use.
/// - force: If true, uses the remaining power from the cell if there isn't enough power to supply the demand.
/// Returns: The power used from the cell in joules.
/obj/item/stock_parts/cell/use(used, force = FALSE)
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
/obj/item/stock_parts/cell/proc/give(amount)
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
/obj/item/stock_parts/cell/proc/change(amount)
	var/energy_used = clamp(amount, -charge, maxcharge - charge)
	charge += energy_used
	if(rigged && energy_used)
		explode()
	return energy_used

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()
	if(rigged)
		. += span_danger("This power cell seems to be faulty!")
	else
		. += "The charge meter reads [CEILING(percent(), 0.1)]%." //so it doesn't say 0% charge when the overlay indicates it still has charge

/obj/item/stock_parts/cell/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS

/obj/item/stock_parts/cell/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	rigged = (corrupted || holder.has_reagent(/datum/reagent/toxin/plasma, 5)) ? TRUE : FALSE //has_reagent returns the reagent datum
	return NONE


/obj/item/stock_parts/cell/proc/explode()
	if(!charge)
		return
	var/range_devastation = -1
	var/range_heavy = round(sqrt(charge / (3.6 * STANDARD_CELL_CHARGE)))
	var/range_light = round(sqrt(charge / (0.9 * STANDARD_CELL_CHARGE)))
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

/obj/item/stock_parts/cell/proc/corrupt(force)
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (force || prob(10))
		rigged = TRUE //broken batterys are dangerous
		corrupted = TRUE

/obj/item/stock_parts/cell/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	use(STANDARD_CELL_CHARGE / severity, force = TRUE)

/obj/item/stock_parts/cell/ex_act(severity, target)
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

/obj/item/stock_parts/cell/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/stomach/maybe_stomach = H.get_organ_slot(ORGAN_SLOT_STOMACH)

		if(istype(maybe_stomach, /obj/item/organ/internal/stomach/ethereal))

			var/charge_limit = ETHEREAL_CHARGE_DANGEROUS - CELL_POWER_GAIN
			var/obj/item/organ/internal/stomach/ethereal/stomach = maybe_stomach
			var/obj/item/stock_parts/cell/stomach_cell = stomach.cell
			if((stomach.drain_time > world.time) || !stomach)
				return
			if(charge < CELL_POWER_DRAIN)
				to_chat(H, span_warning("[src] doesn't have enough power!"))
				return
			if(stomach_cell.charge() > charge_limit)
				to_chat(H, span_warning("Your charge is full!"))
				return
			to_chat(H, span_notice("You begin clumsily channeling power from [src] into your body."))
			stomach.drain_time = world.time + CELL_DRAIN_TIME
			while(do_after(user, CELL_DRAIN_TIME, target = src))
				if((charge < CELL_POWER_DRAIN) || (stomach_cell.charge() > charge_limit))
					return
				if(istype(stomach))
					to_chat(H, span_notice("You receive some charge from [src], wasting some in the process."))
					stomach.adjust_charge(CELL_POWER_GAIN)
					charge -= CELL_POWER_DRAIN //you waste way more than you receive, so that ethereals cant just steal one cell and forget about hunger
				else
					to_chat(H, span_warning("You can't receive charge from [src]!"))
			return


/obj/item/stock_parts/cell/blob_act(obj/structure/blob/B)
	SSexplosions.high_mov_atom += src

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	return ELECTROCUTE_DAMAGE(charge / max(0.001 * STANDARD_CELL_CHARGE, 1)) // Wouldn't want it to consider more energy than whatever is actually in the cell if for some strange reason someone set the STANDARD_CELL_CHARGE to below 1kJ.

/obj/item/stock_parts/cell/get_part_rating()
	return maxcharge * 10 + charge

/* Cell variants*/
/obj/item/stock_parts/cell/empty
	empty = TRUE

/obj/item/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargeable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = STANDARD_CELL_CHARGE * 0.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4)

/obj/item/stock_parts/cell/crap/empty
	empty = TRUE

/obj/item/stock_parts/cell/upgraded
	name = "upgraded power cell"
	desc = "A power cell with a slightly higher capacity than normal!"
	maxcharge = STANDARD_CELL_CHARGE * 2.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)
	chargerate = STANDARD_CELL_RATE * 0.5

/obj/item/stock_parts/cell/upgraded/plus
	name = "upgraded power cell+"
	desc = "A power cell with an even higher capacity than the base model!"
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/cell/secborg
	name = "security borg rechargeable D battery"
	maxcharge = STANDARD_CELL_CHARGE * 0.6
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4)

/obj/item/stock_parts/cell/secborg/empty
	empty = TRUE

/obj/item/stock_parts/cell/mini_egun
	name = "miniature energy gun power cell"
	maxcharge = STANDARD_CELL_CHARGE * 0.6

/obj/item/stock_parts/cell/hos_gun
	name = "X-01 multiphase energy gun power cell"
	maxcharge = STANDARD_CELL_CHARGE * 1.2

/obj/item/stock_parts/cell/pulse //200 pulse shots
	name = "pulse rifle power cell"
	maxcharge = STANDARD_CELL_CHARGE * 40
	chargerate = STANDARD_CELL_RATE * 0.75

/obj/item/stock_parts/cell/pulse/carbine //25 pulse shots
	name = "pulse carbine power cell"
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/cell/pulse/pistol //10 pulse shots
	name = "pulse pistol power cell"
	maxcharge = STANDARD_CELL_CHARGE * 2

/obj/item/stock_parts/cell/ninja
	name = "black power cell"
	icon_state = "bscell"
	maxcharge = STANDARD_CELL_CHARGE * 10
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.6)
	chargerate = STANDARD_CELL_RATE

/obj/item/stock_parts/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = STANDARD_CELL_CHARGE * 10
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.6)
	chargerate = STANDARD_CELL_RATE * 0.75

/obj/item/stock_parts/cell/high/empty
	empty = TRUE

/obj/item/stock_parts/cell/super
	name = "super-capacity power cell"
	icon_state = "scell"
	maxcharge = STANDARD_CELL_CHARGE * 20
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 3)
	chargerate = STANDARD_CELL_RATE

/obj/item/stock_parts/cell/super/empty
	empty = TRUE

/obj/item/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	icon_state = "hpcell"
	maxcharge = STANDARD_CELL_CHARGE * 30
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 4)
	chargerate = STANDARD_CELL_RATE * 1.5

/obj/item/stock_parts/cell/hyper/empty
	empty = TRUE

/obj/item/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable transdimensional power cell."
	icon_state = "bscell"
	maxcharge = STANDARD_CELL_CHARGE * 40
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*6)
	chargerate = STANDARD_CELL_RATE * 2

/obj/item/stock_parts/cell/bluespace/empty
	empty = TRUE

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell"
	icon_state = "icell"
	maxcharge = INFINITY //little disappointing if you examine it and it's not huge
	custom_materials = list(/datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT)
	chargerate = INFINITY
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/use(used, force = FALSE)
	return TRUE

/obj/item/stock_parts/cell/infinite/abductor
	name = "void core"
	desc = "An alien power cell that produces energy seemingly out of nowhere."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "cell"
	maxcharge = STANDARD_CELL_CHARGE * 50
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/abductor/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch based power cell."
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "potato"
	maxcharge = STANDARD_CELL_CHARGE * 0.3
	charge_light_type = null
	connector_type = null
	custom_materials = null
	grown_battery = TRUE //it has the overlays for wires
	custom_premium_price = PAYCHECK_CREW

/obj/item/stock_parts/cell/potato/Initialize(mapload, override_maxcharge)
	charge = maxcharge * 0.3
	. = ..()

/obj/item/stock_parts/cell/emproof
	name = "\improper EMP-proof cell"
	desc = "An EMP-proof cell."
	maxcharge = STANDARD_CELL_CHARGE * 0.5

/obj/item/stock_parts/cell/emproof/Initialize(mapload)
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)
	return ..()

/obj/item/stock_parts/cell/emproof/empty
	empty = TRUE

/obj/item/stock_parts/cell/emproof/corrupt()
	return

/obj/item/stock_parts/cell/emproof/slime
	name = "EMP-proof slime core"
	desc = "A yellow slime core infused with plasma. Its organic nature makes it immune to EMPs."
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "yellow-core"
	custom_materials = null
	maxcharge = STANDARD_CELL_CHARGE * 5
	charge_light_type = null
	connector_type = "slimecore"

/obj/item/stock_parts/cell/beam_rifle
	name = "beam rifle capacitor"
	desc = "A high powered capacitor that can provide huge amounts of energy in an instant."
	maxcharge = STANDARD_CELL_CHARGE * 50
	chargerate = STANDARD_CELL_RATE * 2.5 //Extremely energy intensive

/obj/item/stock_parts/cell/beam_rifle/corrupt()
	return

/obj/item/stock_parts/cell/beam_rifle/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	charge = clamp((charge-(10000/severity)),0,maxcharge)

/obj/item/stock_parts/cell/emergency_light
	name = "miniature power cell"
	desc = "A tiny power cell with a very low power capacity. Used in light fixtures to power them in the event of an outage."
	maxcharge = STANDARD_CELL_CHARGE * 0.12 //Emergency lights use 0.2 W per tick, meaning ~10 minutes of emergency power from a cell
	custom_materials = list(/datum/material/glass = SMALL_MATERIAL_AMOUNT*0.2)
	w_class = WEIGHT_CLASS_TINY

/obj/item/stock_parts/cell/emergency_light/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	if(area)
		if(!area.lightswitch || !area.light_power)
			charge = 0 //For naturally depowered areas, we start with no power

/obj/item/stock_parts/cell/crystal_cell
	name = "crystal power cell"
	desc = "A very high power cell made from crystallized plasma"
	icon_state = "crystal_cell"
	maxcharge = STANDARD_CELL_CHARGE * 50
	chargerate = 0
	charge_light_type = null
	connector_type = "crystal"
	custom_materials = null
	grind_results = null

/obj/item/stock_parts/cell/inducer_supply
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/cell/ethereal
	name = "ahelp it"
	desc = "you sohuldn't see this"
	maxcharge = ETHEREAL_CHARGE_DANGEROUS
	charge = ETHEREAL_CHARGE_FULL
	icon_state = null
	charge_light_type = null
	connector_type = null
	custom_materials = null
	grind_results = null

/obj/item/stock_parts/cell/ethereal/examine(mob/user)
	. = ..()
	CRASH("[src.type] got examined by [user]")

#undef CELL_DRAIN_TIME
#undef CELL_POWER_GAIN
#undef CELL_POWER_DRAIN
