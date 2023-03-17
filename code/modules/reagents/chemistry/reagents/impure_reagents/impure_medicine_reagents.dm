//Reagents produced by metabolising/reacting fermichems inoptimally these specifically are for medicines
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
/datum/reagent/impurity/healing/medicine_failure/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	var/pick = pick("brute", "burn", "tox", "oxy")
	switch(pick)
		if("brute")
			owner.adjustBruteLoss(-0.5, required_bodytype = affected_bodytype)
		if("burn")
			owner.adjustFireLoss(-0.5, required_bodytype = affected_bodytype)
		if("tox")
			owner.adjustToxLoss(-0.5, required_biotype = affected_biotype)
		if("oxy")
			owner.adjustOxyLoss(-0.5, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	..()

// C2 medications
// Helbital
//Inverse:
/datum/reagent/inverse/helgrasp
	name = "Helgrasp"
	description = "This rare and forbidden concoction is thought to bring you closer to the grasp of the Norse goddess Hel."
	metabolization_rate = 1*REM //This is fast
	tox_damage = 0.25
	ph = 14
	//Compensates for delta_time lag by spawning multiple hands at the end
	var/lag_remainder = 0
	//Keeps track of the hand timer so we can cleanup on removal
	var/list/timer_ids

//Warns you about the impenting hands
/datum/reagent/inverse/helgrasp/on_mob_add(mob/living/L, amount)
	to_chat(L, span_hierophant("You hear laughter as malevolent hands apparate before you, eager to drag you down to hell...! Look out!"))
	playsound(L.loc, 'sound/chemistry/ahaha.ogg', 80, TRUE, -1) //Very obvious tell so people can be ready
	. = ..()

//Sends hands after you for your hubris
/*
How it works:
Standard delta_time for a reagent is 2s - and volume consumption is equal to the volume * delta_time.
In this chem, I want to consume 0.5u for 1 hand created (since 1*REM is 0.5) so on a single tick I create a hand and set up a callback for another one in 1s from now. But since delta time can vary, I want to be able to create more hands for when the delay is longer.

Initally I round delta_time to the nearest whole number, and take the part that I am rounding down from (i.e. the decimal numbers) and keep track of them. If the decimilised numbers go over 1, then the number is reduced down and an extra hand is created that tick.

Then I attempt to calculate the how many hands to created based off the current delta_time, since I can't know the delay to the next one it assumes the next will be in 2s.
I take the 2s interval period and divide it by the number of hands I want to make (i.e. the current delta_time) and I keep track of how many hands I'm creating (since I always create one on a tick, then I start at 1 hand). For each hand I then use this time value multiplied by the number of hands. Since we're spawning one now, and it checks to see if hands is less than, but not less than or equal to, delta_time, no hands will be created on the next expected tick.
Basically, we fill the time between now and 2s from now with hands based off the current lag.
*/
/datum/reagent/inverse/helgrasp/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	spawn_hands(owner)
	lag_remainder += delta_time - FLOOR(delta_time, 1)
	delta_time = FLOOR(delta_time, 1)
	if(lag_remainder >= 1)
		delta_time += 1
		lag_remainder -= 1
	var/hands = 1
	var/time = 2 / delta_time
	while(hands < delta_time) //we already made a hand now so start from 1
		LAZYADD(timer_ids, addtimer(CALLBACK(src, PROC_REF(spawn_hands), owner), (time*hands) SECONDS, TIMER_STOPPABLE)) //keep track of all the timers we set up
		hands += time
	return ..()

/datum/reagent/inverse/helgrasp/proc/spawn_hands(mob/living/carbon/owner)
	if(!owner && iscarbon(holder.my_atom))//Catch timer
		owner = holder.my_atom
	//Adapted from the end of the curse - but lasts a short time
	var/grab_dir = turn(owner.dir, pick(-90, 90, 180, 180)) //grab them from a random direction other than the one faced, favoring grabbing from behind
	var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 8)//Larger range so you have more time to dodge
	if(!spawn_turf)
		return
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, TRUE, -1)
	var/obj/projectile/curse_hand/hel/hand = new (spawn_turf)
	hand.preparePixelProjectile(owner, spawn_turf)
	if(QDELETED(hand)) //safety check if above fails - above has a stack trace if it does fail
		return
	hand.fire()

//At the end, we clear up any loose hanging timers just in case and spawn any remaining lag_remaining hands all at once.
/datum/reagent/inverse/helgrasp/on_mob_delete(mob/living/owner)
	var/hands = 0
	while(lag_remainder > hands)
		spawn_hands(owner)
		hands++
	for(var/id in timer_ids) // So that we can be certain that all timers are deleted at the end.
		deltimer(id)
	timer_ids.Cut()
	return ..()

/datum/reagent/inverse/helgrasp/heretic
	name = "Grasp of the Mansus"
	description = "The Hand of the Mansus is at your neck."
	metabolization_rate = 1 * REM
	tox_damage = 0

//libital
//Impure
//Simply reduces your alcohol tolerance, kinda simular to prohol
/datum/reagent/impurity/libitoil
	name = "Libitoil"
	description = "Temporarilly interferes a patient's ability to process alcohol."
	chemical_flags = REAGENT_DONOTSPLIT
	ph = 13.5
	liver_damage = 0.1
	addiction_types = list(/datum/addiction/medicine = 4)

/datum/reagent/impurity/libitoil/on_mob_add(mob/living/L, amount)
	. = ..()
	var/mob/living/carbon/consumer = L
	if(!consumer)
		return
	RegisterSignal(consumer, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(consumer, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/internal/liver/this_liver = consumer.getorganslot(ORGAN_SLOT_LIVER)
	this_liver.alcohol_tolerance *= 2

/datum/reagent/impurity/libitoil/proc/on_gained_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/liver))
		return
	var/obj/item/organ/internal/liver/this_liver = organ
	this_liver.alcohol_tolerance *= 2

/datum/reagent/impurity/libitoil/proc/on_removed_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/liver))
		return
	var/obj/item/organ/internal/liver/this_liver = organ
	this_liver.alcohol_tolerance /= 2

/datum/reagent/impurity/libitoil/on_mob_delete(mob/living/L)
	. = ..()
	var/mob/living/carbon/consumer = L
	UnregisterSignal(consumer, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(consumer, COMSIG_CARBON_GAIN_ORGAN)
	var/obj/item/organ/internal/liver/this_liver = consumer.getorganslot(ORGAN_SLOT_LIVER)
	if(!this_liver)
		return
	this_liver.alcohol_tolerance /= 2


//probital
/datum/reagent/impurity/probital_failed//Basically crashed out failed metafactor
	name = "Metabolic Inhibition Factor"
	description = "This enzyme catalyzes crashes the conversion of nutricious food into healing peptides."
	metabolization_rate = 0.0625  * REAGENTS_METABOLISM //slow metabolism rate so the patient can self heal with food even after the troph has metabolized away for amazing reagent efficency.
	reagent_state = SOLID
	color = "#b3ff00"
	overdose_threshold = 10
	ph = 1
	addiction_types = list(/datum/addiction/medicine = 5)
	liver_damage = 0

/datum/reagent/impurity/probital_failed/overdose_start(mob/living/carbon/M)
	metabolization_rate = 4  * REAGENTS_METABOLISM
	..()

/datum/reagent/peptides_failed
	name = "Prion Peptides"
	taste_description = "spearmint frosting"
	description = "These inhibitory peptides cause cellular damage and cost nutrition to the patient!"
	ph = 2.1

/datum/reagent/peptides_failed/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	owner.adjustCloneLoss(0.25 * delta_time)
	owner.adjust_nutrition(-5 * REAGENTS_METABOLISM * delta_time)
	. = ..()

//Lenturi
//impure
/datum/reagent/impurity/lentslurri //Okay maybe I should outsource names for these
	name = "Lentslurri"//This is a really bad name please replace
	description = "A highly addicitive muscle relaxant that is made when Lenturi reactions go wrong."
	addiction_types = list(/datum/addiction/medicine = 8)
	liver_damage = 0

/datum/reagent/impurity/lentslurri/on_mob_metabolize(mob/living/carbon/owner)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return ..()

/datum/reagent/impurity/lentslurri/on_mob_end_metabolize(mob/living/carbon/owner)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return ..()

//failed
/datum/reagent/inverse/ichiyuri
	name = "Ichiyuri"
	description = "Prolonged exposure to this chemical can cause an overwhelming urge to itch oneself."
	reagent_state = LIQUID
	color = "#C8A5DC"
	ph = 1.7
	addiction_types = list(/datum/addiction/medicine = 2.5)
	tox_damage = 0.1
	///Probability of scratch - increases as a function of time
	var/resetting_probability = 0
	///Prevents message spam
	var/spammer = 0

//Just the removed itching mechanism - omage to it's origins.
/datum/reagent/inverse/ichiyuri/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	if(prob(resetting_probability) && !(HAS_TRAIT(owner, TRAIT_RESTRAINED) || owner.incapacitated()))
		if(spammer < world.time)
			to_chat(owner,span_warning("You can't help but itch yourself."))
			spammer = world.time + (10 SECONDS)
		var/scab = rand(1,7)
		owner.adjustBruteLoss(scab*REM)
		owner.bleed(scab)
		resetting_probability = 0
	resetting_probability += (5*(current_cycle/10) * delta_time) // 10 iterations = >51% to itch
	..()
	return TRUE

//Aiuri
//impure
/datum/reagent/impurity/aiuri
	name = "Aivime"
	description = "This reagent is known to interfere with the eyesight of a patient."
	ph = 3.1
	addiction_types = list(/datum/addiction/medicine = 1.5)
	liver_damage = 0.1
	/// blurriness at the start of taking the med
	var/amount_of_blur_applied = 0 SECONDS

/datum/reagent/impurity/aiuri/on_mob_add(mob/living/owner, amount)
	. = ..()
	amount_of_blur_applied = creation_purity * (volume / metabolization_rate) * 2 SECONDS
	owner.adjust_eye_blur(amount_of_blur_applied)

/datum/reagent/impurity/aiuri/on_mob_delete(mob/living/owner, amount)
	. = ..()
	owner.adjust_eye_blur(-amount_of_blur_applied)

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

/datum/reagent/inverse/hercuri/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	. = ..()
	var/heating = rand(5, 25) * creation_purity * REM * delta_time
	owner.reagents?.chem_temp += heating
	owner.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human = owner
	human.adjust_coretemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)

/datum/reagent/inverse/hercuri/expose_mob(mob/living/carbon/exposed_mob, methods=VAPOR, reac_volume)
	. = ..()
	if(!(methods & VAPOR))
		return

	exposed_mob.adjust_bodytemperature(reac_volume * TEMPERATURE_DAMAGE_COEFFICIENT)
	exposed_mob.adjust_fire_stacks(reac_volume / 2)

/datum/reagent/inverse/hercuri/overdose_process(mob/living/carbon/owner, delta_time, times_fired)
	. = ..()
	owner.adjustOrganLoss(ORGAN_SLOT_LIVER, 2 * REM * delta_time, required_organtype = affected_organtype) //Makes it so you can't abuse it with pyroxadone very easily (liver dies from 25u unless it's fully upgraded)
	var/heating = 10 * creation_purity * REM * delta_time * TEMPERATURE_DAMAGE_COEFFICIENT
	owner.adjust_bodytemperature(heating) //hot hot
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
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
/datum/reagent/inverse/healing/tirimol/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	switch(current_cycle)
		if(1 to 10)//same delay as chloral hydrate
			if(prob(50))
				owner.emote("yawn")
		if(10 to INFINITY)
			owner.Sleeping(40)
			. = 1
			if(owner.IsSleeping())
				for(var/datum/reagent/reagent as anything in owner.reagents.reagent_list)
					if(reagent in cached_reagent_list)
						continue
					if(!istype(reagent, /datum/reagent/medicine))
						continue
					reagent.creation_purity *= 1.25
					cached_reagent_list += reagent

			else if(!owner.IsSleeping() && length(cached_reagent_list))
				for(var/datum/reagent/reagent as anything in cached_reagent_list)
					if(!reagent)
						continue
					reagent.creation_purity *= 0.8
				cached_reagent_list = list()
	..()

/datum/reagent/inverse/healing/tirimol/on_mob_delete(mob/living/owner)
	if(owner.IsSleeping())
		owner.visible_message(span_notice("[icon2html(owner, viewers(DEFAULT_MESSAGE_RANGE, src))] [owner] lets out a hearty snore!"))//small way of letting people know the supersnooze is ended
	for(var/datum/reagent/reagent as anything in cached_reagent_list)
		if(!reagent)
			continue
		reagent.creation_purity *= 0.8
	cached_reagent_list = list()
	..()

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

/datum/reagent/inverse/healing/convermol/on_mob_add(mob/living/owner, amount)
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/internal/lungs/lungs = owner.getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		return
	apply_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/on_gained_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/lungs))
		return
	var/obj/item/organ/internal/lungs/lungs = organ
	apply_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/apply_lung_levels(obj/item/organ/internal/lungs/lungs)
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
	if(!istype(organ, /obj/item/organ/internal/lungs))
		return
	var/obj/item/organ/internal/lungs/lungs = organ
	restore_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/restore_lung_levels(obj/item/organ/internal/lungs/lungs)
	lungs.heat_level_1_threshold = cached_heat_level_1
	lungs.heat_level_2_threshold = cached_heat_level_2
	lungs.heat_level_3_threshold = cached_heat_level_3
	lungs.cold_level_1_threshold = cached_cold_level_1
	lungs.cold_level_2_threshold = cached_cold_level_2
	lungs.cold_level_3_threshold = cached_cold_level_3

/datum/reagent/inverse/healing/convermol/on_mob_delete(mob/living/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN)
	var/obj/item/organ/internal/lungs/lungs = owner.getorganslot(ORGAN_SLOT_LUNGS)
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

/datum/reagent/inverse/technetium/on_mob_life(mob/living/carbon/owner, delta_time, times_fired)
	time_until_next_poison -= delta_time * (1 SECONDS)
	if (time_until_next_poison <= 0)
		time_until_next_poison = poison_interval
		owner.adjustToxLoss(creation_purity * 1, required_biotype = affected_biotype)

	..()

//Kind of a healing effect, Presumably you're using syrinver to purge so this helps that
/datum/reagent/inverse/healing/syriniver
	name = "Syrinifergus"
	description = "This reagent reduces the impurity of all non medicines within the patient, reducing their negative effects."
	self_consuming = TRUE //No pesky liver shenanigans
	chemical_flags = REAGENT_DONOTSPLIT | REAGENT_DEAD_PROCESS
	///The list of reagents we've affected
	var/cached_reagent_list = list()
	addiction_types = list(/datum/addiction/medicine = 1.75)

/datum/reagent/inverse/healing/syriniver/on_mob_add(mob/living/affected_mob)
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
/datum/reagent/inverse/healing/monover/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(length(affected_mob.reagents.reagent_list) > 1)
		affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5 * delta_time, required_organtype = affected_organtype) //Hey! It's everyone's favourite drawback from multiver!
		return ..()
	affected_mob.adjustToxLoss(-2 * REM * creation_purity * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	return TRUE

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
	///If we brought someone back from the dead
	var/back_from_the_dead = FALSE

/datum/reagent/inverse/penthrite/on_mob_dead(mob/living/carbon/affected_mob, delta_time)
	var/obj/item/organ/internal/heart/heart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		return ..()
	metabolization_rate = 0.2 * REM
	ADD_TRAIT(affected_mob, TRAIT_STABLEHEART, type)
	ADD_TRAIT(affected_mob, TRAIT_NOHARDCRIT, type)
	ADD_TRAIT(affected_mob, TRAIT_NOSOFTCRIT, type)
	ADD_TRAIT(affected_mob, TRAIT_NOCRITDAMAGE, type)
	ADD_TRAIT(affected_mob, TRAIT_NODEATH, type)
	ADD_TRAIT(affected_mob, TRAIT_NOCRITOVERLAY, type)
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
	affected_mob.playsound_local(affected_mob, 'sound/health/fastbeat.ogg', 65)
	..()

/datum/reagent/inverse/penthrite/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(!back_from_the_dead)
		return ..()
	//Following is for those brought back from the dead only
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	for(var/datum/wound/iter_wound as anything in affected_mob.all_wounds)
		iter_wound.adjust_blood_flow(1-creation_purity)
	affected_mob.adjustBruteLoss(5 * (1-creation_purity) * delta_time, required_bodytype = affected_bodytype)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, (1 + (1-creation_purity)) * delta_time, required_organtype = affected_organtype)
	if(affected_mob.health < HEALTH_THRESHOLD_CRIT)
		affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nooartrium)
	if(affected_mob.health < HEALTH_THRESHOLD_FULLCRIT)
		affected_mob.add_actionspeed_modifier(/datum/actionspeed_modifier/nooartrium)
	var/obj/item/organ/internal/heart/heart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		remove_buffs(affected_mob)
	..()

/datum/reagent/inverse/penthrite/on_mob_delete(mob/living/carbon/affected_mob)
	remove_buffs(affected_mob)
	var/obj/item/organ/internal/heart/heart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
	if(affected_mob.health < -500 || heart.organ_flags & ORGAN_FAILING)//Honestly commendable if you get -500
		explosion(affected_mob, light_impact_range = 1, explosion_cause = src)
		qdel(heart)
		affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))
	return ..()

/datum/reagent/inverse/penthrite/overdose_start(mob/living/carbon/affected_mob)
	if(!back_from_the_dead)
		return ..()
	var/obj/item/organ/internal/heart/heart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
	if(!heart) //No heart? No life!
		REMOVE_TRAIT(affected_mob, TRAIT_NODEATH, type)
		affected_mob.stat = DEAD
		return ..()
	explosion(affected_mob, light_impact_range = 1, explosion_cause = src)
	qdel(heart)
	affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))
	return..()

/datum/reagent/inverse/penthrite/proc/remove_buffs(mob/living/carbon/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_STABLEHEART, type)
	REMOVE_TRAIT(affected_mob, TRAIT_NOHARDCRIT, type)
	REMOVE_TRAIT(affected_mob, TRAIT_NOSOFTCRIT, type)
	REMOVE_TRAIT(affected_mob, TRAIT_NOCRITDAMAGE, type)
	REMOVE_TRAIT(affected_mob, TRAIT_NODEATH, type)
	REMOVE_TRAIT(affected_mob, TRAIT_NOCRITOVERLAY, type)
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

/datum/reagent/inverse/neurine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	.=..()
	if(temp_trauma)
		return
	if(!(DT_PROB(creation_purity*10, delta_time)))
		return
	var/traumalist = subtypesof(/datum/brain_trauma)
	var/list/forbiddentraumas = list(
		/datum/brain_trauma/severe/split_personality,  // Split personality uses a ghost, I don't want to use a ghost for a temp thing
		/datum/brain_trauma/special/obsessed, // Obsessed sets the owner as an antag - I presume this will lead to problems, so we'll remove it
		/datum/brain_trauma/hypnosis, // Hypnosis, same reason as obsessed, plus a bug makes it remain even after the neurowhine purges and then turn into "nothing" on the med reading upon a second application
		/datum/brain_trauma/special/honorbound, // Designed to be chaplain exclusive
	)
	traumalist -= forbiddentraumas
	var/obj/item/organ/internal/brain/brain = affected_mob.getorganslot(ORGAN_SLOT_BRAIN)
	traumalist = shuffle(traumalist)
	for(var/trauma in traumalist)
		if(brain.brain_gain_trauma(trauma, TRAUMA_RESILIENCE_MAGIC))
			temp_trauma = trauma
			return

/datum/reagent/inverse/neurine/on_mob_delete(mob/living/carbon/affected_mob)
	.=..()
	if(!temp_trauma)
		return
	if(istype(temp_trauma, /datum/brain_trauma/special/imaginary_friend))//Good friends stay by you, no matter what
		return
	affected_mob.cure_trauma_type(temp_trauma, resilience = TRAUMA_RESILIENCE_MAGIC)

/datum/reagent/inverse/corazargh
	name = "Corazargh" //It's what you yell! Though, if you've a better name feel free. Also an omage to an older chem
	description = "Interferes with the body's natural pacemaker, forcing the patient to manually beat their heart."
	color = "#5F5F5F"
	self_consuming = TRUE
	ph = 13.5
	addiction_types = list(/datum/addiction/medicine = 2.5)
	metabolization_rate = REM
	chemical_flags = REAGENT_DEAD_PROCESS
	tox_damage = 0
	///The old heart we're swapping for
	var/obj/item/organ/internal/heart/original_heart
	///The new heart that's temp added
	var/obj/item/organ/internal/heart/cursed/manual_heart

///Creates a new cursed heart and puts the old inside of it, then replaces the position of the old
/datum/reagent/inverse/corazargh/on_mob_metabolize(mob/living/affected_mob)
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	original_heart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
	if(!original_heart)
		return
	manual_heart = new(null, src)
	original_heart.Remove(carbon_mob, special = TRUE) //So we don't suddenly die
	original_heart.forceMove(manual_heart)
	original_heart.organ_flags |= ORGAN_FROZEN //Not actually frozen, but we want to pause decay
	manual_heart.Insert(carbon_mob, special = TRUE)
	//these last so instert doesn't call them
	RegisterSignal(carbon_mob, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(carbon_mob, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	to_chat(affected_mob, span_userdanger("You feel your heart suddenly stop beating on it's own - you'll have to manually beat it!"))
	..()

///Intercepts the new heart and creates a new cursed heart - putting the old inside of it
/datum/reagent/inverse/corazargh/proc/on_gained_organ(mob/affected_mob, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/heart))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	original_heart = organ
	original_heart.Remove(affected_carbon, special = TRUE)
	original_heart.forceMove(manual_heart)
	original_heart.organ_flags |= ORGAN_FROZEN //Not actually frozen, but we want to pause decay
	if(!manual_heart)
		manual_heart = new(null, src)
	manual_heart.Insert(affected_carbon, special = TRUE)

///If we're ejecting out the organ - replace it with the original
/datum/reagent/inverse/corazargh/proc/on_removed_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!organ == manual_heart)
		return
	original_heart.forceMove(organ.loc)
	original_heart.organ_flags &= ~ORGAN_FROZEN //enable decay again
	qdel(organ)

///We're done - remove the curse and restore the old one
/datum/reagent/inverse/corazargh/on_mob_end_metabolize(mob/living/affected_mob)
	//Do these first so Insert doesn't call them
	UnregisterSignal(affected_mob, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(affected_mob, COMSIG_CARBON_GAIN_ORGAN)
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(original_heart) //Mostly a just in case
		original_heart.organ_flags &= ~ORGAN_FROZEN //enable decay again
		original_heart.Insert(affected_carbon, special = TRUE)
	qdel(manual_heart)
	to_chat(affected_mob, span_userdanger("You feel your heart start beating normally again!"))
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

/datum/reagent/inverse/antihol/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	for(var/datum/reagent/consumable/ethanol/alcohol in C.reagents.reagent_list)
		alcohol.boozepwr += delta_time
	..()

/datum/reagent/inverse/oculine
	name = "Oculater"
	description = "Temporarily blinds the patient."
	reagent_state = LIQUID
	color = "#DDDDDD"
	metabolization_rate = 0.1 * REM
	addiction_types = list(/datum/addiction/medicine = 3)
	taste_description = "funky toxin"
	ph = 13
	tox_damage = 0
	metabolization_rate = 0.2 * REM
	///Did we get a headache?
	var/headache = FALSE

/datum/reagent/inverse/oculine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(headache)
		return ..()
	if(DT_PROB(100 * creation_purity, delta_time))
		affected_mob.become_blind(IMPURE_OCULINE)
		to_chat(affected_mob, span_danger("You suddenly develop a pounding headache as your vision fluxuates."))
		headache = TRUE
	..()

/datum/reagent/inverse/oculine/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.cure_blind(IMPURE_OCULINE)
	if(headache)
		to_chat(affected_mob, span_notice("Your headache clears up!"))
	..()

/datum/reagent/impurity/inacusiate
	name = "Tinacusiate"
	description = "Makes the patient's hearing temporarily funky."
	reagent_state = LIQUID
	addiction_types = list(/datum/addiction/medicine = 5.6)
	color = "#DDDDFF"
	taste_description = "the heat evaporating from your mouth."
	ph = 1
	liver_damage = 0.1
	metabolization_rate = 0.04 * REM
	///The random span we start hearing in
	var/randomSpan

/datum/reagent/impurity/inacusiate/on_mob_metabolize(mob/living/affected_mob, delta_time, times_fired)
	randomSpan = pick(list("clown", "small", "big", "hypnophrase", "alien", "cult", "alert", "danger", "emote", "yell", "brass", "sans", "papyrus", "robot", "his_grace", "phobia"))
	RegisterSignal(affected_mob, COMSIG_MOVABLE_HEAR, PROC_REF(owner_hear))
	to_chat(affected_mob, span_warning("Your hearing seems to be a bit off!"))
	..()

/datum/reagent/impurity/inacusiate/on_mob_end_metabolize(mob/living/affected_mob)
	UnregisterSignal(affected_mob, COMSIG_MOVABLE_HEAR)
	to_chat(affected_mob, span_notice("You start hearing things normally again."))
	..()

/datum/reagent/impurity/inacusiate/proc/owner_hear(mob/living/owner, list/hearing_args)
	SIGNAL_HANDLER

	// don't skip messages that the owner says or can't understand (since they still make sounds)
	if(!owner.can_hear())
		return

	hearing_args[HEARING_RAW_MESSAGE] = "<span class='[randomSpan]'>[hearing_args[HEARING_RAW_MESSAGE]]</span>"
