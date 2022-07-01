/datum/cleaner
	/// Gets called when trying to clean something, the cleaning will be cancelled if this callback returns false.
	var/datum/callback/clean_start_callback
	/// Gets called when something is successfully cleaned.
	var/datum/callback/on_cleaned_callback
	/// The time it takes to clean something, without reductions from the cleaning skill modifier.
	var/base_cleaning_duration = 10 SECONDS
	/// Offsets the cleaning duration modifier that you get from your cleaning skill, the duration cannot be modified to be more than the base duration.
	var/skill_speed_modifier_offset = 0
	/// Determines what this cleaner can wash off, [the available options are found here](code/__DEFINES/cleaning.html).
	var/cleaning_strength = CLEAN_SCRUB

/datum/cleaner/New(var/datum/callback/clean_start_callback = null, var/datum/callback/on_cleaned_callback = null)
	src.clean_start_callback = clean_start_callback
	src.on_cleaned_callback = on_cleaned_callback

/datum/cleaner/proc/clean(atom/target as obj|turf|area, mob/living/user)
	if(clean_start_callback != null)
		if(clean_start_callback.Invoke() == FALSE)
			return

	//add the cleaning overlay
	var/already_cleaning = FALSE //tracks if atom had the cleaning trait when you started cleaning
	if(HAS_TRAIT(target, CURRENTLY_CLEANING))
		already_cleaning = TRUE
	else //add the trait and overlay
		ADD_TRAIT(target, CURRENTLY_CLEANING, src)
		if(target.plane > GLOB.cleaning_bubbles_lower.plane) //check if the higher overlay is necessary
			target.add_overlay(GLOB.cleaning_bubbles_higher)
		else if(target.plane == GLOB.cleaning_bubbles_lower.plane)
			if(target.layer > GLOB.cleaning_bubbles_lower.layer)
				target.add_overlay(GLOB.cleaning_bubbles_higher)
			else
				target.add_overlay(GLOB.cleaning_bubbles_lower)
		else //(target.plane < GLOB.cleaning_bubbles_lower.plane)
			target.add_overlay(GLOB.cleaning_bubbles_lower)

	//set the cleaning duration
	var/cleaning_duration = base_cleaning_duration
	if(user.mind) //higher cleaning skill can make the duration shorter
		//offsets the multiplier you get from cleaning skill, but doesn't allow the duration to be longer than the base duration
		cleaning_duration = cleaning_duration * min(user.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER)+skill_speed_modifier_offset,1)

	//do the cleaning
	user.visible_message(span_notice("[user] starts to wipe down [target] with [src]!"), span_notice("You start to wipe down [target] with [src]..."))
	if(do_after(user, cleaning_duration, target = target))
		user.visible_message(span_notice("[user] finishes wiping off [target]!"), span_notice("You finish wiping off [target]."))
		target.wash(cleaning_strength)

	//remove the cleaning overlay
	if(!already_cleaning)
		target.cut_overlay(GLOB.cleaning_bubbles_lower)
		target.cut_overlay(GLOB.cleaning_bubbles_higher)
		REMOVE_TRAIT(target, CURRENTLY_CLEANING, src)

	if(on_cleaned_callback != null)
		on_cleaned_callback.Invoke()

//TODO give cleaning experience
//TODO change visible message
//TODO add soap features
//TODO apply to soap, mop, cleanbot
//TODO give this a better name (meelee_cleaner?)
//TODO move global overlays to here?