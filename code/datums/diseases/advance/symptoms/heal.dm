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
	var/hide_healing = FALSE
	threshold_desc = "<b>Stage Speed 6:</b> Doubles healing speed.<br>\
					  <b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/heal/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4) //invisible healing
		hide_healing = TRUE
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
				return
			else
				Heal(M, A, effectiveness)
	return

/datum/symptom/heal/proc/CanHeal(datum/disease/advance/A)
	return power

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	return 1

/*
//////////////////////////////////////

Toxin Filter

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins when near or in space

//////////////////////////////////////
*/

/datum/symptom/heal/toxin
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -3
	level = 6

/datum/symptom/heal/toxin/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(istype(get_turf(M), /turf/open/space))
		return power
	else
		for(var/turf/T in view(M, 2))
			if(istype(T, /turf/open/space))
				return power * 0.3

/datum/symptom/heal/toxin/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 1 * actual_power
	if(M.toxloss > 0 && prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(M.loc, "#66FF99")
	M.adjustToxLoss(-heal_amt)
	return 1

/*
//////////////////////////////////////

Toxolysis

	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity.

Bonus
	Removes all chems in the host's body

//////////////////////////////////////
*/

/datum/symptom/heal/chem
	name = "Toxolysis"
	stealth = 0
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 8
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.id, actual_power)
	return 1

/*
//////////////////////////////////////

Regeneration

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals brute damage when in a hot room.

//////////////////////////////////////
*/

/datum/symptom/heal/brute
	name = "Cellular Molding"
	desc = "The virus is able to shift cells around when in conditions of high heat, repairing existing physical damage."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -3
	level = 6

/datum/symptom/heal/brute/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	switch(M.bodytemperature)
		if(0 to 340)
			return FALSE
		if(340 to BODYTEMP_HEAT_DAMAGE_LIMIT)
			. = 0.3 * power
		if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
			. = 0.5 * power
		if(400 to 460)
			. = 0.75 * power
		else
			. = power

	if(M.on_fire)
		. *= 2

/datum/symptom/heal/brute/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 1 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,0) //brute only

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, 0))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(M.loc, "#FF3333")

	return 1


/*
//////////////////////////////////////

Regenerative Coma

	No resistance change.
	Decreases stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Heals brute and burn while unconscious, but causes a long period of unconsciousness if the host is heavily damaged.

//////////////////////////////////////
*/

/datum/symptom/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a coma when severely damaged, then rapidly fixes the damage."
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/heal/coma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(M.IsUnconscious() || M.stat == UNCONSCIOUS)
		return power
	else if(M.stat == SOFT_CRIT)
		return power * 0.5
	else if(M.IsSleeping())
		return power * 0.25
	else if(M.getBruteLoss() + M.getFireLoss() >= 70)
		to_chat(M, "<span class='warning'>You feel yourself slip into a regenerative coma...</span>")
		M.Unconscious(450)

/datum/symptom/heal/coma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 3 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(M.loc, "#CC1100")

	return 1

/*
//////////////////////////////////////

Tissue Regrowth

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals burn damage slowly over time.

//////////////////////////////////////
*/

/datum/symptom/heal/burn

	name = "Tissue Hydration"
	desc = "The virus uses excess water inside and outside the body to repair burned tisue cells."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -3
	level = 6

/datum/symptom/heal/burn/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(M.fire_stacks < 0)
		M.fire_stacks = min(M.fire_stacks + 1, 0)
		return power
	else if(M.reagents.has_reagent("holywater"))
		M.reagents.remove_reagent("holywater", 0.5)
		return power * 0.60
	else if(M.reagents.has_reagent("water"))
		M.reagents.remove_reagent("water", 0.5)
		return power * 0.5

/datum/symptom/heal/burn/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(0,1) //burn only

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt/parts.len))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(M.loc, "#FF9933")
	return 1


/*
//////////////////////////////////////

Heat Resistance //Needs a better name

	No resistance change.
	Decreases stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Heals burn damage over time, and helps stabilize body temperature.

//////////////////////////////////////
*/

/datum/symptom/heal/plasma
	name = "Plasma Fixation"
	desc = "The virus draws plasma from the atmosphere and from inside the body to stabilize body temperature and heal burns."
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8

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

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (10 * heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (10 * heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt/parts.len))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(M.loc, "#CC6600")
	return 1


/*
//////////////////////////////////////

	DNA Restoration

	Not well hidden.
	Lowers resistance minorly.
	Does not affect stage speed.
	Decreases transmittablity greatly.
	Very high level.

Bonus
	Heals brain damage, treats radiation, cleans SE of non-power mutations.

//////////////////////////////////////
*/

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
	threshold_desc = "<b>Stage Speed 6:</b> Increases healing."

/datum/symptom/heal/radiation/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	switch(M.radiation)
		if(0)
			return FALSE
		if(1 to RAD_MOB_SAFE)
			return 0.25
		if(RAD_MOB_SAFE to 750)
			return 0.5
		if(751 to 1250)
			return 0.75
		if(1251 to 2000)
			return 1
		else
			return 1.5

/datum/symptom/heal/radiation/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 1 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len))
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(M.loc, "#66ff22")
	return 1
