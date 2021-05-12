/obj/item/organ/lungs
	var/failed = FALSE
	var/operated = FALSE //whether we can still have our damages fixed through surgery
	name = "lungs"
	icon_state = "lungs"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 0.9 // fails around 16.5 minutes, lungs are one of the last organs to die (of the ones we have)

	low_threshold_passed = "<span class='warning'>You feel short of breath.</span>"
	high_threshold_passed = "<span class='warning'>You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.</span>"
	now_fixed = "<span class='warning'>Your lungs seem to once again be able to hold air.</span>"
	low_threshold_cleared = "<span class='info'>You can breathe normally again.</span>"
	high_threshold_cleared = "<span class='info'>The constriction around your chest loosens as your breathing calms down.</span>"


	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)

	//Breath damage
	//These thresholds are checked against what amounts to total_mix_pressure * (gas_type_mols/total_mols)

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	///How much breath partial pressure is a safe amount of toxins. 0 means that we are immune to toxins.
	var/safe_toxins_max = 0.05
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas
	var/BZ_brain_damage_min = 10 //Give people some room to play around without killing the station
	var/gas_stimulation_min = 0.002 //Nitryl, Stimulum and Freon
	///Minimum amount of healium to make you unconscious for 4 seconds
	var/healium_para_min = 3
	///Minimum amount of healium to knock you down for good
	var/healium_sleep_min = 6

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

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine

/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/human)
	if(human.status_flags & GODMODE)
		human.failed_last_breath = FALSE //clear oxy issues
		human.clear_alert("not_enough_oxy")
		return
	if(HAS_TRAIT(human, TRAIT_NOBREATH))
		return

	if(!breath || (breath.total_moles() == 0))
		if(human.reagents.has_reagent(crit_stabilizing_reagent, needs_metabolizing = TRUE))
			return
		if(human.health >= human.crit_threshold)
			human.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!HAS_TRAIT(human, TRAIT_NOCRITDAMAGE))
			human.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		human.failed_last_breath = TRUE
		if(safe_oxygen_min)
			human.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
		else if(safe_toxins_min)
			human.throw_alert("not_enough_tox", /atom/movable/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			human.throw_alert("not_enough_co2", /atom/movable/screen/alert/not_enough_co2)
		else if(safe_nitro_min)
			human.throw_alert("not_enough_nitro", /atom/movable/screen/alert/not_enough_nitro)
		return FALSE

	var/gas_breathed = 0

	var/list/breath_gases = breath.gases

	breath.assert_gases(/datum/gas/oxygen,
						/datum/gas/plasma,
						/datum/gas/carbon_dioxide,
						/datum/gas/nitrous_oxide,
						/datum/gas/bz,
						/datum/gas/nitrogen,
						/datum/gas/tritium,
						/datum/gas/nitryl,
						/datum/gas/pluoxium,
						/datum/gas/stimulum,
						/datum/gas/freon,
						/datum/gas/hypernoblium,
						/datum/gas/healium,
						/datum/gas/proto_nitrate,
						/datum/gas/zauker,
						/datum/gas/halon
						)

	//Partial pressures in our breath
	var/O2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES])+(8*breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium][MOLES]))
	var/N2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
	var/Toxins_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
	var/CO2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
	//Vars for n2o and healium induced euphorias.
	var/n2o_euphoria = EUPHORIA_LAST_FLAG
	var/healium_euphoria = EUPHORIA_LAST_FLAG
	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if(O2_pp > safe_oxygen_max)
			var/ratio = (breath_gases[/datum/gas/oxygen][MOLES]/safe_oxygen_max) * 10
			human.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
			human.throw_alert("too_much_oxy", /atom/movable/screen/alert/too_much_oxy)
		else
			human.clear_alert("too_much_oxy")

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			gas_breathed = handle_too_little_breath(human, O2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen][MOLES])
			human.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
		else
			human.failed_last_breath = FALSE
			if(human.health >= human.crit_threshold)
				human.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/oxygen][MOLES]
			human.clear_alert("not_enough_oxy")

	//Exhale
	breath_gases[/datum/gas/oxygen][MOLES] -= gas_breathed
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += gas_breathed
	gas_breathed = 0

	//-- Nitrogen --//

	//Too much nitrogen!
	if(safe_nitro_max)
		if(N2_pp > safe_nitro_max)
			var/ratio = (breath_gases[/datum/gas/nitrogen][MOLES]/safe_nitro_max) * 10
			human.apply_damage_type(clamp(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type)
			human.throw_alert("too_much_nitro", /atom/movable/screen/alert/too_much_nitro)
		else
			human.clear_alert("too_much_nitro")

	//Too little nitrogen!
	if(safe_nitro_min)
		if(N2_pp < safe_nitro_min)
			gas_breathed = handle_too_little_breath(human, N2_pp, safe_nitro_min, breath_gases[/datum/gas/nitrogen][MOLES])
			human.throw_alert("nitro", /atom/movable/screen/alert/not_enough_nitro)
		else
			human.failed_last_breath = FALSE
			if(human.health >= human.crit_threshold)
				human.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/nitrogen][MOLES]
			human.clear_alert("nitro")

	//Exhale
	breath_gases[/datum/gas/nitrogen][MOLES] -= gas_breathed
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += gas_breathed
	gas_breathed = 0

	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max)
			if(!human.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				human.co2overloadtime = world.time
			else if(world.time - human.co2overloadtime > 120)
				human.Unconscious(60)
				human.apply_damage_type(3, co2_damage_type) // Lets hurt em a little, let them know we mean business
				if(world.time - human.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					human.apply_damage_type(8, co2_damage_type)
				human.throw_alert("too_much_co2", /atom/movable/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				human.emote("cough")

		else
			human.co2overloadtime = 0
			human.clear_alert("too_much_co2")

	//Too little CO2!
	if(safe_co2_min)
		if(CO2_pp < safe_co2_min)
			gas_breathed = handle_too_little_breath(human, CO2_pp, safe_co2_min, breath_gases[/datum/gas/carbon_dioxide][MOLES])
			human.throw_alert("not_enough_co2", /atom/movable/screen/alert/not_enough_co2)
		else
			human.failed_last_breath = FALSE
			if(human.health >= human.crit_threshold)
				human.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/carbon_dioxide][MOLES]
			human.clear_alert("not_enough_co2")

	//Exhale
	breath_gases[/datum/gas/carbon_dioxide][MOLES] -= gas_breathed
	breath_gases[/datum/gas/oxygen][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max)
			var/ratio = (breath_gases[/datum/gas/plasma][MOLES]/safe_toxins_max) * 10
			human.apply_damage_type(clamp(ratio, tox_breath_dam_min, tox_breath_dam_max), tox_damage_type)
			human.throw_alert("too_much_tox", /atom/movable/screen/alert/too_much_tox)
		else
			human.clear_alert("too_much_tox")


	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min)
			gas_breathed = handle_too_little_breath(human, Toxins_pp, safe_toxins_min, breath_gases[/datum/gas/plasma][MOLES])
			human.throw_alert("not_enough_tox", /atom/movable/screen/alert/not_enough_tox)
		else
			human.failed_last_breath = FALSE
			if(human.health >= human.crit_threshold)
				human.adjustOxyLoss(-5)
			gas_breathed = breath_gases[/datum/gas/plasma][MOLES]
			human.clear_alert("not_enough_tox")

	//Exhale
	breath_gases[/datum/gas/plasma][MOLES] -= gas_breathed
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TRACES --//

	if(breath) // If there's some other shit in the air lets deal with it here.

	// N2O

		var/SA_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide][MOLES])
		if(SA_pp > SA_para_min) // Enough to make us stunned for a bit
			human.throw_alert("too_much_n2o", /atom/movable/screen/alert/too_much_n2o)
			human.Unconscious(60) // 60 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				human.Sleeping(min(human.AmountSleeping() + 100, 200))
		else if(SA_pp > 0.01) // There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			human.clear_alert("too_much_n2o")
			if(prob(20))
				n2o_euphoria = EUPHORIA_ACTIVE
				human.emote(pick("giggle", "laugh"))
		else
			n2o_euphoria = EUPHORIA_INACTIVE
			human.clear_alert("too_much_n2o")


	// BZ

		var/bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
		if(bz_pp > BZ_trip_balls_min)
			human.hallucination += 10
			human.reagents.add_reagent(/datum/reagent/bz_metabolites,5)
		if(bz_pp > BZ_brain_damage_min && prob(33))
			human.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)

	// Tritium
		var/trit_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/tritium][MOLES])
		if (trit_pp > 50)
			human.radiation += trit_pp/2 //If you're breathing in half an atmosphere of radioactive gas, you fucked up.
		else
			human.radiation += trit_pp/10

	// Nitryl
		var/nitryl_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitryl][MOLES])
		if (prob(nitryl_pp))
			human.emote("burp")
		if (prob(nitryl_pp) && nitryl_pp>10)
			human.adjustOrganLoss(ORGAN_SLOT_LUNGS, nitryl_pp/2)
			to_chat(human, "<span class='notice'>You feel a burning sensation in your chest</span>")
		gas_breathed = breath_gases[/datum/gas/nitryl][MOLES]
		if (gas_breathed > gas_stimulation_min)
			human.reagents.add_reagent(/datum/reagent/nitryl,1)

		breath_gases[/datum/gas/nitryl][MOLES]-=gas_breathed

	// Freon
		var/freon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/freon][MOLES])
		if (prob(freon_pp))
			to_chat(human, "<span class='alert'>Your mouth feels like it's burning!</span>")
		if (freon_pp >40)
			human.emote("gasp")
			human.adjustFireLoss(15)
			if (prob(freon_pp/2))
				to_chat(human, "<span class='alert'>Your throat closes up!</span>")
				human.silent = max(human.silent, 3)
		else
			human.adjustFireLoss(freon_pp/4)
		gas_breathed = breath_gases[/datum/gas/freon][MOLES]
		if (gas_breathed > gas_stimulation_min)
			human.reagents.add_reagent(/datum/reagent/freon,1)

		breath_gases[/datum/gas/freon][MOLES]-=gas_breathed

	// Healium
		var/healium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/healium][MOLES])
		if(healium_pp > gas_stimulation_min)
			if(prob(15))
				to_chat(human, "<span class='alert'>Your head starts spinning and your lungs burn!</span>")
				healium_euphoria = EUPHORIA_ACTIVE
				human.emote("gasp")
		else
			healium_euphoria = EUPHORIA_INACTIVE

		if(healium_pp > healium_para_min)
			human.Unconscious(rand(30, 50))//not in seconds to have a much higher variation
			if(healium_pp > healium_sleep_min)
				var/existing = human.reagents.get_reagent_amount(/datum/reagent/healium)
				human.reagents.add_reagent(/datum/reagent/healium,max(0, 1 - existing))
		gas_breathed = breath_gases[/datum/gas/healium][MOLES]
		breath_gases[/datum/gas/healium][MOLES]-=gas_breathed

	// Proto Nitrate
		// Inert
	// Zauker
		var/zauker_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/zauker][MOLES])
		if(zauker_pp > gas_stimulation_min)
			human.adjustBruteLoss(25)
			human.adjustOxyLoss(5)
			human.adjustFireLoss(8)
			human.adjustToxLoss(8)
		gas_breathed = breath_gases[/datum/gas/zauker][MOLES]
		breath_gases[/datum/gas/zauker][MOLES]-=gas_breathed

	// Halon
		var/halon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/halon][MOLES])
		if(halon_pp > gas_stimulation_min)
			human.adjustOxyLoss(5)
			var/existing = human.reagents.get_reagent_amount(/datum/reagent/halon)
			human.reagents.add_reagent(/datum/reagent/halon,max(0, 1 - existing))
		gas_breathed = breath_gases[/datum/gas/halon][MOLES]
		breath_gases[/datum/gas/halon][MOLES]-=gas_breathed

	// Stimulum
		gas_breathed = breath_gases[/datum/gas/stimulum][MOLES]
		if (gas_breathed > gas_stimulation_min)
			var/existing = human.reagents.get_reagent_amount(/datum/reagent/stimulum)
			human.reagents.add_reagent(/datum/reagent/stimulum,max(0, 1 - existing))
		breath_gases[/datum/gas/stimulum][MOLES]-=gas_breathed

	// Hyper-Nob
		gas_breathed = breath_gases[/datum/gas/hypernoblium][MOLES]
		if (gas_breathed > gas_stimulation_min)
			var/existing = human.reagents.get_reagent_amount(/datum/reagent/hypernoblium)
			human.reagents.add_reagent(/datum/reagent/hypernoblium,max(0, 1 - existing))
		breath_gases[/datum/gas/hypernoblium][MOLES]-=gas_breathed

	// Miasma
		if (breath_gases[/datum/gas/miasma])
			var/miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])

			//Miasma sickness
			if(prob(0.5 * miasma_pp))
				var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(min(round(max(miasma_pp/2, 1), 1), 6), min(round(max(miasma_pp, 1), 1), 8))
				//tl;dr the first argument chooses the smaller of miasma_pp/2 or 6(typical max virus symptoms), the second chooses the smaller of miasma_pp or 8(max virus symptom level) //
				miasma_disease.name = "Unknown"//^each argument has a minimum of 1 and rounds to the nearest value. Feel free to change the pp scaling I couldn't decide on good numbers for it.
				miasma_disease.try_infect(owner)

			// Miasma side effects
			switch(miasma_pp)
				if(0.25 to 5)
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

		if (n2o_euphoria == EUPHORIA_ACTIVE || healium_euphoria == EUPHORIA_ACTIVE)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
		else if (n2o_euphoria == EUPHORIA_INACTIVE && healium_euphoria == EUPHORIA_INACTIVE)
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")
		// Activate mood on first flag, remove on second, do nothing on third.

		handle_breath_temperature(breath, human)
		breath.garbage_collect()

	return TRUE


/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/human = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!human || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE

	if(prob(20))
		human.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		human.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		human.failed_last_breath = TRUE
		. = true_pp*ratio/6
	else
		human.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		human.failed_last_breath = TRUE


/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/human) // called by human/life, handles temperatures
	var/breath_temperature = breath.temperature

	if(!HAS_TRAIT(human, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = human.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			human.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			human.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			human.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(human, "<span class='warning'>You feel [cold_message] in your [name]!</span>")

	if(!HAS_TRAIT(human, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = human.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			human.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			human.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_3_threshold)
			human.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(human, "<span class='warning'>You feel [hot_message] in your [name]!</span>")

	// The air you breathe out should match your body temperature
	breath.temperature = human.bodytemperature

/obj/item/organ/lungs/on_life(delta_time, times_fired)
	. = ..()
	if(failed && !(organ_flags & ORGAN_FAILING))
		failed = FALSE
		return
	if(damage >= low_threshold)
		var/do_i_cough = DT_PROB((damage < high_threshold) ? 2.5 : 5, delta_time) // between : past high
		if(do_i_cough)
			owner.emote("cough")
	if(organ_flags & ORGAN_FAILING && owner.stat == CONSCIOUS)
		owner.visible_message("<span class='danger'>[owner] grabs [owner.p_their()] throat, struggling for breath!</span>", "<span class='userdanger'>You suddenly feel like you can't breathe!</span>")
		failed = TRUE

/obj/item/organ/lungs/get_availability(datum/species/species)
	return !(TRAIT_NOBREATH in species.inherent_traits)

/obj/item/organ/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"

	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0

/obj/item/organ/lungs/slime
	name = "vacuole"
	desc = "A large organelle designed to store oxygen and other important gasses."

	safe_toxins_max = 0 //We breathe this to gain POWER.

/obj/item/organ/lungs/slime/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/human)
	. = ..()
	if (breath?.gases[/datum/gas/plasma])
		var/plasma_pp = breath.get_breath_partial_pressure(breath.gases[/datum/gas/plasma][MOLES])
		owner.blood_volume += (0.2 * plasma_pp) // 10/s when breathing literally nothing but plasma, which will suffocate you.

/obj/item/organ/lungs/cybernetic
	name = "basic cybernetic lungs"
	desc = "A basic cybernetic version of the lungs found in traditional humanoid entities."
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5

	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/lungs/cybernetic/tier2
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Allows for greater intakes of oxygen than organic lungs, requiring slightly less pressure."
	icon_state = "lungs-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 13
	emp_vulnerability = 40

/obj/item/organ/lungs/cybernetic/tier3
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. Features the ability to filter out lower levels of toxins and carbon dioxide."
	icon_state = "lungs-c-u2"
	safe_toxins_max = 20
	safe_co2_max = 20
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 13
	emp_vulnerability = 20

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100

/obj/item/organ/lungs/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.losebreath += 20
		COOLDOWN_START(src, severe_cooldown, 30 SECONDS)
	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.
