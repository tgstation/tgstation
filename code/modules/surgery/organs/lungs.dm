/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_NORMAL

	//Breath damage

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = 0.05
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas
	var/gas_stimulation_min = 0.002 //Nitryl and Stimulum

	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/tox_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/tox_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/tox_damage_type = TOX

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/crit_stabilizing_reagent = "epinephrine"


/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	if((H.status_flags & GODMODE))
		return
	if(H.has_trait(TRAIT_NOBREATH))
		return

	if(!breath || (breath.total_moles() == 0))
		if(H.reagents.has_reagent(crit_stabilizing_reagent))
			return
		if(H.health >= H.crit_threshold)
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!H.has_trait(TRAIT_NOCRITDAMAGE))
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		H.failed_last_breath = TRUE
		if(safe_oxygen_min)
			H.throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		else if(safe_toxins_min)
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else if(safe_nitro_min)
			H.throw_alert("not_enough_nitro", /obj/screen/alert/not_enough_nitro)
		return FALSE

	var/gas_breathed = 0

	var/list/breath_gases = breath.gases

	breath.assert_gases(/datum/gas/oxygen, /datum/gas/plasma, /datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/bz, /datum/gas/nitrogen, /datum/gas/tritium, /datum/gas/nitryl, /datum/gas/pluoxium, /datum/gas/stimulum)

	//Partial pressures in our breath
	var/O2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES])+(8*breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium][MOLES]))
	var/N2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
	var/Toxins_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
	var/CO2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])


	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if(O2_pp > safe_oxygen_max)
			var/ratio = (breath_gases[/datum/gas/oxygen][MOLES]/safe_oxygen_max) * 10
			H.apply_damage_type(CLAMP(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
			H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
		else
			H.clear_alert("too_much_oxy")

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			gas_breathed = handle_too_little_breath(H, O2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen][MOLES])
			H.throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/oxygen][MOLES]
			H.clear_alert("not_enough_oxy")

	//Exhale
	breath_gases[/datum/gas/oxygen][MOLES] -= gas_breathed
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += gas_breathed
	gas_breathed = 0

	//-- Nitrogen --//

	//Too much nitrogen!
	if(safe_nitro_max)
		if(N2_pp > safe_nitro_max)
			var/ratio = (breath_gases[/datum/gas/nitrogen][MOLES]/safe_nitro_max) * 10
			H.apply_damage_type(CLAMP(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type)
			H.throw_alert("too_much_nitro", /obj/screen/alert/too_much_nitro)
		else
			H.clear_alert("too_much_nitro")

	//Too little nitrogen!
	if(safe_nitro_min)
		if(N2_pp < safe_nitro_min)
			gas_breathed = handle_too_little_breath(H, N2_pp, safe_nitro_min, breath_gases[/datum/gas/nitrogen][MOLES])
			H.throw_alert("nitro", /obj/screen/alert/not_enough_nitro)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/nitrogen][MOLES]
			H.clear_alert("nitro")

	//Exhale
	breath_gases[/datum/gas/nitrogen][MOLES] -= gas_breathed
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += gas_breathed
	gas_breathed = 0

	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max)
			if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				H.co2overloadtime = world.time
			else if(world.time - H.co2overloadtime > 120)
				H.Unconscious(60)
				H.apply_damage_type(3, co2_damage_type) // Lets hurt em a little, let them know we mean business
				if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					H.apply_damage_type(8, co2_damage_type)
				H.throw_alert("too_much_co2", /obj/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				H.emote("cough")

		else
			H.co2overloadtime = 0
			H.clear_alert("too_much_co2")

	//Too little CO2!
	if(safe_co2_min)
		if(CO2_pp < safe_co2_min)
			gas_breathed = handle_too_little_breath(H, CO2_pp, safe_co2_min, breath_gases[/datum/gas/carbon_dioxide][MOLES])
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/carbon_dioxide][MOLES]
			H.clear_alert("not_enough_co2")

	//Exhale
	breath_gases[/datum/gas/carbon_dioxide][MOLES] -= gas_breathed
	breath_gases[/datum/gas/oxygen][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max)
			var/ratio = (breath_gases[/datum/gas/plasma][MOLES]/safe_toxins_max) * 10
			H.apply_damage_type(CLAMP(ratio, tox_breath_dam_min, tox_breath_dam_max), tox_damage_type)
			H.throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
		else
			H.clear_alert("too_much_tox")


	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min)
			gas_breathed = handle_too_little_breath(H, Toxins_pp, safe_toxins_min, breath_gases[/datum/gas/plasma][MOLES])
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/plasma][MOLES]
			H.clear_alert("not_enough_tox")

	//Exhale
	breath_gases[/datum/gas/plasma][MOLES] -= gas_breathed
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TRACES --//

	if(breath)	// If there's some other shit in the air lets deal with it here.

	// N2O

		var/SA_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide][MOLES])
		if(SA_pp > SA_para_min) // Enough to make us stunned for a bit
			H.Unconscious(60) // 60 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.AmountSleeping() + 40, 200))
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))

	// BZ

		var/bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
		if(bz_pp > BZ_trip_balls_min)
			H.hallucination += 10
			H.reagents.add_reagent("bz_metabolites",5)
			if(prob(33))
				H.adjustBrainLoss(3, 150)

		else if(bz_pp > 0.01)
			H.hallucination += 5
			H.reagents.add_reagent("bz_metabolites",1)


	// Tritium
		var/trit_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/tritium][MOLES])
		if (trit_pp > 50)
			H.radiation += trit_pp/2 //If you're breathing in half an atmosphere of radioactive gas, you fucked up.
		else
			H.radiation += trit_pp/10

	// Nitryl
		var/nitryl_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitryl][MOLES])
		if (prob(nitryl_pp))
			to_chat(H, "<span class='alert'>Your mouth feels like it's burning!</span>")
		if (nitryl_pp >40)
			H.emote("gasp")
			H.adjustFireLoss(10)
			if (prob(nitryl_pp/2))
				to_chat(H, "<span class='alert'>Your throat closes up!</span>")
				H.silent = max(H.silent, 3)
		else
			H.adjustFireLoss(nitryl_pp/4)
		gas_breathed = breath_gases[/datum/gas/nitryl][MOLES]
		if (gas_breathed > gas_stimulation_min)
			H.reagents.add_reagent("no2",1)

		breath_gases[/datum/gas/nitryl][MOLES]-=gas_breathed

	// Stimulum
		gas_breathed = breath_gases[/datum/gas/stimulum][MOLES]
		if (gas_breathed > gas_stimulation_min)
			var/existing = H.reagents.get_reagent_amount("stimulum")
			H.reagents.add_reagent("stimulum",max(0, 1 - existing))
		breath_gases[/datum/gas/stimulum][MOLES]-=gas_breathed

	// Miasma
		if (breath_gases[/datum/gas/miasma])
			var/miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])

			//Miasma sickness
			if(prob(0.5 * miasma_pp))
				var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2,3)
				miasma_disease.name = "Unknown"
				miasma_disease.try_infect(owner)

			// Miasma side effects
			switch(miasma_pp)
				if(1 to 5)
					// At lower pp, give out a little warning
					SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")
					if(prob(5))
						to_chat(owner, "<span class='notice'>There is an unpleasant smell in the air.</span>")
				if(5 to 15)
					//At somewhat higher pp, warning becomes more obvious
					if(prob(15))
						to_chat(owner, "<span class='warning'>You smell something horribly decayed inside this room.</span>")
						SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
				if(15 to 30)
					//Small chance to vomit. By now, people have internals on anyway
					if(prob(5))
						to_chat(owner, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
						SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
						owner.vomit()
				if(30 to INFINITY)
					//Higher chance to vomit. Let the horror start
					if(prob(15))
						to_chat(owner, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
						SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
						owner.vomit()
				else
					SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

			// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
			// Then again, this is a purely hypothetical scenario and hardly reachable
			owner.adjust_disgust(0.1 * miasma_pp)

			breath_gases[/datum/gas/miasma][MOLES]-=gas_breathed

		// Clear out moods when no miasma at all
		else
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

		handle_breath_temperature(breath, H)
		breath.garbage_collect()
	return TRUE


/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE

	if(prob(20))
		H.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		H.failed_last_breath = TRUE
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = TRUE


/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.temperature

	if(!H.has_trait(TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = H.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			H.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			H.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			H.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [cold_message] in your [name]!</span>")

	if(!H.has_trait(TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = H.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			H.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			H.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_3_threshold)
			H.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [hot_message] in your [name]!</span>")

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

/obj/item/organ/lungs/cybernetic
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Allows for greater intakes of oxygen than organic lungs, requiring slightly less pressure."
	icon_state = "lungs-c"
	synthetic = TRUE
	safe_oxygen_min = 13

/obj/item/organ/lungs/cybernetic/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	owner.losebreath = 20


/obj/item/organ/lungs/cybernetic/upgraded
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. Features the ability to filter out lower levels of toxins and carbon dioxide."
	icon_state = "lungs-c-u"
	safe_toxins_max = 20
	safe_co2_max = 20

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100
