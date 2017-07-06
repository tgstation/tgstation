//Ported from /vg/station13, which was in turn forked from baystation12;
//Please do not bother them with bugs from this port, however, as it has been modified quite a bit.
//Modifications include removing the world-ending full supermatter variation, and leaving only the shard.

#define PLASMA_HEAT_PENALTY 15     // Higher == Bigger heat and waste penalty from having the crystal surrounded by this gas. Negative numbers reduce penalty.
#define OXYGEN_HEAT_PENALTY 1
#define CO2_HEAT_PENALTY 0.1
#define NITROGEN_HEAT_MODIFIER -1.5

#define OXYGEN_TRANSMIT_MODIFIER 1.5   //Higher == Bigger bonus to power generation.
#define PLASMA_TRANSMIT_MODIFIER 4
#define FREON_TRANSMIT_PENALTY 0.75    // Scales how much freon reduces total power transmission. 1 equals 1% per 1% of freon in the mix.

#define N2O_HEAT_RESISTANCE 6          //Higher == Gas makes the crystal more resistant against heat damage.

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20         //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20        //Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.        //Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

#define MOLE_PENALTY_THRESHOLD 1800           //Higher == Shard can absorb more moles before triggering the high mole penalties.
#define MOLE_HEAT_PENALTY 350                 //Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
#define POWER_PENALTY_THRESHOLD 5000          //Higher == Engine can generate more power before triggering the high power penalties.
#define SEVERE_POWER_PENALTY_THRESHOLD 7000   //Same as above, but causes more dangerous effects
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000 //Even more dangerous effects, threshold for tesla delamination
#define HEAT_PENALTY_THRESHOLD 40             //Higher == Crystal safe operational temperature is higher.
#define DAMAGE_HARDCAP 0.0025
#define DAMAGE_INCREASE_MULTIPLIER 0.25


#define THERMAL_RELEASE_MODIFIER 5         //Higher == less heat released during reaction, not to be confused with the above values
#define PLASMA_RELEASE_MODIFIER 750        //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 325        //Higher == less oxygen released at high temperature/power
#define FREON_BREEDING_MODIFIER 100        //Higher == less freon created
#define REACTION_POWER_MODIFIER 0.55       //Higher == more overall power

#define MATTER_POWER_CONVERSION 10         //Crystal converts 1/this value of stored matter into energy.

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600


#define WARNING_DELAY 60

#define HALLUCINATION_RANGE(P) (min(7, round(P ** 0.25)))


#define GRAVITATIONAL_ANOMALY "gravitational_anomaly"
#define FLUX_ANOMALY "flux_anomaly"
#define PYRO_ANOMALY "pyro_anomaly"

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define SUPERMATTER_DELAM_PERCENT 5
#define SUPERMATTER_EMERGENCY_PERCENT 25
#define SUPERMATTER_DANGER_PERCENT 50
#define SUPERMATTER_WARNING_PERCENT 100

/obj/machinery/power/supermatter_shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter_shard"
	density = TRUE
	anchored = FALSE
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	critical_machine = TRUE

	var/gasefficency = 0.125

	var/base_icon_state = "darkmatter_shard"

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystalline hyperstructure returning to safe operating levels."
	var/warning_point = 50
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/damage_penalty_point = 550
	var/emergency_point = 700
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	var/explosion_point = 900

	var/emergency_issued = FALSE

	var/explosion_power = 12
	var/temp_factor = 30

	var/lastwarning = 0				// Time in 1/10th of seconds since the last sent warning
	var/power = 0

	var/n2comp = 0					// raw composition of each gas in the chamber, ranges from 0 to 1
	var/freoncomp = 0

	var/plasmacomp = 0
	var/o2comp = 0
	var/co2comp = 0
	var/n2ocomp = 0

	var/combined_gas = 0
	var/gasmix_power_ratio = 0
	var/dynamic_heat_modifier = 1
	var/dynamic_heat_resistance = 1
	var/powerloss_inhibitor = 1
	var/powerloss_dynamic_scaling= 0
	var/power_transmission_bonus = 0
	var/mole_heat_penalty = 0
	var/freon_transmit_modifier = 1

	var/matter_power = 0

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much of the power is left after processing is finished?
//	var/config_power_reduction_per_tick = 0.5
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/obj/item/device/radio/radio
	var/radio_key = /obj/item/device/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/common_channel = null

	//for logging
	var/has_been_powered = FALSE
	var/has_reached_emergency = FALSE

	// For making hugbox supermatter
	var/takes_damage = TRUE
	var/produces_gas = TRUE
	var/obj/effect/countdown/supermatter/countdown

/obj/machinery/power/supermatter_shard/make_frozen_visual()
	return

/obj/machinery/power/supermatter_shard/Initialize()
	. = ..()
	SSair.atmos_machinery += src
	countdown = new(src)
	countdown.start()
	GLOB.poi_list |= src
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()
	investigate_log("has been created.", INVESTIGATE_SUPERMATTER)


/obj/machinery/power/supermatter_shard/Destroy()
	investigate_log("has been destroyed.", INVESTIGATE_SUPERMATTER)
	SSair.atmos_machinery -= src
	QDEL_NULL(radio)
	GLOB.poi_list -= src
	QDEL_NULL(countdown)
	. = ..()

/obj/machinery/power/supermatter_shard/examine(mob/user)
	..()
	if(!ishuman(user))
		return

	var/range = HALLUCINATION_RANGE(power)
	for(var/mob/living/carbon/human/H in viewers(range, src))
		if(H != user)
			continue
		if(!istype(H.glasses, /obj/item/clothing/glasses/meson))
			to_chat(H, "<span class='danger'>You get headaches just from looking at it.</span>")
		return

/obj/machinery/power/supermatter_shard/get_spans()
	return list(SPAN_ROBOT)

#define CRITICAL_TEMPERATURE 10000

/obj/machinery/power/supermatter_shard/proc/get_status()
	var/turf/T = get_turf(src)
	if(!T)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	if(get_integrity() < SUPERMATTER_DELAM_PERCENT)
		return SUPERMATTER_DELAMINATING

	if(get_integrity() < SUPERMATTER_EMERGENCY_PERCENT)
		return SUPERMATTER_EMERGENCY

	if(get_integrity() < SUPERMATTER_DANGER_PERCENT)
		return SUPERMATTER_DANGER

	if((get_integrity() < SUPERMATTER_WARNING_PERCENT) || (air.temperature > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.temperature > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter_shard/proc/get_integrity()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/power/supermatter_shard/proc/explode()
	var/turf/T = get_turf(src)
	for(var/mob/M in GLOB.mob_list)
		if(M.z == z)
			M << 'sound/magic/charge.ogg'
			to_chat(M, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
	if(combined_gas > MOLE_PENALTY_THRESHOLD)
		investigate_log("has collapsed into a singularity.", INVESTIGATE_SUPERMATTER)
		if(T)
			var/obj/singularity/S = new(T)
			S.energy = 800
			S.consume(src)
	else
		investigate_log("has exploded.", INVESTIGATE_SUPERMATTER)
		explosion(get_turf(T), explosion_power * max(gasmix_power_ratio, 0.205) * 0.5 , explosion_power * max(gasmix_power_ratio, 0.205) + 2, explosion_power * max(gasmix_power_ratio, 0.205) + 4 , explosion_power * max(gasmix_power_ratio, 0.205) + 6, 1, 1)
		if(power > POWER_PENALTY_THRESHOLD)
			investigate_log("has spawned additional energy balls.", INVESTIGATE_SUPERMATTER)
			var/obj/singularity/energy_ball/E = new(T)
			E.energy = power
		qdel(src)

/obj/machinery/power/supermatter_shard/process_atmos()
	var/turf/T = loc

	if(isnull(T))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(T)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = T.return_air()

	var/datum/gas_mixture/removed

	if(produces_gas)
		//Remove gas from surrounding area
		removed = env.remove(gasefficency * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		removed = new()

	if(!removed || !removed.total_moles() || isspaceturf(T)) //we're in space or there is no gas to process
		if(takes_damage)
			damage += max((power-1600)/10, 0)
		return 1

	damage_archived = damage
	if(takes_damage)
		//causing damage
		damage = max(damage + (max(removed.temperature - ((T0C + HEAT_PENALTY_THRESHOLD)*dynamic_heat_resistance), 0) * mole_heat_penalty / 150 ) * DAMAGE_INCREASE_MULTIPLIER, 0)
		damage = max(damage + (max(power - POWER_PENALTY_THRESHOLD, 0)/500) * DAMAGE_INCREASE_MULTIPLIER, 0)
		damage = max(damage + (max(combined_gas - MOLE_PENALTY_THRESHOLD, 0)/80) * DAMAGE_INCREASE_MULTIPLIER, 0)

		//healing damage
		if(combined_gas < MOLE_PENALTY_THRESHOLD)
			damage = max(damage + (min(removed.temperature - (T0C + HEAT_PENALTY_THRESHOLD), 0) / 150 ), 0)

		//capping damage
		damage = min(damage_archived + (DAMAGE_HARDCAP * explosion_point),damage)
		if(damage > damage_archived && prob(10))
			playsound(get_turf(src), 'sound/effects/empulse.ogg', 50, 1)

	removed.assert_gases("o2", "plasma", "co2", "n2o", "n2", "freon")
	//calculating gas related values
	combined_gas = max(removed.total_moles(), 0)

	plasmacomp = max(removed.gases["plasma"][MOLES]/combined_gas, 0)
	o2comp = max(removed.gases["o2"][MOLES]/combined_gas, 0)
	co2comp = max(removed.gases["co2"][MOLES]/combined_gas, 0)

	n2ocomp = max(removed.gases["n2o"][MOLES]/combined_gas, 0)
	n2comp = max(removed.gases["n2"][MOLES]/combined_gas, 0)
	freoncomp = max(removed.gases["freon"][MOLES]/combined_gas, 0)

	gasmix_power_ratio = min(max(plasmacomp + o2comp + co2comp - n2comp - freoncomp, 0), 1)

	dynamic_heat_modifier = max((plasmacomp * PLASMA_HEAT_PENALTY)+(o2comp * OXYGEN_HEAT_PENALTY)+(co2comp * CO2_HEAT_PENALTY)+(n2comp * NITROGEN_HEAT_MODIFIER), 0.5)
	dynamic_heat_resistance = max(n2ocomp * N2O_HEAT_RESISTANCE, 1)

	power_transmission_bonus = max((plasmacomp * PLASMA_TRANSMIT_MODIFIER) + (o2comp * OXYGEN_TRANSMIT_MODIFIER), 0)

	freon_transmit_modifier = max(1-(freoncomp * FREON_TRANSMIT_PENALTY), 0)

	//more moles of gases are harder to heat than fewer, so let's scale heat damage around them
	mole_heat_penalty = max(combined_gas / MOLE_HEAT_PENALTY, 0.25)

	if (combined_gas > POWERLOSS_INHIBITION_MOLE_THRESHOLD && co2comp > POWERLOSS_INHIBITION_GAS_THRESHOLD)
		powerloss_dynamic_scaling = Clamp(powerloss_dynamic_scaling + Clamp(co2comp - powerloss_dynamic_scaling, -0.02, 0.02), 0, 1)
	else
		powerloss_dynamic_scaling = Clamp(powerloss_dynamic_scaling - 0.05,0, 1)
	powerloss_inhibitor = Clamp(1-(powerloss_dynamic_scaling * Clamp(combined_gas/POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD,1 ,1.5)),0 ,1)

	if(matter_power)
		var/removed_matter = max(matter_power/MATTER_POWER_CONVERSION, 40)
		power = max(power + removed_matter, 0)
		matter_power = max(matter_power - removed_matter, 0)

	var/temp_factor = 50

	if(gasmix_power_ratio > 0.8)
		// with a perfect gas mix, make the power less based on heat
		icon_state = "[base_icon_state]_glow"
	else
		// in normal mode, base the produced energy around the heat
		temp_factor = 30
		icon_state = base_icon_state

	power = max( (removed.temperature * temp_factor / T0C) * gasmix_power_ratio + power, 0) //Total laser power plus an overload

	//We've generated power, now let's transfer it to the collectors for storing/usage
	transfer_energy()

	var/device_energy = power * REACTION_POWER_MODIFIER

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.
	removed.temperature += ((device_energy * dynamic_heat_modifier) / THERMAL_RELEASE_MODIFIER)

	removed.temperature = max(0, min(removed.temperature, 2500 * dynamic_heat_modifier))

	//Calculate how much gas to release
	removed.gases["plasma"][MOLES] += max((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER, 0)

	removed.gases["o2"][MOLES] += max(((device_energy + removed.temperature * dynamic_heat_modifier) - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

	if(combined_gas < 50)
		removed.gases["freon"][MOLES] = max((removed.gases["freon"][MOLES] + device_energy) * freoncomp / FREON_BREEDING_MODIFIER, 0)

	if(produces_gas)
		env.merge(removed)
		air_update_turf()

	for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_RANGE(power))) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			var/D = sqrt(1 / max(1, get_dist(l, src)))
			l.hallucination += power * config_hallucination_power * D
			l.hallucination = Clamp(0, 200, l.hallucination)

	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))
		var/rads = (power / 10) * sqrt( 1 / max(get_dist(l, src),1) )
		l.rad_act(rads)

	if(power > POWER_PENALTY_THRESHOLD || damage > damage_penalty_point)

		if(power > POWER_PENALTY_THRESHOLD)
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
			supermatter_zap(src, 5, min(power*2, 20000))
			supermatter_zap(src, 5, min(power*2, 20000))
			if(power > SEVERE_POWER_PENALTY_THRESHOLD)
				supermatter_zap(src, 5, min(power*2, 20000))
				if(power > CRITICAL_POWER_PENALTY_THRESHOLD)
					supermatter_zap(src, 5, min(power*2, 20000))
		else if (damage > damage_penalty_point && prob(20))
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
			supermatter_zap(src, 5, Clamp(power*2, 4000, 20000))

		if(prob(15) && power > POWER_PENALTY_THRESHOLD)
			supermatter_pull(src, power/750)
		if(prob(5))
			supermatter_anomaly_gen(src, FLUX_ANOMALY, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
			supermatter_anomaly_gen(src, GRAVITATIONAL_ANOMALY, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(2) || prob(0.3) && power > POWER_PENALTY_THRESHOLD)
			supermatter_anomaly_gen(src, PYRO_ANOMALY, rand(5, 10))



	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_DELAY)
			var/stability = num2text(round((damage / explosion_point) * 100))

			if(damage > emergency_point)
				radio.talk_into(src, "[emergency_alert] Instability: [stability]%", common_channel, get_spans(), get_default_language())
				lastwarning = REALTIMEOFDAY
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", INVESTIGATE_SUPERMATTER)
					message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
					has_reached_emergency = 1
			else if(damage >= damage_archived) // The damage is still going up
				radio.talk_into(src, "[warning_alert] Instability: [stability]%", engineering_channel, get_spans(), get_default_language())
				lastwarning = REALTIMEOFDAY - (WARNING_DELAY * 5)

			else                                                 // Phew, we're safe
				radio.talk_into(src, "[safe_alert] Instability: [stability]%", engineering_channel, get_spans(), get_default_language())
				lastwarning = REALTIMEOFDAY

			if(power > POWER_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Hyperstructure has reached dangerous power level.", engineering_channel, get_spans(), get_default_language())
				if(powerloss_inhibitor < 0.5)
					radio.talk_into(src, "DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.", engineering_channel, get_spans(), get_default_language())

			if(combined_gas > MOLE_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Critical coolant mass reached.", engineering_channel, get_spans(), get_default_language())

		if(damage > explosion_point)
			for(var/mob in GLOB.living_mob_list)
				var/mob/living/L = mob
				if(istype(L) && L.z == z)
					if(ishuman(mob))
						//Hilariously enough, running into a closet should make you get hit the hardest.
						var/mob/living/carbon/human/H = mob
						H.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)) ) )
					var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(L, src) + 1) )
					L.rad_act(rads)

			explode()


	power -= ((power/500)**3) * powerloss_inhibitor

	return 1

/obj/machinery/power/supermatter_shard/bullet_act(obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L) || isspaceturf(L))		// We don't run process() when we are in space
		return FALSE	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.
	if(!istype(Proj.firer, /obj/machinery/power/emitter))
		investigate_log("has been hit by [Proj] fired by [Proj.firer]", INVESTIGATE_SUPERMATTER)
	if(Proj.flag != "bullet")
		power += Proj.damage * config_bullet_energy
		if(!has_been_powered)
			investigate_log("has been powered for the first time.", INVESTIGATE_SUPERMATTER)
			message_admins("[src] has been powered for the first time [ADMIN_JMP(src)].")
			has_been_powered = TRUE
	else if(takes_damage)
		damage += Proj.damage * config_bullet_energy
	return FALSE

/obj/machinery/power/supermatter_shard/singularity_act()
	var/gain = 100
	investigate_log("Supermatter shard consumed by singularity.", INVESTIGATE_SINGULO)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message("<span class='userdanger'>[src] is consumed by the singularity!</span>")
	for(var/mob/M in GLOB.mob_list)
		if(M.z == z)
			M << 'sound/effects/supermatter.ogg' //everyone goan know bout this
			to_chat(M, "<span class='boldannounce'>A horrible screeching fills your ears, and a wave of dread washes over you...</span>")
	qdel(src)
	return gain

/obj/machinery/power/supermatter_shard/blob_act(obj/structure/blob/B)
	if(B && !isspaceturf(loc)) //does nothing in space
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)
		damage += B.obj_integrity * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us
		if(B.obj_integrity > 100)
			B.visible_message("<span class='danger'>\The [B] strikes at \the [src] and flinches away!</span>",\
			"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
			B.take_damage(100, BURN)
		else
			B.visible_message("<span class='danger'>\The [B] strikes at \the [src] and rapidly flashes to ash.</span>",\
			"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
			Consume(B)

/obj/machinery/power/supermatter_shard/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		to_chat(C, "<span class='userdanger'>That was a really dumb idea.</span>")
		var/obj/item/bodypart/head/rip_u = C.get_bodypart("head")
		rip_u.dismember(BURN) //nice try jedi

/obj/machinery/power/supermatter_shard/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/power/supermatter_shard/attack_robot(mob/user)
	if(Adjacent(user))
		return attack_hand(user)
	else
		return

/obj/machinery/power/supermatter_shard/attack_ai(mob/user)
	return

/obj/machinery/power/supermatter_shard/attack_hand(mob/living/user)
	if(!istype(user))
		return
	user.visible_message("<span class='danger'>\The [user] reaches out and touches \the [src], inducing a resonance... [user.p_their()] body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class='userdanger'>You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	investigate_log("has been attacked (hand) by [user]", INVESTIGATE_SUPERMATTER)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(user)

/obj/machinery/power/supermatter_shard/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in GLOB.rad_collectors)
		if(R.z == z && get_dist(R, src) <= 15) //Better than using orange() every process
			R.receive_pulse(power * (1 + power_transmission_bonus)/10 * freon_transmit_modifier)

/obj/machinery/power/supermatter_shard/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.flags & ABSTRACT) || !istype(user))
		return
	if(istype(W, /obj/item/weapon/scalpel/supermatter))
		playsound(src, W.usesound, 100, 1)
		to_chat(user, "<span class='notice'>You carefully begin to scrape \the [src] with \the [W]...</span>")
		if(do_after(user, 60 * W.toolspeed, TRUE, src))
			to_chat(user, "<span class='notice'>You extract a sliver from \the [src]. \The [src] begins to react violently!</span>")
			new /obj/item/nuke_core/supermatter_sliver(user.loc)
			matter_power += 200
	else if(user.dropItemToGround(W))
		user.visible_message("<span class='danger'>As [user] touches \the [src] with \a [W], silence fills the room...</span>",\
			"<span class='userdanger'>You touch \the [src] with \the [W], and everything suddenly goes silent.</span>\n<span class='notice'>\The [W] flashes into dust as you flinch away from \the [src].</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")
		investigate_log("has been attacked ([W]) by [user]", INVESTIGATE_SUPERMATTER)
		Consume(W)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

		radiation_pulse(get_turf(src), 1, 1, 150, 1)


/obj/machinery/power/supermatter_shard/Bumped(atom/AM)
	if(isliving(AM))
		AM.visible_message("<span class='danger'>\The [AM] slams into \the [src] inducing a resonance... [AM.p_their()] body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class='userdanger'>You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(isobj(AM) && !istype(AM, /obj/effect))
		AM.visible_message("<span class='danger'>\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>", null,\
		"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(AM)

/obj/machinery/power/supermatter_shard/proc/Consume(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", INVESTIGATE_SUPERMATTER)
		user.dust()
		matter_power += 200
	else if(istype(AM, /obj/singularity))
		return
	else if(isobj(AM) && !istype(AM, /obj/effect))
		investigate_log("has consumed [AM].", INVESTIGATE_SUPERMATTER)
		qdel(AM)

	matter_power += 200

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(get_turf(src), 4, 10, 500, 1)
	for(var/mob/living/L in range(10))
		investigate_log("has irradiated [L] after consuming [AM].", INVESTIGATE_SUPERMATTER)
		if(L in view())
			L.show_message("<span class='danger'>As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class='danger'>The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			L.show_message("<span class='italics'>You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)

// When you wanna make a supermatter shard for the dramatic effect, but
// don't want it exploding suddenly
/obj/machinery/power/supermatter_shard/hugbox
	takes_damage = FALSE
	produces_gas = FALSE

/obj/machinery/power/supermatter_shard/crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	base_icon_state = "darkmatter"
	icon_state = "darkmatter"
	anchored = TRUE
	gasefficency = 0.15
	explosion_power = 35

/obj/machinery/power/supermatter_shard/proc/supermatter_pull(turf/center, pull_range = 10)
	playsound(src.loc, 'sound/weapons/marauder.ogg', 100, 1, extrarange = 7)
	for(var/atom/P in orange(pull_range,center))
		if(ismovableatom(P))
			var/atom/movable/pulled_object = P
			if(ishuman(P))
				var/mob/living/carbon/human/H = P
				H.apply_effect(40, KNOCKDOWN, 0)
			if(pulled_object && !pulled_object.anchored && !ishuman(P))
				step_towards(pulled_object,center)
				step_towards(pulled_object,center)
				step_towards(pulled_object,center)
				step_towards(pulled_object,center)

/obj/machinery/power/supermatter_shard/proc/supermatter_anomaly_gen(turf/anomalycenter, type = FLUX_ANOMALY, anomalyrange = 5)
	var/turf/L = pick(orange(anomalyrange, anomalycenter))
	if(L)
		switch(type)
			if(FLUX_ANOMALY)
				var/obj/effect/anomaly/flux/A = new(L, 300)
				A.explosive = FALSE
			if(GRAVITATIONAL_ANOMALY)
				new /obj/effect/anomaly/grav(L, 250)
			if(PYRO_ANOMALY)
				new /obj/effect/anomaly/pyro(L, 200)

/obj/machinery/power/supermatter_shard/proc/supermatter_zap(atom/zapstart, range = 3, power)
	. = zapstart.dir
	if(power < 1000)
		return

	var/target_atom
	var/mob/living/target_mob
	var/obj/machinery/target_machine
	var/obj/structure/target_structure
	var/list/arctargetsmob = list()
	var/list/arctargetsmachine = list()
	var/list/arctargetsstructure = list()

	if(prob(20)) //let's not hit all the engineers with every beam and/or segment of the arc
		for(var/mob/living/Z in oview(zapstart, range+2))
			arctargetsmob += Z
	if(arctargetsmob.len)
		var/mob/living/H = pick(arctargetsmob)
		var/atom/A = H
		target_mob = H
		target_atom = A

	else
		for(var/obj/machinery/X in oview(zapstart, range+2))
			arctargetsmachine += X
		if(arctargetsmachine.len)
			var/obj/machinery/M = pick(arctargetsmachine)
			var/atom/A = M
			target_machine = M
			target_atom = A

		else
			for(var/obj/structure/Y in oview(zapstart, range+2))
				arctargetsstructure += Y
			if(arctargetsstructure.len)
				var/obj/structure/O = pick(arctargetsstructure)
				var/atom/A = O
				target_structure = O
				target_atom = A

	if(target_atom)
		zapstart.Beam(target_atom, icon_state="nzcrentrs_power", time=5)
		var/zapdir = get_dir(zapstart, target_atom)
		if(zapdir)
			. = zapdir

	if(target_mob)
		target_mob.electrocute_act(rand(5,10), "Supermatter Discharge Bolt", 1, stun = 0)
		if(prob(15))
			supermatter_zap(target_mob, 5, power / 2)
			supermatter_zap(target_mob, 5, power / 2)
		else
			supermatter_zap(target_mob, 5, power / 1.5)

	else if(target_machine)
		if(prob(15))
			supermatter_zap(target_machine, 5, power / 2)
			supermatter_zap(target_machine, 5, power / 2)
		else
			supermatter_zap(target_machine, 5, power / 1.5)

	else if(target_structure)
		if(prob(15))
			supermatter_zap(target_structure, 5, power / 2)
			supermatter_zap(target_structure, 5, power / 2)
		else
			supermatter_zap(target_structure, 5, power / 1.5)

#undef HALLUCINATION_RANGE
#undef GRAVITATIONAL_ANOMALY
#undef FLUX_ANOMALY
#undef PYRO_ANOMALY
