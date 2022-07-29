/// How much time (in seconds) is assumed to pass while assuming air. Used to scale overpressure/overtemp damage when assuming air.
#define ASSUME_AIR_DT_FACTOR 1

/**
 * # Gas Tank
 *
 * Handheld gas canisters
 * Can rupture explosively if overpressurized
 */
/obj/item/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	icon_state = "generic"
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	worn_icon = 'icons/mob/clothing/back.dmi' //since these can also get thrown into suit storage slots. if something goes on the belt, set this to null.
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	demolition_mod = 1.25
	custom_materials = list(/datum/material/iron = 500)
	actions_types = list(/datum/action/item_action/set_internals)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 80, ACID = 30)
	integrity_failure = 0.5
	/// The gases this tank contains. Don't modify this directly, use return_air() to get it instead
	var/datum/gas_mixture/air_contents = null
	/// The volume of this tank. Among other things gas tank explosions (including TTVs) scale off of this. Be sure to account for that if you change this or you will break ~~toxins~~ordinance.
	var/volume = TANK_STANDARD_VOLUME
	/// Whether the tank is currently leaking.
	var/leaking = FALSE
	/// The pressure of the gases this tank supplies to internals.
	var/distribute_pressure = ONE_ATMOSPHERE
	/// Icon state when in a tank holder. Null makes it incompatible with tank holder.
	var/tank_holder_icon_state = "holder_generic"
	///Used by process() to track if there's a reason to process each tick
	var/excited = TRUE
	/// How our particular tank explodes.
	var/list/explosion_info
	/// List containing reactions happening inside our tank.
	var/list/reaction_info

/obj/item/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/tank/proc/toggle_internals(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return

	if(H.internal == src)
		to_chat(H, span_notice("You close [src] valve."))
		H.internal = null
	else
		if(!H.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			if(!H.wear_mask)
				to_chat(H, span_warning("You need a mask!"))
				return
			var/is_clothing = isclothing(H.wear_mask)
			if(is_clothing && H.wear_mask.mask_adjusted)
				H.wear_mask.adjustmask(H)
			if(!is_clothing || !(H.wear_mask.clothing_flags & MASKINTERNALS))
				to_chat(H, span_warning("[H.wear_mask] can't use [src]!"))
				return

		if(H.internal)
			to_chat(H, span_notice("You switch your internals to [src]."))
		else
			to_chat(H, span_notice("You open [src] valve."))
		H.internal = src
	H.update_action_buttons_icon()


/obj/item/tank/Initialize(mapload)
	. = ..()

	air_contents = new(volume) //liters
	air_contents.temperature = T20C

	populate_gas()

	reaction_info = list()
	explosion_info = list()

	AddComponent(/datum/component/atmos_reaction_recorder, reset_criteria = list(COMSIG_GASMIX_MERGING = air_contents, COMSIG_GASMIX_REMOVING = air_contents), target_list = reaction_info)

	// This is separate from the reaction recorder.
	// In this case we are only listening to determine if the tank is overpressurized but not destroyed.
	RegisterSignal(air_contents, COMSIG_GASMIX_MERGED, .proc/merging_information)

	START_PROCESSING(SSobj, src)

/obj/item/tank/proc/populate_gas()
	return

/obj/item/tank/ComponentInitialize()
	. = ..()
	if(tank_holder_icon_state)
		AddComponent(/datum/component/container_item/tank_holder, tank_holder_icon_state)

/obj/item/tank/Destroy()
	UnregisterSignal(air_contents, COMSIG_GASMIX_MERGED)
	air_contents = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/tank/examine(mob/user)
	var/obj/icon = src
	. = ..()
	if(istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if(!in_range(src, user) && !isobserver(user))
		if(icon == src)
			. += span_notice("If you want any more information you'll need to get closer.")
		return

	. += span_notice("The pressure gauge reads [round(src.air_contents.return_pressure(),0.01)] kPa.")

	var/celsius_temperature = air_contents.temperature-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	. += span_notice("It feels [descriptive].")

/obj/item/tank/deconstruct(disassembled = TRUE)
	var/atom/location = loc
	if(location)
		location.assume_air(air_contents)
		playsound(location, 'sound/effects/spray.ogg', 10, TRUE, -3)
	return ..()

/obj/item/tank/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	user.visible_message(span_suicide("[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	if(!QDELETED(H) && air_contents && air_contents.return_pressure() >= 1000)
		ADD_TRAIT(H, TRAIT_DISFIGURED, TRAIT_GENERIC)
		H.inflate_gib()
		return MANUAL_SUICIDE
	else
		to_chat(user, span_warning("There isn't enough pressure in [src] to commit suicide with..."))
	return SHAME

/obj/item/tank/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/assembly_holder))
		bomb_assemble(W, user)
		return TRUE
	return ..()

/obj/item/tank/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/tank/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tank", name)
		ui.open()

/obj/item/tank/ui_static_data(mob/user)
	. = list (
		"defaultReleasePressure" = round(TANK_DEFAULT_RELEASE_PRESSURE),
		"minReleasePressure" = round(TANK_MIN_RELEASE_PRESSURE),
		"maxReleasePressure" = round(TANK_MAX_RELEASE_PRESSURE),
		"leakPressure" = round(TANK_LEAK_PRESSURE),
		"fragmentPressure" = round(TANK_FRAGMENT_PRESSURE)
	)

/obj/item/tank/ui_data(mob/user)
	. = list(
		"tankPressure" = round(air_contents.return_pressure()),
		"releasePressure" = round(distribute_pressure)
	)

	var/mob/living/carbon/C = user
	if(!istype(C))
		C = loc.loc
	if(istype(C) && C.internal == src)
		.["connected"] = TRUE

/obj/item/tank/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(distribute_pressure)
				. = TRUE
			else if(pressure == "min")
				pressure = TANK_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				distribute_pressure = clamp(round(pressure), TANK_MIN_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)

/obj/item/tank/remove_air(amount)
	START_PROCESSING(SSobj, src)
	return air_contents.remove(amount)

/obj/item/tank/return_air()
	START_PROCESSING(SSobj, src)
	return air_contents

/obj/item/tank/return_analyzable_air()
	return air_contents

/obj/item/tank/assume_air(datum/gas_mixture/giver)
	START_PROCESSING(SSobj, src)
	air_contents.merge(giver)
	handle_tolerances(ASSUME_AIR_DT_FACTOR)
	return TRUE

/**
 * Removes some volume of the tanks gases as the tanks distribution pressure.
 *
 * Arguments:
 * - volume_to_return: The amount of volume to remove from the tank.
 */
/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	var/actual_distribute_pressure = clamp(tank_pressure, 0, distribute_pressure)

	// Lets do some algebra to understand why this works, yeah?
	// R_IDEAL_GAS_EQUATION is (kPa * L) / (K * mol) by the by, so the units in this equation look something like this
	// kpa * L / (R_IDEAL_GAS_EQUATION * K)
	// Or restated (kpa * L / K) * 1/R_IDEAL_GAS_EQUATION
	// (kpa * L * K * mol) / (kpa * L * K)
	// If we cancel it all out, we get moles, which is the expected unit
	// This sort of thing comes up often in atmos, keep the tool in mind for other bits of code
	var/moles_needed = actual_distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	return remove_air(moles_needed)

/obj/item/tank/process(delta_time)
	if(!air_contents)
		return

	//Allow for reactions
	excited = (excited | air_contents.react(src))
	excited = (excited | handle_tolerances(delta_time))
	excited = (excited | leaking)

	if(!excited)
		STOP_PROCESSING(SSobj, src)
	excited = FALSE

	if(QDELETED(src) || !leaking || !air_contents)
		return
	var/atom/location = loc
	if(!location)
		return
	var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
	location.assume_air(leaked_gas)

/**
 * Handles the minimum and maximum pressure tolerances of the tank.
 *
 * Returns true if it did anything of significance, false otherwise
 * Arguments:
 * - delta_time: How long has passed between ticks.
 */
/obj/item/tank/proc/handle_tolerances(delta_time)
	if(!air_contents)
		return FALSE

	var/pressure = air_contents.return_pressure()
	var/temperature = air_contents.return_temperature()
	if(temperature >= TANK_MELT_TEMPERATURE)
		var/temperature_damage_ratio = (temperature - TANK_MELT_TEMPERATURE) / temperature
		take_damage(max_integrity * temperature_damage_ratio * delta_time, BURN, FIRE, FALSE, NONE)
		if(QDELETED(src))
			return TRUE

	if(pressure >= TANK_LEAK_PRESSURE)
		var/pressure_damage_ratio = (pressure - TANK_LEAK_PRESSURE) / (TANK_RUPTURE_PRESSURE - TANK_LEAK_PRESSURE)
		take_damage(max_integrity * pressure_damage_ratio * delta_time, BRUTE, BOMB, FALSE, NONE)
		return TRUE
	return FALSE

/// Handles the tank springing a leak.
/obj/item/tank/atom_break(damage_flag)
	. = ..()
	if(leaking)
		return

	leaking = TRUE
	START_PROCESSING(SSobj, src)

	if(atom_integrity < 0) // So we don't play the alerts while we are exploding or rupturing.
		return
	visible_message(span_warning("[src] springs a leak!"))
	playsound(src, 'sound/effects/spray.ogg', 10, TRUE, -3)

/// Handles rupturing and fragmenting
/obj/item/tank/atom_destruction(damage_flag)
	if(!air_contents)
		return ..()

	/// Handle fragmentation
	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(loc, /obj/item/transfer_valve))
			log_bomber(get_mob_by_key(fingerprintslast), "was last key to touch", src, "which ruptured explosively")
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react(src)
		pressure = air_contents.return_pressure()

		// As of writing this this is calibrated to maxcap at 140L and 160atm.
		var/power = (air_contents.volume * (pressure - TANK_FRAGMENT_PRESSURE)) / TANK_FRAGMENT_SCALE
		log_atmos("[type] exploded with a power of [power] and a mix of ", air_contents)
		dyn_explosion(src, power, flash_range = 1.5, ignorecap = FALSE)
	return ..()

/obj/item/tank/proc/merging_information()
	SIGNAL_HANDLER
	if(air_contents.return_pressure() > TANK_FRAGMENT_PRESSURE)
		explosion_info += TANK_MERGE_OVERPRESSURE

/obj/item/tank/proc/explosion_information()
	return list(TANK_RESULTS_REACTION = reaction_info, TANK_RESULTS_MISC = explosion_info)

#undef ASSUME_AIR_DT_FACTOR
