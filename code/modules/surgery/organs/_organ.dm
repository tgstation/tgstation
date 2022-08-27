
/obj/item/organ
	name = "organ"
	icon = 'icons/obj/medical/surgery.dmi'
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	///The mob that owns this organ.
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	///The body zone this organ is supposed to inhabit.
	var/zone = BODY_ZONE_CHEST
	///The organ slot this organ is supposed to inhabit. This should be unique by type. (Lungs, Appendix, Stomach, etc)
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/organ_flags = ORGAN_EDIBLE
	var/maxHealth = STANDARD_ORGAN_THRESHOLD
	/// Total damage this organ has sustained
	/// Should only ever be modified by applyOrganDamage
	var/damage = 0
	///Healing factor and decay factor function on % of maxhealth, and do not work by applying a static number per tick
	var/healing_factor = 0 //fraction of maxhealth healed per on_life(), set to 0 for generic organs
	var/decay_factor = 0 //same as above but when without a living owner, set to 0 for generic organs
	var/high_threshold = STANDARD_ORGAN_THRESHOLD * 0.45 //when severe organ damage occurs
	var/low_threshold = STANDARD_ORGAN_THRESHOLD * 0.1 //when minor organ damage occurs
	var/severe_cooldown //cooldown for severe effects, used for synthetic organ emp effects.
	///Organ variables for determining what we alert the owner with when they pass/clear the damage thresholds
	var/prev_damage = 0
	var/low_threshold_passed
	var/high_threshold_passed
	var/now_failing
	var/now_fixed
	var/high_threshold_cleared
	var/low_threshold_cleared

	///When you take a bite you cant jam it in for surgery anymore.
	var/useable = TRUE
	var/list/food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	///The size of the reagent container
	var/reagent_vol = 10

	var/failure_time = 0
	///Do we effect the appearance of our mob. Used to save time in preference code
	var/visual = TRUE
	/// Traits that are given to the holder of the organ.
	var/list/organ_traits = list()

// Players can look at prefs before atoms SS init, and without this
// they would not be able to see external organs, such as moth wings.
// This is also necessary because assets SS is before atoms, and so
// any nonhumans created in that time would experience the same effect.
INITIALIZE_IMMEDIATE(/obj/item/organ)

/obj/item/organ/Initialize(mapload)
	. = ..()
	if(organ_flags & ORGAN_EDIBLE)
		AddComponent(/datum/component/edible,\
			initial_reagents = food_reagents,\
			foodtypes = RAW | MEAT | GORE,\
			volume = reagent_vol,\
			after_eat = CALLBACK(src, .proc/OnEatFrom))

/obj/item/organ/forceMove(atom/destination, check_dest = TRUE)
	if(check_dest && destination) //Nullspace is always a valid location for organs. Because reasons.
		if(organ_flags & ORGAN_UNREMOVABLE) //If this organ is unremovable, it should delete itself if it tries to be moved to anything besides a bodypart.
			if(!isbodypart(destination) && !iscarbon(destination))
				qdel(src)
				return //Don't move it out of nullspace if it's deleted.
	return ..()

/*
 * Insert the organ into the select mob.
 *
 * reciever - the mob who will get our organ
 * special - "quick swapping" an organ out - when TRUE, the mob will be unaffected by not having that organ for the moment
 * drop_if_replaced - if there's an organ in the slot already, whether we drop it afterwards
 */
/obj/item/organ/proc/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	if(!iscarbon(reciever) || owner == reciever)
		return FALSE

	var/obj/item/organ/replaced = reciever.getorganslot(slot)
	if(replaced)
		replaced.Remove(reciever, special = TRUE)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(reciever))
		else
			qdel(replaced)

	SEND_SIGNAL(src, COMSIG_ORGAN_IMPLANTED, reciever)
	SEND_SIGNAL(reciever, COMSIG_CARBON_GAIN_ORGAN, src, special)

	owner = reciever
	moveToNullspace()
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/on_owner_examine)
	for(var/datum/action/action as anything in actions)
		action.Grant(reciever)
	for(var/trait in organ_traits)
		ADD_TRAIT(reciever, trait, REF(src))
	return TRUE


/*
 * Remove the organ from the select mob.
 *
 * organ_owner - the mob who owns our organ, that we're removing the organ from.
 * special - "quick swapping" an organ out - when TRUE, the mob will be unaffected by not having that organ for the moment
 */
/obj/item/organ/proc/Remove(mob/living/carbon/organ_owner, special = FALSE)

	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)

	owner = null
	for(var/datum/action/action as anything in actions)
		action.Remove(organ_owner)
	for(var/trait in organ_traits)
		REMOVE_TRAIT(organ_owner, trait, REF(src))

	SEND_SIGNAL(src, COMSIG_ORGAN_REMOVED, organ_owner)
	SEND_SIGNAL(organ_owner, COMSIG_CARBON_LOSE_ORGAN, src, special)


/obj/item/organ/proc/on_owner_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	return

/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/process(delta_time, times_fired)
	return

/obj/item/organ/proc/on_death(delta_time, times_fired)
	return

/obj/item/organ/proc/on_life(delta_time, times_fired)
	CRASH("Oh god oh fuck something is calling parent organ life")

/obj/item/organ/examine(mob/user)
	. = ..()

	. += span_notice("It should be inserted in the [parse_zone(zone)].")

	if(organ_flags & ORGAN_FAILING)
		if(status == ORGAN_ROBOTIC)
			. += span_warning("[src] seems to be broken.")
			return
		. += span_warning("[src] has decayed for too long, and has turned a sickly color. It probably won't work without repairs.")
		return

	if(damage > high_threshold)
		. += span_warning("[src] is starting to look discolored.")

///Used as callbacks by object pooling
/obj/item/organ/proc/exit_wardrobe()
	return

//See above
/obj/item/organ/proc/enter_wardrobe()
	return

/obj/item/organ/proc/OnEatFrom(eater, feeder)
	useable = FALSE //You can't use it anymore after eating it you spaztic

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

///Adjusts an organ's damage by the amount "damage_amount", up to a maximum amount, which is by default max damage
/obj/item/organ/proc/applyOrganDamage(damage_amount, maximum = maxHealth) //use for damaging effects
	if(!damage_amount) //Micro-optimization.
		return
	if(maximum < damage)
		return
	damage = clamp(damage + damage_amount, 0, maximum)
	var/mess = check_damage_thresholds(owner)
	check_failing_thresholds()
	prev_damage = damage
	if(mess && owner && owner.stat <= SOFT_CRIT)
		to_chat(owner, mess)

///SETS an organ's damage to the amount "damage_amount", and in doing so clears or sets the failing flag, good for when you have an effect that should fix an organ if broken
/obj/item/organ/proc/setOrganDamage(damage_amount) //use mostly for admin heals
	applyOrganDamage(damage_amount - damage)

/** check_damage_thresholds
 * input: mob/organ_owner (a mob, the owner of the organ we call the proc on)
 * output: returns a message should get displayed.
 * description: By checking our current damage against our previous damage, we can decide whether we've passed an organ threshold.
 *  If we have, send the corresponding threshold message to the owner, if such a message exists.
 */
/obj/item/organ/proc/check_damage_thresholds(mob/organ_owner)
	if(damage == prev_damage)
		return
	var/delta = damage - prev_damage
	if(delta > 0)
		if(damage >= maxHealth)
			return now_failing
		if(damage > high_threshold && prev_damage <= high_threshold)
			return high_threshold_passed
		if(damage > low_threshold && prev_damage <= low_threshold)
			return low_threshold_passed
	else
		if(prev_damage > low_threshold && damage <= low_threshold)
			return low_threshold_cleared
		if(prev_damage > high_threshold && damage <= high_threshold)
			return high_threshold_cleared
		if(prev_damage == maxHealth)
			return now_fixed

///Checks if an organ should/shouldn't be failing and gives the appropriate organ flag
/obj/item/organ/proc/check_failing_thresholds()
	if(damage >= maxHealth)
		organ_flags |= ORGAN_FAILING
	if(damage < maxHealth)
		organ_flags &= ~ORGAN_FAILING

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/mob/living/proc/regenerate_organs()
	return FALSE

/mob/living/carbon/regenerate_organs()
	if(dna?.species)
		dna.species.regenerate_organs(src)
		return

	else
		var/obj/item/organ/internal/lungs/lungs = getorganslot(ORGAN_SLOT_LUNGS)
		if(!lungs)
			lungs = new()
			lungs.Insert(src)
		lungs.setOrganDamage(0)

		var/obj/item/organ/internal/heart/heart = getorganslot(ORGAN_SLOT_HEART)
		if(!heart)
			heart = new()
			heart.Insert(src)
		heart.setOrganDamage(0)

		var/obj/item/organ/internal/tongue/tongue = getorganslot(ORGAN_SLOT_TONGUE)
		if(!tongue)
			tongue = new()
			tongue.Insert(src)
		tongue.setOrganDamage(0)

		var/obj/item/organ/internal/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
		if(!eyes)
			eyes = new()
			eyes.Insert(src)
		eyes.setOrganDamage(0)

		var/obj/item/organ/internal/ears/ears = getorganslot(ORGAN_SLOT_EARS)
		if(!ears)
			ears = new()
			ears.Insert(src)
		ears.setOrganDamage(0)

/obj/item/organ/proc/handle_failing_organs(delta_time)
	return

/** organ_failure
 * generic proc for handling dying organs
 *
 * Arguments:
 * delta_time - seconds since last tick
 */
/obj/item/organ/proc/organ_failure(delta_time)
	return

/** get_availability
 * returns whether the species should innately have this organ.
 *
 * regenerate organs works with generic organs, so we need to get whether it can accept certain organs just by what this returns.
 * This is set to return true or false, depending on if a species has a specific organless trait. stomach for example checks if the species has NOSTOMACH and return based on that.
 * Arguments:
 * owner_species - species, needed to return whether the species has an organ specific trait
 */
/obj/item/organ/proc/get_availability(datum/species/owner_species)
	return TRUE

/// Called before organs are replaced in regenerate_organs with new ones
/obj/item/organ/proc/before_organ_replacement(obj/item/organ/replacement)
	return

/// Called by medical scanners to get a simple summary of how healthy the organ is. Returns an empty string if things are fine.
/obj/item/organ/proc/get_status_text()
	var/status = ""
	if(owner.has_reagent(/datum/reagent/inverse/technetium))
		status = "<font color='#E42426'> organ is [round((damage/maxHealth)*100, 1)]% damaged.</font>"
	else if(organ_flags & ORGAN_FAILING)
		status = "<font color='#cc3333'>Non-Functional</font>"
	else if(damage > high_threshold)
		status = "<font color='#ff9933'>Severely Damaged</font>"
	else if (damage > low_threshold)
		status = "<font color='#ffcc33'>Mildly Damaged</font>"

	return status
