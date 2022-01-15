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
		/datum/gas/miasma
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
	)
	///The last air sample's total molar count, will always be above or equal to 0
	var/combined_gas = 0
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
	investigate_log("has been created.", INVESTIGATE_SUPERMATTER)
	if(is_main_engine)
		GLOB.main_supermatter_engine = src

	AddElement(/datum/element/bsa_blocker)
	RegisterSignal(src, COMSIG_ATOM_BSA_BEAM, .proc/call_explode)

	soundloop = new(src, TRUE)
	if(ispath(psyOverlay))
		psyOverlay = new psyOverlay()
	else
		stack_trace("Supermatter created with non-path psyOverlay variable. This can break things, please fix.")
		psyOverlay = new()

	if (!moveable)
		move_resist = MOVE_FORCE_OVERPOWERING // Avoid being moved by statues or other memes

	AddComponent(/datum/component/dusting,\
		callback_after_consume = CALLBACK(src, .proc/after_consumed),\
		callback_get_flavortext = CALLBACK(src, .proc/provide_text_vars),\
		callback_hitby_blob = CALLBACK(src, .proc/handle_blob_act),\
		callback_attackby = CALLBACK(src, .proc/handle_attackby),\
		ignore_subtypesof = list(/obj/effect, /obj/item/wrench),\
	)

	update_constants()

/obj/machinery/power/supermatter_crystal/Destroy()
	investigate_log("has been destroyed.", INVESTIGATE_SUPERMATTER)
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

/obj/machinery/power/supermatter_crystal/examine(mob/user)
	. = ..()
	var/immune = HAS_TRAIT(user, TRAIT_SUPERMATTER_MADNESS_IMMUNE) || (user.mind && HAS_TRAIT(user.mind, TRAIT_SUPERMATTER_MADNESS_IMMUNE))
	if(isliving(user) && !immune && (get_dist(user, src) < HALLUCINATION_RANGE(power)))
		. += span_danger("You get headaches just from looking at it.")

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
	if(final_countdown)
		. += "casuality_field"

/obj/machinery/power/supermatter_crystal/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE
	update_appearance()

	var/speaking = "[emergency_alert] The supermatter has reached critical integrity failure. Emergency causality destabilization field has been activated."
	radio.talk_into(src, speaking, common_channel, language = get_selected_language())
	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		if(damage < explosion_point) // Cutting it a bit close there engineers
			radio.talk_into(src, "[safe_alert] Failsafe has been disengaged.", common_channel)
			final_countdown = FALSE
			update_appearance()
			return
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(10)
			continue
		else if(i > 50)
			speaking = "[DisplayTimeText(i, TRUE)] remain before causality stabilization."
		else
			speaking = "[i*0.1]..."
		radio.talk_into(src, speaking, common_channel)
		sleep(10)

	explode()

/obj/machinery/power/supermatter_crystal/proc/explode()

	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || victim.z != z)
			continue
		if(ishuman(victim))
			//Hilariously enough, running into a closet should make you get hit the hardest.
			var/mob/living/carbon/human/human = victim
			human.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(victim, src) + 1)) ) )

		if (get_dist(victim, src) <= DETONATION_RADIATION_RANGE)
			SSradiation.irradiate(victim)

	var/turf/local_turf = get_turf(src)
	for(var/mob/victim as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(victim)
		if(local_turf.z != mob_turf.z)
			continue
		SEND_SOUND(victim, 'sound/magic/charge.ogg')

		if (victim.z != z)
			to_chat(victim, span_boldannounce("You hold onto \the [victim.loc] as hard as you can, as reality distorts around you. You feel safe."))
			continue
		to_chat(victim, span_boldannounce("You feel reality distort for a moment..."))
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)


	if(combined_gas > MOLE_PENALTY_THRESHOLD)
		investigate_log("has collapsed into a singularity.", INVESTIGATE_SUPERMATTER)
		if(local_turf) //If something fucks up we blow anyhow. This fix is 4 years old and none ever said why it's here. help.
			var/obj/singularity/created_singularity = new(local_turf)
			created_singularity.energy = 800
			created_singularity.consume(src)
			return //No boom for me sir
	if(power > POWER_PENALTY_THRESHOLD)
		investigate_log("has spawned additional energy balls.", INVESTIGATE_SUPERMATTER)
		if(local_turf)
			var/obj/energy_ball/created_tesla = new(local_turf)
			created_tesla.energy = 200 //Gets us about 9 balls
	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	explosion(origin = src,
		devastation_range = explosion_power * max(gasmix_power_ratio, 0.205) * 0.5,
		heavy_impact_range = explosion_power * max(gasmix_power_ratio, 0.205) + 2,
		light_impact_range = explosion_power * max(gasmix_power_ratio, 0.205) + 4,
		flash_range = explosion_power * max(gasmix_power_ratio, 0.205) + 6,
		adminlog = TRUE,
		ignorecap = TRUE
	)
	qdel(src)


//this is here to eat arguments
/obj/machinery/power/supermatter_crystal/proc/call_explode()
	SIGNAL_HANDLER

	explode()

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

	//We vary volume by power, and handle OH FUCK FUSION IN COOLING LOOP noises.
	if(power)
		soundloop.volume = clamp((50 + (power / 50)), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	//We play delam/neutral sounds at a rate determined by power and damage
	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((damage / 800) * (power / 2500)), 1.0) * 100
		if(damage >= 300)
			playsound(src, "smdelam", max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
		else
			playsound(src, "smcalm", max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
		var/next_sound = round((100 - aggression) * 5)
		last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = local_turf.return_air()
	var/env_pressure = env.return_pressure()
	var/datum/gas_mixture/removed
	if(produces_gas)
		//Remove gas from surrounding area
		removed = env.remove(gasefficency * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		removed = new()
	overlays -= psyOverlay
	if(psy_overlay)
		overlays -= psyOverlay
		if(psyCoeff > 0)
			psyOverlay.alpha = psyCoeff * 255
			overlays += psyOverlay
		else
			psy_overlay = FALSE
	damage_archived = damage
	if(!removed || !removed.total_moles() || isspaceturf(local_turf)) //we're in space or there is no gas to process
		if(takes_damage)
			damage += max((power / 1000) * DAMAGE_INCREASE_MULTIPLIER, 0.1) // always does at least some damage
		if(!istype(env, /datum/gas_mixture/immutable) && produces_gas && power) //There is no gas to process, but we are not in a space turf. Lets make them.
			//Power * 0.55 * a value between 1 and 0.8
			var/device_energy = power * REACTION_POWER_MODIFIER * (1 - (psyCoeff * 0.2))
			//Can't do stuff if it's null, so lets make a new gasmix.
			removed = new()
			//Since there is no gas to process, we will produce as if heat penalty is 1 and temperature at TCMB.
			removed.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)
			removed.temperature = ((device_energy) / THERMAL_RELEASE_MODIFIER)
			removed.temperature = max(TCMB, min(removed.temperature, 2500))
			removed.gases[/datum/gas/plasma][MOLES] = max((device_energy) / PLASMA_RELEASE_MODIFIER, 0)
			removed.gases[/datum/gas/oxygen][MOLES] = max(((device_energy + TCMB) - T0C) / OXYGEN_RELEASE_MODIFIER, 0)
			removed.garbage_collect()
			env.merge(removed)
			air_update_turf(FALSE, FALSE)
	else
		if(takes_damage)
			//causing damage
			//Due to DAMAGE_INCREASE_MULTIPLIER, we only deal one 4th of the damage the statements otherwise would cause

			//((((some value between 0.5 and 1 * temp - ((273.15 + 40) * some values between 1 and 10)) * some number between 0.25 and knock your socks off / 150) * 0.25
			//Heat and mols account for each other, a lot of hot mols are more damaging then a few
			//Mols start to have a positive effect on damage after 350
			damage = max(damage + (max(clamp(removed.total_moles() / 200, 0.5, 1) * removed.temperature - ((T0C + HEAT_PENALTY_THRESHOLD)*dynamic_heat_resistance), 0) * mole_heat_penalty / 150 ) * DAMAGE_INCREASE_MULTIPLIER, 0)
			//Power only starts affecting damage when it is above 5000
			damage = max(damage + (max(power - POWER_PENALTY_THRESHOLD, 0)/500) * DAMAGE_INCREASE_MULTIPLIER, 0)
			//Molar count only starts affecting damage when it is above 1800
			damage = max(damage + (max(combined_gas - MOLE_PENALTY_THRESHOLD, 0)/80) * DAMAGE_INCREASE_MULTIPLIER, 0)

			//There might be a way to integrate healing and hurting via heat
			//healing damage
			if(combined_gas < MOLE_PENALTY_THRESHOLD)
				//Only has a net positive effect when the temp is below 313.15, heals up to 2 damage. Psycologists increase this temp min by up to 45
				damage = max(damage + (min(removed.temperature - ((T0C + HEAT_PENALTY_THRESHOLD) + (45 * psyCoeff)), 0) / 150 ), 0)

			//Check for holes in the SM inner chamber
			for(var/turf/open/space/turf_to_check in RANGE_TURFS(1, loc))
				if(LAZYLEN(turf_to_check.atmos_adjacent_turfs))
					var/integrity = get_integrity_percent()
					if(integrity < 10)
						damage += clamp((power * 0.0005) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					else if(integrity < 25)
						damage += clamp((power * 0.0009) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					else if(integrity < 45)
						damage += clamp((power * 0.005) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					else if(integrity < 75)
						damage += clamp((power * 0.002) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					break
			//caps damage rate

			//Takes the lower number between archived damage + (1.8) and damage
			//This means we can only deal 1.8 damage per function call
			damage = min(damage_archived + (DAMAGE_HARDCAP * explosion_point),damage)

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

		var/h2obonus = 1 - (gas_comp[/datum/gas/water_vapor] * 0.25)//At max this value should be 0.75
		var/freonbonus = (gas_comp[/datum/gas/freon] <= 0.03) //Let's just yeet power output if this shit is high


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
		power_transmission_bonus *= h2obonus

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
			consumed_carbon_dioxide = min(consumed_carbon_dioxide * gas_comp[/datum/gas/carbon_dioxide] * combined_gas, removed.gases[/datum/gas/carbon_dioxide][MOLES], removed.gases[/datum/gas/oxygen][MOLES] * INVERSE(0.5))
			if(consumed_carbon_dioxide)
				removed.gases[/datum/gas/carbon_dioxide][MOLES] -= consumed_carbon_dioxide
				removed.gases[/datum/gas/oxygen][MOLES] -= consumed_carbon_dioxide * 0.5
				removed.gases[/datum/gas/pluoxium][MOLES] += consumed_carbon_dioxide * 0.5

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

		emit_radiation()

		//Zaps around 2.5 seconds at 1500 MeV, limited to 0.5 from 4000 MeV and up
		if(power && (last_power_zap + 4 SECONDS - (power * 0.001)) < world.time)
			//(1 + (tritRad + pluoxDampen * bzDampen * o2Rad * plasmaRad / (10 - bzrads))) * freonbonus
			playsound(src, 'sound/weapons/emitter2.ogg', 70, TRUE)
			var/power_multiplier = max(0, (1 + (power_transmission_bonus / (10 - (gas_comp[/datum/gas/bz] * BZ_RADIOACTIVITY_MODIFIER)))) * freonbonus)// RadModBZ(500%)
			var/pressure_multiplier = max((1 / ((env_pressure ** pressure_bonus_curve_angle) + 1) * pressure_bonus_derived_steepness) + pressure_bonus_derived_constant, 1)
			var/co2_power_increase = max(gas_comp[/datum/gas/carbon_dioxide] * 2, 1)
			supermatter_zap(
				zapstart = src,
				range = 3,
				zap_str = 2.5 * power * power_multiplier * pressure_multiplier * co2_power_increase,
				zap_flags = ZAP_SUPERMATTER_FLAGS,
				zap_cutoff = 300,
				power_level = power
			)
			last_power_zap = world.time

		if(prob(gas_comp[/datum/gas/zauker]))
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
			supermatter_zap(src, 6, clamp(power*2, 4000, 20000), ZAP_MOB_STUN, zap_cutoff = src.zap_cutoff, power_level = power, zap_icon = src.zap_icon)

		if(gas_comp[/datum/gas/bz] >= 0.4 && prob(30 * gas_comp[/datum/gas/bz]))
			src.fire_nuclear_particle()        // Start to emit radballs at a maximum of 30% chance per tick

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

	// Defaults to a value less than 1. Over time the psyCoeff goes to 0 if
	// no supermatter soothers are nearby.
	var/psy_coeff_diff = -0.05
	for(var/mob/living/carbon/human/seen_by_sm in view(src, HALLUCINATION_RANGE(power)))
		// Someone (generally a Psychologist), when looking at the SM
		// within hallucination range makes it easier to manage.
		if(HAS_TRAIT(seen_by_sm, TRAIT_SUPERMATTER_SOOTHER) || (seen_by_sm.mind && HAS_TRAIT(seen_by_sm.mind, TRAIT_SUPERMATTER_SOOTHER)))
			psy_coeff_diff = 0.05
			psy_overlay = TRUE

		// If they are immune to supermatter hallucinations.
		if (HAS_TRAIT(seen_by_sm, TRAIT_SUPERMATTER_MADNESS_IMMUNE) || (seen_by_sm.mind && HAS_TRAIT(seen_by_sm.mind, TRAIT_SUPERMATTER_MADNESS_IMMUNE)))
			continue

		// Blind people don't get supermatter hallucinations.
		if (seen_by_sm.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(seen_by_sm, src)))
		seen_by_sm.hallucination += power * hallucination_power * dist
		seen_by_sm.hallucination = clamp(seen_by_sm.hallucination, 0, 200)
	psyCoeff = clamp(psyCoeff + psy_coeff_diff, 0, 1)

	//Transitions between one function and another, one we use for the fast inital startup, the other is used to prevent errors with fusion temperatures.
	//Use of the second function improves the power gain imparted by using co2
	if(power_changes)
		power = max(power - min(((power/500)**3) * powerloss_inhibitor, power * 0.83 * powerloss_inhibitor) * (1 - (0.2 * psyCoeff)),0)
	//After this point power is lowered
	//This wraps around to the begining of the function
	//Handle high power zaps/anomaly generation
	if(power > POWER_PENALTY_THRESHOLD || damage > damage_penalty_point) //If the power is above 5000 or if the damage is above 550
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
		if (damage > damage_penalty_point && prob(20))
			zap_count += 1

		if(zap_count >= 1)
			playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
			for(var/i in 1 to zap_count)
				supermatter_zap(src, range, clamp(power*2, 4000, 20000), flags, zap_cutoff = src.zap_cutoff, power_level = power, zap_icon = src.zap_icon)

		if(prob(5))
			supermatter_anomaly_gen(src, FLUX_ANOMALY, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
			supermatter_anomaly_gen(src, GRAVITATIONAL_ANOMALY, rand(5, 10))
		if((power > SEVERE_POWER_PENALTY_THRESHOLD && prob(2)) || (prob(0.3) && power > POWER_PENALTY_THRESHOLD))
			supermatter_anomaly_gen(src, PYRO_ANOMALY, rand(5, 10))

	if(prob(15))
		supermatter_pull(loc, min(power/850, 3))//850, 1700, 2550

	//Tells the engi team to get their butt in gear
	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if(damage_archived < warning_point) //If damage_archive is under the warning point, this is the very first cycle that we've reached said point.
			SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_START_ALARM)
		if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_DELAY)
			alarm()

			//Oh shit it's bad, time to freak out
			if(damage > emergency_point)
				radio.talk_into(src, "[emergency_alert] Integrity: [get_integrity_percent()]%", common_channel)
				SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_ALARM)
				lastwarning = REALTIMEOFDAY
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", INVESTIGATE_SUPERMATTER)
					message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
					has_reached_emergency = TRUE
			else if(damage >= damage_archived) // The damage is still going up
				radio.talk_into(src, "[warning_alert] Integrity: [get_integrity_percent()]%", engineering_channel)
				SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_ALARM)
				lastwarning = REALTIMEOFDAY - (WARNING_DELAY * 5)

			else                                                 // Phew, we're safe
				radio.talk_into(src, "[safe_alert] Integrity: [get_integrity_percent()]%", engineering_channel)
				lastwarning = REALTIMEOFDAY

			if(power > POWER_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Hyperstructure has reached dangerous power level.", engineering_channel)
				if(powerloss_inhibitor < 0.5)
					radio.talk_into(src, "DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.", engineering_channel)

			if(combined_gas > MOLE_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Critical coolant mass reached.", engineering_channel)
		//Boom (Mind blown)
		if(damage > explosion_point)
			countdown()

	return TRUE

/obj/machinery/power/supermatter_crystal/bullet_act(obj/projectile/projectile)
	var/turf/local_turf = loc
	var/kiss_power = 0
	switch(projectile.type)
		if(/obj/projectile/kiss)
			kiss_power = 60
		if(/obj/projectile/kiss/death)
			kiss_power = 20000
	if(!istype(local_turf))
		return FALSE
	if(!istype(projectile.firer, /obj/machinery/power/emitter) && power_changes)
		investigate_log("has been hit by [projectile] fired by [key_name(projectile.firer)]", INVESTIGATE_SUPERMATTER)
	if(projectile.flag != BULLET || kiss_power)
		if(kiss_power)
			psyCoeff = 1
			psy_overlay = TRUE
		if(power_changes) //This needs to be here I swear
			power += projectile.damage * bullet_energy + kiss_power
			if(!has_been_powered)
				investigate_log("has been powered for the first time.", INVESTIGATE_SUPERMATTER)
				message_admins("[src] has been powered for the first time [ADMIN_JMP(src)].")
				has_been_powered = TRUE
	else if(takes_damage)
		damage += (projectile.damage * bullet_energy) * clamp((emergency_point - damage) / emergency_point, 0, 1)
		if(damage > damage_penalty_point)
			visible_message(span_notice("[src] compresses under stress, resisting further impacts!"))
	return BULLET_ACT_HIT

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("Supermatter shard consumed by singularity.", INVESTIGATE_SINGULO)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message(span_userdanger("[src] is consumed by the singularity!"))
	for(var/mob/hearing_mob as anything in GLOB.player_list)
		if(hearing_mob.z != z)
			continue
		SEND_SOUND(hearing_mob, 'sound/effects/supermatter.ogg') //everyone goan know bout this
		to_chat(hearing_mob, span_boldannounce("A horrible screeching fills your ears, and a wave of dread washes over you..."))
	qdel(src)
	return gain

/obj/machinery/power/supermatter_crystal/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a really dense idea."))
	jedi.ghostize()
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.internal_organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/power/supermatter_crystal/proc/after_consumed(/datum/component/dusting/comp_source, atom/consumed_atom)
	if(power_changes)
		matter_power += 200
	if(ismob(consumed_atom))
		var/mob/consumed_mob = consumed_atom
		if(takes_damage && is_clown_job(consumed_mob.mind?.assigned_role))
			damage += rand(-300, 300) // HONK
			damage = max(damage, 0)
		dust_memory(consumed_atom)
	if(power_changes)
		matter_power += 200

/obj/machinery/power/supermatter_crystal/proc/handle_blob_act(datum/component/dusting/comp_source, obj/structure/blob/attacking_blob)
	if(!attacking_blob || isspaceturf(loc)) //does nothing in space
		return
	damage += attacking_blob.get_integrity() * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us
	if(attacking_blob.get_integrity() > 100)
		attacking_blob.visible_message(span_danger("[attacking_blob] strikes at [src] and flinches away!"),
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
		attacking_blob.take_damage(100, BURN)
	else
		attacking_blob.visible_message(span_danger("[attacking_blob] strikes at [src] and rapidly flashes to ash."),
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
		return FALSE //Gets eaten
	return TRUE //Doesn't get eaten!

/obj/machinery/power/supermatter_crystal/proc/provide_text_vars(datum/component/dusting/comp_source, atom/consumed_atom, list/magic_text)
	. = list(
		COMP_DUST_RADIATION_VISUAL = span_danger("As [src] slowly stops resonating, you find your skin covered in new radiation burns."),
		COMP_DUST_RADIATION_AUDIBLE = span_danger("The unearthly ringing subsides and you find your skin covered in new radiation burns."),
		COMP_DUST_RADIATION_UNSEEN = span_hear("An unearthly ringing fills your ears, and you find your skin covered in new radiation burns."),
	) + magic_text
	if(ismob(consumed_atom))
		.[COMP_DUST_RADIATION_RANGE] = 6
		.[COMP_DUST_RADIATION_THRESHOLD] = 0.6
		.[COMP_DUST_RADIATION_CHANCE] = 60
		if(ishuman(consumed_atom))
			. += get_human_text_interaction(comp_source, consumed_atom)
		else if(isanimal(consumed_atom))
			var/mob/living/simple_animal/animal_user = consumed_atom
			var/verb_attack
			if(!animal_user.melee_damage_upper && !animal_user.melee_damage_lower)
				verb_attack = animal_user.friendly_verb_continuous
			else
				verb_attack = animal_user.attack_verb_continuous
			.[COMP_DUST_MOB_VISUAL] = span_danger("[animal_user] unwisely [verb_attack] [src], and [animal_user.p_their()] body burns brilliantly before flashing into ash!")
			.[COMP_DUST_MOB_SELF] = span_userdanger("You unwisely touch [src], and your vision glows brightly as your body crumbles to dust. Oops.")

/obj/machinery/power/supermatter_crystal/proc/get_human_text_interaction(datum/component/dusting/comp_source, mob/living/carbon/human/user)
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return

	if(!user.is_mouth_covered())
		if(user.combat_mode)
			return list(
				COMP_DUST_MOB_VISUAL = span_danger("As [user] tries to take a bite out of [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash."),
				COMP_DUST_MOB_SELF = span_userdanger("You try to take a bite out of [src], but find [p_them()] far too hard to get anywhere before everything starts burning and your ears fill with ringing!"),
			)

		var/obj/item/organ/tongue/licking_tongue = user.getorganslot(ORGAN_SLOT_TONGUE)
		if(licking_tongue)
			return list(
				COMP_DUST_MOB_VISUAL = span_danger("As [user] hesitantly leans in and licks [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash!"),
				COMP_DUST_MOB_SELF = span_userdanger("You tentatively lick [src], but you can't figure out what it tastes like before everything starts burning and your ears fill with ringing!"),
			)

	var/obj/item/bodypart/head/forehead = user.get_bodypart(BODY_ZONE_HEAD)
	if(forehead)
		return list(
			COMP_DUST_MOB_VISUAL = span_danger("As [user]'s forehead bumps into [src], inducing a resonance... Everything goes silent before [user.p_their()] [forehead] flashes to ash!"),
			COMP_DUST_MOB_SELF = span_userdanger("You feel your forehead bump into [src] and everything suddenly goes silent. As your head fills with ringing you come to realize that that was not a wise decision."),
		)
	
	return list(
		COMP_DUST_MOB_VISUAL = span_danger("[user] leans in and tries to lick [src], inducing a resonance... [user.p_their()] body starts to glow and burst into flames before flashing into dust!"),
		COMP_DUST_MOB_SELF = span_userdanger("You lean in and try to lick [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\""),
	)

/obj/machinery/power/supermatter_crystal/proc/dust_memory(mob/living/nom)
	add_memory_in_range(src, 7, MEMORY_SUPERMATTER_DUSTED, list(DETAIL_PROTAGONIST = nom, DETAIL_WHAT_BY = src), story_value = STORY_VALUE_OKAY, memory_flags = MEMORY_CHECK_BLIND_AND_DEAF)

/obj/machinery/power/supermatter_crystal/proc/handle_attackby(datum/component/dusting/comp_source, obj/item/item, mob/living/carbon/user, params)
	if(!istype(item) || (item.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(item, /obj/item/melee/roastingstick))
		return TRUE
	if(istype(item, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cig = item
		var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
		if(clumsy)
			var/which_hand = BODY_ZONE_L_ARM
			if(!(user.active_hand_index % 2))
				which_hand = BODY_ZONE_R_ARM
			var/obj/item/bodypart/dust_arm = user.get_bodypart(which_hand)
			dust_arm.dismember()
			comp_source.consume_and_radiate(dust_arm, visual_message = span_danger("The [item] flashes out of existence on contact with [src], resonating with a horrible sound..."))
			to_chat(user, span_danger("Oops! The [item] flashes out of existence on contact with [src], taking your arm with it! That was clumsy of you!"))
			item.forceMove(loc)
			qdel(item)
			return
		if(cig.lit || user.combat_mode)
			comp_source.consume_and_radiate(item, visual_message = span_danger("A hideous sound echoes as [item] is ashed out on contact with [src]. That didn't seem like a good idea..."))
			return
		else
			cig.light()
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
			comp_source.do_radiation(range=1, threshold=0, chance=100, visual_message = span_danger("As [user] lights [user.p_their()] [item] on [src], silence fills the room..."))
			user.visible_message(span_notice("[item] flashes alight with an eerie energy as [user] nonchalantly lifts [user.p_their()] hand away from [src]. Damn."),
				span_notice("[item] flashes alight with an eerie energy as you nonchalantly lift your hand away from [src]. Damn."))
			return TRUE

	if(istype(item, /obj/item/scalpel/supermatter))
		var/obj/item/scalpel/supermatter/scalpel = item
		to_chat(user, span_notice("You carefully begin to scrape [src] with [item]..."))
		if(item.use_tool(src, user, 60, volume=100))
			if (scalpel.usesLeft)
				to_chat(user, span_danger("You extract a sliver from [src], it begins to react violently!"))
				new /obj/item/nuke_core/supermatter_sliver(drop_location())
				matter_power += 800
				scalpel.usesLeft--
				if (!scalpel.usesLeft)
					to_chat(user, span_notice("A tiny piece of [item] falls off, rendering it useless!"))
			else
				to_chat(user, span_warning("You fail to extract a sliver from [src]! [item] isn't sharp enough anymore."))
		return TRUE

	else if(user.dropItemToGround(item)) //Consume the item
		investigate_log("has been attacked ([item]) by [key_name(user)]", INVESTIGATE_SUPERMATTER)
		user.visible_message(span_danger("As [user] touches [src] with \a [item], silence fills the room..."),
			span_userdanger("You touch [src] with [item], and everything suddenly goes silent.</span>\n<span class='notice'> [item] flashes into dust as you flinch away from [src]."),
			span_hear("Everything suddenly goes silent."))

	else if(Adjacent(user)) //if the item is stuck to the person, kill the person too instead of eating just the item.
		comp_source.consume_atom(item)
		comp_source.consume_atom(user)
		return TRUE

/obj/machinery/power/supermatter_crystal/wrench_act(mob/user, obj/item/tool)
	..()
	if (moveable)
		default_unfasten_wrench(user, tool, time = 20)
	return TRUE

/obj/machinery/power/supermatter_crystal/intercept_zImpact(list/falling_movables, levels)
	. = ..()
	for(var/atom/movable/hit_object as anything in falling_movables)
		Bumped(hit_object)
	. |= FALL_STOP_INTERCEPTING | FALL_INTERCEPTED

//Do not blow up our internal radio
/obj/machinery/power/supermatter_crystal/contents_explosion(severity, target)
	return

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
	moveable = TRUE
	psyOverlay = /obj/overlay/psy/shard

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

/obj/machinery/power/supermatter_crystal/proc/supermatter_anomaly_gen(turf/anomalycenter, type = FLUX_ANOMALY, anomalyrange = 5)
	var/turf/local_turf = pick(orange(anomalyrange, anomalycenter))
	if(!local_turf)
		return
	switch(type)
		if(FLUX_ANOMALY)
			var/obj/effect/anomaly/flux/flux = new(local_turf, 300, FALSE)
			flux.explosive = FALSE
		if(GRAVITATIONAL_ANOMALY)
			new /obj/effect/anomaly/grav(local_turf, 250, FALSE)
		if(PYRO_ANOMALY)
			new /obj/effect/anomaly/pyro(local_turf, 200, FALSE)

/obj/machinery/proc/supermatter_zap(atom/zapstart = src, range = 5, zap_str = 4000, zap_flags = ZAP_SUPERMATTER_FLAGS, list/targets_hit = list(), zap_cutoff = 1500, power_level = 0, zap_icon = DEFAULT_ZAP_ICON_STATE)
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
	zapstart.Beam(target, icon_state=zap_icon, time = 0.5 SECONDS)
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
		supermatter_zap(target, new_range, zap_str, zap_flags, child_targets_hit, zap_cutoff, power_level, zap_icon)

/obj/overlay/psy
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "psy"
	layer = FLOAT_LAYER - 1

/obj/overlay/psy/shard
	icon_state = "psy_shard"

#undef HALLUCINATION_RANGE
#undef GRAVITATIONAL_ANOMALY
#undef FLUX_ANOMALY
#undef PYRO_ANOMALY
#undef BIKE
#undef COIL
#undef ROD
#undef LIVING
#undef MACHINERY
#undef OBJECT
#undef LOWEST
