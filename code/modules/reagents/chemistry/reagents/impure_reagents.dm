//Reagents produced by metabolising/reacting fermichems suboptimally, i.e. inverse_chems or impure_chems
//Inverse = Splitting
//Invert = Whole conversion

//Causes slight liver damage, and that's it.
/datum/reagent/impurity
	name = "Chemical Isomers"
	description = "Impure chemical isomers made from suboptimal reactions. Causes mild liver damage"
	//by default, it will stay hidden on splitting, but take the name of the source on inverting. Cannot be fractioned down either if the reagent is somehow isolated.
	chemical_flags = REAGENT_SNEAKYNAME | REAGENT_DONOTSPLIT | REAGENT_CAN_BE_SYNTHESIZED //impure can be synthed, and is one of the only ways to get almost pure impure
	ph = 3
	inverse_chem = null
	inverse_chem_val = 0
	metabolization_rate = 0.1 * REM //default impurity is 0.75, so we get 25% converted. Default metabolisation rate is 0.4, so we're 4 times slower.
	var/liver_damage = 0.5

/datum/reagent/impurity/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	var/need_mob_update

	if(liver)//Though, lets be safe
		need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, liver_damage * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	else
		need_mob_update = affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)//Incase of no liver!

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

//Basically just so people don't forget to adjust metabolization_rate
/datum/reagent/inverse
	name = "Toxic Monomers"
	description = "Inverse reagents are created when a reagent's purity is below it's inverse threshold. The are created either during ingestion - which will then replace their associated reagent, or some can be created during the reaction process."
	ph = 2
	chemical_flags = REAGENT_SNEAKYNAME | REAGENT_DONOTSPLIT //Inverse generally cannot be synthed - they're difficult to get
	//Mostly to be safe - but above flags will take care of this. Also prevents it from showing these on reagent lookups in the ui
	inverse_chem = null
	///how much this reagent does for tox damage too
	var/tox_damage = 1


/datum/reagent/inverse/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(tox_damage * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

//Failed chems - generally use inverse if you want to use a impure subtype for it
//technically not a impure chem, but it's here because it can only be made with a failed impure reaction
/datum/reagent/consumable/failed_reaction
	name = "Viscous Sludge"
	description = "A off smelling sludge that's created when a reaction gets too impure."
	nutriment_factor = -1
	quality = -1
	ph = 1.5
	taste_description = "an awful, strongly chemical taste"
	color = "#270d03"
	glass_price = DRINK_PRICE_HIGH
	fallback_icon = 'icons/obj/drinks/drink_effects.dmi'
	fallback_icon_state = "failed_reaction_fallback"

// Unique

/datum/reagent/inverse/eigenswap
	name = "Eigenswap"
	description = "This reagent is known to swap the handedness of a patient."
	ph = 3.3
	chemical_flags = REAGENT_DONOTSPLIT
	tox_damage = 0

/datum/reagent/inverse/eigenswap/on_mob_life(mob/living/carbon/affected_mob)
	. = ..()
	if(!prob(creation_purity * 100))
		return
	var/list/cached_hand_items = affected_mob.held_items
	var/index = 1
	for(var/thing in cached_hand_items)
		index++
		if(index > length(cached_hand_items))//If we're past the end of the list, go back to start
			index = 1
		if(!thing)
			continue
		affected_mob.put_in_hand(thing, index, forced = TRUE, ignore_anim = TRUE)
		playsound(affected_mob, 'sound/effects/phasein.ogg', 20, TRUE)
/*
* Freezes the player in a block of ice, 1s = 1u
* Will be removed when the required reagent is removed too
* Does not work via INGEST method (pills, drinking)
* is processed on the dead.
*/

/datum/reagent/inverse/cryostylane
	name = "Cryogelidia"
	description = "Freezes the live or dead patient in a cryostasis ice block. Won't work if you drink it."
	color = "#03dbfc"
	taste_description = "your tongue freezing, shortly followed by your thoughts. Brr!"
	ph = 14
	chemical_flags = REAGENT_DEAD_PROCESS | REAGENT_IGNORE_STASIS | REAGENT_DONOTSPLIT | REAGENT_UNAFFECTED_BY_METABOLISM
	metabolization_rate = 1 * REM

/datum/reagent/inverse/cryostylane/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(HAS_TRAIT(exposed_mob, TRAIT_RESISTCOLD))
		holder.remove_reagent(type, volume)
		return
	if(!(methods & INGEST))
		exposed_mob.apply_status_effect(/datum/status_effect/frozenstasis/irresistable)
		if(!exposed_mob.has_status_effect(/datum/status_effect/grouped/stasis, STASIS_CHEMICAL_EFFECT))
			exposed_mob.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_CHEMICAL_EFFECT)

/datum/reagent/inverse/cryostylane/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!affected_mob.has_status_effect(/datum/status_effect/frozenstasis/irresistable))
		holder.remove_reagent(type, volume) // remove it all if we were broken out
		return
	metabolization_rate += 0.01 //speed up our metabolism over time. Chop chop.

/datum/reagent/inverse/cryostylane/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(current_cycle >= 60)
		holder.remove_reagent(type, volume) // remove it all if we're past 60 cycles
		return
	return ..()

/datum/reagent/inverse/cryostylane/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/frozenstasis/irresistable)
	affected_mob.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_CHEMICAL_EFFECT)

/datum/reagent/inverse/cryostylane/on_mob_delete(mob/living/affected_mob, amount)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/frozenstasis/irresistable)
	affected_mob.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_CHEMICAL_EFFECT)

/datum/reagent/inverse/condensedcapsaicin
	name = "Achoonium"
	description = "A strange poison that induces dangerously powerful sneezing."
	color = "#B37008"
	taste_description = "black pepper"
	penetrates_skin = TOUCH|VAPOR
	ph = 7.4
	tox_damage = 0
	chemical_flags = REAGENT_DONOTSPLIT

/datum/reagent/inverse/condensedcapsaicin/on_mob_add(mob/living/carbon/affected_mob)
	. = ..()
	to_chat(affected_mob, span_notice("Your nose itches."))
	affected_mob.emote("sneeze")
/datum/reagent/inverse/condensedcapsaicin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	switch(current_cycle)
		if(1 to 10)
			if(prob(33))
				affected_mob.emote("sneeze")
		if(10 to 21)
			if(prob(33))
				affected_mob.emote("sneeze")
				need_mob_update = affected_mob.adjustOxyLoss(5 * REM * seconds_per_tick, updating_health = FALSE)
				affected_mob.AdjustKnockdown(2 SECONDS)
				to_chat(affected_mob, span_warning("You sneeze violently, stumbling to the ground!"))
		if(21 to 29) //shamelessly copied from the cartoon sneezing effect since it's exactly what i was going for anyways
			if(prob(33))
				affected_mob.emote("sneeze")
				to_chat(affected_mob, span_userdanger("You are launched backwards by an all-mighty sneeze!"))
				var/sneeze_distance = rand(2,4)
				var/turf/target = get_ranged_target_turf(affected_mob, REVERSE_DIR(affected_mob.dir), sneeze_distance)
				affected_mob.throw_at(target, sneeze_distance, rand(1,5))
				need_mob_update = affected_mob.adjustOxyLoss(5 * REM * seconds_per_tick, updating_health = FALSE)
		if(29 to INFINITY)
			if(prob(33))
				affected_mob.emote("sneeze")
				to_chat(affected_mob, span_userdanger("You are launched violently backwards by an all-mighty sneeze!"))
				var/sneeze_distance = rand(3,5)
				var/turf/target = get_ranged_target_turf(affected_mob, REVERSE_DIR(affected_mob.dir), sneeze_distance)
				affected_mob.throw_at(target, sneeze_distance, rand(2,6))
				need_mob_update = affected_mob.adjustOxyLoss(10 * REM * seconds_per_tick, updating_health = FALSE)
				need_mob_update += affected_mob.adjustStaminaLoss(25 * REM * seconds_per_tick, updating_stamina = FALSE)
				if(prob(25) && affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS))
					var/obj/item/organ/lungs/breathybits = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
					to_chat(affected_mob, span_userdanger("Something mushy is expelled from your nose!"))
					var/turf/T = get_turf(affected_mob)
					breathybits.Remove(affected_mob)
					breathybits.forceMove(T)
					breathybits.throw_at(target, 5, 4, affected_mob)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH



