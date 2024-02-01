/// How much time (in seconds) is assumed to pass while assuming air. Used to scale overpressure/overtemp damage when assuming air.
#define ASSUME_AIR_DT_FACTOR 1
/// Multiplies the pressure of assembly bomb explosions before it's put through THE LOGARITHM
#define ASSEMBLY_BOMB_COEFFICIENT 0.5
/// Base of the logarithmic function used to calculate assembly bomb explosion size
#define ASSEMBLY_BOMB_BASE 2.7

/**
 * # Gas Tank
 *
 * Handheld gas canisters
 * Can rupture explosively if overpressurized
 */
/obj/item/tank
	name = "tank"
	icon = 'icons/obj/canisters.dmi'
	icon_state = "generic"
	inhand_icon_state = "generic_tank"
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BACK
	worn_icon = 'icons/mob/clothing/back.dmi' //since these can also get thrown into suit storage slots. if something goes on the belt, set this to null.
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	demolition_mod = 1.25
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)
	actions_types = list(/datum/action/item_action/set_internals)
	armor_type = /datum/armor/item_tank
	integrity_failure = 0.5
	/// If we are in the process of exploding, stops multi explosions
	var/igniting = FALSE
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
	/// Mob that is currently breathing from the tank.
	var/mob/living/carbon/breathing_mob = null
	/// Attached assembly, can either detonate the tank or release its contents when receiving a signal
	var/obj/item/assembly_holder/tank_assembly
	/// Whether or not it will try to explode when it receives a signal
	var/bomb_status = FALSE

/// Closes the tank if dropped while open.
/datum/armor/item_tank
	bomb = 10
	fire = 80
	acid = 30

/obj/item/tank/dropped(mob/living/user, silent)
	. = ..()
	// Close open air tank if its current user got sent to the shadowrealm.
	if (QDELETED(breathing_mob))
		breathing_mob = null
		return
	// Close open air tank if it got dropped by it's current user.
	if (loc != breathing_mob)
		breathing_mob.cutoff_internals()

/// Closes the tank if given to another mob while open.
/obj/item/tank/equipped(mob/living/user, slot, initial)
	. = ..()
	// Close open air tank if it was equipped by a mob other than the current user.
	if (breathing_mob && (user != breathing_mob))
		breathing_mob.cutoff_internals()

/// Called by carbons after they connect the tank to their breathing apparatus.
/obj/item/tank/proc/after_internals_opened(mob/living/carbon/carbon_target)
	breathing_mob = carbon_target
	RegisterSignal(carbon_target, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

/// Called by carbons after they disconnect the tank from their breathing apparatus.
/obj/item/tank/proc/after_internals_closed(mob/living/carbon/carbon_target)
	breathing_mob = null
	UnregisterSignal(carbon_target, COMSIG_MOB_GET_STATUS_TAB_ITEMS)

/obj/item/tank/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Internal Atmosphere Info: [name]"
	items += "Tank Pressure: [air_contents.return_pressure()] kPa"
	items += "Distribution Pressure: [distribute_pressure] kPa"

/// Attempts to toggle the mob's internals on or off using this tank. Returns TRUE if successful.
/obj/item/tank/proc/toggle_internals(mob/living/carbon/mob_target)
	return mob_target.toggle_internals(src)

/obj/item/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/tank/Initialize(mapload)
	. = ..()

	if(tank_holder_icon_state)
		AddComponent(/datum/component/container_item/tank_holder, tank_holder_icon_state)

	air_contents = new(volume) //liters
	air_contents.temperature = T20C

	populate_gas()

	reaction_info = list()
	explosion_info = list()

	AddComponent(/datum/component/atmos_reaction_recorder, reset_criteria = list(COMSIG_GASMIX_MERGING = air_contents, COMSIG_GASMIX_REMOVING = air_contents), target_list = reaction_info)

	// This is separate from the reaction recorder.
	// In this case we are only listening to determine if the tank is overpressurized but not destroyed.
	RegisterSignal(air_contents, COMSIG_GASMIX_MERGED, PROC_REF(merging_information))

	START_PROCESSING(SSobj, src)

/obj/item/tank/proc/populate_gas()
	return

/obj/item/tank/Destroy()
	STOP_PROCESSING(SSobj, src)
	air_contents = null
	if(tank_assembly)
		QDEL_NULL(tank_assembly)
	return ..()

/obj/item/tank/update_overlays()
	. = ..()
	if(tank_assembly)
		. += tank_assembly.icon_state
		. += tank_assembly.overlays
		. += "bomb_assembly"

/obj/item/tank/examine(mob/user)
	var/obj/icon = src
	. = ..()
	if(istype(loc, /obj/item/assembly))
		icon = loc
	if(!in_range(src, user) && !isobserver(user))
		if(icon == src)
			. += span_notice("If you want any more information you'll need to get closer.")
		return

	. += span_notice("The pressure gauge reads [round(air_contents.return_pressure(),0.01)] kPa.")

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

	if(tank_assembly)
		. += span_warning("There is some kind of device <b>rigged</b> to the tank!")

/obj/item/tank/deconstruct(disassembled = TRUE)
	var/atom/location = loc
	if(location)
		location.assume_air(air_contents)
		playsound(location, 'sound/effects/spray.ogg', 10, TRUE, -3)
	return ..()

/obj/item/tank/suicide_act(mob/living/user)
	var/mob/living/carbon/human/human_user = user
	user.visible_message(span_suicide("[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	if(!QDELETED(human_user) && air_contents && air_contents.return_pressure() >= 1000)
		ADD_TRAIT(human_user, TRAIT_DISFIGURED, TRAIT_GENERIC)
		human_user.inflate_gib()
		return MANUAL_SUICIDE
	to_chat(user, span_warning("There isn't enough pressure in [src] to commit suicide with..."))
	return SHAME

/obj/item/tank/attackby(obj/item/attacking_item, mob/user, params)
	add_fingerprint(user)
	if(istype(attacking_item, /obj/item/assembly_holder))
		if(tank_assembly)
			balloon_alert(user, "something is already attached!")
			return TRUE
		bomb_assemble(attacking_item, user)
		return TRUE
	return ..()

/obj/item/tank/wrench_act(mob/living/user, obj/item/tool)
	if(tank_assembly)
		tool.play_tool_sound(src)
		bomb_disassemble(user)
		return TRUE
	return ..()

/obj/item/tank/welder_act(mob/living/user, obj/item/tool)
	if(bomb_status)
		balloon_alert(user, "already welded!")
		return TRUE
	if(tool.use_tool(src, user, 0, volume=40))
		bomb_status = TRUE
		balloon_alert(user, "bomb is now armed")
		log_bomber(user, "welded a single tank bomb,", src, "| Temp: [air_contents.temperature] Pressure: [air_contents.return_pressure()]")
		to_chat(user, span_notice("A pressure hole has been bored to [src]'s valve. \The [src] can now be ignited."))
		add_fingerprint(user)
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

	var/mob/living/carbon/carbon_user = user
	if(!istype(carbon_user))
		carbon_user = loc
	if(istype(carbon_user) && (carbon_user.external == src || carbon_user.internal == src))
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

/obj/item/tank/process(seconds_per_tick)
	if(!air_contents)
		return

	//Allow for reactions
	excited = (excited | air_contents.react(src))
	excited = (excited | handle_tolerances(seconds_per_tick))
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
 * - seconds_per_tick: How long has passed between ticks.
 */
/obj/item/tank/proc/handle_tolerances(seconds_per_tick)
	if(!air_contents)
		return FALSE

	var/pressure = air_contents.return_pressure()
	var/temperature = air_contents.return_temperature()
	if(temperature >= TANK_MELT_TEMPERATURE)
		var/temperature_damage_ratio = (temperature - TANK_MELT_TEMPERATURE) / temperature
		take_damage(max_integrity * temperature_damage_ratio * seconds_per_tick, BURN, FIRE, FALSE, NONE)
		if(QDELETED(src))
			return TRUE

	if(pressure >= TANK_LEAK_PRESSURE)
		var/pressure_damage_ratio = (pressure - TANK_LEAK_PRESSURE) / (TANK_RUPTURE_PRESSURE - TANK_LEAK_PRESSURE)
		take_damage(max_integrity * pressure_damage_ratio * seconds_per_tick, BRUTE, BOMB, FALSE, NONE)
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
	else
		release()
	return ..()

/obj/item/tank/proc/merging_information()
	SIGNAL_HANDLER
	if(air_contents.return_pressure() > TANK_FRAGMENT_PRESSURE)
		explosion_info += TANK_MERGE_OVERPRESSURE

/obj/item/tank/proc/explosion_information()
	return list(TANK_RESULTS_REACTION = reaction_info, TANK_RESULTS_MISC = explosion_info)

/obj/item/tank/on_found(mob/finder) //for mousetraps
	..()
	if(tank_assembly)
		tank_assembly.on_found(finder)

/obj/item/tank/attack_hand() //also for mousetraps
	if(..())
		return
	if(tank_assembly)
		tank_assembly.attack_hand()

/obj/item/tank/Move()
	. = ..()
	if(tank_assembly)
		tank_assembly.setDir(dir)
		tank_assembly.Move()

/obj/item/tank/dropped()
	. = ..()
	if(tank_assembly)
		tank_assembly.dropped()

/obj/item/tank/IsSpecialAssembly()
	return TRUE

/obj/item/tank/receive_signal() //This is mainly called by the sensor through sense() to the holder, and from the holder to here.
	audible_message(span_warning("[icon2html(src, hearers(src))] *beep* *beep* *beep*"))
	playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	if(bomb_status)
		ignite() //if its not a dud, boom (or not boom if you made shitty mix) the ignite proc is below, in this file
	else
		release()

/// Attaches an assembly holder to the tank to create a bomb.
/obj/item/tank/proc/bomb_assemble(obj/item/assembly_holder/assembly, mob/living/user)
	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
	var/igniter_count = 0
	for(var/obj/item/assembly/attached_assembly as anything in assembly.assemblies)
		if(isigniter(attached_assembly))
			igniter_count += 1
	if(LAZYLEN(assembly.assemblies) == igniter_count)
		return

	if((src in user.get_equipped_items(include_pockets = TRUE, include_accessories = TRUE)) && !user.canUnEquip(src))
		to_chat(user, span_warning("[src] is stuck to you!"))
		return

	if(!user.canUnEquip(assembly))
		to_chat(user, span_warning("[assembly] is stuck to your hand!"))
		return

	user.transferItemToLoc(assembly, src)
	tank_assembly = assembly //Tell the tank about its assembly part
	assembly.master = src //Tell the assembly about its new owner
	assembly.on_attach()

	balloon_alert(user, "bomb assembled")
	update_icon(UPDATE_OVERLAYS)
	return

/// Detaches an assembly holder from the tank, disarming the bomb
/obj/item/tank/proc/bomb_disassemble(mob/user)
	bomb_status = FALSE
	balloon_alert(user, "bomb disarmed")
	if(!tank_assembly)
		CRASH("bomb_disassemble() called on a tank with no assembly!")
	user.put_in_hands(tank_assembly)
	tank_assembly.master = null
	tank_assembly = null
	update_icon(UPDATE_OVERLAYS)

/// Ignites the contents of the tank. Called when receiving a signal if the tank is welded and has an igniter attached.
/obj/item/tank/proc/ignite()
	var/igniter_temperature = 0
	for(var/obj/item/assembly/igniter/firestarter in tank_assembly.assemblies)
		igniter_temperature = max(igniter_temperature, firestarter.heat)

	var/datum/gas_mixture/our_mix = return_air()
	var/temperature_delta = igniter_temperature - our_mix.temperature // keep track of how much energy was added/subtracted, we'll need that later

	// now set the temperature to the igniter's temperature and react, condensers can be used to cool the gas which might be useful for something
	our_mix.temperature = igniter_temperature
	our_mix.react(src)

	// then set the temperature back by the amount added/removed, so it only gets the temperature change from the reaction
	our_mix.temperature -= temperature_delta

	// release the contents if it wasn't enough to explode, and ignite it
	if(our_mix.return_pressure() < TANK_FRAGMENT_PRESSURE)
		release()
		var/turf/burned_turf = get_turf(src)
		burned_turf.hotspot_expose(igniter_temperature)
		return

	// check to make sure it's not already exploding before exploding it
	if(igniting)
		CRASH("ignite() called multiple times on [type]")
	igniting = TRUE

	// calculate an explosion size - this formula is logarithmic and has much worse diminishing returns than standard dynamic explosions to prevent maxcaps without relying on a hard cap
	var/power = log(ASSEMBLY_BOMB_BASE, ((ASSEMBLY_BOMB_COEFFICIENT * our_mix.volume * (our_mix.return_pressure() - TANK_FRAGMENT_PRESSURE)) / TANK_FRAGMENT_SCALE) + 1)

	// and finally, the big kaboom
	log_atmos("[type] exploded with a range of [power] and a mix of ", air_contents)
	explosion(src, round(power * 0.25), round(power * 0.5), round(power * 0.75), round(power), round(power), ignorecap = FALSE)
	if(!QDELETED(src)) // delete if it didn't get destroyed by the explosion
		qdel(src)

/// Releases air stored in the tank. Called when signaled without being welded, or when ignited without enough pressure to explode.
/obj/item/tank/proc/release()
	var/datum/gas_mixture/our_mix = return_air()
	var/datum/gas_mixture/removed = remove_air(our_mix.total_moles())
	var/turf/T = get_turf(src)
	if(!T)
		return
	log_atmos("[type] released its contents of ", air_contents)
	T.assume_air(removed)

#undef ASSEMBLY_BOMB_BASE
#undef ASSEMBLY_BOMB_COEFFICIENT
#undef ASSUME_AIR_DT_FACTOR
