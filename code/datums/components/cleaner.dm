/**
 * Component that can be used to clean things.
 * Takes care of duration, cleaning skill and special cleaning interactions.
 * A callback can be set by the datum holding the cleaner to add custom functionality.
 * Soap uses a callback to decrease the amount of uses it has left after cleaning for example.
 */
/datum/component/cleaner
	/// The time it takes to clean something, without reductions from the cleaning skill modifier.
	var/base_cleaning_duration
	/// Offsets the cleaning duration modifier that you get from your cleaning skill, the duration won't be modified to be more than the base duration.
	var/skill_duration_modifier_offset
	/// Determines what this cleaner can wash off, [the available options are found here](code/__DEFINES/cleaning.html).
	var/cleaning_strength
	/// Gets called before you start cleaning, returns TRUE/FALSE whether the clean should actually wash tiles, or DO_NOT_CLEAN to not clean at all.
	var/datum/callback/pre_clean_callback
	/// Gets called when something is successfully cleaned.
	var/datum/callback/on_cleaned_callback

/datum/component/cleaner/Initialize(
	base_cleaning_duration = 3 SECONDS,
	skill_duration_modifier_offset = 0,
	cleaning_strength = CLEAN_SCRUB,
	datum/callback/pre_clean_callback = null,
	datum/callback/on_cleaned_callback = null,
)
	src.base_cleaning_duration = base_cleaning_duration
	src.skill_duration_modifier_offset = skill_duration_modifier_offset
	src.cleaning_strength = cleaning_strength
	src.pre_clean_callback = pre_clean_callback
	src.on_cleaned_callback = on_cleaned_callback

/datum/component/cleaner/Destroy(force)
	pre_clean_callback = null
	on_cleaned_callback = null
	return ..()

/datum/component/cleaner/RegisterWithParent()
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_interaction))

/datum/component/cleaner/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
		COMSIG_LIVING_UNARMED_ATTACK,
	))

/**
 * Handles the COMSIG_LIVING_UNARMED_ATTACK signal used for cleanbots
 * Redirects to afterattack, while setting parent (the bot) as user.
 */
/datum/component/cleaner/proc/on_unarmed_attack(datum/source, atom/target, proximity_flags, modifiers)
	SIGNAL_HANDLER
	if(on_interaction(source, source, target, modifiers) & ITEM_INTERACT_ANY_BLOCKER)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/**
 * Handles the COMSIG_ITEM_INTERACTING_WITH_ATOM signal by calling the clean proc.
 */
/datum/component/cleaner/proc/on_interaction(datum/source, mob/living/user, atom/target, list/modifiers)
	SIGNAL_HANDLER

	if(isitem(source) && SHOULD_SKIP_INTERACTION(target, source, user))
		return NONE

	// By default, give XP
	var/give_xp = TRUE
	if(pre_clean_callback)
		var/callback_return = pre_clean_callback.Invoke(source, target, user)
		if(callback_return & CLEAN_BLOCKED)
			return (callback_return & CLEAN_DONT_BLOCK_INTERACTION) ? NONE : ITEM_INTERACT_BLOCKING
		if(callback_return & CLEAN_NO_XP)
			give_xp = FALSE

	INVOKE_ASYNC(src, PROC_REF(clean), source, target, user, give_xp)
	return ITEM_INTERACT_SUCCESS

/**
 * Cleans something using this cleaner.
 * The cleaning duration is modified by the cleaning skill of the user.
 * Successfully cleaning gives cleaning experience to the user and invokes the on_cleaned_callback.
 *
 * Arguments
 * * source the datum that sent the signal to start cleaning
 * * target the thing being cleaned
 * * user the person doing the cleaning
 * * clean_target set this to false if the target should not be washed and if experience should not be awarded to the user
 */
/datum/component/cleaner/proc/clean(datum/source, atom/target, mob/living/user, clean_target = TRUE)
	//make sure we don't attempt to clean something while it's already being cleaned
	if(HAS_TRAIT(target, TRAIT_CURRENTLY_CLEANING) || (SEND_SIGNAL(target, COMSIG_ATOM_PRE_CLEAN, user) & COMSIG_ATOM_CANCEL_CLEAN))
		return
	//add the trait and overlay
	ADD_TRAIT(target, TRAIT_CURRENTLY_CLEANING, REF(src))
	// We need to update our planes on overlay changes
	RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(cleaning_target_moved))
	var/mutable_appearance/low_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", CLEANABLE_OBJECT_LAYER, target, GAME_PLANE)
	var/mutable_appearance/high_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", CLEANABLE_OBJECT_LAYER, target, ABOVE_GAME_PLANE)
	var/list/icon_offsets = target.get_oversized_icon_offsets()
	low_bubble.pixel_w = icon_offsets["x"]
	low_bubble.pixel_z = icon_offsets["y"]
	high_bubble.pixel_w = icon_offsets["x"]
	high_bubble.pixel_z = icon_offsets["y"]
	if(target.plane > low_bubble.plane) //check if the higher overlay is necessary
		target.add_overlay(high_bubble)
	else if(target.plane == low_bubble.plane)
		if(target.layer > low_bubble.layer)
			target.add_overlay(high_bubble)
		else
			target.add_overlay(low_bubble)
	else //(target.plane < low_bubble.plane)
		target.add_overlay(low_bubble)

	//set the cleaning duration
	var/cleaning_duration = base_cleaning_duration
	if(user.mind) //higher cleaning skill can make the duration shorter
		//offsets the multiplier you get from cleaning skill, but doesn't allow the duration to be longer than the base duration
		cleaning_duration = (cleaning_duration * min(user.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER)+skill_duration_modifier_offset, 1))
	// Assoc list, collects all items being cleaned with its value being any blood on it
	var/list/all_cleaned = list()
	all_cleaned[target] = GET_ATOM_BLOOD_DNA(target) || list()
	//do the cleaning
	var/clean_succeeded = FALSE
	if(do_after(user, cleaning_duration, target = target))
		clean_succeeded = TRUE
		if(clean_target)
			for(var/obj/effect/decal/cleanable/cleanable_decal in target) //it's important to do this before you wash all of the cleanables off
				user.mind?.adjust_experience(/datum/skill/cleaning, round(cleanable_decal.beauty / CLEAN_SKILL_BEAUTY_ADJUSTMENT))
				all_cleaned[cleanable_decal] = GET_ATOM_BLOOD_DNA(cleanable_decal)
			if(target.wash(cleaning_strength))
				user.mind?.adjust_experience(/datum/skill/cleaning, round(CLEAN_SKILL_GENERIC_WASH_XP))

	on_cleaned_callback?.Invoke(source, target, user, clean_succeeded, all_cleaned)
	//remove the cleaning overlay
	target.cut_overlay(low_bubble)
	target.cut_overlay(high_bubble)
	UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)
	REMOVE_TRAIT(target, TRAIT_CURRENTLY_CLEANING, REF(src))

/datum/component/cleaner/proc/cleaning_target_moved(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	if(same_z_layer)
		return
	// First, get rid of the old overlay
	var/mutable_appearance/old_low_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", CLEANABLE_OBJECT_LAYER, old_turf, GAME_PLANE)
	var/mutable_appearance/old_high_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", CLEANABLE_OBJECT_LAYER, old_turf, ABOVE_GAME_PLANE)
	source.cut_overlay(old_low_bubble)
	source.cut_overlay(old_high_bubble)

	// Now, add the new one
	var/mutable_appearance/new_low_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", CLEANABLE_OBJECT_LAYER, new_turf, GAME_PLANE)
	var/mutable_appearance/new_high_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", CLEANABLE_OBJECT_LAYER, new_turf, ABOVE_GAME_PLANE)
	source.add_overlay(new_low_bubble)
	source.add_overlay(new_high_bubble)
