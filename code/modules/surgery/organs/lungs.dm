#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS (SSmobs.wait/30)
#define HEAT_GAS_DAMAGE_LEVEL_1 2
#define HEAT_GAS_DAMAGE_LEVEL_2 4
#define HEAT_GAS_DAMAGE_LEVEL_3 8

#define COLD_GAS_DAMAGE_LEVEL_1 0.5
#define COLD_GAS_DAMAGE_LEVEL_2 1.5
#define COLD_GAS_DAMAGE_LEVEL_3 3

/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	zone = "chest"
	slot = "lungs"
	gender = PLURAL
	w_class = WEIGHT_CLASS_NORMAL
	var/list/breathlevels = list("safe_oxygen_min" = 16,"safe_oxygen_max" = 0,"safe_co2_min" = 0,"safe_co2_max" = 10,
	"safe_toxins_min" = 0,"safe_toxins_max" = 0.05,"SA_para_min" = 1,"SA_sleep_min" = 5,"BZ_trip_balls_min" = 1)

	//Breath damage

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = 0.05
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas.

	var/oxy_breath_dam_min = 1
	var/oxy_breath_dam_max = 10
	var/co2_breath_dam_min = 1
	var/co2_breath_dam_max = 10
	var/tox_breath_dam_min = MIN_PLASMA_DAMAGE
	var/tox_breath_dam_max = MAX_PLASMA_DAMAGE



/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	if((H.status_flags & GODMODE))
		return

	var/species_traits = list()
	if(H && H.dna && H.dna.species && H.dna.species.species_traits)
		species_traits = H.dna.species.species_traits

	if(!breath || (breath.total_moles() == 0))
		if(H.reagents.has_reagent("epinephrine"))
			return
		if(H.health >= HEALTH_THRESHOLD_CRIT)
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!(NOCRITDAMAGE in species_traits))
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		H.failed_last_breath = 1
		if(safe_oxygen_min)
			H.throw_alert("oxy", /obj/screen/alert/oxy)
		else if(safe_toxins_min)
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		return 0

	var/gas_breathed = 0

	var/list/breath_gases = breath.gases

	breath.assert_gases("o2", "plasma", "co2", "n2o", "bz")

	//Partial pressures in our breath
	var/O2_pp = breath.get_breath_partial_pressure(breath_gases["o2"][MOLES])
	var/Toxins_pp = breath.get_breath_partial_pressure(breath_gases["plasma"][MOLES])
	var/CO2_pp = breath.get_breath_partial_pressure(breath_gases["co2"][MOLES])


	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if(O2_pp > safe_oxygen_max)
			var/ratio = (breath_gases["o2"][MOLES]/safe_oxygen_max) * 10
			H.adjustOxyLoss(Clamp(ratio,oxy_breath_dam_min,oxy_breath_dam_max))
			H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
		else
			H.clear_alert("too_much_oxy")

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			gas_breathed = handle_too_little_breath(H,O2_pp,safe_oxygen_min,breath_gases["o2"][MOLES])
			H.throw_alert("oxy", /obj/screen/alert/oxy)
		else
			H.failed_last_breath = 0
			if(H.getOxyLoss())
				H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["o2"][MOLES]
			H.clear_alert("oxy")

	//Exhale
	breath_gases["o2"][MOLES] -= gas_breathed
	breath_gases["co2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max)
			if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				H.co2overloadtime = world.time
			else if(world.time - H.co2overloadtime > 120)
				H.Unconscious(60)
				H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
				if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					H.adjustOxyLoss(8)
				H.throw_alert("too_much_co2", /obj/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				H.emote("cough")

		else
			H.co2overloadtime = 0
			H.clear_alert("too_much_co2")

	//Too little CO2!
	if(breathlevels["safe_co2_min"])
		if(CO2_pp < safe_co2_min)
			gas_breathed = handle_too_little_breath(H,CO2_pp, safe_co2_min,breath_gases["co2"][MOLES])
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["co2"][MOLES]
			H.clear_alert("not_enough_co2")

	//Exhale
	breath_gases["co2"][MOLES] -= gas_breathed
	breath_gases["o2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max)
			var/ratio = (breath_gases["plasma"][MOLES]/safe_toxins_max) * 10
			if(H.reagents)
				H.reagents.add_reagent("plasma", Clamp(ratio, tox_breath_dam_min, tox_breath_dam_max))
			H.throw_alert("tox_in_air", /obj/screen/alert/tox_in_air)
		else
			H.clear_alert("tox_in_air")


	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min)
			gas_breathed = handle_too_little_breath(H,Toxins_pp, safe_toxins_min, breath_gases["plasma"][MOLES])
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["plasma"][MOLES]
			H.clear_alert("not_enough_tox")

	//Exhale
	breath_gases["plasma"][MOLES] -= gas_breathed
	breath_gases["co2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TRACES --//

	if(breath)	// If there's some other shit in the air lets deal with it here.

	// N2O

		var/SA_pp = breath.get_breath_partial_pressure(breath_gases["n2o"][MOLES])
		if(SA_pp > SA_para_min) // Enough to make us stunned for a bit
			H.Unconscious(60) // 60 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.AmountSleeping() + 40, 200))
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))

	// BZ

		var/bz_pp = breath.get_breath_partial_pressure(breath_gases["bz"][MOLES])
		if(bz_pp > BZ_trip_balls_min)
			H.hallucination += 20
			if(prob(33))
				H.adjustBrainLoss(3)
		else if(bz_pp > 0.01)
			H.hallucination += 5//Removed at 2 per tick so this will slowly build up
		handle_breath_temperature(breath, H)
		breath.garbage_collect()

	return 1


/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null,breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return 0

	if(prob(20))
		H.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		H.failed_last_breath = 1
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = 1


/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	if(abs(310.15 - breath.temperature) > 50)

		var/species_traits = list()
		if(H && H.dna && H.dna.species && H.dna.species.species_traits)
			species_traits = H.dna.species.species_traits

		if(!(GLOB.mutations_list[COLDRES] in H.dna.mutations) && !(RESISTCOLD in species_traits)) // COLD DAMAGE
			switch(breath.temperature)
				if(-INFINITY to 120)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head")
				if(120 to 200)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head")
				if(200 to 260)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head")

		if(!(RESISTHOT in species_traits)) // HEAT DAMAGE
			switch(breath.temperature)
				if(360 to 400)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head")
				if(400 to 1000)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head")
				if(1000 to INFINITY)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head")

/obj/item/organ/lungs/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("salbutamol", 5)
	return S

/obj/item/organ/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"

	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0

#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS
#undef HEAT_GAS_DAMAGE_LEVEL_1
#undef HEAT_GAS_DAMAGE_LEVEL_2
#undef HEAT_GAS_DAMAGE_LEVEL_3

#undef COLD_GAS_DAMAGE_LEVEL_1
#undef COLD_GAS_DAMAGE_LEVEL_2
#undef COLD_GAS_DAMAGE_LEVEL_3
