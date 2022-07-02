/**
 * Can be used to clean things.
 * Takes care of duration, cleaning skill and special cleaning interactions.
 * A callback can be set by the datum holding the cleaner to add custom functionality.
 * Soap uses a callback to decrease the amount of uses it has left after cleaning for example.
 */
/datum/cleaner
	/// Gets called when something is successfully cleaned.
	var/datum/callback/on_cleaned_callback
	/// The time it takes to clean something, without reductions from the cleaning skill modifier.
	var/base_cleaning_duration = 3 SECONDS
	/// Offsets the cleaning duration modifier that you get from your cleaning skill, the duration won't be modified to be more than the base duration.
	var/skill_duration_modifier_offset = 0
	/// Determines what this cleaner can wash off, [the available options are found here](code/__DEFINES/cleaning.html).
	var/cleaning_strength = CLEAN_SCRUB
	/// Multiplies the cleaning skill experience gained from cleaning.
	var/experience_gain_modifier = 1

/**
 * Creates a new cleaner.
 *
 * Arguments
 * * on_cleaned_callback the callback that should be called when something is cleaned successfully
 */

/datum/cleaner/New(datum/callback/on_cleaned_callback = null)
	src.on_cleaned_callback = on_cleaned_callback

/**
 * Cleans something using this cleaner.
 * The cleaning duration is modified by the cleaning skill of the user.
 * Successfully cleaning gives cleaning experience to the user and invokes the on_cleaned_callback.
 *
 * Arguments
 * * target the thing being cleaned
 * * user the person doing the cleaning
 */
/datum/cleaner/proc/clean(atom/target as obj|turf|area, mob/living/user)
	//set the cleaning duration
	var/cleaning_duration = base_cleaning_duration
	if(user.mind) //higher cleaning skill can make the duration shorter
		//offsets the multiplier you get from cleaning skill, but doesn't allow the duration to be longer than the base duration
		cleaning_duration = cleaning_duration * min(user.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER)+skill_duration_modifier_offset,1)

	//do the cleaning
	user.visible_message(span_notice("[user] starts to clean [target]!"), span_notice("You start to clean [target]..."))
	if(do_after(user, cleaning_duration, target = target))
		user.visible_message(span_notice("[user] finishes cleaning [target]!"), span_notice("You finish cleaning [target]."))
		if(isturf(target)) //cleaning the floor and every bit of filth on top of it
			for(var/obj/effect/decal/cleanable/cleanable_decal in target) //it's important to do this before you wash all of the cleanables off
				user.mind?.adjust_experience(/datum/skill/cleaning, round((cleanable_decal.beauty / CLEAN_SKILL_BEAUTY_ADJUSTMENT) * experience_gain_modifier))
		else if(istype(target, /obj/structure/window)) //window cleaning
			target.set_opacity(initial(target.opacity))
			target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			var/obj/structure/window/window = target
			if(window.bloodied)
				for(var/obj/effect/decal/cleanable/blood/iter_blood in window)
					window.vis_contents -= iter_blood
					qdel(iter_blood)
					window.bloodied = FALSE
		user.mind?.adjust_experience(/datum/skill/cleaning, round(CLEAN_SKILL_GENERIC_WASH_XP * experience_gain_modifier))
		target.wash(cleaning_strength)
		on_cleaned_callback?.Invoke(target, user)
