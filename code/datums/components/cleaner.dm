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

/datum/component/cleaner/Destroy(force, silent)
	pre_clean_callback = null
	on_cleaned_callback = null
	return ..()

/datum/component/cleaner/RegisterWithParent()
	if(isbot(parent))
		RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
		return
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/component/cleaner/UnregisterFromParent()
	if(isbot(parent))
		UnregisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK)
		return
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)

/**
 * Handles the COMSIG_LIVING_UNARMED_ATTACK signal used for cleanbots
 * Redirects to afterattack, while setting parent (the bot) as user.
 */
/datum/component/cleaner/proc/on_unarmed_attack(datum/source, atom/target, proximity_flags, modifiers)
	SIGNAL_HANDLER
	return on_afterattack(source, target, parent, proximity_flags, modifiers)

/**
 * Handles the COMSIG_ITEM_AFTERATTACK signal by calling the clean proc.
 *
 * Arguments
 * * source the datum that sent the signal to start cleaning
 * * target the thing being cleaned
 * * user the person doing the cleaning
 * * clean_target set this to false if the target should not be washed and if experience should not be awarded to the user
 */
/datum/component/cleaner/proc/on_afterattack(datum/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return
	. |= COMPONENT_AFTERATTACK_PROCESSED_ITEM
	var/clean_target
	if(pre_clean_callback)
		clean_target = pre_clean_callback?.Invoke(source, target, user)
		if(clean_target == DO_NOT_CLEAN)
			return .
	INVOKE_ASYNC(src, PROC_REF(clean), source, target, user, clean_target) //signal handlers can't have do_afters inside of them
	return .

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
	if(HAS_TRAIT(target, TRAIT_CURRENTLY_CLEANING))
		return

	//add the trait and overlay
	ADD_TRAIT(target, TRAIT_CURRENTLY_CLEANING, REF(src))
	// We need to update our planes on overlay changes
	RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(cleaning_target_moved))
	var/mutable_appearance/low_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", FLOOR_CLEAN_LAYER, target, GAME_PLANE)
	var/mutable_appearance/high_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", FLOOR_CLEAN_LAYER, target, ABOVE_GAME_PLANE)
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

	//do the cleaning
	if(do_after(user, cleaning_duration, target = target))
		if(clean_target)
			for(var/obj/effect/decal/cleanable/cleanable_decal in target) //it's important to do this before you wash all of the cleanables off
				user.mind?.adjust_experience(/datum/skill/cleaning, round(cleanable_decal.beauty / CLEAN_SKILL_BEAUTY_ADJUSTMENT))
			if(target.wash(cleaning_strength))
				user.mind?.adjust_experience(/datum/skill/cleaning, round(CLEAN_SKILL_GENERIC_WASH_XP))
		on_cleaned_callback?.Invoke(source, target, user)

	//remove the cleaning overlay
	target.cut_overlay(low_bubble)
	target.cut_overlay(high_bubble)
	UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)
	REMOVE_TRAIT(target, TRAIT_CURRENTLY_CLEANING, REF(src))

/datum/component/cleaner/proc/cleaning_target_moved(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	if(same_z_layer)
		return
	// First, get rid of the old overlay
	var/mutable_appearance/old_low_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", FLOOR_CLEAN_LAYER, old_turf, GAME_PLANE)
	var/mutable_appearance/old_high_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", FLOOR_CLEAN_LAYER, old_turf, ABOVE_GAME_PLANE)
	source.cut_overlay(old_low_bubble)
	source.cut_overlay(old_high_bubble)

	// Now, add the new one
	var/mutable_appearance/new_low_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", FLOOR_CLEAN_LAYER, new_turf, GAME_PLANE)
	var/mutable_appearance/new_high_bubble = mutable_appearance('icons/effects/effects.dmi', "bubbles", FLOOR_CLEAN_LAYER, new_turf, ABOVE_GAME_PLANE)
	source.add_overlay(new_low_bubble)
	source.add_overlay(new_high_bubble)
