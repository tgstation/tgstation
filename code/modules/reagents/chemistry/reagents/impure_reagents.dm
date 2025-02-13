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
* is processed on the dead.
*/
/atom/movable/screen/alert/status_effect/freon/cryostylane
	desc = "You're frozen inside of a protective ice cube! While inside, you can't do anything, but are immune to harm! You will be free when the chem runs out."

/datum/reagent/inverse/cryostylane
	name = "Cryogelidia"
	description = "Freezes the live or dead patient in a cryostasis ice block."
	color = "#03dbfc"
	taste_description = "your tongue freezing, shortly followed by your thoughts. Brr!"
	ph = 14
	chemical_flags = REAGENT_DEAD_PROCESS | REAGENT_IGNORE_STASIS | REAGENT_DONOTSPLIT
	metabolization_rate = 1 * REM
	///The cube we're stasis'd in
	var/obj/structure/ice_stasis/cube
	var/atom/movable/screen/alert/status_effect/freon/cryostylane_alert

/datum/reagent/inverse/cryostylane/on_mob_add(mob/living/carbon/affected_mob, amount)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_RESISTCOLD))
		holder.remove_reagent(type, volume)
		return
	cube = new /obj/structure/ice_stasis(get_turf(affected_mob))
	cube.color = COLOR_CYAN
	cube.set_anchored(TRUE)
	affected_mob.forceMove(cube)
	affected_mob.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_CHEMICAL_EFFECT)
	cryostylane_alert = affected_mob.throw_alert("cryostylane_alert", /atom/movable/screen/alert/status_effect/freon/cryostylane)
	cryostylane_alert.attached_effect = src //so the alert can reference us, if it needs to

/datum/reagent/inverse/cryostylane/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!cube || affected_mob.loc != cube)
		metabolization_rate += 0.01

/datum/reagent/inverse/cryostylane/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(current_cycle >= 60)
		holder.remove_reagent(type, volume) // remove it all if we're past 60 cycles
		return
	return ..()

/datum/reagent/inverse/cryostylane/on_mob_delete(mob/living/carbon/affected_mob, amount)
	. = ..()
	QDEL_NULL(cube)
	if(!iscarbon(affected_mob))
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_CHEMICAL_EFFECT)
	carbon_mob.clear_alert("cryostylane_alert")
