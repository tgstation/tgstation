//Ported from /vg/station13, which was in turn forked from baystation12;
//Please do not bother them with bugs from this port, however, as it has been modified quite a bit.
//Modifications include removing the world-ending full supermatter variation, and leaving only the shard.

//Zap constants, speeds up targeting

#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (OBJECT + 1)
#define OBJECT (LOWEST + 1)
#define LOWEST (1)

GLOBAL_DATUM(main_supermatter_engine, /obj/machinery/power/supermatter_crystal)

/obj/machinery/power/supermatter_crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/obj/engine/supermatter.dmi'
	density = TRUE
	anchored = TRUE
	layer = MOB_LAYER
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	critical_machine = TRUE
	base_icon_state = "sm"
	icon_state = "sm"

	///The id of our supermatter
	var/uid = 1
	///The amount of supermatters that have been created this round
	var/static/gl_uid = 1
	///Tracks the bolt color we are using
	var/zap_icon = DEFAULT_ZAP_ICON_STATE

	///The portion of the gasmix we're on that we should remove
	var/absorption_ratio = 0.15
	/// The gasmix we just recently absorbed. Tile's air multiplied by absorption_ratio
	var/datum/gas_mixture/absorbed_gasmix

	///Refered to as EER on the monitor. This value effects gas output, damage, and power generation.
	var/internal_energy = 0
	var/list/internal_energy_factors

	///The amount of damage we have currently.
	var/damage = 0
	/// The damage we had before this cycle.
	/// Used to check if we are currently taking damage or healing.
	var/damage_archived = 0
	var/list/damage_factors

	/// How much extra power does the main zap generate.
	var/zap_multiplier = 1
	var/list/zap_factors

	/// The temperature at which we start taking damage
	var/temp_limit = T0C + HEAT_PENALTY_THRESHOLD
	var/list/temp_limit_factors

	/// Multiplies our waste gas amount and temperature.
	var/waste_multiplier = 0
	var/list/waste_multiplier_factors

	///The point at which we consider the supermatter to be [SUPERMATTER_STATUS_WARNING]
	var/warning_point = 50
	var/warning_channel = RADIO_CHANNEL_ENGINEERING
	///The point at which we consider the supermatter to be [SUPERMATTER_STATUS_DANGER]
	///Spawns anomalies when more damaged than this too.
	var/danger_point = 550
	///The point at which we consider the supermatter to be [SUPERMATTER_STATUS_EMERGENCY]
	var/emergency_point = 675
	var/emergency_channel = null // Need null to actually broadcast, lol.
	///The point at which we delam [SUPERMATTER_STATUS_DELAMINATING]
	var/explosion_point = 900
	///Are we exploding?
	var/final_countdown = FALSE
	///A scaling value that affects the severity of explosions.
	var/explosion_power = 35
	///Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0

	/// The list of gases mapped against their current comp.
	/// We use this to calculate different values the supermatter uses, like power or heat resistance.
	/// Ranges from 0 to 1
	var/list/gas_percentage

	/// Affects the heat our SM makes.
	var/gas_heat_modifier = 0
	/// Affects the minimum point at which the SM takes heat damage
	var/gas_heat_resistance = 0
	/// How much power decay is negated. Complete power decay negation at 1.
	var/gas_powerloss_inhibition = 0
	/// Affects the amount of power the main SM zap makes.
	var/gas_power_transmission = 0
	/// Affects the power gain the SM experiances from heat.
	var/gas_heat_power_generation = 0

	/// External power that are added over time instead of immediately.
	var/external_power_trickle = 0
	/// External power that are added to the sm on next [/obj/machinery/power/supermatter_crystal/process_atmos] call.
	var/external_power_immediate = 0

	/// External damage that are added to the sm on next [/obj/machinery/power/supermatter_crystal/process_atmos] call.
	/// SM will not take damage if it's health is lower than emergency point.
	var/external_damage_immediate = 0

	///The cutoff for a bolt jumping, grows with heat, lowers with higher mol count,
	var/zap_cutoff = 1500
	///How much the bullets damage should be multiplied by when it is added to the internal variables
	var/bullet_energy = 2
	///How much hallucination should we produce per unit of power?
	var/hallucination_power = 0.1

	///Our internal radio
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng

	///Boolean used for logging if we've been powered
	var/has_been_powered = FALSE

	///An effect we show to admins and ghosts the percentage of delam we're at
	var/obj/effect/countdown/supermatter/countdown

	///Only main engines can have their sliver stolen, can trigger cascades, and can spawn stationwide anomalies.
	var/is_main_engine = FALSE
	///Our soundloop
	var/datum/looping_sound/supermatter/soundloop
	///Can it be moved?
	var/moveable = FALSE

	///cooldown tracker for accent sounds
	var/last_accent_sound = 0
	///Var that increases from 0 to 1 when a psychologist is nearby, and decreases in the same way
	var/psy_coeff = 0

	/// Disables all methods of taking damage.
	var/disable_damage = FALSE
	/// Disables the calculation of gas effects and production of waste.
	/// SM still "breathes" though, still takes gas and spits it out. Nothing is done on them though.
	/// Cleaner code this way. Get rid of if it's too wasteful.
	var/disable_gas = FALSE
	/// Disables power changes.
	var/disable_power_change = FALSE
	/// Disables the SM's proccessing totally.
	/// Make sure absorbed_gasmix and gas_percentage isnt null if this is on.
	var/disable_process = FALSE

	///Stores the time of when the last zap occurred
	var/last_power_zap = 0
	///Do we show this crystal in the CIMS modular program
	var/include_in_cims = TRUE

	///Hue shift of the zaps color based on the power of the crystal
	var/hue_angle_shift = 0
	///Reference to the warp effect
	var/atom/movable/supermatter_warp_effect/warp
	///The power threshold required to transform the powerloss function into a linear function from a cubic function.
	var/powerloss_linear_threshold = 0
	///The offset of the linear powerloss function set so the transition is differentiable.
	var/powerloss_linear_offset = 0

	/// How we are delaminating.
	var/datum/sm_delam/delamination_strategy
	/// Whether the sm is forced in a specific delamination_strategy or not. All truthy values means it's forced.
	/// Only values greater or equal to the current one can change the strat.
	var/delam_priority = SM_DELAM_PRIO_NONE

/obj/machinery/power/supermatter_crystal/Initialize(mapload)
	. = ..()
	gas_percentage = list()
	absorbed_gasmix = new()
	uid = gl_uid++
	set_delam(SM_DELAM_PRIO_NONE, /datum/sm_delam/explosive)
	SSair.start_processing_machine(src)
	countdown = new(src)
	countdown.start()
	SSpoints_of_interest.make_point_of_interest(src)
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	investigate_log("has been created.", INVESTIGATE_ENGINE)
	if(is_main_engine)
		GLOB.main_supermatter_engine = src

	AddElement(/datum/element/bsa_blocker)
	RegisterSignal(src, COMSIG_ATOM_BSA_BEAM, .proc/force_delam)

	var/static/list/loc_connections = list(
		COMSIG_TURF_INDUSTRIAL_LIFT_ENTER = .proc/tram_contents_consume,
	)
	AddElement(/datum/element/connect_loc, loc_connections)	//Speficially for the tram, hacky

	AddComponent(/datum/component/supermatter_crystal, CALLBACK(src, .proc/wrench_act_callback), CALLBACK(src, .proc/consume_callback))

	soundloop = new(src, TRUE)

	if (!moveable)
		move_resist = MOVE_FORCE_OVERPOWERING // Avoid being moved by statues or other memes

	// Damn math nerds
	powerloss_linear_threshold = sqrt(POWERLOSS_LINEAR_RATE / 3 * POWERLOSS_CUBIC_DIVISOR ** 3)
	powerloss_linear_offset = -1 * powerloss_linear_threshold * POWERLOSS_LINEAR_RATE + (powerloss_linear_threshold / POWERLOSS_CUBIC_DIVISOR) ** 3

/obj/machinery/power/supermatter_crystal/Destroy()
	if(warp)
		vis_contents -= warp
		QDEL_NULL(warp)
	investigate_log("has been destroyed.", INVESTIGATE_ENGINE)
	SSair.stop_processing_machine(src)
	absorbed_gasmix = null
	QDEL_NULL(radio)
	QDEL_NULL(countdown)
	if(is_main_engine && GLOB.main_supermatter_engine == src)
		GLOB.main_supermatter_engine = null
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/supermatter_crystal/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	if(warp)
		SET_PLANE_EXPLICIT(warp, PLANE_TO_TRUE(warp.plane), src)

/obj/machinery/power/supermatter_crystal/examine(mob/user)
	. = ..()
	var/immune = HAS_TRAIT(user, TRAIT_MADNESS_IMMUNE) || (user.mind && HAS_TRAIT(user.mind, TRAIT_MADNESS_IMMUNE))
	if(isliving(user) && !immune && (get_dist(user, src) < SM_HALLUCINATION_RANGE(internal_energy)))
		. += span_danger("You get headaches just from looking at it.")
	. += delamination_strategy.examine(src)
	return .

/obj/machinery/power/supermatter_crystal/process_atmos()
	// PART 1: PRELIMINARIES
	if(disable_process)
		return

	var/turf/local_turf = loc
	if(!istype(local_turf))//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.
	if(isclosedturf(local_turf))
		var/turf/did_it_melt = local_turf.Melt()
		if(!isclosedturf(did_it_melt)) //In case some joker finds way to place these on indestructible walls
			visible_message(span_warning("[src] melts through [local_turf]!"))
		return

	// PART 2: GAS PROCESSING
	var/datum/gas_mixture/env = local_turf.return_air()
	absorbed_gasmix = env?.remove_ratio(absorption_ratio) || new()
	absorbed_gasmix.volume = (env?.volume || CELL_VOLUME) * absorption_ratio // To match the pressure.
	calculate_gases()
	// Extra effects should always fire after the compositions are all finished
	// Some extra effects like [/datum/sm_gas/carbon_dioxide/extra_effects]
	// needs more than one gas and rely on a fully parsed gas_percentage.
	for (var/gas_path in absorbed_gasmix.gases)
		var/datum/sm_gas/sm_gas = GLOB.sm_gas_behavior[gas_path]
		sm_gas?.extra_effects(src)

	// PART 3: POWER PROCESSING
	internal_energy_factors = calculate_internal_energy()
	zap_factors = calculate_zap_multiplier()
	if(internal_energy && (last_power_zap + 4 SECONDS - (internal_energy * 0.001)) < world.time)
		playsound(src, 'sound/weapons/emitter2.ogg', 70, TRUE)
		hue_angle_shift = clamp(903 * log(10, (internal_energy + 8000)) - 3590, -50, 240)
		var/zap_color = color_matrix_rotate_hue(hue_angle_shift)
		supermatter_zap(
			zapstart = src,
			range = 3,
			zap_str = 5 * internal_energy * zap_multiplier,
			zap_flags = ZAP_SUPERMATTER_FLAGS,
			zap_cutoff = 300,
			power_level = internal_energy,
			color = zap_color,
		)
		last_power_zap = world.time

	// PART 4: DAMAGE PROCESSING
	temp_limit_factors = calculate_temp_limit()
	damage_factors = calculate_damage()
	if(damage == 0) // Clear any in game forced delams if on full health.
		set_delam(SM_DELAM_PRIO_IN_GAME, SM_DELAM_STRATEGY_PURGE)
	else
		set_delam(SM_DELAM_PRIO_NONE, SM_DELAM_STRATEGY_PURGE) // This one cant clear any forced delams.
	delamination_strategy.delam_progress(src)
	if(damage > explosion_point && !final_countdown)
		count_down()

	// PART 5: WASTE GAS PROCESSING
	waste_multiplier_factors = calculate_waste_multiplier()
	var/device_energy = internal_energy * REACTION_POWER_MODIFIER

	/// Do waste on another gasmix so we can keep a copy of the gasmix we use for processing.
	var/datum/gas_mixture/merged_gasmix = absorbed_gasmix.copy()
	merged_gasmix.temperature += device_energy * waste_multiplier / THERMAL_RELEASE_MODIFIER
	merged_gasmix.temperature = clamp(merged_gasmix.temperature, TCMB, 2500 * waste_multiplier)
	merged_gasmix.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)
	merged_gasmix.gases[/datum/gas/plasma][MOLES] += max(device_energy * waste_multiplier / PLASMA_RELEASE_MODIFIER, 0)
	merged_gasmix.gases[/datum/gas/oxygen][MOLES] += max(((device_energy + merged_gasmix.temperature * waste_multiplier) - T0C) / OXYGEN_RELEASE_MODIFIER, 0)
	merged_gasmix.garbage_collect()
	env.merge(merged_gasmix)
	air_update_turf(FALSE, FALSE)

	// PART 6: EXTRA BEHAVIOUR
	emit_radiation()
	processing_sound()
	handle_high_power()
	psychological_examination()
	if(prob(15))
		supermatter_pull(loc, min(internal_energy/850, 3))//850, 1700, 2550
	update_appearance()
	return TRUE

// SupermatterMonitor UI for ghosts only. Inherited attack_ghost will call this.
/obj/machinery/power/supermatter_crystal/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user))
		return FALSE
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Supermatter")
		ui.open()

/obj/machinery/power/supermatter_crystal/ui_static_data(mob/user)
	var/list/data = list()
	data["gas_metadata"] = sm_gas_data()
	return data

/// Returns data that are exclusively about this sm.
/obj/machinery/power/supermatter_crystal/proc/sm_ui_data()
	var/list/data = list()
	data["uid"] = uid
	data["area_name"] = get_area_name(src)

	data["integrity"] = get_integrity_percent()
	data["integrity_factors"] = list()
	for (var/factor in damage_factors)
		var/amount = round(damage_factors[factor], 0.01)
		if(!amount)
			continue
		data["integrity_factors"] += list(list(
			"name" = factor,
			"amount" = amount * -1
		))
	data["internal_energy"] = internal_energy
	data["internal_energy_factors"] = list()
	for (var/factor in internal_energy_factors)
		var/amount = round(internal_energy_factors[factor], 0.01)
		if(!amount)
			continue
		data["internal_energy_factors"] += list(list(
			"name" = factor,
			"amount" = amount
		))
	data["temp_limit"] = temp_limit
	data["temp_limit_factors"] = list()
	for (var/factor in temp_limit_factors)
		var/amount = round(temp_limit_factors[factor], 0.01)
		if(!amount)
			continue
		data["temp_limit_factors"] += list(list(
			"name" = factor,
			"amount" = amount
		))
	data["waste_multiplier"] = waste_multiplier
	data["waste_multiplier_factors"] = list()
	for (var/factor in waste_multiplier_factors)
		var/amount = round(waste_multiplier_factors[factor], 0.01)
		if(!amount)
			continue
		data["waste_multiplier_factors"] += list(list(
			"name" = factor,
			"amount" = amount
		))
	data["zap_multiplier"] = zap_multiplier
	data["zap_multiplier_factors"] = list()
	for (var/factor in zap_factors)
		var/amount = round(zap_factors[factor], 0.01)
		if(!amount)
			continue
		data["zap_multiplier_factors"] += list(list(
			"name" = factor,
			"amount" = amount
		))
	data["absorbed_ratio"] = absorption_ratio
	var/list/formatted_gas_percentage = list()
	for (var/datum/gas/gas_path as anything in subtypesof(/datum/gas))
		formatted_gas_percentage[gas_path] = gas_percentage?[gas_path] || 0
	data["gas_composition"] = formatted_gas_percentage
	data["gas_temperature"] = absorbed_gasmix.temperature
	data["gas_total_moles"] = absorbed_gasmix.total_moles()
	return data

/obj/machinery/power/supermatter_crystal/ui_data(mob/user)
	var/list/data = list()
	data["sm_data"] = list(sm_ui_data())
	return data

/// Encodes the current state of the supermatter.
/obj/machinery/power/supermatter_crystal/proc/get_status()
	if(!absorbed_gasmix)
		return SUPERMATTER_ERROR
	if(final_countdown)
		return SUPERMATTER_DELAMINATING
	if(damage >= emergency_point)
		return SUPERMATTER_EMERGENCY
	if(damage >= danger_point)
		return SUPERMATTER_DANGER
	if(damage >= warning_point)
		return SUPERMATTER_WARNING
	if(absorbed_gasmix.temperature > temp_limit * 0.8)
		return SUPERMATTER_NOTIFY
	if(internal_energy)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter_crystal/proc/get_integrity_percent()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100, 0.01)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/power/supermatter_crystal/update_overlays()
	. = ..()
	if(psy_coeff > 0)
		var/mutable_appearance/psy_overlay = mutable_appearance(icon, "[base_icon_state]-psy", FLOAT_LAYER - 1)
		psy_overlay.alpha = psy_coeff * 255
		. += psy_overlay
	if(delamination_strategy)
		. += delamination_strategy.overlays(src)
	return .

/obj/machinery/power/supermatter_crystal/update_icon(updates)
	. = ..()
	if(gas_heat_power_generation > 0.8)
		icon_state = "[base_icon_state]-glow"
	else
		icon_state = base_icon_state

/obj/machinery/power/supermatter_crystal/proc/force_delam()
	SIGNAL_HANDLER
	investigate_log("was forcefully delaminated", INVESTIGATE_ENGINE)
	INVOKE_ASYNC(delamination_strategy, /datum/sm_delam/proc/delaminate, src)

/**
 * Count down, spout some messages, and then execute the delam itself.
 * We guard for last second delam strat changes here, mostly because some have diff messages.
 *
 * By last second changes, we mean that it's possible for say, a tesla delam to
 * just explode normally if at the absolute last second it loses power and switches to default one.
 * Even after countdown is already in progress.
 */
/obj/machinery/power/supermatter_crystal/proc/count_down()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		stack_trace("[src] told to delaminate again while it's already delaminating.")
		return

	final_countdown = TRUE

	var/datum/sm_delam/last_delamination_strategy = delamination_strategy
	var/list/count_down_messages = delamination_strategy.count_down_messages()

	radio.talk_into(
		src,
		count_down_messages[1],
		emergency_channel
	)

	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		if(last_delamination_strategy != delamination_strategy)
			count_down_messages = delamination_strategy.count_down_messages()
			last_delamination_strategy = delamination_strategy

		var/message
		var/healed = FALSE

		if(damage < explosion_point) // Cutting it a bit close there engineers
			message = count_down_messages[2]
			healed = TRUE
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(1 SECONDS)
			continue
		else if(i > 50)
			message = "[DisplayTimeText(i, TRUE)] [count_down_messages[3]]"
		else
			message = "[i*0.1]..."

		radio.talk_into(src, message, emergency_channel)

		if(healed)
			final_countdown = FALSE
			return // delam averted
		sleep(1 SECONDS)

	delamination_strategy.delaminate(src)

// All the calculate procs should only update variables.
// Move the actual real-world effects to [/obj/machinery/power/supermatter_crystal/process_atmos].

/**
 * Perform calculation for variables that depend on gases.
 * Description of each factors can be found in the defines.
 *
 * Updates:
 * [/obj/machinery/power/supermatter_crystal/var/list/gas_percentage]
 * [/obj/machinery/power/supermatter_crystal/var/gas_power_transmission]
 * [/obj/machinery/power/supermatter_crystal/var/gas_heat_modifier]
 * [/obj/machinery/power/supermatter_crystal/var/gas_heat_resistance]
 * [/obj/machinery/power/supermatter_crystal/var/gas_heat_power_generation]
 * [/obj/machinery/power/supermatter_crystal/var/gas_powerloss_inhibition]
 *
 * Returns: null
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_gases()
	gas_percentage = list()
	gas_power_transmission = 0
	gas_heat_modifier = 0
	gas_heat_resistance = 0
	gas_heat_power_generation = 0
	gas_powerloss_inhibition = 0
	if(disable_gas)
		return

	var/total_moles = absorbed_gasmix.total_moles()

	for (var/gas_path in absorbed_gasmix.gases)
		gas_percentage[gas_path] = absorbed_gasmix.gases[gas_path][MOLES] / total_moles
		var/datum/sm_gas/sm_gas = GLOB.sm_gas_behavior[gas_path]
		if(!sm_gas)
			continue
		gas_power_transmission += sm_gas.power_transmission * gas_percentage[gas_path]
		gas_heat_modifier += sm_gas.heat_modifier * gas_percentage[gas_path]
		gas_heat_resistance += sm_gas.heat_resistance * gas_percentage[gas_path]
		gas_heat_power_generation += sm_gas.heat_power_generation * gas_percentage[gas_path]
		gas_powerloss_inhibition += sm_gas.powerloss_inhibition * gas_percentage[gas_path]

	gas_heat_power_generation = clamp(gas_heat_power_generation, 0, 1)
	gas_powerloss_inhibition = clamp(gas_powerloss_inhibition, 0, 1)

/**
 * Perform calculation for power lost and gained this tick.
 * Description of each factors can be found in the defines.
 *
 * Updates:
 * [/obj/machinery/power/supermatter_crystal/var/internal_energy]
 * [/obj/machinery/power/supermatter_crystal/var/external_power_trickle]
 * [/obj/machinery/power/supermatter_crystal/var/external_power_immediate]
 *
 * Returns: The factors that have influenced the calculation. list[FACTOR_DEFINE] = number
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_internal_energy()
	if(disable_power_change)
		return
	var/list/additive_power = list()

	/// If we have a small amount of external_power_trickle we just round it up to 40.
	additive_power[SM_POWER_EXTERNAL_TRICKLE] = external_power_trickle ? max(external_power_trickle/MATTER_POWER_CONVERSION, 40) : 0
	external_power_trickle -= min(additive_power[SM_POWER_EXTERNAL_TRICKLE], external_power_trickle)
	additive_power[SM_POWER_EXTERNAL_IMMEDIATE] = external_power_immediate
	external_power_immediate = 0
	additive_power[SM_POWER_HEAT] = gas_heat_power_generation * absorbed_gasmix.temperature / 6

	// I'm sorry for this, but we need to calculate power lost immediately after power gain.
	// Helps us prevent cases when someone dumps superhothotgas into the SM and shoots the power to the moon for one tick.
	/// Power if we dont have decay. Used for powerloss calc.
	var/momentary_power = internal_energy
	for(var/powergain_type in additive_power)
		momentary_power += additive_power[powergain_type]
	if(internal_energy < powerloss_linear_threshold) // Negative numbers
		additive_power[SM_POWER_POWERLOSS] = -1 * (momentary_power / POWERLOSS_CUBIC_DIVISOR) ** 3
	else
		additive_power[SM_POWER_POWERLOSS] = -1 * (momentary_power * POWERLOSS_LINEAR_RATE + powerloss_linear_offset)
	// Positive number
	additive_power[SM_POWER_POWERLOSS_GAS] = -1 * gas_powerloss_inhibition *  additive_power[SM_POWER_POWERLOSS]
	additive_power[SM_POWER_POWERLOSS_SOOTHED] = -1 * min(1-gas_powerloss_inhibition , 0.2 * psy_coeff) *  additive_power[SM_POWER_POWERLOSS]

	for(var/powergain_types in additive_power)
		internal_energy += additive_power[powergain_types]
	internal_energy = max(internal_energy, 0)
	return additive_power

/**
 * Perform calculation for the main zap power multiplier.
 * Description of each factors can be found in the defines.
 *
 * Updates:
 * [/obj/machinery/power/supermatter_crystal/var/zap_multiplier]
 *
 * Returns: The factors that have influenced the calculation. list[FACTOR_DEFINE] = number
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_zap_multiplier()
	var/list/additive_transmission = list()
	additive_transmission[SM_ZAP_BASE] = 1
	additive_transmission[SM_ZAP_GAS] = gas_power_transmission

	zap_multiplier = 0
	for (var/transmission_types in additive_transmission)
		zap_multiplier += additive_transmission[transmission_types]
	zap_multiplier = max(zap_multiplier, 0)
	return additive_transmission

/**
 * Perform calculation for the waste multiplier.
 * This number affects the temperature, plasma, and oxygen of the waste gas.
 * Multiplier is applied to energy for plasma and temperature but temperature for oxygen.
 *
 * Description of each factors can be found in the defines.
 *
 * Updates:
 * [/obj/machinery/power/supermatter_crystal/var/waste_multiplier]
 *
 * Returns: The factors that have influenced the calculation. list[FACTOR_DEFINE] = number
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_waste_multiplier()
	waste_multiplier = 0
	if(disable_gas)
		return
	/// Tell people the heat output in energy. More informative than telling them the heat multiplier.
	var/additive_waste_multiplier = list()
	additive_waste_multiplier[SM_WASTE_BASE] = 1
	additive_waste_multiplier[SM_WASTE_GAS] = gas_heat_modifier
	additive_waste_multiplier[SM_WASTE_SOOTHED] = -0.2 * psy_coeff

	for (var/waste_type in additive_waste_multiplier)
		waste_multiplier += additive_waste_multiplier[waste_type]
	waste_multiplier = clamp(waste_multiplier, 0.5, INFINITY)
	return additive_waste_multiplier

/**
 * Calculate at which temperature the sm starts taking damage.
 * heat limit is given by: (T0C+40) * (1 + gas heat res + psy_coeff)
 *
 * Description of each factors can be found in the defines.
 *
 * Updates:
 * [/obj/machinery/power/supermatter_crystal/var/temp_limit]
 *
 * Returns: The factors that have influenced the calculation. list[FACTOR_DEFINE] = number
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_temp_limit()
	var/list/additive_temp_limit = list()
	additive_temp_limit[SM_TEMP_LIMIT_BASE] = T0C + HEAT_PENALTY_THRESHOLD
	additive_temp_limit[SM_TEMP_LIMIT_GAS] = gas_heat_resistance *  (T0C + HEAT_PENALTY_THRESHOLD)
	additive_temp_limit[SM_TEMP_LIMIT_SOOTHED] = psy_coeff * 45
	additive_temp_limit[SM_TEMP_LIMIT_LOW_MOLES] =  clamp(2 - absorbed_gasmix.total_moles() / 100, 0, 1) * (T0C + HEAT_PENALTY_THRESHOLD)

	temp_limit = 0
	for (var/resistance_type in additive_temp_limit)
		temp_limit += additive_temp_limit[resistance_type]
	temp_limit = max(temp_limit, TCMB)

	return additive_temp_limit

/**
 * Perform calculation for the damage taken or healed.
 * Description of each factors can be found in the defines.
 *
 * Updates:
 * [/obj/machinery/power/supermatter_crystal/var/damage]
 *
 * Returns: The factors that have influenced the calculation. list[FACTOR_DEFINE] = number
 */
/obj/machinery/power/supermatter_crystal/proc/calculate_damage()
	if(disable_damage)
		return

	var/list/additive_damage = list()
	var/total_moles = absorbed_gasmix.total_moles()

	// We dont let external factors deal more damage than the emergency point.
	// Only cares about the damage before this proc is run. We ignore soon-to-be-applied damage.
	additive_damage[SM_DAMAGE_EXTERNAL] = external_damage_immediate * clamp((emergency_point - damage) / emergency_point, 0, 1)
	external_damage_immediate = 0

	additive_damage[SM_DAMAGE_HEAT] = clamp((absorbed_gasmix.temperature - temp_limit) / 2400, 0, 1.5)
	additive_damage[SM_DAMAGE_POWER] = clamp((internal_energy - POWER_PENALTY_THRESHOLD) / 4000, 0, 1)
	additive_damage[SM_DAMAGE_MOLES] = clamp((total_moles - MOLE_PENALTY_THRESHOLD) / 320, 0, 1)

	var/is_spaced = FALSE
	if(isturf(src.loc))
		var/turf/local_turf = src.loc
		for (var/turf/open/space/turf in ((local_turf.atmos_adjacent_turfs || list()) + local_turf))
			additive_damage[SM_DAMAGE_SPACED] = clamp(internal_energy * 0.00125, 0, 10)
			is_spaced = TRUE
			break

	if(total_moles > 0 && !is_spaced)
		additive_damage[SM_DAMAGE_HEAL_HEAT] = clamp((absorbed_gasmix.temperature - temp_limit) / 600, -1, 0)

	var/total_damage = 0
	for (var/damage_type in additive_damage)
		total_damage += additive_damage[damage_type]

	damage_archived = damage
	damage += total_damage
	damage = max(damage, 0)
	return additive_damage

/**
 * Sets the delam of our sm.
 *
 * Arguments:
 * * priority: Truthy values means a forced delam. If current forced_delam is higher than priority we dont run.
 * Set to a number higher than [SM_DELAM_PRIO_IN_GAME] to fully force an admin delam.
 * * delam_path: Typepath of a [/datum/sm_delam]. [SM_DELAM_STRATEGY_PURGE] means reset and put prio back to zero.
 *
 * Returns: Not used for anything, just returns true on succesful set, manual and automatic. Helps admins check stuffs.
 */
/obj/machinery/power/supermatter_crystal/proc/set_delam(priority = SM_DELAM_PRIO_NONE, manual_delam_path = SM_DELAM_STRATEGY_PURGE)
	if(priority < delam_priority)
		return FALSE
	var/datum/sm_delam/new_delam = null

	if(manual_delam_path == SM_DELAM_STRATEGY_PURGE)
		for (var/delam_path in GLOB.sm_delam_list)
			var/datum/sm_delam/delam = GLOB.sm_delam_list[delam_path]
			if(!delam.can_select(src))
				continue
			if(delam == delamination_strategy)
				return FALSE
			new_delam = delam
			break
		delam_priority = SM_DELAM_PRIO_NONE
	else
		new_delam = GLOB.sm_delam_list[manual_delam_path]
		delam_priority = priority

	if(!new_delam)
		return FALSE
	delamination_strategy?.on_deselect(src)
	delamination_strategy = new_delam
	delamination_strategy.on_select(src)
	return TRUE

/obj/machinery/proc/supermatter_zap(atom/zapstart = src, range = 5, zap_str = 4000, zap_flags = ZAP_SUPERMATTER_FLAGS, list/targets_hit = list(), zap_cutoff = 1500, power_level = 0, zap_icon = DEFAULT_ZAP_ICON_STATE, color = null)
	if(QDELETED(zapstart))
		return
	. = zapstart.dir
	//If the strength of the zap decays past the cutoff, we stop
	if(zap_str < zap_cutoff)
		return
	var/atom/target
	var/target_type = LOWEST
	var/list/arc_targets = list()
	//Making a new copy so additons further down the recursion do not mess with other arcs
	//Lets put this ourself into the do not hit list, so we don't curve back to hit the same thing twice with one arc
	for(var/atom/test as anything in oview(zapstart, range))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(targets_hit, test))
			continue

		if(istype(test, /obj/vehicle/ridden/bicycle/))
			var/obj/vehicle/ridden/bicycle/bike = test
			if(!HAS_TRAIT(bike, TRAIT_BEING_SHOCKED) && bike.can_buckle)//God's not on our side cause he hates idiots.
				if(target_type != BIKE)
					arc_targets = list()
				arc_targets += test
				target_type = BIKE

		if(target_type > COIL)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/tesla_coil/))
			var/obj/machinery/power/energy_accumulator/tesla_coil/coil = test
			if(!HAS_TRAIT(coil, TRAIT_BEING_SHOCKED) && coil.anchored && !coil.panel_open && prob(70))//Diversity of death
				if(target_type != COIL)
					arc_targets = list()
				arc_targets += test
				target_type = COIL

		if(target_type > ROD)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/grounding_rod/))
			var/obj/machinery/power/energy_accumulator/grounding_rod/rod = test
			//We're adding machine damaging effects, rods need to be surefire
			if(rod.anchored && !rod.panel_open)
				if(target_type != ROD)
					arc_targets = list()
				arc_targets += test
				target_type = ROD

		if(target_type > LIVING)
			continue

		if(isliving(test))
			var/mob/living/alive = test
			if(!HAS_TRAIT(alive, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(alive, TRAIT_BEING_SHOCKED) && alive.stat != DEAD && prob(20))//let's not hit all the engineers with every beam and/or segment of the arc
				if(target_type != LIVING)
					arc_targets = list()
				arc_targets += test
				target_type = LIVING

		if(target_type > MACHINERY)
			continue

		if(ismachinery(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED) && prob(40))
				if(target_type != MACHINERY)
					arc_targets = list()
				arc_targets += test
				target_type = MACHINERY

		if(target_type > OBJECT)
			continue

		if(isobj(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED))
				if(target_type != OBJECT)
					arc_targets = list()
				arc_targets += test
				target_type = OBJECT

	if(arc_targets.len)//Pick from our pool
		target = pick(arc_targets)

	if(QDELETED(target))//If we didn't found something
		return

	//Do the animation to zap to it from here
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(targets_hit, target, TRUE)
	zapstart.Beam(target, icon_state=zap_icon, time = 0.5 SECONDS, beam_color = color)
	var/zapdir = get_dir(zapstart, target)
	if(zapdir)
		. = zapdir

	//Going boom should be rareish
	if(prob(80))
		zap_flags &= ~ZAP_MACHINE_EXPLOSIVE
	if(target_type == COIL)
		var/multi = 2
		switch(power_level)//Between 7k and 9k it's 4, above that it's 8
			if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
				multi = 4
			if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
				multi = 8
		if(zap_flags & ZAP_SUPERMATTER_FLAGS)
			var/remaining_power = target.zap_act(zap_str * multi, zap_flags)
			zap_str = remaining_power * 0.5 //Coils should take a lot out of the power of the zap
		else
			zap_str /= 3

	else if(isliving(target))//If we got a fleshbag on our hands
		var/mob/living/creature = target
		ADD_TRAIT(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
		addtimer(TRAIT_CALLBACK_REMOVE(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
		//3 shots a human with no resistance. 2 to crit, one to death. This is at at least 10000 power.
		//There's no increase after that because the input power is effectivly capped at 10k
		//Does 1.5 damage at the least
		var/shock_damage = ((zap_flags & ZAP_MOB_DAMAGE) ? (power_level / 200) - 10 : rand(5,10))
		creature.electrocute_act(shock_damage, "Supermatter Discharge Bolt", 1,  ((zap_flags & ZAP_MOB_STUN) ? SHOCK_TESLA : SHOCK_NOSTUN))
		zap_str /= 1.5 //Meatsacks are conductive, makes working in pairs more destructive

	else
		zap_str = target.zap_act(zap_str, zap_flags)

	//This gotdamn variable is a boomer and keeps giving me problems
	var/turf/target_turf = get_turf(target)
	var/pressure = 1
	if(target_turf?.return_air())
		pressure = max(1,target_turf.return_air().return_pressure())
	//We get our range with the strength of the zap and the pressure, the higher the former and the lower the latter the better
	var/new_range = clamp(zap_str / pressure * 10, 2, 7)
	var/zap_count = 1
	if(prob(5))
		zap_str -= (zap_str/10)
		zap_count += 1
	for(var/j in 1 to zap_count)
		var/child_targets_hit = targets_hit
		if(zap_count > 1)
			child_targets_hit = targets_hit.Copy() //Pass by ref begone
		supermatter_zap(target, new_range, zap_str, zap_flags, child_targets_hit, zap_cutoff, power_level, zap_icon, color)

#undef BIKE
#undef COIL
#undef ROD
#undef LIVING
#undef MACHINERY
#undef OBJECT
#undef LOWEST
