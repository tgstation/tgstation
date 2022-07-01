/datum/cleaner
	var/datum/callback/clean_start_callback //cleaning will be cancelled if this returns false
	var/datum/callback/on_cleaned_callback

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

	//do the cleaning
	user.visible_message(span_notice("[user] starts to wipe down [target] with [src]!"), span_notice("You start to wipe down [target] with [src]..."))
	if(do_after(user,30, target = target))
		user.visible_message(span_notice("[user] finishes wiping off [target]!"), span_notice("You finish wiping off [target]."))
		target.wash(CLEAN_SCRUB)

	//remove the cleaning overlay
	if(!already_cleaning)
		target.cut_overlay(GLOB.cleaning_bubbles_lower)
		target.cut_overlay(GLOB.cleaning_bubbles_higher)
		REMOVE_TRAIT(target, CURRENTLY_CLEANING, src)

	if(on_cleaned_callback != null)
		on_cleaned_callback.Invoke()

//TODO apply to soap, mop, cleanbot
//TODO account for different washing strenghts
//TODO change visible message
//TODO account for cleaning speed
//TODO give cleaning experience
//TODO add soap features
//TODO give this a better name (meelee_cleaner?)
//TODO move global overlays to here?