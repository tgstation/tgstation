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

#define CASCADING_ADMIN "Admin"
#define CASCADING_CRITICAL_GAS "Critical gas point"
#define CASCADING_DESTAB_CRYSTAL "Destabilizing crystal"

GLOBAL_DATUM(main_supermatter_engine, /obj/machinery/power/supermatter_crystal)

/obj/machinery/power/supermatter_crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter"
	density = TRUE
	anchored = TRUE
	layer = MOB_LAYER
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	critical_machine = TRUE
	base_icon_state = "darkmatter"

	///The id of our supermatter
	var/uid = 1
	///The amount of supermatters that have been created this round
	var/static/gl_uid = 1
	///Tracks the bolt color we are using
	var/zap_icon = DEFAULT_ZAP_ICON_STATE
	///The portion of the gasmix we're on that we should remove
	var/gasefficency = 0.15

	///Are we exploding?
	var/final_countdown = FALSE

	///The amount of damage we have currently
	var/damage = 0
	///The damage we had before this cycle. Used to limit the damage we can take each cycle, and for safe_alert
	var/damage_archived = 0
	///Our "Shit is no longer fucked" message. We send it when damage is less then damage_archived
	var/safe_alert = "Crystalline hyperstructure returning to safe operating parameters."
	///The point at which we should start sending messeges about the damage to the engi channels.
	var/warning_point = 50
	///The alert we send when we've reached warning_point
	var/warning_alert = "Danger! Crystal hyperstructure integrity faltering!"
	///The point at which we start sending messages to the common channel
	var/emergency_point = 700
	///The alert we send when we've reached emergency_point
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	///The point at which we delam
	var/explosion_point = 900
	///When we pass this amount of damage we start shooting bolts
	var/damage_penalty_point = 550

	///A scaling value that affects the severity of explosions.
	var/explosion_power = 35
	///Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0
	///Refered to as eer on the moniter. This value effects gas output, heat, damage, and radiation.
	var/power = 0
	///Determines the rate of positve change in gas comp values
	var/gas_change_rate = 0.05
	///The list of gases we will be interacting with in process_atoms()
	var/list/gases_we_care_about = list(
		/datum/gas/oxygen,
		/datum/gas/water_vapor,
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrous_oxide,
		/datum/gas/nitrogen,
		/datum/gas/pluoxium,
		/datum/gas/tritium,
		/datum/gas/bz,
		/datum/gas/freon,
		/datum/gas/hydrogen,
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/zauker,
		/datum/gas/miasma,
		/datum/gas/hypernoblium,
		/datum/gas/antinoblium,
	)
	///The list of gases mapped against their current comp. We use this to calculate different values the supermatter uses, like power or heat resistance. It doesn't perfectly match the air around the sm, instead moving up at a rate determined by gas_change_rate per call. Ranges from 0 to 1
	var/list/gas_comp = list(
		/datum/gas/oxygen = 0,
		/datum/gas/water_vapor = 0,
		/datum/gas/plasma = 0,
		/datum/gas/carbon_dioxide = 0,
		/datum/gas/nitrous_oxide = 0,
		/datum/gas/nitrogen = 0,
		/datum/gas/pluoxium = 0,
		/datum/gas/tritium = 0,
		/datum/gas/bz = 0,
		/datum/gas/freon = 0,
		/datum/gas/hydrogen = 0,
		/datum/gas/healium = 0,
		/datum/gas/proto_nitrate = 0,
		/datum/gas/zauker = 0,
		/datum/gas/hypernoblium = 0,
		/datum/gas/antinoblium = 0,
	)
	///The list of gases mapped against their transmit values. We use it to determine the effect different gases have on the zaps
	var/list/gas_trans = list(
		/datum/gas/oxygen = OXYGEN_TRANSMIT_MODIFIER,
		/datum/gas/water_vapor = H2O_TRANSMIT_MODIFIER,
		/datum/gas/plasma = PLASMA_TRANSMIT_MODIFIER,
		/datum/gas/pluoxium = PLUOXIUM_TRANSMIT_MODIFIER,
		/datum/gas/tritium = TRITIUM_TRANSMIT_MODIFIER,
		/datum/gas/bz = BZ_TRANSMIT_MODIFIER,
		/datum/gas/hydrogen = HYDROGEN_TRANSMIT_MODIFIER,
		/datum/gas/healium = HEALIUM_TRANSMIT_MODIFIER,
		/datum/gas/proto_nitrate = PROTO_NITRATE_TRANSMIT_MODIFIER,
		/datum/gas/zauker = ZAUKER_TRANSMIT_MODIFIER,
		/datum/gas/hypernoblium = HYPERNOBLIUM_TRANSMIT_MODIFIER,
		/datum/gas/antinoblium = ANTINOBLIUM_TRANSMIT_MODIFIER,
	)
	///The list of gases mapped against their heat penaltys. We use it to determin molar and heat output
	var/list/gas_heat = list(
		/datum/gas/oxygen = OXYGEN_HEAT_PENALTY,
		/datum/gas/water_vapor = H2O_HEAT_PENALTY,
		/datum/gas/plasma = PLASMA_HEAT_PENALTY,
		/datum/gas/carbon_dioxide = CO2_HEAT_PENALTY,
		/datum/gas/nitrogen = NITROGEN_HEAT_PENALTY,
		/datum/gas/pluoxium = PLUOXIUM_HEAT_PENALTY,
		/datum/gas/tritium = TRITIUM_HEAT_PENALTY,
		/datum/gas/bz = BZ_HEAT_PENALTY,
		/datum/gas/freon = FREON_HEAT_PENALTY,
		/datum/gas/hydrogen = HYDROGEN_HEAT_PENALTY,
		/datum/gas/healium = HEALIUM_HEAT_PENALTY,
		/datum/gas/proto_nitrate = PROTO_NITRATE_HEAT_PENALTY,
		/datum/gas/zauker = ZAUKER_HEAT_PENALTY,
		/datum/gas/hypernoblium = HYPERNOBLIUM_HEAT_PENALTY,
		/datum/gas/antinoblium = ANTINOBLIUM_HEAT_PENALTY,
	)
	///The list of gases mapped against their heat resistance. We use it to moderate heat damage.
	var/list/gas_resist = list(
		/datum/gas/nitrous_oxide = N2O_HEAT_RESISTANCE,
		/datum/gas/hydrogen = HYDROGEN_HEAT_RESISTANCE,
		/datum/gas/proto_nitrate = PROTO_NITRATE_HEAT_RESISTANCE,
	)
	///The list of gases mapped against their powermix ratio
	var/list/gas_powermix = list(
		/datum/gas/oxygen = 1,
		/datum/gas/water_vapor = 1,
		/datum/gas/plasma = 1,
		/datum/gas/carbon_dioxide = 1,
		/datum/gas/nitrogen = -1,
		/datum/gas/pluoxium = -1,
		/datum/gas/tritium = 1,
		/datum/gas/bz = 1,
		/datum/gas/freon = -1,
		/datum/gas/hydrogen = 1,
		/datum/gas/healium = 1,
		/datum/gas/proto_nitrate = 1,
		/datum/gas/zauker = 1,
		/datum/gas/miasma = 0.5,
		/datum/gas/antinoblium = 1,
		/datum/gas/hypernoblium = -1,
	)
	///The last air sample's total molar count, will always be above or equal to 0
	var/combined_gas = 0
	///Total mole count of the environment we are in
	var/environment_total_moles = 0
	///Affects the power gain the sm experiances from heat
	var/gasmix_power_ratio = 0
	///Affects the amount of o2 and plasma the sm outputs, along with the heat it makes.
	var/dynamic_heat_modifier = 1
	///Affects the amount of damage and minimum point at which the sm takes heat damage
	var/dynamic_heat_resistance = 1
	///Uses powerloss_dynamic_scaling and combined_gas to lessen the effects of our powerloss functions
	var/powerloss_inhibitor = 1
	///Based on co2 percentage, slowly moves between 0 and 1. We use it to calc the powerloss_inhibitor
	var/powerloss_dynamic_scaling= 0
	///Affects the amount of radiation the sm makes. We multiply this with power to find the zap power.
	var/power_transmission_bonus = 0
	///Used to increase or lessen the amount of damage the sm takes from heat based on molar counts.
	var/mole_heat_penalty = 0
	///Takes the energy throwing things into the sm generates and slowly turns it into actual power
	var/matter_power = 0
	///The cutoff for a bolt jumping, grows with heat, lowers with higher mol count,
	var/zap_cutoff = 1500
	///How much the bullets damage should be multiplied by when it is added to the internal variables
	var/bullet_energy = 2
	///How much hallucination should we produce per unit of power?
	var/hallucination_power = 0.1

	///Pressure bonus constants
	///If the SM is operating in sufficiently low pressure, increase power output.
	///This needs both a small amount of gas and a strong cooling system to keep temperature low in a low heat capacity environment.

	///These constants are used to derive the values in the pressure bonus equation from human-meaningful values
	///If you're varediting these, call update_constants() to update the derived values

	///What is the maximum multiplier reachable from having low pressure?
	var/pressure_bonus_max_multiplier = 0.5
	///At what environmental pressure, in kPa, should we start giving a pressure bonus?
	var/pressure_bonus_max_pressure = 100
	///How steeply angled is the pressure bonus curve? Higher values means more of the bonus is available at higher pressures.
	///Note that very low values can keep the bonus very close to 1 until it's nearly a vaccuum. Higher values can introduce diminishing returns on lower pressure.
	var/pressure_bonus_curve_angle = 1.8

	///These values are calculated from the above in update_constants() and immediately overwritten
	///The default values will always result in a no-op 1x modifier, in case something breaks.
	var/pressure_bonus_derived_constant = 1
	var/pressure_bonus_derived_steepness = 0


	///Our internal radio
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng
	///The engineering channel
	var/engineering_channel = "Engineering"
	///The common channel
	var/common_channel = null

	///Boolean used for logging if we've been powered
	var/has_been_powered = FALSE
	///Boolean used for logging if we've passed the emergency point
	var/has_reached_emergency = FALSE

	///An effect we show to admins and ghosts the percentage of delam we're at
	var/obj/effect/countdown/supermatter/countdown

	///Used along with a global var to track if we can give out the sm sliver stealing objective
	var/is_main_engine = FALSE
	///Our soundloop
	var/datum/looping_sound/supermatter/soundloop
	///Can it be moved?
	var/moveable = FALSE

	///cooldown tracker for accent sounds
	var/last_accent_sound = 0
	///Var that increases from 0 to 1 when a psycologist is nearby, and decreases in the same way
	var/psyCoeff = 0
	///Should we check the psy overlay?
	var/psy_overlay = FALSE
	///A pinkish overlay used to denote the presance of a psycologist. We fade in and out of this depending on the amount of time they've spent near the crystal
	var/obj/overlay/psy/psyOverlay = /obj/overlay/psy

	//For making hugbox supermatters
	///Disables all methods of taking damage
	var/takes_damage = TRUE
	///Disables the production of gas, and pretty much any handling of it we do.
	var/produces_gas = TRUE
	///Disables power changes
	var/power_changes = TRUE
	///Disables the sm's proccessing totally.
	var/processes = TRUE
	///Stores the time of when the last zap occurred
	var/last_power_zap = 0
	///Do we show this crystal in the CIMS modular program
	var/include_in_cims = TRUE

	var/freonbonus = 0
	///Can the crystal trigger the station wide anomaly spawn?
	var/anomaly_event = TRUE
	///Hue shift of the zaps color based on the power of the crystal
	var/hue_angle_shift = 0
	///If an admin wants a sure cascade with the delamination just set this to true (don't be a badmin)
	var/admin_cascade = FALSE
	///Do we have a destabilizing crystal attached?
	var/has_destabilizing_crystal = FALSE
	///Has the cascade been triggered?
	var/cascade_initiated = FALSE
	///Reference to the warp effect
	var/atom/movable/supermatter_warp_effect/warp
	///The power threshold required to transform the powerloss function into a linear function from a cubic function.
	var/powerloss_linear_threshold = 0
	///The offset of the linear powerloss function set so the transition is differentiable.
	var/powerloss_linear_offset = 0

/obj/machinery/power/supermatter_crystal/Initialize(mapload)
	. = ..()
	uid = gl_uid++
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
	RegisterSignal(src, COMSIG_ATOM_BSA_BEAM, .proc/call_delamination_event)

	var/static/list/loc_connections = list(
		COMSIG_TURF_INDUSTRIAL_LIFT_ENTER = .proc/tram_contents_consume,
	)
	AddElement(/datum/element/connect_loc, loc_connections)	//Speficially for the tram, hacky

	AddComponent(/datum/component/supermatter_crystal, CALLBACK(src, .proc/wrench_act_callback), CALLBACK(src, .proc/consume_callback))

	soundloop = new(src, TRUE)
	if(ispath(psyOverlay))
		psyOverlay = new psyOverlay()
	else
		stack_trace("Supermatter created with non-path psyOverlay variable. This can break things, please fix.")
		psyOverlay = new()

	if (!moveable)
		move_resist = MOVE_FORCE_OVERPOWERING // Avoid being moved by statues or other memes

	update_constants()

/obj/machinery/power/supermatter_crystal/Destroy()
	if(warp)
		vis_contents -= warp
		QDEL_NULL(warp)
	investigate_log("has been destroyed.", INVESTIGATE_ENGINE)
	SSair.stop_processing_machine(src)
	QDEL_NULL(radio)
	QDEL_NULL(countdown)
	if(is_main_engine && GLOB.main_supermatter_engine == src)
		GLOB.main_supermatter_engine = null
	QDEL_NULL(soundloop)
	if(psyOverlay)
		QDEL_NULL(psyOverlay)
	return ..()

/obj/machinery/power/supermatter_crystal/proc/update_constants()
	pressure_bonus_derived_steepness = (1 - 1 / pressure_bonus_max_multiplier) / (pressure_bonus_max_pressure ** pressure_bonus_curve_angle)
	pressure_bonus_derived_constant = 1 / pressure_bonus_max_multiplier - pressure_bonus_derived_steepness
	powerloss_linear_threshold = sqrt(POWERLOSS_LINEAR_RATE / 3 * POWERLOSS_CUBIC_DIVISOR ** 3)
	powerloss_linear_offset = -1 * powerloss_linear_threshold * POWERLOSS_LINEAR_RATE + (powerloss_linear_threshold / POWERLOSS_CUBIC_DIVISOR) ** 3

/obj/machinery/power/supermatter_crystal/examine(mob/user)
	. = ..()
	var/immune = HAS_TRAIT(user, TRAIT_MADNESS_IMMUNE) || (user.mind && HAS_TRAIT(user.mind, TRAIT_MADNESS_IMMUNE))
	if(isliving(user) && !immune && (get_dist(user, src) < HALLUCINATION_RANGE(power)))
		. += span_danger("You get headaches just from looking at it.")
	if(cascade_initiated)
		. += span_bolddanger("The crystal is vibrating at immense speeds, warping space around it!")

// SupermatterMonitor UI for ghosts only. Inherited attack_ghost will call this.
/obj/machinery/power/supermatter_crystal/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user))
		return FALSE
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SupermatterMonitor")
		ui.open()

/obj/machinery/power/supermatter_crystal/ui_data(mob/user)
	var/list/data = list()

	var/turf/local_turf = get_turf(src)

	var/datum/gas_mixture/air = local_turf.return_air()

	// singlecrystal set to true eliminates the back sign on the gases breakdown.
	data["singlecrystal"] = TRUE
	data["active"] = TRUE
	data["SM_integrity"] = get_integrity_percent()
	data["SM_power"] = power
	data["SM_ambienttemp"] = air.temperature
	data["SM_ambientpressure"] = air.return_pressure()
	data["SM_bad_moles_amount"] = MOLE_PENALTY_THRESHOLD / gasefficency
	data["SM_moles"] = 0
	data["SM_uid"] = uid
	var/area/active_supermatter_area = get_area(src)
	data["SM_area_name"] = active_supermatter_area.name

	var/list/gasdata = list()

	if(air.total_moles())
		data["SM_moles"] = air.total_moles()
		for(var/gasid in air.gases)
			gasdata.Add(list(list(
			"name"= air.gases[gasid][GAS_META][META_GAS_NAME],
			"amount" = round(100*air.gases[gasid][MOLES]/air.total_moles(),0.01))))

	else
		for(var/gasid in air.gases)
			gasdata.Add(list(list(
				"name"= air.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = 0)))

	data["gases"] = gasdata

	return data

/obj/machinery/power/supermatter_crystal/proc/get_status()
	var/turf/local_turf = get_turf(src)
	if(!local_turf)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = local_turf.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	var/integrity = get_integrity_percent()
	if(integrity < SUPERMATTER_DELAM_PERCENT)
		return SUPERMATTER_DELAMINATING

	if(integrity < SUPERMATTER_EMERGENCY_PERCENT)
		return SUPERMATTER_EMERGENCY

	if(integrity < SUPERMATTER_DANGER_PERCENT)
		return SUPERMATTER_DANGER

	if((integrity < SUPERMATTER_WARNING_PERCENT) || (air.temperature > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.temperature > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter_crystal/proc/alarm()
	switch(get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(SUPERMATTER_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/obj/machinery/power/supermatter_crystal/proc/get_integrity_percent()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100, 0.01)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/power/supermatter_crystal/update_overlays()
	. = ..()
	if(final_countdown && !cascade_initiated)
		. += "casuality_field"

/obj/machinery/power/supermatter_crystal/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE
	update_appearance()

	var/cascading = cascade_initiated

	var/speaking = "[emergency_alert] The supermatter has reached critical integrity failure."

	if(cascading)
		speaking += " Harmonic frequency limits exceeded. Causality destabilization field could not be engaged."
	else
		speaking += " Emergency causality destabilization field has been activated."

	radio.talk_into(src, speaking, common_channel, language = get_selected_language())
	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		if(damage < explosion_point) // Cutting it a bit close there engineers
			if(cascading)
				radio.talk_into(src, "[safe_alert] Harmonic frequency restored within emergency bounds. Anti-resonance filter initiated.", common_channel)
			else
				radio.talk_into(src, "[safe_alert] Failsafe has been disengaged.", common_channel)
			final_countdown = FALSE
			update_appearance()
			return
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(10)
			continue
		else if(i > 50)
			if(cascading)
				speaking = "[DisplayTimeText(i, TRUE)] remain before resonance-induced stabilization."
			else
				speaking = "[DisplayTimeText(i, TRUE)] remain before causality stabilization."
		else
			speaking = "[i*0.1]..."
		radio.talk_into(src, speaking, common_channel)
		sleep(1 SECONDS)

	delamination_event()

/obj/machinery/power/supermatter_crystal/proc/delamination_event()
	var/can_spawn_anomalies = is_station_level(loc.z) && is_main_engine && anomaly_event

	var/is_cascading = cascade_initiated

	new /datum/supermatter_delamination(power, combined_gas, get_turf(src), explosion_power, gasmix_power_ratio, can_spawn_anomalies, is_cascading)
	qdel(src)

//this is here to eat arguments
/obj/machinery/power/supermatter_crystal/proc/call_delamination_event()
	SIGNAL_HANDLER
	delamination_event()

/**
 * Checks if and why the supermatter is in a state where it can cascade
 *
 * Returns: cause of the cascade, for logging
 */
/obj/machinery/power/supermatter_crystal/proc/check_cascade_requirements()
	if(admin_cascade)
		return CASCADING_ADMIN

	if(!anomaly_event)
		return FALSE

	if(has_destabilizing_crystal)
		return CASCADING_DESTAB_CRYSTAL

	var/critical_gas_exceeded = TRUE
	var/list/required_gases = list(/datum/gas/hypernoblium, /datum/gas/antinoblium)
	if(environment_total_moles < MOLE_PENALTY_THRESHOLD)
		critical_gas_exceeded = FALSE
	else
		for(var/gas_path in required_gases)
			if(gas_comp[gas_path] < 0.4)
				critical_gas_exceeded = FALSE
				break

	if(critical_gas_exceeded)
		return CASCADING_CRITICAL_GAS

	return FALSE

/obj/machinery/power/supermatter_crystal/proc/supermatter_pull(turf/center, pull_range = 3)
	playsound(center, 'sound/weapons/marauder.ogg', 100, TRUE, extrarange = pull_range - world.view)
	for(var/atom/movable/movable_atom in orange(pull_range,center))
		if((movable_atom.anchored || movable_atom.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)) //move resist memes.
			if(istype(movable_atom, /obj/structure/closet))
				var/obj/structure/closet/closet = movable_atom
				closet.open(force = TRUE)
			continue
		if(ismob(movable_atom))
			var/mob/pulled_mob = movable_atom
			if(pulled_mob.mob_negates_gravity())
				continue //You can't pull someone nailed to the deck
		step_towards(movable_atom,center)

/proc/supermatter_anomaly_gen(turf/anomalycenter, type = FLUX_ANOMALY, anomalyrange = 5, has_changed_lifespan = TRUE)
	var/turf/local_turf = pick(orange(anomalyrange, anomalycenter))
	if(!local_turf)
		return
	switch(type)
		if(FLUX_ANOMALY)
			var/explosive = has_changed_lifespan ? FLUX_NO_EXPLOSION : FLUX_LOW_EXPLOSIVE
			new /obj/effect/anomaly/flux(local_turf, has_changed_lifespan ? rand(250, 350) : null, FALSE, explosive)
		if(GRAVITATIONAL_ANOMALY)
			new /obj/effect/anomaly/grav(local_turf, has_changed_lifespan ? rand(200, 300) : null, FALSE)
		if(PYRO_ANOMALY)
			new /obj/effect/anomaly/pyro(local_turf, has_changed_lifespan ? rand(150, 250) : null, FALSE)
		if(HALLUCINATION_ANOMALY)
			new /obj/effect/anomaly/hallucination(local_turf, has_changed_lifespan ? rand(150, 250) : null, FALSE)
		if(VORTEX_ANOMALY)
			new /obj/effect/anomaly/bhole(local_turf, 20, FALSE)
		if(BIOSCRAMBLER_ANOMALY)
			new /obj/effect/anomaly/bioscrambler(local_turf, null, FALSE)

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
	for(var/test in oview(zapstart, range))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(targets_hit, test))
			continue

		if(istype(test, /obj/vehicle/ridden/bicycle/))
			var/obj/vehicle/ridden/bicycle/bike = test
			if(!(bike.obj_flags & BEING_SHOCKED) && bike.can_buckle)//God's not on our side cause he hates idiots.
				if(target_type != BIKE)
					arc_targets = list()
				arc_targets += test
				target_type = BIKE

		if(target_type > COIL)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/tesla_coil/))
			var/obj/machinery/power/energy_accumulator/tesla_coil/coil = test
			if(coil.anchored && !(coil.obj_flags & BEING_SHOCKED) && !coil.panel_open && prob(70))//Diversity of death
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

		if(istype(test, /mob/living/))
			var/mob/living/alive = test
			if(!(HAS_TRAIT(alive, TRAIT_TESLA_SHOCKIMMUNE)) && !(alive.flags_1 & SHOCKED_1) && alive.stat != DEAD && prob(20))//let's not hit all the engineers with every beam and/or segment of the arc
				if(target_type != LIVING)
					arc_targets = list()
				arc_targets += test
				target_type = LIVING

		if(target_type > MACHINERY)
			continue

		if(istype(test, /obj/machinery/))
			var/obj/machinery/machine = test
			if(!(machine.obj_flags & BEING_SHOCKED) && prob(40))
				if(target_type != MACHINERY)
					arc_targets = list()
				arc_targets += test
				target_type = MACHINERY

		if(target_type > OBJECT)
			continue

		if(istype(test, /obj/))
			var/obj/object = test
			if(!(object.obj_flags & BEING_SHOCKED))
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
		creature.set_shocked()
		addtimer(CALLBACK(creature, /mob/living/proc/reset_shocked), 1 SECONDS)
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

/obj/machinery/power/supermatter_crystal/engine
	is_main_engine = TRUE

/obj/machinery/power/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure."
	base_icon_state = "darkmatter_shard"
	icon_state = "darkmatter_shard"
	anchored = FALSE
	gasefficency = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	moveable = TRUE
	psyOverlay = /obj/overlay/psy/shard
	anomaly_event = FALSE

/obj/machinery/power/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	is_main_engine = TRUE
	anchored = TRUE
	moveable = FALSE

// When you wanna make a supermatter shard for the dramatic effect, but
// don't want it exploding suddenly
/obj/machinery/power/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	takes_damage = FALSE
	produces_gas = FALSE
	power_changes = FALSE
	processes = FALSE //SHUT IT DOWN
	moveable = FALSE
	anchored = TRUE

/obj/machinery/power/supermatter_crystal/shard/hugbox/fakecrystal //Hugbox shard with crystal visuals, used in the Supermatter/Hyperfractal shuttle
	name = "supermatter crystal"
	base_icon_state = "darkmatter"
	icon_state = "darkmatter"

/obj/overlay/psy
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "psy"
	layer = FLOAT_LAYER - 1

/obj/overlay/psy/shard
	icon_state = "psy_shard"

/atom/movable/supermatter_warp_effect
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE // no tile bound so you can see it around corners and so
	icon = 'icons/effects/light_overlays/light_352.dmi'
	icon_state = "light"
	pixel_x = -176
	pixel_y = -176

#undef CASCADING_ADMIN
#undef CASCADING_CRITICAL_GAS
#undef CASCADING_DESTAB_CRYSTAL

#undef BIKE
#undef COIL
#undef ROD
#undef LIVING
#undef MACHINERY
#undef OBJECT
#undef LOWEST
