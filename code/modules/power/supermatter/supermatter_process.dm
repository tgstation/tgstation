/obj/machinery/power/supermatter_crystal/process_atmos()
	if(!processes) //Just fuck me up bro
		return
	var/turf/local_turf = loc

	if(isnull(local_turf))// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(local_turf))//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(isclosedturf(local_turf))
		var/turf/did_it_melt = local_turf.Melt()
		if(!isclosedturf(did_it_melt)) //In case some joker finds way to place these on indestructible walls
			visible_message(span_warning("[src] melts through [local_turf]!"))
		return

	handle_crystal_sounds()

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = local_turf.return_air()
	environment_total_moles = env.total_moles()
	if(produces_gas)
		//Remove gas from surrounding area
		absorbed_gasmix = env.remove(absorption_ratio * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		absorbed_gasmix = new()
	overlays -= psyOverlay
	if(psy_overlay)
		overlays -= psyOverlay
		if(psyCoeff > 0)
			psyOverlay.alpha = psyCoeff * 255
			overlays += psyOverlay
		else
			psy_overlay = FALSE
	damage_archived = damage
	if(!absorbed_gasmix || !absorbed_gasmix.total_moles() || isspaceturf(local_turf)) //we're in space or there is no gas to process
		if(takes_damage)
			damage += max((power / 1000) * DAMAGE_INCREASE_MULTIPLIER, 0.1) // always does at least some damage
		if(!istype(env, /datum/gas_mixture/immutable) && produces_gas && power) //There is no gas to process, but we are not in a space turf. Lets make them.
			//Power * 0.55 * a value between 1 and 0.8
			var/device_energy = power * REACTION_POWER_MODIFIER * (1 - (psyCoeff * 0.2))
			//Can't do stuff if it's null, so lets make a new gasmix.
			absorbed_gasmix = new()
			//Since there is no gas to process, we will produce as if heat penalty is 1 and temperature at TCMB.
			absorbed_gasmix.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)
			absorbed_gasmix.temperature = ((device_energy) / THERMAL_RELEASE_MODIFIER)
			absorbed_gasmix.temperature = max(TCMB, min(absorbed_gasmix.temperature, 2500))
			absorbed_gasmix.gases[/datum/gas/plasma][MOLES] = max((device_energy) / PLASMA_RELEASE_MODIFIER, 0)
			absorbed_gasmix.gases[/datum/gas/oxygen][MOLES] = max(((device_energy + TCMB) - T0C) / OXYGEN_RELEASE_MODIFIER, 0)
			absorbed_gasmix.garbage_collect()
			env.merge(absorbed_gasmix)
			air_update_turf(FALSE, FALSE)
	else
		if(takes_damage)
			//causing damage
			deal_damage(absorbed_gasmix)

		//registers the current enviromental gases in the various lists and vars
		setup_lists(absorbed_gasmix)
		//some gases can have special interactions
		special_gases_interactions(env, absorbed_gasmix)
		//main power calculations proc
		power_calculations(env, absorbed_gasmix)
		//irradiate at this point
		emit_radiation()
		//handles temperature increase and gases made by the crystal
		temperature_gas_production(env, absorbed_gasmix)

	//handles hallucinations and the presence of a psychiatrist
	psychological_examination()

	//Transitions between one function and another, one we use for the fast inital startup, the other is used to prevent errors with fusion temperatures.
	//Use of the second function improves the power gain imparted by using co2
	if(power_changes)
		///The power that is getting lost this tick.
		var/power_loss = power < powerloss_linear_threshold ? ((power / POWERLOSS_CUBIC_DIVISOR) ** 3) : (power * POWERLOSS_LINEAR_RATE + powerloss_linear_offset)
		power_loss *= powerloss_inhibitor * (1 - (PSYCHOLOGIST_POWERLOSS_REDUCTION * psyCoeff))
		power = max(power - power_loss, 0)
	//After this point power is lowered
	//This wraps around to the begining of the function
	//Handle high power zaps/anomaly generation
	handle_high_power(absorbed_gasmix)

	if(prob(15))
		supermatter_pull(loc, min(power/850, 3))//850, 1700, 2550

	if(damage == 0) // Clear any in game forced delams if on full health.
		set_delam(SM_DELAM_PRIO_IN_GAME, SM_DELAM_STRATEGY_PURGE)
	else
		set_delam() // This one cant clear any forced delams.
	delamination_strategy.delam_progress(src)

	if(damage > explosion_point && !final_countdown)
		count_down()

	return TRUE

/obj/machinery/power/supermatter_crystal/proc/handle_crystal_sounds()
	//We vary volume by power, and handle OH FUCK FUSION IN COOLING LOOP noises.
	if(power)
		soundloop.volume = clamp((50 + (power / 50)), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	//We play delam/neutral sounds at a rate determined by power and damage
	if(last_accent_sound >= world.time || !prob(20))
		return
	var/aggression = min(((damage / 800) * (power / 2500)), 1.0) * 100
	if(damage >= 300)
		playsound(src, SFX_SM_DELAM, max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
	else
		playsound(src, SFX_SM_CALM, max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
	var/next_sound = round((100 - aggression) * 5)
	last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

/obj/machinery/power/supermatter_crystal/proc/deal_damage(datum/gas_mixture/removed)
	var/has_holes = FALSE
	//Check for holes in the SM inner chamber
	for(var/turf/open/space/turf_to_check in RANGE_TURFS(1, loc))
		if(LAZYLEN(turf_to_check.atmos_adjacent_turfs))
			damage += clamp((power * 0.005) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
			power += 250
			has_holes = TRUE
			break

	var/delam_damage_multipler = delamination_strategy.damage_multiplier(src)

	//Due to DAMAGE_INCREASE_MULTIPLIER, we only deal one 4th of the damage the statements otherwise would cause
	//((((some value between 0.5 and 1 * temp - ((273.15 + 40) * some values between 1 and 10)) * some number between 0.25 and knock your socks off / 150) * 0.25
	//Heat and mols account for each other, a lot of hot mols are more damaging then a few
	//Mols start to have a positive effect on damage after 350
	damage = max(damage + (max(clamp(removed.total_moles() / 200, 0.5, 1) * removed.temperature - ((T0C + HEAT_PENALTY_THRESHOLD)*dynamic_heat_resistance), 0) * mole_heat_penalty / 150 ) * DAMAGE_INCREASE_MULTIPLIER, 0)
	//Power only starts affecting damage when it is above 5000 (1250 when a cascade is occurring)
	damage = max(damage + (max(power - (POWER_PENALTY_THRESHOLD * delam_damage_multipler), 0)/500) * DAMAGE_INCREASE_MULTIPLIER, 0)
	//Molar count only starts affecting damage when it is above 1800 (450 when a cascade is occurring)
	damage = max(damage + (max(combined_gas - (MOLE_PENALTY_THRESHOLD * delam_damage_multipler), 0)/80) * DAMAGE_INCREASE_MULTIPLIER, 0)

	//There might be a way to integrate healing and hurting via heat
	//healing damage
	if(combined_gas < MOLE_PENALTY_THRESHOLD && !has_holes)
		//Only has a net positive effect when the temp is below 313.15, heals up to 2 damage. Psycologists increase this temp min by up to 45
		damage = max(damage + (min(removed.temperature - ((T0C + HEAT_PENALTY_THRESHOLD) + (45 * psyCoeff)), 0) / 150 ), 0)

	//caps damage rate
	//Takes the lower number between archived damage + (1.8) and damage
	//This means we can only deal 1.8 damage per function call
	damage = min(damage_archived + (DAMAGE_HARDCAP * explosion_point),damage)

/obj/machinery/power/supermatter_crystal/proc/setup_lists(datum/gas_mixture/removed)

	for(var/gas_id in gases_we_care_about)
		removed.assert_gas(gas_id)

	//calculating gas related values
	//Wanna know a secret? See that max() to zero? it's used for error checking. If we get a mol count in the negative, we'll get a divide by zero error //Old me, you're insane
	combined_gas = max(removed.total_moles(), 0)

	//This is more error prevention, according to all known laws of atmos, gas_mix.remove() should never make negative mol values.
	//But this is tg

	//Lets get the proportions of the gasses in the mix for scaling stuff later
	//They range between 0 and 1
	for(var/gas_id in gases_we_care_about)
		gas_comp[gas_id] = clamp(removed.gases[gas_id][MOLES] / combined_gas, 0, 1)

	var/list/heat_mod = gases_we_care_about.Copy()
	var/list/transit_mod = gases_we_care_about.Copy()
	var/list/resistance_mod = gases_we_care_about.Copy()

	//No less then zero, and no greater then one, we use this to do explosions and heat to power transfer
	//Be very careful with modifing this var by large amounts, and for the love of god do not push it past 1
	gasmix_power_ratio = 0
	for(var/gas_id in gas_powermix)
		gasmix_power_ratio += gas_comp[gas_id] * gas_powermix[gas_id]
	gasmix_power_ratio = clamp(gasmix_power_ratio, 0, 1)

	//Minimum value of -10, maximum value of 23. Effects plasma and o2 output and the output heat
	dynamic_heat_modifier = 0
	for(var/gas_id in gas_heat)
		dynamic_heat_modifier += gas_comp[gas_id] * gas_heat[gas_id] * (isnull(heat_mod[gas_id]) ? 1 : heat_mod[gas_id])
	dynamic_heat_modifier = max(dynamic_heat_modifier, 0.5)

	//Value between 1 and 10. Effects the damage heat does to the crystal
	dynamic_heat_resistance = 0
	for(var/gas_id in gas_resist)
		dynamic_heat_resistance += gas_comp[gas_id] * gas_resist[gas_id] * (isnull(resistance_mod[gas_id]) ? 1 : resistance_mod[gas_id])
	dynamic_heat_resistance = max(dynamic_heat_resistance, 1)

	//Value between -5 and 30, used to determine radiation output as it concerns things like collectors.
	power_transmission_bonus = 0
	for(var/gas_id in gas_trans)
		power_transmission_bonus += gas_comp[gas_id] * gas_trans[gas_id] * (isnull(transit_mod[gas_id]) ? 1 : transit_mod[gas_id])

/obj/machinery/power/supermatter_crystal/proc/special_gases_interactions(datum/gas_mixture/env, datum/gas_mixture/removed)
	//Miasma is really just microscopic particulate. It gets consumed like anything else that touches the crystal.
	if(gas_comp[/datum/gas/miasma])
		var/miasma_pp = env.return_pressure() * gas_comp[/datum/gas/miasma]
		var/consumed_miasma = clamp(((miasma_pp - MIASMA_CONSUMPTION_PP) / (miasma_pp + MIASMA_PRESSURE_SCALING)) * (1 + (gasmix_power_ratio * MIASMA_GASMIX_SCALING)), MIASMA_CONSUMPTION_RATIO_MIN, MIASMA_CONSUMPTION_RATIO_MAX)
		consumed_miasma *= gas_comp[/datum/gas/miasma] * combined_gas
		if(consumed_miasma)
			removed.gases[/datum/gas/miasma][MOLES] -= consumed_miasma
			matter_power += consumed_miasma * MIASMA_POWER_GAIN

	//Let's say that the CO2 touches the SM surface and the radiation turns it into Pluoxium.
	if(gas_comp[/datum/gas/carbon_dioxide] && gas_comp[/datum/gas/oxygen])
		var/carbon_dioxide_pp = env.return_pressure() * gas_comp[/datum/gas/carbon_dioxide]
		var/consumed_carbon_dioxide = clamp(((carbon_dioxide_pp - CO2_CONSUMPTION_PP) / (carbon_dioxide_pp + CO2_PRESSURE_SCALING)), CO2_CONSUMPTION_RATIO_MIN, CO2_CONSUMPTION_RATIO_MAX)
		consumed_carbon_dioxide = min(consumed_carbon_dioxide * gas_comp[/datum/gas/carbon_dioxide] * combined_gas, removed.gases[/datum/gas/carbon_dioxide][MOLES] * INVERSE(0.5), removed.gases[/datum/gas/oxygen][MOLES] * INVERSE(0.5))
		if(consumed_carbon_dioxide)
			removed.gases[/datum/gas/carbon_dioxide][MOLES] -= consumed_carbon_dioxide * 0.5
			removed.gases[/datum/gas/oxygen][MOLES] -= consumed_carbon_dioxide * 0.5
			removed.gases[/datum/gas/pluoxium][MOLES] += consumed_carbon_dioxide * 0.25

	if(prob(gas_comp[/datum/gas/zauker]))
		playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
		supermatter_zap(src, 6, clamp(power * 2, 4000, 20000), ZAP_MOB_STUN, zap_cutoff = src.zap_cutoff, power_level = power, zap_icon = src.zap_icon)

	if(gas_comp[/datum/gas/bz] >= 0.4 && prob(30 * gas_comp[/datum/gas/bz]))
		fire_nuclear_particle()        // Start to emit radballs at a maximum of 30% chance per tick


/obj/machinery/power/supermatter_crystal/proc/power_calculations(datum/gas_mixture/env, datum/gas_mixture/removed)
	//more moles of gases are harder to heat than fewer, so let's scale heat damage around them
	mole_heat_penalty = max(combined_gas / MOLE_HEAT_PENALTY, 0.25)

	//Ramps up or down in increments of 0.02 up to the proportion of co2
	//Given infinite time, powerloss_dynamic_scaling = co2comp
	//Some value between 0 and 1
	if (combined_gas > POWERLOSS_INHIBITION_MOLE_THRESHOLD && gas_comp[/datum/gas/carbon_dioxide] > POWERLOSS_INHIBITION_GAS_THRESHOLD) //If there are more then 20 mols, and more then 20% co2
		powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling + clamp(gas_comp[/datum/gas/carbon_dioxide] - powerloss_dynamic_scaling, -0.02, 0.02), 0, 1)
	else
		powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling - 0.05, 0, 1)
	//Ranges from 0 to 1(1-(value between 0 and 1 * ranges from 1 to 1.5(mol / 500)))
	//We take the mol count, and scale it to be our inhibitor
	powerloss_inhibitor = clamp(1-(powerloss_dynamic_scaling * clamp(combined_gas/POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD, 1, 1.5)), 0, 1)

	//Releases stored power into the general pool
	//We get this by consuming shit or being scalpeled
	if(matter_power && power_changes)
		//We base our removed power off one 10th of the matter_power.
		var/removed_matter = max(matter_power/MATTER_POWER_CONVERSION, 40)
		//Adds at least 40 power
		power = max(power + removed_matter, 0)
		//Removes at least 40 matter power
		matter_power = max(matter_power - removed_matter, 0)

	var/temp_factor = 50
	if(gasmix_power_ratio > 0.8)
		//with a perfect gas mix, make the power more based on heat
		icon_state = "[base_icon_state]_glow"
	else
		//in normal mode, power is less effected by heat
		temp_factor = 30
		icon_state = base_icon_state

	//if there is more pluox and n2 then anything else, we receive no power increase from heat
	if(power_changes)
		power = max((removed.temperature * temp_factor / T0C) * gasmix_power_ratio + power, 0)

	//Zaps around 2.5 seconds at 1500 MeV, limited to 0.5 from 4000 MeV and up
	if(power && (last_power_zap + 4 SECONDS - (power * 0.001)) < world.time)
		playsound(src, 'sound/weapons/emitter2.ogg', 70, TRUE)
		var/power_multiplier = max(0, 1 + power_transmission_bonus / 10)
		var/pressure_multiplier = max((1 / ((env.return_pressure() ** pressure_bonus_curve_angle) + 1) * pressure_bonus_derived_steepness) + pressure_bonus_derived_constant, 1)
		hue_angle_shift = clamp(903 * log(10, (power + 8000)) - 3590, -50, 240)
		var/zap_color = color_matrix_rotate_hue(hue_angle_shift)
		supermatter_zap(
			zapstart = src,
			range = 3,
			zap_str = 2.5 * power * power_multiplier * pressure_multiplier,
			zap_flags = ZAP_SUPERMATTER_FLAGS,
			zap_cutoff = 300,
			power_level = power,
			color = zap_color,
		)
		last_power_zap = world.time

/obj/machinery/power/supermatter_crystal/proc/temperature_gas_production(datum/gas_mixture/env, datum/gas_mixture/removed)
	//Power * 0.55 * a value between 1 and 0.8
	var/device_energy = power * REACTION_POWER_MODIFIER * (1 - (psyCoeff * 0.2))

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.
	//Power * 0.55 * (some value between 1.5 and 23) / 5
	removed.temperature += ((device_energy * dynamic_heat_modifier) / THERMAL_RELEASE_MODIFIER)
	//We can only emit so much heat, that being 57500
	removed.temperature = max(TCMB, min(removed.temperature, 2500 * dynamic_heat_modifier))

	//Calculate how much gas to release
	//Varies based on power and gas content
	removed.gases[/datum/gas/plasma][MOLES] += max((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER, 0)
	//Varies based on power, gas content, and heat
	removed.gases[/datum/gas/oxygen][MOLES] += max(((device_energy + removed.temperature * dynamic_heat_modifier) - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

	if(produces_gas)
		removed.garbage_collect()
		env.merge(removed)
		air_update_turf(FALSE, FALSE)

/obj/machinery/power/supermatter_crystal/proc/psychological_examination()
	// Defaults to a value less than 1. Over time the psyCoeff goes to 0 if
	// no supermatter soothers are nearby.
	var/psy_coeff_diff = -0.05
	for(var/mob/living/carbon/human/seen_by_sm in view(src, HALLUCINATION_RANGE(power)))
		// Someone (generally a Psychologist), when looking at the SM within hallucination range makes it easier to manage.
		if(HAS_TRAIT(seen_by_sm, TRAIT_SUPERMATTER_SOOTHER) || (seen_by_sm.mind && HAS_TRAIT(seen_by_sm.mind, TRAIT_SUPERMATTER_SOOTHER)))
			psy_coeff_diff = 0.05
			psy_overlay = TRUE

	visible_hallucination_pulse(
		center = src,
		radius = HALLUCINATION_RANGE(power),
		hallucination_duration = power * hallucination_power,
		hallucination_max_duration = 400 SECONDS,
	)
	psyCoeff = clamp(psyCoeff + psy_coeff_diff, 0, 1)

/obj/machinery/power/supermatter_crystal/proc/handle_high_power(datum/gas_mixture/removed)
	if(power <= POWER_PENALTY_THRESHOLD && damage <= danger_point) //If the power is above 5000 or if the damage is above 550
		return
	var/range = 4
	zap_cutoff = 1500
	if(removed && removed.return_pressure() > 0 && removed.return_temperature() > 0)
		//You may be able to freeze the zapstate of the engine with good planning, we'll see
		zap_cutoff = clamp(3000 - (power * (removed.total_moles()) / 10) / removed.return_temperature(), 350, 3000)//If the core is cold, it's easier to jump, ditto if there are a lot of mols
		//We should always be able to zap our way out of the default enclosure
		//See supermatter_zap() for more details
		range = clamp(power / removed.return_pressure() * 10, 2, 7)
	var/flags = ZAP_SUPERMATTER_FLAGS
	var/zap_count = 0
	//Deal with power zaps
	switch(power)
		if(POWER_PENALTY_THRESHOLD to SEVERE_POWER_PENALTY_THRESHOLD)
			zap_icon = DEFAULT_ZAP_ICON_STATE
			zap_count = 2
		if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
			zap_icon = SLIGHTLY_CHARGED_ZAP_ICON_STATE
			//Uncaps the zap damage, it's maxed by the input power
			//Objects take damage now
			flags |= (ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
			zap_count = 3
		if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
			zap_icon = OVER_9000_ZAP_ICON_STATE
			//It'll stun more now, and damage will hit harder, gloves are no garentee.
			//Machines go boom
			flags |= (ZAP_MOB_STUN | ZAP_MACHINE_EXPLOSIVE | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
			zap_count = 4
	//Now we deal with damage shit
	if (damage > danger_point && prob(20))
		zap_count += 1

	if(zap_count >= 1)
		playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
		for(var/i in 1 to zap_count)
			supermatter_zap(src, range, clamp(power*2, 4000, 20000), flags, zap_cutoff = src.zap_cutoff, power_level = power, zap_icon = src.zap_icon)

	if(prob(5))
		supermatter_anomaly_gen(src, FLUX_ANOMALY, rand(5, 10))
	if(prob(5))
		supermatter_anomaly_gen(src, HALLUCINATION_ANOMALY, rand(5, 10))
	if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
		supermatter_anomaly_gen(src, GRAVITATIONAL_ANOMALY, rand(5, 10))
	if((power > SEVERE_POWER_PENALTY_THRESHOLD && prob(2)) || (prob(0.3) && power > POWER_PENALTY_THRESHOLD))
		supermatter_anomaly_gen(src, PYRO_ANOMALY, rand(5, 10))

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
