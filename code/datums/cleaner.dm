/datum/cleaner
	/// Gets called when trying to clean something, the cleaning will be cancelled if this callback returns false.
	var/datum/callback/clean_start_callback
	/// Gets called when something is successfully cleaned.
	var/datum/callback/on_cleaned_callback
	/// The time it takes to clean something, without reductions from the cleaning skill modifier.
	var/base_cleaning_duration = 3 SECONDS
	/// Offsets the cleaning duration modifier that you get from your cleaning skill, the duration cannot be modified to be more than the base duration.
	var/skill_speed_modifier_offset = 0
	/// Determines what this cleaner can wash off, [the available options are found here](code/__DEFINES/cleaning.html).
	var/cleaning_strength = CLEAN_SCRUB
	/// Multiplies the cleaning skill experience gained from cleaning.
	var/experience_gain_modifier = 1




/datum/cleaner/New(var/datum/callback/clean_start_callback = null, var/datum/callback/on_cleaned_callback = null)
	src.clean_start_callback = clean_start_callback
	src.on_cleaned_callback = on_cleaned_callback



/**
 * Cleans something using this cleaner.
 * The cleaning duration is modified by the cleaning skill of the user.
 * Successfully cleaning gives cleaning experience to the user.
 *
 * Arguments
 * * target the thing being cleaned
 * * user the person doing the cleaning
 */
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
	if(ishuman(target) && user.zone_selected == BODY_ZONE_PRECISE_MOUTH) //washing that potty mouth of yours
		var/mob/living/carbon/human/human_target = target
		user.visible_message(span_warning("\the [user] washes \the [target]'s mouth out!"), span_notice("You wash \the [target]'s mouth out!"))
		if(human_target.lip_style)
			user.mind?.adjust_experience(/datum/skill/cleaning, CLEAN_SKILL_GENERIC_WASH_XP)
			human_target.update_lips(null)
			if(on_cleaned_callback != null)
				on_cleaned_callback.Invoke()

	else //normal cleaning
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
			if(on_cleaned_callback != null)
				on_cleaned_callback.Invoke()


	//remove the cleaning overlay
	if(!already_cleaning)
		target.cut_overlay(GLOB.cleaning_bubbles_lower)
		target.cut_overlay(GLOB.cleaning_bubbles_higher)
		REMOVE_TRAIT(target, CURRENTLY_CLEANING, src)

//TODO use ? for callback access
//TODO write datum code comment
//TODO QOL washing walls with blood on them
//TODO apply to soap, mop, cleanbot
//TODO give this a better name (meelee_cleaner?)
//TODO move global overlays to here?