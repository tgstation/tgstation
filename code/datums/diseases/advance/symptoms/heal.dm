/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	desc = "You should not be seeing this."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 0 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/passive_message = "" //random message to infected but not actively healing people
	threshold_desc = "<b>Stage Speed 6:</b> Doubles healing speed.<br>\
					  <b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/heal/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 6) //stronger healing
		power = 2

/datum/symptom/heal/Activate(datum/disease/advance/A)
	if(!..())
		return
	 //100% chance to activate for slow but consistent healing
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/effectiveness = CanHeal(A)
			if(!effectiveness)
				if(passive_message && prob(2) && passive_message_condition(M))
					to_chat(M, passive_message)
				return
			else
				Heal(M, A, effectiveness)
	return

/datum/symptom/heal/proc/CanHeal(datum/disease/advance/A)
	return power

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	return TRUE

/datum/symptom/heal/proc/passive_message_condition(mob/living/M)
	return TRUE


/datum/symptom/heal/toxin
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals that can cure toxin damage."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -3
	level = 6
	passive_message = "<span class='notice'>You miss the feeling of starlight on your skin.</span>"
	var/nearspace_penalty = 0.3
	threshold_desc = "<b>Stage Speed 6:</b> Increases healing speed.<br>\
					  <b>Transmission 6:</b> Removes penalty for only being close to space."

/datum/symptom/heal/toxin/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmission"] >= 6)
		nearspace_penalty = 1
	if(A.properties["stage_rate"] >= 6)
		power = 2

/datum/symptom/heal/toxin/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(istype(get_turf(M), /turf/open/space))
		return power
	else
		for(var/turf/T in view(M, 2))
			if(istype(T, /turf/open/space))
				return power * nearspace_penalty

/datum/symptom/heal/toxin/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power
	if(M.getToxLoss() && prob(5))
		to_chat(M, "<span class='notice'>Your skin tingles as the starlight purges toxins from your bloodstream.</span>")
	M.adjustToxLoss(-heal_amt)
	return 1

/datum/symptom/heal/toxin/passive_message_condition(mob/living/M)
	if(M.getToxLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/chem
	name = "Toxolysis"
	stealth = 0
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 7
	var/food_conversion = FALSE
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	threshold_desc = "<b>Resistance 7:</b> Increases chem removal speed.<br>\
					  <b>Stage Speed 6:</b> Consumed chemicals nourish the host."

/datum/symptom/heal/chem/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 6)
		food_conversion = TRUE
	if(A.properties["resistance"] >= 7)
		power = 2

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.id, actual_power)
		if(food_conversion)
			M.nutrition += 0.3
		if(prob(2))
			to_chat(M, "<span class='notice'>You feel a mild warmth as your blood purifies itself.</span>")
	return 1



/datum/symptom/heal/metabolism
	name = "Metabolic Boost"
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = 1
	level = 7
	var/triple_metabolism = FALSE
	var/reduced_hunger = FALSE
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast,\
	 but also causing increased hunger."
	threshold_desc = "<b>Stealth 3:</b> Reduces hunger rate.<br>\
					  <b>Stage Speed 10:</b> Chemical metabolization is tripled instead of doubled."

/datum/symptom/heal/metabolism/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 10)
		triple_metabolism = TRUE
	if(A.properties["stealth"] >= 3)
		reduced_hunger = TRUE

/datum/symptom/heal/metabolism/Heal(mob/living/carbon/C, datum/disease/advance/A, actual_power)
	if(!istype(C))
		return
	C.reagents.metabolize(C, can_overdose=TRUE) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	if(triple_metabolism)
		C.reagents.metabolize(C, can_overdose=TRUE)
	C.overeatduration = max(C.overeatduration - 2, 0)
	var/lost_nutrition = 9 - (reduced_hunger * 5)
	C.nutrition = max(C.nutrition - (lost_nutrition * HUNGER_FACTOR), 0) //Hunger depletes at 10x the normal speed
	if(prob(2))
		to_chat(C, "<span class='notice'>You feel an odd gurgle in your stomach, as if it was working much faster than normal.</span>")
	return 1

/datum/symptom/heal/brute
	name = "Cellular Molding"
	desc = "The virus is able to shift cells around when in conditions of high heat, repairing existing physical damage."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -3
	level = 6
	passive_message = "<span class='notice'>You feel the flesh pulsing under your skin for a moment, but it's too cold to move.</span>"
	threshold_desc = "<b>Stage Speed 8:</b> Doubles healing speed."

/datum/symptom/heal/brute/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 8)
		power = 2

/datum/symptom/heal/brute/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	switch(M.bodytemperature)
		if(0 to 340)
			return FALSE
		if(340 to BODYTEMP_HEAT_DAMAGE_LIMIT)
			. = 0.3 * power
		if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
			. = 0.75 * power
		if(400 to 460)
			. = power
		else
			. = 1.5 * power

	if(M.on_fire)
		. *= 2

/datum/symptom/heal/brute/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,0) //brute only

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, "<span class='notice'>You feel your flesh moving beneath your heated skin, mending your wounds.</span>")

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, 0))
			M.update_damage_overlays()
	return 1

/datum/symptom/heal/brute/passive_message_condition(mob/living/M)
	if(M.getBruteLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage."
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8
	passive_message = "<span class='notice'>The pain from your wounds makes you feel oddly sleepy...</span>"
	var/deathgasp = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs
	threshold_desc = "<b>Stealth 2:</b> Host appears to die when falling into a coma.<br>\
					  <b>Stage Speed 7:</b> Increases healing speed."

/datum/symptom/heal/coma/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 7)
		power = 1.5
	if(A.properties["stealth"] >= 2)
		deathgasp = TRUE

/datum/symptom/heal/coma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(M.status_flags & FAKEDEATH)
		return power
	else if(M.IsUnconscious() || M.stat == UNCONSCIOUS)
		return power * 0.9
	else if(M.stat == SOFT_CRIT)
		return power * 0.5
	else if(M.IsSleeping())
		return power * 0.25
	else if(M.getBruteLoss() + M.getFireLoss() >= 70 && !active_coma)
		to_chat(M, "<span class='warning'>You feel yourself slip into a regenerative coma...</span>")
		active_coma = TRUE
		addtimer(CALLBACK(src, .proc/coma, M), 60)

/datum/symptom/heal/coma/proc/coma(mob/living/M)
	if(deathgasp)
		M.emote("deathgasp")
	M.status_flags |= FAKEDEATH
	M.update_stat()
	M.update_canmove()
	addtimer(CALLBACK(src, .proc/uncoma, M), 300)

/datum/symptom/heal/coma/proc/uncoma(mob/living/M)
	if(!active_coma)
		return
	active_coma = FALSE
	M.status_flags &= ~FAKEDEATH
	M.update_stat()
	M.update_canmove()

/datum/symptom/heal/coma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len))
			M.update_damage_overlays()

	if(active_coma && M.getBruteLoss() + M.getFireLoss() == 0)
		uncoma(M)

	return 1

/datum/symptom/heal/coma/passive_message_condition(mob/living/M)
	if((M.getBruteLoss() + M.getFireLoss()) > 30)
		return TRUE
	return FALSE

/datum/symptom/heal/burn
	name = "Tissue Hydration"
	desc = "The virus uses excess water inside and outside the body to repair burned tisue cells."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -3
	level = 6
	passive_message = "<span class='notice'>Your burned skin feels oddly dry...</span>"
	var/absorption_coeff = 1
	threshold_desc = "<b>Resistance 5:</b> Water is consumed at a much slower rate.<br>\
					  <b>Stage Speed 7:</b> Increases healing speed."

/datum/symptom/heal/burn/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 7)
		power = 2
	if(A.properties["stealth"] >= 2)
		absorption_coeff = 0.25

/datum/symptom/heal/burn/CanHeal(datum/disease/advance/A)
	. = 0
	var/mob/living/M = A.affected_mob
	if(M.fire_stacks < 0)
		M.fire_stacks = min(M.fire_stacks + 1 * absorption_coeff, 0)
		. += power
	if(M.reagents.has_reagent("holywater"))
		M.reagents.remove_reagent("holywater", 0.5 * absorption_coeff)
		. += power * 0.75
	else if(M.reagents.has_reagent("water"))
		M.reagents.remove_reagent("water", 0.5 * absorption_coeff)
		. += power * 0.5

/datum/symptom/heal/burn/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(0,1) //burn only

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, "<span class='notice'>You feel yourself absorbing the water around you to soothe your burned skin.</span>")

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt/parts.len))
			M.update_damage_overlays()

	return 1

/datum/symptom/heal/burn/passive_message_condition(mob/living/M)
	if(M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/plasma
	name = "Plasma Fixation"
	desc = "The virus draws plasma from the atmosphere and from inside the body to stabilize body temperature and heal burns."
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8
	passive_message = "<span class='notice'>You feel an odd attraction to plasma.</span>"
	var/temp_rate = 1
	threshold_desc = "<b>Transmission 6:</b> Increases temperature adjustment rate.<br>\
					  <b>Stage Speed 7:</b> Increases healing speed."

/datum/symptom/heal/plasma/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 7)
		power = 2
	if(A.properties["trasmission"] >= 6)
		temp_rate = 4

/datum/symptom/heal/plasma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/datum/gas_mixture/environment
	var/list/gases

	. = 0

	if(M.loc)
		environment = M.loc.return_air()
	if(environment)
		gases = environment.gases
		if(gases["plasma"] && gases["plasma"][MOLES] > gases["plasma"][GAS_META][META_GAS_MOLES_VISIBLE]) //if there's enough plasma in the air to see
			. += power * 0.5
	if(M.reagents.has_reagent("plasma"))
		. +=  power * 0.75

/datum/symptom/heal/plasma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(0,1) //burn only

	if(prob(5))
		to_chat(M, "<span class='notice'>You feel yourself absorbing plasma inside and around you...</span>")

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT))
		if(prob(5))
			to_chat(M, "<span class='notice'>You feel less hot.</span>")
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT))
		if(prob(5))
			to_chat(M, "<span class='notice'>You feel warmer.</span>")

	if(!parts.len)
		return
	if(prob(5))
		to_chat(M, "<span class='notice'>The pain from your burns fades rapidly.</span>")

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt/parts.len))
			M.update_damage_overlays()
	return 1



/datum/symptom/heal/radiation
	name = "Radioactive Resonance"
	desc = "The virus uses radiation to fix damage through dna mutations."
	stealth = -1
	resistance = -2
	stage_speed = 0
	transmittable = -3
	level = 6
	symptom_delay_min = 1
	symptom_delay_max = 1
	passive_message = "<span class='notice'>Your skin glows faintly for a moment.</span>"
	var/cellular_damage = FALSE
	threshold_desc = "<b>Transmission 6:</b> Additionally heals cellular damage.<br>\
					  <b>Resistance 7:</b> Increases healing speed."

/datum/symptom/heal/radiation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 7)
		power = 2
	if(A.properties["trasmission"] >= 6)
		cellular_damage = TRUE

/datum/symptom/heal/radiation/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	switch(M.radiation)
		if(0)
			return FALSE
		if(1 to RAD_MOB_SAFE)
			return 0.25
		if(RAD_MOB_SAFE to RAD_BURN_THRESHOLD)
			return 0.5
		if(RAD_BURN_THRESHOLD to RAD_MOB_MUTATE)
			return 0.75
		if(RAD_MOB_MUTATE to RAD_MOB_KNOCKDOWN)
			return 1
		else
			return 1.5

/datum/symptom/heal/radiation/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power

	if(cellular_damage)
		M.adjustCloneLoss(-heal_amt * 0.5)

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	if(prob(4))
		to_chat(M, "<span class='notice'>Your skin glows faintly, and you feel your wounds mending themselves.</span>")

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len))
			M.update_damage_overlays()
	return 1
