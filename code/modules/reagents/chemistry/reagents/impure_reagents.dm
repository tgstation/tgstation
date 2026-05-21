//Reagents produced by metabolising/reacting fermichems suboptimally, i.e. inverse_chems or impure_chems
//Inverse = Splitting
//Invert = Whole conversion

//Causes slight liver damage, and that's it.
/datum/reagent/impurity
	name = "Chemical Isomers"
	description = "Impure chemical isomers made from suboptimal reactions. Causes mild liver damage"
	//by default, it will stay hidden on splitting, but take the name of the source on inverting. Cannot be fractioned down either if the reagent is somehow isolated.
	chemical_flags = REAGENT_SNEAKYNAME | REAGENT_CAN_BE_SYNTHESIZED //impure can be synthed, and is one of the only ways to get almost pure impure
	ph = 3
	inverse_chem = null
	inverse_chem_val = 0
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	var/liver_damage = 0.5

/datum/reagent/impurity/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	var/need_mob_update

	if(liver)//Though, lets be safe
		need_mob_update = affected_mob.adjust_organ_loss(ORGAN_SLOT_LIVER, METABOLIZE_FREE_CONSTANT(0.5) * liver_damage * metabolization_ratio * seconds_per_tick, required_organ_flag = affected_organ_flags)
	else
		need_mob_update = affected_mob.adjust_tox_loss(1 * liver_damage * metabolization_ratio * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)//Incase of no liver!

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

//Basically just so people don't forget to adjust metabolization_rate
/datum/reagent/inverse
	name = "Toxic Monomers"
	description = "Inverse reagents are created when a reagent's purity is below it's inverse threshold. The are created either during ingestion - which will then replace their associated reagent, or some can be created during the reaction process."
	ph = 2
	chemical_flags = REAGENT_SNEAKYNAME //Inverse generally cannot be synthed - they're difficult to get
	//Mostly to be safe - but above flags will take care of this. Also prevents it from showing these on reagent lookups in the ui
	inverse_chem = null
	///how much this reagent does for tox damage too
	var/tox_damage = 1

/datum/reagent/inverse/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()

	if(affected_mob.adjust_tox_loss(METABOLIZE_FREE_CONSTANT(0.5) * tox_damage * metabolization_ratio * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
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
	chemical_flags = NONE
	tox_damage = 0

/datum/reagent/inverse/eigenswap/on_mob_life(mob/living/carbon/affected_mob, metabolization_ratio)
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
	chemical_flags = REAGENT_DEAD_PROCESS | REAGENT_IGNORE_STASIS | REAGENT_UNAFFECTED_BY_METABOLISM
	metabolization_rate = 2.5 * REAGENTS_METABOLISM

/datum/reagent/inverse/cryostylane/expose_mob(mob/living/carbon/human/human_thing, methods, reac_volume, show_message, touch_protection)
	. = ..()
	if((methods & INGEST) || !ishuman(human_thing))
		return

	if(HAS_TRAIT(human_thing, TRAIT_RESISTCOLD))
		holder.del_reagent(type)
		return

	human_thing.apply_status_effect(/datum/status_effect/reagent_effect/freeze, type)

/datum/reagent/inverse/cryostylane/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	metabolization_rate += 0.05 * REAGENTS_METABOLISM //speed up our metabolism over time. Chop chop.

/datum/reagent/inverse/cryostylane/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, metabolized_volume)
	if(current_cycle >= 60)
		volume = 0 // remove it all if we're past 60 cycles
		holder.update_total()
		return

	return ..()

/datum/reagent/inverse/cryostylane/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/reagent_effect/freeze)
