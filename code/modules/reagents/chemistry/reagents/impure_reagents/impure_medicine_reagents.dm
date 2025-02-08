//Reagents produced by metabolising/reacting fermichems suboptimally these specifically are for medicines
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min

//START SUBTYPES

//We don't want these to hide - they're helpful!
/datum/reagent/impurity/healing
	name = "Healing Impure Reagent"
	description = "Not all impure reagents are bad! Sometimes you might want to specifically make these!"
	chemical_flags = REAGENT_DONOTSPLIT
	addiction_types = list(/datum/addiction/medicine = 3.5)
	liver_damage = 0

/datum/reagent/inverse/healing
	name = "Healing Inverse Reagent"
	description = "Not all impure reagents are bad! Sometimes you might want to specifically make these!"
	chemical_flags = REAGENT_DONOTSPLIT
	addiction_types = list(/datum/addiction/medicine = 3)
	tox_damage = 0

// END SUBTYPES

////////////////////MEDICINES///////////////////////////

//Catch all failed reaction for medicines - supposed to be non punishing
/datum/reagent/impurity/healing/medicine_failure
	name = "Insolvent Medicinal Precipitate"
	description = "A viscous mess of various medicines. Will heal a damage type at random"
	metabolization_rate = 1 * REM//This is fast
	addiction_types = list(/datum/addiction/medicine = 7.5)
	ph = 11
	affected_biotype = MOB_ORGANIC | MOB_MINERAL | MOB_PLANT // no healing ghosts
	affected_respiration_type = ALL

//Random healing of the 4 main groups
/datum/reagent/impurity/healing/medicine_failure/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	var/pick = pick("brute", "burn", "tox", "oxy")
	switch(pick)
		if("brute")
			need_mob_update = affected_mob.adjustBruteLoss(-0.5, updating_health = FALSE, required_bodytype = affected_bodytype)
		if("burn")
			need_mob_update += affected_mob.adjustFireLoss(-0.5, updating_health = FALSE, required_bodytype = affected_bodytype)
		if("tox")
			need_mob_update += affected_mob.adjustToxLoss(-0.5, updating_health = FALSE, required_biotype = affected_biotype)
		if("oxy")
			need_mob_update += affected_mob.adjustOxyLoss(-0.5, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

// C2 medications
// Helbital
//Inverse:
/datum/reagent/inverse/helgrasp
	name = "Helgrasp"
	description = "This rare and forbidden concoction is thought to bring you closer to the grasp of the Norse goddess Hel."
	metabolization_rate = 1*REM //This is fast
	tox_damage = 0.25
	ph = 14
	//Compensates for seconds_per_tick lag by spawning multiple hands at the end
	var/lag_remainder = 0
	//Keeps track of the hand timer so we can cleanup on removal
	var/list/timer_ids

//Warns you about the impenting hands
/datum/reagent/inverse/helgrasp/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	to_chat(affected_mob, span_hierophant("You hear laughter as malevolent hands apparate before you, eager to drag you down to hell...! Look out!"))
	playsound(affected_mob.loc, 'sound/effects/chemistry/ahaha.ogg', 80, TRUE, -1) //Very obvious tell so people can be ready

//Sends hands after you for your hubris
/*
How it works:
Standard seconds_per_tick for a reagent is 2s - and volume consumption is equal to the volume * seconds_per_tick.
In this chem, I want to consume 0.5u for 1 hand created (since 1*REM is 0.5) so on a single tick I create a hand and set up a callback for another one in 1s from now. But since delta time can vary, I want to be able to create more hands for when the delay is longer.

Initally I round seconds_per_tick to the nearest whole number, and take the part that I am rounding down from (i.e. the decimal numbers) and keep track of them. If the decimilised numbers go over 1, then the number is reduced down and an extra hand is created that tick.

Then I attempt to calculate the how many hands to created based off the current seconds_per_tick, since I can't know the delay to the next one it assumes the next will be in 2s.
I take the 2s interval period and divide it by the number of hands I want to make (i.e. the current seconds_per_tick) and I keep track of how many hands I'm creating (since I always create one on a tick, then I start at 1 hand). For each hand I then use this time value multiplied by the number of hands. Since we're spawning one now, and it checks to see if hands is less than, but not less than or equal to, seconds_per_tick, no hands will be created on the next expected tick.
Basically, we fill the time between now and 2s from now with hands based off the current lag.
*/
/datum/reagent/inverse/helgrasp/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	spawn_hands(affected_mob)
	lag_remainder += seconds_per_tick - FLOOR(seconds_per_tick, 1)
	seconds_per_tick = FLOOR(seconds_per_tick, 1)
	if(lag_remainder >= 1)
		seconds_per_tick += 1
		lag_remainder -= 1
	var/hands = 1
	var/time = 2 / seconds_per_tick
	while(hands < seconds_per_tick) //we already made a hand now so start from 1
		LAZYADD(timer_ids, addtimer(CALLBACK(src, PROC_REF(spawn_hands), affected_mob), (time*hands) SECONDS, TIMER_STOPPABLE)) //keep track of all the timers we set up
		hands += time

/datum/reagent/inverse/helgrasp/proc/spawn_hands(mob/living/carbon/affected_mob)
	if(!affected_mob && iscarbon(holder.my_atom))//Catch timer
		affected_mob = holder.my_atom
	fire_curse_hand(affected_mob)

//At the end, we clear up any loose hanging timers just in case and spawn any remaining lag_remaining hands all at once.
/datum/reagent/inverse/helgrasp/on_mob_delete(mob/living/affected_mob)
	. = ..()
	var/hands = 0
	while(lag_remainder > hands)
		spawn_hands(affected_mob)
		hands++
	for(var/id in timer_ids) // So that we can be certain that all timers are deleted at the end.
		deltimer(id)
	timer_ids.Cut()

/datum/reagent/inverse/helgrasp/heretic
	name = "Grasp of the Mansus"
	description = "The Hand of the Mansus is at your neck."
	metabolization_rate = 1 * REM
	tox_damage = 0

//libital
//Inverse:
//Simply reduces your alcohol tolerance, kinda simular to prohol
/datum/reagent/inverse/libitoil
	name = "Libitoil"
	description = "Temporarily interferes with a patient's ability to process alcohol."
	chemical_flags = REAGENT_DONOTSPLIT
	ph = 13.5
	addiction_types = list(/datum/addiction/medicine = 4)
	tox_damage = 0

/datum/reagent/inverse/libitoil/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.1 * REM * delta_time)

/datum/reagent/inverse/libitoil/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	var/mob/living/carbon/consumer = affected_mob
	if(!consumer)
		return
	RegisterSignal(consumer, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(consumer, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/liver/this_liver = consumer.get_organ_slot(ORGAN_SLOT_LIVER)
	this_liver.alcohol_tolerance *= 2

/datum/reagent/inverse/libitoil/proc/on_gained_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/liver))
		return
	var/obj/item/organ/liver/this_liver = organ
	this_liver.alcohol_tolerance *= 2

/datum/reagent/inverse/libitoil/proc/on_removed_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/liver))
		return
	var/obj/item/organ/liver/this_liver = organ
	this_liver.alcohol_tolerance /= 2

/datum/reagent/inverse/libitoil/on_mob_delete(mob/living/affected_mob)
	. = ..()
	var/mob/living/carbon/consumer = affected_mob
	UnregisterSignal(consumer, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(consumer, COMSIG_CARBON_GAIN_ORGAN)
	var/obj/item/organ/liver/this_liver = consumer.get_organ_slot(ORGAN_SLOT_LIVER)
	if(!this_liver)
		return
	this_liver.alcohol_tolerance /= 2


//probital
/datum/reagent/impurity/probital_failed//Basically crashed out failed metafactor
	name = "Metabolic Inhibition Factor"
	description = "This enzyme catalyzes crashes the conversion of nutritious food into healing peptides."
	metabolization_rate = 0.0625  * REAGENTS_METABOLISM //slow metabolism rate so the patient can self heal with food even after the troph has metabolized away for amazing reagent efficency.
	color = "#b3ff00"
	overdose_threshold = 10
	ph = 1
	addiction_types = list(/datum/addiction/medicine = 5)
	liver_damage = 0

/datum/reagent/impurity/probital_failed/overdose_start(mob/living/carbon/M)
	. = ..()
	metabolization_rate = 4  * REAGENTS_METABOLISM

/datum/reagent/peptides_failed
	name = "Prion Peptides"
	taste_description = "spearmint frosting"
	description = "These inhibitory peptides drains nutrition and causes brain damage in the patient!"
	ph = 2.1

/datum/reagent/peptides_failed/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * seconds_per_tick, 170))
		. = UPDATE_MOB_HEALTH
	affected_mob.adjust_nutrition(-5 * REAGENTS_METABOLISM * seconds_per_tick)

//Lenturi
//inverse
/datum/reagent/inverse/lentslurri //Okay maybe I should outsource names for these
	name = "Lentslurri"//This is a really bad name please replace
	description = "A highly addictive muscle relaxant that is made when Lenturi reactions go wrong, this will cause the patient to move slowly."
	addiction_types = list(/datum/addiction/medicine = 8)
	tox_damage = 0

/datum/reagent/inverse/lentslurri/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)

/datum/reagent/inverse/lentslurri/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)

//Aiuri
//inverse
/datum/reagent/inverse/aiuri
	name = "Aivime"
	description = "This reagent is known to interfere with the eyesight of a patient."
	ph = 3.1
	addiction_types = list(/datum/addiction/medicine = 1.5)
	///The amount of blur applied per second. Given the average on_life interval is 2 seconds, that'd be 2.5s.
	var/amount_of_blur_applied = 1.25 SECONDS
	tox_damage = 0

/datum/reagent/inverse/aiuri/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	owner.adjustOrganLoss(ORGAN_SLOT_EYES, 0.1 * REM * delta_time)
	owner.adjust_eye_blur(amount_of_blur_applied * delta_time)
	. = ..()
	return TRUE

//Hercuri
//inverse
/datum/reagent/inverse/hercuri
	name = "Herignis"
	description = "This reagent causes a dramatic raise in the patient's body temperature. Overdosing makes the effect even stronger and causes severe liver damage."
	ph = 0.8
	tox_damage = 0
	color = "#ff1818"
	overdose_threshold = 25
	reagent_weight = 0.6
	taste_description = "heat! Ouch!"
	addiction_types = list(/datum/addiction/medicine = 2.5)

/datum/reagent/inverse/hercuri/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/heating = rand(5, 25) * creation_purity * REM * seconds_per_tick
	var/datum/reagents/mob_reagents = affected_mob.reagents
	if(mob_reagents)
		mob_reagents.expose_temperature(mob_reagents.chem_temp + heating, 1)
	affected_mob.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)
	if(!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/human = affected_mob
	human.adjust_coretemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)

/datum/reagent/inverse/hercuri/expose_mob(mob/living/carbon/exposed_mob, methods=VAPOR, reac_volume)
	. = ..()
	if(!(methods & VAPOR))
		return

	exposed_mob.adjust_bodytemperature(reac_volume * TEMPERATURE_DAMAGE_COEFFICIENT)
	exposed_mob.adjust_fire_stacks(reac_volume / 2)

/datum/reagent/inverse/hercuri/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)) //Makes it so you can't abuse it with pyroxadone very easily (liver dies from 25u unless it's fully upgraded)
		. = UPDATE_MOB_HEALTH
	var/heating = 10 * creation_purity * REM * seconds_per_tick * TEMPERATURE_DAMAGE_COEFFICIENT
	affected_mob.adjust_bodytemperature(heating) //hot hot
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/human = affected_mob
		human.adjust_coretemperature(heating)

/datum/reagent/inverse/healing/tirimol
	name = "Super Melatonin"//It's melatonin, but super!
	description = "This will send the patient to sleep, adding a bonus to the efficacy of all reagents administered."
	ph = 12.5 //sleeping is a basic need of all lifeformsa
	self_consuming = TRUE //No pesky liver shenanigans
	chemical_flags = REAGENT_DONOTSPLIT | REAGENT_DEAD_PROCESS
	var/cached_reagent_list = list()
	addiction_types = list(/datum/addiction/medicine = 5)

//Makes patients fall asleep, then boosts the purirty of their medicine reagents if they're asleep
/datum/reagent/inverse/healing/tirimol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	switch(current_cycle)
		if(2 to 11)//same delay as chloral hydrate
			if(prob(50))
				affected_mob.emote("yawn")
		if(11 to INFINITY)
			affected_mob.Sleeping(40)
			. = 1
			if(affected_mob.IsSleeping())
				for(var/datum/reagent/reagent as anything in affected_mob.reagents.reagent_list)
					if(reagent in cached_reagent_list)
						continue
					if(!istype(reagent, /datum/reagent/medicine))
						continue
					reagent.creation_purity *= 1.25
					cached_reagent_list += reagent

			else if(!affected_mob.IsSleeping() && length(cached_reagent_list))
				for(var/datum/reagent/reagent as anything in cached_reagent_list)
					if(!reagent)
						continue
					reagent.creation_purity *= 0.8
				cached_reagent_list = list()

/datum/reagent/inverse/healing/tirimol/on_mob_delete(mob/living/affected_mob)
	. = ..()
	if(affected_mob.IsSleeping())
		affected_mob.visible_message(span_notice("[icon2html(affected_mob, viewers(DEFAULT_MESSAGE_RANGE, src))] [affected_mob] lets out a hearty snore!"))//small way of letting people know the supersnooze is ended
	for(var/datum/reagent/reagent as anything in cached_reagent_list)
		if(!reagent)
			continue
		reagent.creation_purity *= 0.8
	cached_reagent_list = list()

//convermol
//inverse
/datum/reagent/inverse/healing/convermol
	name = "Coveroli"
	description = "This reagent is known to coat the inside of a patient's lungs, providing greater protection against hot or cold air."
	ph = 3.82
	tox_damage = 0
	addiction_types = list(/datum/addiction/medicine = 2.3)
	//The heat damage levels of lungs when added (i.e. heat_level_1_threshold on lungs)
	var/cached_heat_level_1
	var/cached_heat_level_2
	var/cached_heat_level_3
	//The cold damage levels of lungs when added (i.e. cold_level_1_threshold on lungs)
	var/cached_cold_level_1
	var/cached_cold_level_2
	var/cached_cold_level_3

/datum/reagent/inverse/healing/convermol/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	RegisterSignal(affected_mob, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(affected_mob, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/lungs/lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		return
	apply_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/on_gained_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/lungs))
		return
	var/obj/item/organ/lungs/lungs = organ
	apply_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/apply_lung_levels(obj/item/organ/lungs/lungs)
	cached_heat_level_1 = lungs.heat_level_1_threshold
	cached_heat_level_2 = lungs.heat_level_2_threshold
	cached_heat_level_3 = lungs.heat_level_3_threshold
	cached_cold_level_1 = lungs.cold_level_1_threshold
	cached_cold_level_2 = lungs.cold_level_2_threshold
	cached_cold_level_3 = lungs.cold_level_3_threshold
	//Heat threshold is increased
	lungs.heat_level_1_threshold *= creation_purity * 1.5
	lungs.heat_level_2_threshold *= creation_purity * 1.5
	lungs.heat_level_3_threshold *= creation_purity * 1.5
	//Cold threshold is decreased
	lungs.cold_level_1_threshold *= creation_purity * 0.5
	lungs.cold_level_2_threshold *= creation_purity * 0.5
	lungs.cold_level_3_threshold *= creation_purity * 0.5

/datum/reagent/inverse/healing/convermol/proc/on_removed_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/lungs))
		return
	var/obj/item/organ/lungs/lungs = organ
	restore_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/restore_lung_levels(obj/item/organ/lungs/lungs)
	lungs.heat_level_1_threshold = cached_heat_level_1
	lungs.heat_level_2_threshold = cached_heat_level_2
	lungs.heat_level_3_threshold = cached_heat_level_3
	lungs.cold_level_1_threshold = cached_cold_level_1
	lungs.cold_level_2_threshold = cached_cold_level_2
	lungs.cold_level_3_threshold = cached_cold_level_3

/datum/reagent/inverse/healing/convermol/on_mob_delete(mob/living/affected_mob)
	. = ..()
	UnregisterSignal(affected_mob, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(affected_mob, COMSIG_CARBON_GAIN_ORGAN)
	var/obj/item/organ/lungs/lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		return
	restore_lung_levels(lungs)

//seiver
//Inverse
//Allows the scanner to detect organ health to the nearest 1% (similar use to irl) and upgrates the scan to advanced
/datum/reagent/inverse/technetium
	name = "Technetium 99"
	description = "A radioactive tracer agent that can improve a scanner's ability to detect internal organ damage. Will poison the patient when present very slowly, purging or using a low dose is recommended after use."
	metabolization_rate = 0.3 * REM
	chemical_flags = REAGENT_DONOTSPLIT //Do show this on scanner
	tox_damage = 0

	var/time_until_next_poison = 0

	var/poison_interval = (9 SECONDS)

/datum/reagent/inverse/technetium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	time_until_next_poison -= seconds_per_tick * (1 SECONDS)
	if (time_until_next_poison <= 0)
		time_until_next_poison = poison_interval
		if(affected_mob.adjustToxLoss(creation_purity * 1, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

//Kind of a healing effect, Presumably you're using syrinver to purge so this helps that
/datum/reagent/inverse/healing/syriniver
	name = "Syrinifergus"
	description = "This reagent reduces the impurity of all non medicines within the patient, reducing their negative effects."
	self_consuming = TRUE //No pesky liver shenanigans
	chemical_flags = REAGENT_DONOTSPLIT | REAGENT_DEAD_PROCESS
	///The list of reagents we've affected
	var/cached_reagent_list = list()
	addiction_types = list(/datum/addiction/medicine = 1.75)

/datum/reagent/inverse/healing/syriniver/on_mob_add(mob/living/affected_mob, amount)
	if(!(iscarbon(affected_mob)))
		return ..()
	var/mob/living/carbon/affected_carbon = affected_mob
	for(var/datum/reagent/reagent as anything in affected_carbon.reagents.reagent_list)
		if(reagent in cached_reagent_list)
			continue
		if(istype(reagent, /datum/reagent/medicine))
			continue
		reagent.creation_purity *= 0.8
		cached_reagent_list += reagent
	..()

/datum/reagent/inverse/healing/syriniver/on_mob_delete(mob/living/affected_mob)
	. = ..()
	if(!(iscarbon(affected_mob)))
		return
	if(!cached_reagent_list)
		return
	for(var/datum/reagent/reagent as anything in cached_reagent_list)
		if(!reagent)
			continue
		reagent.creation_purity *= 1.25
	cached_reagent_list = null

//Multiver
//Inverse
//Reaction product when between 0.2 and 0.35 purity.
/datum/reagent/inverse/healing/monover
	name = "Monover"
	description = "A toxin treating reagent, that only is effective if it's the only reagent present in the patient."
	ph = 0.5
	addiction_types = list(/datum/addiction/medicine = 3.5)

//Heals toxins if it's the only thing present - kinda the oposite of multiver! Maybe that's why it's inverse!
/datum/reagent/inverse/healing/monover/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(length(affected_mob.reagents.reagent_list) > 1)
		need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5 * seconds_per_tick, required_organ_flag = affected_organ_flags) //Hey! It's everyone's favourite drawback from multiver!
	else
		need_mob_update = affected_mob.adjustToxLoss(-2 * REM * creation_purity * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

///Can bring a corpse back to life temporarily (if heart is intact)
///Makes wounds bleed more, if it brought someone back, they take additional brute and heart damage
///They can't die during this, but if they're past crit then take increasing stamina damage
///If they're past fullcrit, their movement is slowed by half
///If they OD, their heart explodes (if they were brought back from the dead)
/datum/reagent/inverse/penthrite
	name = "Nooartrium"
	description = "A reagent that is known to stimulate the heart in a dead patient, temporarily bringing back recently dead patients at great cost to their heart."
	ph = 14
	metabolization_rate = 0.05 * REM
	addiction_types = list(/datum/addiction/medicine = 12)
	overdose_threshold = 20
	self_consuming = TRUE //No pesky liver shenanigans
	chemical_flags = REAGENT_DONOTSPLIT | REAGENT_DEAD_PROCESS
	affected_organ_flags = NONE
	///If we brought someone back from the dead
	var/back_from_the_dead = FALSE
	/// List of trait buffs to give to the affected mob, and remove as needed.
	var/static/list/trait_buffs = list(
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOCRITOVERLAY,
		TRAIT_NODEATH,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_STABLEHEART,
	)

/datum/reagent/inverse/penthrite/on_mob_dead(mob/living/carbon/affected_mob, seconds_per_tick)
	. = ..()
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		return
	metabolization_rate = 0.2 * REM
	affected_mob.add_traits(trait_buffs, type)
	affected_mob.set_stat(CONSCIOUS) //This doesn't touch knocked out
	affected_mob.updatehealth()
	affected_mob.update_sight()
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, STAT_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT) //Because these are normally updated using set_health() - but we don't want to adjust health, and the addition of NOHARDCRIT blocks it being added after, but doesn't remove it if it was added before
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT) //Prevents the user from being knocked out by oxyloss
	affected_mob.set_resting(FALSE) //Please get up, no one wants a deaththrows juggernaught that lies on the floor all the time
	affected_mob.SetAllImmobility(0)
	affected_mob.grab_ghost(force = FALSE) //Shoves them back into their freshly reanimated corpse.
	back_from_the_dead = TRUE
	affected_mob.emote("gasp")
	affected_mob.playsound_local(affected_mob, 'sound/effects/health/fastbeat.ogg', 65)

/datum/reagent/inverse/penthrite/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!back_from_the_dead)
		return
	//Following is for those brought back from the dead only
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	for(var/datum/wound/iter_wound as anything in affected_mob.all_wounds)
		iter_wound.adjust_blood_flow(1-creation_purity)
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(5 * (1-creation_purity) * seconds_per_tick, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, (1 + (1-creation_purity)) * seconds_per_tick, required_organ_flag = affected_organ_flags)
	if(affected_mob.health < HEALTH_THRESHOLD_CRIT)
		affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nooartrium)
	if(affected_mob.health < HEALTH_THRESHOLD_FULLCRIT)
		affected_mob.add_actionspeed_modifier(/datum/actionspeed_modifier/nooartrium)
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		remove_buffs(affected_mob)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/inverse/penthrite/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	remove_buffs(affected_mob)
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(affected_mob.health < -500 || heart.organ_flags & ORGAN_FAILING)//Honestly commendable if you get -500
		explosion(affected_mob, light_impact_range = 1, explosion_cause = src)
		qdel(heart)
		affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))

/datum/reagent/inverse/penthrite/overdose_start(mob/living/carbon/affected_mob)
	. = ..()
	if(!back_from_the_dead)
		return ..()
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart) //No heart? No life!
		REMOVE_TRAIT(affected_mob, TRAIT_NODEATH, type)
		affected_mob.stat = DEAD
		return ..()
	explosion(affected_mob, light_impact_range = 1, explosion_cause = src)
	qdel(heart)
	affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))
	return..()

/datum/reagent/inverse/penthrite/proc/remove_buffs(mob/living/carbon/affected_mob)
	affected_mob.remove_traits(trait_buffs, type)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nooartrium)
	affected_mob.remove_actionspeed_modifier(/datum/actionspeed_modifier/nooartrium)
	affected_mob.update_sight()

/*				Non c2 medicines 				*/

/datum/reagent/impurity/mannitol
	name = "Mannitoil"
	description = "Gives the patient a temporary speech impediment."
	color = "#CDCDFF"
	addiction_types = list(/datum/addiction/medicine = 5)
	ph = 12.4
	liver_damage = 0
	///The speech we're forcing on the affected mob
	var/speech_option

/datum/reagent/impurity/mannitol/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(!affected_carbon.dna)
		return
	var/list/speech_options = list(
		/datum/mutation/human/swedish,
		/datum/mutation/human/unintelligible,
		/datum/mutation/human/stoner,
		/datum/mutation/human/medieval,
		/datum/mutation/human/wacky,
		/datum/mutation/human/piglatin,
		/datum/mutation/human/nervousness,
		/datum/mutation/human/mute,
		)
	speech_options = shuffle(speech_options)
	for(var/option in speech_options)
		if(affected_carbon.dna.get_mutation(option))
			continue
		affected_carbon.dna.add_mutation(option)
		speech_option = option
		return

/datum/reagent/impurity/mannitol/on_mob_delete(mob/living/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/carbon = affected_mob
	carbon.dna?.remove_mutation(speech_option)

/datum/reagent/inverse/neurine
	name = "Neruwhine"
	description = "Induces a temporary brain trauma in the patient by redirecting neuron activity."
	color = "#DCDCAA"
	ph = 13.4
	addiction_types = list(/datum/addiction/medicine = 8)
	metabolization_rate = 0.025 * REM
	tox_damage = 0
	//The temporary trauma passed to the affected mob
	var/datum/brain_trauma/temp_trauma

/datum/reagent/inverse/neurine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(temp_trauma)
		return
	if(!(SPT_PROB(creation_purity*10, seconds_per_tick)))
		return
	var/static/list/traumalist
	if (!traumalist)
		traumalist = subtypesof(/datum/brain_trauma)

		// Don't add these to the list because they're abstract category types
		var/list/abstracttraumas = list(
			/datum/brain_trauma/magic,
			/datum/brain_trauma/mild,
			/datum/brain_trauma/severe,
			/datum/brain_trauma/special,
		)

		// Don't give out these traumas or any of their descendants
		var/list/forbiddentraumas = list(
			/datum/brain_trauma/severe/split_personality, // Uses a ghost, I don't want to use a ghost for a temp thing
			/datum/brain_trauma/special/imaginary_friend, // Same as above
			/datum/brain_trauma/special/obsessed, // Obsessed sets the affected_mob as an antag - I presume this will lead to problems, so we'll remove it
			/datum/brain_trauma/hypnosis, // Hypnosis, same reason as obsessed, plus a bug makes it remain even after the neruwhine purges and then turn into "nothing" on the med reading upon a second application
			/datum/brain_trauma/severe/hypnotic_stupor, // These apply the above blacklisted trauma
			/datum/brain_trauma/severe/hypnotic_trigger,
			/datum/brain_trauma/special/honorbound, // Designed to be chaplain exclusive
		)

		// Do give out these traumas but not any of their subtypes, usually because the trauma replaces itself with a subtype
		var/list/forbiddensubtypes = list(
			/datum/brain_trauma/mild/phobia,
			/datum/brain_trauma/severe/paralysis,
			/datum/brain_trauma/special/psychotic_brawling,
		)

		traumalist -= abstracttraumas
		for (var/type as anything in forbiddentraumas)
			traumalist -= typesof(type)
		for (var/type as anything in forbiddensubtypes)
			traumalist -= subtypesof(type)

	traumalist = shuffle(traumalist)
	var/obj/item/organ/brain/brain = affected_mob.get_organ_slot(ORGAN_SLOT_BRAIN)
	for(var/trauma in traumalist)
		if(brain.brain_gain_trauma(trauma, TRAUMA_RESILIENCE_MAGIC))
			temp_trauma = trauma
			return

/datum/reagent/inverse/neurine/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	if(!temp_trauma)
		return
	if(istype(temp_trauma, /datum/brain_trauma/special/imaginary_friend))//Good friends stay by you, no matter what
		return
	affected_mob.cure_trauma_type(temp_trauma, resilience = TRAUMA_RESILIENCE_MAGIC)

/datum/reagent/inverse/corazargh
	name = "Corazargh" //It's what you yell! Though, if you've a better name feel free. Also an homage to an older chem
	description = "Interferes with the body's natural pacemaker, forcing the patient to manually beat their heart."
	color = "#5F5F5F"
	self_consuming = TRUE
	ph = 13.5
	addiction_types = list(/datum/addiction/medicine = 2.5)
	metabolization_rate = REM
	chemical_flags = REAGENT_DEAD_PROCESS
	tox_damage = 0

///Give the victim the manual heart beating component.
/datum/reagent/inverse/corazargh/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	var/obj/item/organ/heart/affected_heart = carbon_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(isnull(affected_heart))
		return
	carbon_mob.AddComponent(/datum/component/manual_heart)
	return ..()

///We're done - remove the curse
/datum/reagent/inverse/corazargh/on_mob_end_metabolize(mob/living/affected_mob)
	qdel(affected_mob.GetComponent(/datum/component/manual_heart))
	..()

/datum/reagent/inverse/antihol
	name = "Prohol"
	description = "Promotes alcoholic substances within the patients body, making their effects more potent."
	taste_description = "alcohol" //mostly for sneaky slips
	chemical_flags = REAGENT_INVISIBLE
	metabolization_rate = 0.05 * REM//This is fast
	addiction_types = list(/datum/addiction/medicine = 4.5)
	color = "#4C8000"
	tox_damage = 0

/datum/reagent/inverse/antihol/on_mob_life(mob/living/carbon/C, seconds_per_tick, times_fired)
	. = ..()
	for(var/datum/reagent/consumable/ethanol/alcohol in C.reagents.reagent_list)
		alcohol.boozepwr += seconds_per_tick

/datum/reagent/inverse/oculine
	name = "Oculater"
	description = "Temporarily blinds the patient."
	color = "#DDDDDD"
	metabolization_rate = 0.1 * REM
	addiction_types = list(/datum/addiction/medicine = 3)
	taste_description = "funky toxin"
	ph = 13
	tox_damage = 0
	metabolization_rate = 0.2 * REM
	///Did we get a headache?
	var/headache = FALSE

/datum/reagent/inverse/oculine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(headache)
		return ..()
	if(SPT_PROB(100 * creation_purity, seconds_per_tick))
		affected_mob.become_blind(IMPURE_OCULINE)
		to_chat(affected_mob, span_danger("You suddenly develop a pounding headache as your vision fluxuates."))
		headache = TRUE

/datum/reagent/inverse/oculine/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.cure_blind(IMPURE_OCULINE)
	if(headache)
		to_chat(affected_mob, span_notice("Your headache clears up!"))

/datum/reagent/impurity/inacusiate
	name = "Tinacusiate"
	description = "Makes the patient's hearing temporarily funky."
	addiction_types = list(/datum/addiction/medicine = 5.6)
	color = "#DDDDFF"
	taste_description = "the heat evaporating from your mouth."
	ph = 1
	liver_damage = 0.1
	metabolization_rate = 0.04 * REM
	///The random span we start hearing in
	var/random_span

/datum/reagent/impurity/inacusiate/on_mob_metabolize(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	random_span = pick("clown", "small", "big", "hypnophrase", "alien", "cult", "alert", "danger", "emote", "yell", "brass", "sans", "papyrus", "robot", "his_grace", "phobia")
	RegisterSignal(affected_mob, COMSIG_MOVABLE_HEAR, PROC_REF(owner_hear))
	to_chat(affected_mob, span_warning("Your hearing seems to be a bit off[affected_mob.can_hear() ? "!" : " - wait, that's normal."]"))

/datum/reagent/impurity/inacusiate/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	UnregisterSignal(affected_mob, COMSIG_MOVABLE_HEAR)
	to_chat(affected_mob, span_notice("You start hearing things normally again[affected_mob.can_hear() ? "" : " - no, wait, no you don't"]."))

/datum/reagent/impurity/inacusiate/proc/owner_hear(mob/living/owner, list/hearing_args)
	SIGNAL_HANDLER

	// don't skip messages that the owner says or can't understand (since they still make sounds)
	if(!owner.can_hear())
		return
	// not technically hearing
	var/atom/movable/speaker = hearing_args[HEARING_SPEAKER]
	if(!isnull(speaker) && HAS_TRAIT(speaker, TRAIT_SIGN_LANG))
		return

	var/list/spans = hearing_args[HEARING_SPANS]
	var/list/copied_spans = spans.Copy()
	copied_spans |= random_span
	hearing_args[HEARING_SPANS] = copied_spans

/datum/reagent/inverse/sal_acid
	name = "Benzoic Acid"
	description = "Robust fertilizer that provides a decent range of benefits for plant life."
	taste_description = "flowers"
	color = "#e6c843"
	ph = 3.4
	tox_damage = 0

/datum/reagent/inverse/sal_acid/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume * 0.5))
	mytray.myseed?.adjust_production(-round(volume * 0.2))
	mytray.myseed?.adjust_potency(round(volume * 0.25))
	mytray.myseed?.adjust_yield(round(volume * 0.2))

/datum/reagent/inverse/oxandrolone
	name = "Oxymetholone"
	description = "Anabolic steroid that promotes the growth of muscle during and after exercise."
	color = "#520c23"
	taste_description = "sweat"
	metabolization_rate = 0.4 * REM
	overdose_threshold = 25
	ph = 12.2
	tox_damage = 0

/datum/reagent/inverse/oxandrolone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/high_message = pick("You feel unstoppable.", "Giving it EVERYTHING!!", "You feel ready for anything.", "You feel like doing a thousand jumping jacks!")
	if(SPT_PROB(2, seconds_per_tick))
		to_chat(affected_mob, span_notice("[high_message]"))

/datum/reagent/inverse/oxandrolone/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(25, seconds_per_tick))
		affected_mob.adjust_bodytemperature(30 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)
		affected_mob.set_jitter_if_lower(3 SECONDS)
		affected_mob.adjustStaminaLoss(5 * REM * seconds_per_tick)
	else if(SPT_PROB(5, seconds_per_tick))
		affected_mob.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 0, distance = 3)
		affected_mob.Paralyze(3 SECONDS)

/datum/reagent/inverse/salbutamol
	name = "Bamethan"
	description = "Blood thinner that drastically increases the chance of receiving bleeding wounds."
	color = "#ecd4d6"
	taste_description = "paint thinner"
	ph = 4.5
	metabolization_rate = 0.08 * REM
	tox_damage = 0
	metabolized_traits = list(TRAIT_EASYBLEED)

/datum/reagent/inverse/pen_acid
	name = "Pendetide"
	description = "Purges basic toxin healing medications and increases the severity of radiation poisoning."
	color = "#09ff00"
	ph = 3.7
	taste_description = "venom"
	metabolization_rate = 0.25 * REM
	tox_damage = 0

/datum/reagent/inverse/pen_acid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	holder.remove_reagent(/datum/reagent/medicine/c2/seiver, 5 * REM * seconds_per_tick)
	holder.remove_reagent(/datum/reagent/medicine/potass_iodide, 5 * REM * seconds_per_tick)
	holder.remove_reagent(/datum/reagent/medicine/c2/multiver, 5 * REM * seconds_per_tick)

	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
		affected_mob.set_jitter_if_lower(10 SECONDS)
		affected_mob.adjust_disgust(3 * REM * seconds_per_tick)
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(affected_mob, span_warning("A horrible ache spreads in your insides!"))
			affected_mob.adjust_confusion_up_to(10 SECONDS, 15 SECONDS)

/datum/reagent/inverse/atropine
	name = "Hyoscyamine"
	description = "Slowly regenerates all damaged organs, but cannot restore non-functional organs."
	color = "#273333"
	ph = 13.6
	metabolization_rate = 0.2 * REM
	tox_damage = 0
	overdose_threshold = 40

/datum/reagent/inverse/atropine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_STOMACH, -1 * REM * seconds_per_tick)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, -1 * REM * seconds_per_tick)
	if(affected_mob.getToxLoss() <= 25)
		need_mob_update = affected_mob.adjustToxLoss(-0.5, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/inverse/atropine/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/static/list/possible_organs = list(
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_TONGUE,
	)
	affected_mob.adjustOrganLoss(pick(possible_organs) ,2 * seconds_per_tick)
	affected_mob.reagents.remove_reagent(type, 1 * REM * seconds_per_tick)

/datum/reagent/inverse/ammoniated_mercury
	name = "Ammoniated Sludge"
	description = "A ghastly looking mess of mercury by-product. Causes bursts of manic hysteria."
	color = "#353535"
	ph = 10.2
	metabolization_rate = 0.4 * REM
	tox_damage = 0

/datum/reagent/inverse/ammoniated_mercury/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(7.5, seconds_per_tick))
		affected_mob.emote("scream")
		affected_mob.say(pick("AAAAAAAHHHHH!!","OOOOH NOOOOOO!!","GGGUUUUHHHHH!!","AIIIIIEEEEEE!!","HAHAHAHAHAAAAAA!!","OORRRGGGHHH!!","AAAAAAAJJJJJJJJJ!!"), forced = type)

/datum/reagent/inverse/rezadone
	name = "Inreziniver"
	description = "Makes the user horribly afraid of all things related to fish."
	color = "#c92eb4"
	ph = 13.9
	metabolization_rate = 0.05 * REM
	tox_damage = 0

/datum/reagent/inverse/rezadone/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.gain_trauma(/datum/brain_trauma/mild/phobia/fish, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/inverse/rezadone/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.cure_trauma_type(/datum/brain_trauma/mild/phobia/fish, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
