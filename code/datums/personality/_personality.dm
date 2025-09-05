SUBSYSTEM_DEF(personalities)
	name = "Personalities"
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 3 SECONDS

	/// All personality singletons indexed by their type
	VAR_FINAL/list/personalities_by_type
	/// All personality singletons indexed by their savefile key
	VAR_FINAL/list/personalities_by_key
	/// List of lists of incompatible personality types.
	VAR_FINAL/list/incompatibilities

	/// For personalities which process, this tracks all mobs we need to process for
	var/list/processing_personalities = list()

/datum/controller/subsystem/personalities/Initialize()
	init_personalities()
	init_incompatibilities()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/personalities/fire(resumed)
	var/seconds_per_tick = wait / (1 SECONDS)
	for(var/datum/personality/personality as anything in processing_personalities)
		for(var/mob/living/target  as anything in processing_personalities[personality])
			if(target.stat >= UNCONSCIOUS || HAS_TRAIT(target, TRAIT_NO_TRANSFORM))
				continue
			personality.on_tick(target, seconds_per_tick)

/datum/controller/subsystem/personalities/proc/init_personalities()
	personalities_by_type = list()
	personalities_by_key = list()
	for(var/personality_type in typesof(/datum/personality))
		var/datum/personality/personality = new personality_type()
		if(isnull(personality.savefile_key))
			// No key = abstract = ignore
			continue
		if(personalities_by_key[personality.savefile_key])
			stack_trace("Personality save key collision! key: [personality.savefile_key] - new: [personality_type] - old: [personalities_by_key[personality.savefile_key]]")
			continue

		personalities_by_type[personality_type] = personality
		personalities_by_key[personality.savefile_key] = personality
		if(personality.processes)
			processing_personalities[personality] = list()

/datum/controller/subsystem/personalities/proc/init_incompatibilities()
	incompatibilities = list(
		list(
			/datum/personality/callous,
			/datum/personality/compassionate,
		),
		list(
			/datum/personality/department/analytical,
			/datum/personality/department/impulsive,
		),
		list(
			/datum/personality/introvert,
			/datum/personality/extrovert,
		),
		list(
			/datum/personality/teetotal,
			/datum/personality/bibulous,
		),
		list(
			/datum/personality/gourmand,
			/datum/personality/ascetic,
		),
		// list(
		// 	/datum/personality/authoritarian,
		// 	/datum/personality/egalitarian,
		// ),
		list(
			/datum/personality/nt/loyalist,
			/datum/personality/nt/disillusioned,
		),
		list(
			/datum/personality/hopeful,
			/datum/personality/pessimistic,
		),
		list(
			/datum/personality/compassionate,
			/datum/personality/misanthropic,
		),
		list(
			/datum/personality/misanthropic,
			/datum/personality/extrovert,
			/datum/personality/empathetic,
		),
		list(
			/datum/personality/brave,
			/datum/personality/cowardly,
		),
		list(
			/datum/personality/brave,
			/datum/personality/paranoid,
		),
		list(
			/datum/personality/slacking/lazy,
			/datum/personality/slacking/diligent,
		),
		list(
			/datum/personality/slacking/lazy,
			/datum/personality/athletic,
		),
		list(
			/datum/personality/brooding,
			/datum/personality/resilient,
		),
		// list(
		// 	/datum/personality/reckless,
		// 	/datum/personality/cautious,
		// ),
		list(
			/datum/personality/slacking/lazy,
			/datum/personality/industrious,
		),
		list(
			/datum/personality/creative,
			/datum/personality/unimaginative,
		),
		list(
			/datum/personality/hopeful,
			/datum/personality/pessimistic,
		),
		list(
			/datum/personality/humble,
			/datum/personality/prideful,
		),
		list(
			/datum/personality/erudite,
			/datum/personality/uneducated,
		),
		list(
			/datum/personality/apathetic,
			/datum/personality/sensitive,
		),
		list(
			/datum/personality/animal_friend,
			/datum/personality/animal_disliker,
			/datum/personality/cat_lover,
			/datum/personality/dog_lover,
		),
	)

/// Helper to check if the new personality type is incompatible with the passed list of personality types
/datum/controller/subsystem/personalities/proc/is_incompatible(list/personality_types, new_personality_type)
	if(!LAZYLEN(personality_types))
		return FALSE
	for(var/incompatibility in incompatibilities)
		if(!(new_personality_type in incompatibility))
			continue
		for(var/contrasting_type in personality_types)
			if(contrasting_type == new_personality_type) // You're not incompatible with yourself
				continue
			if(contrasting_type in incompatibility)
				return TRUE
	return FALSE

/// Helper to select a random list of personalities, respecting incompatibilities. REturns a list of typepaths
/datum/controller/subsystem/personalities/proc/select_random_personalities(lower_end = 1, upper_end = CONFIG_GET(number/max_personalities))
	var/list/personality_pool = personalities_by_type.Copy()
	var/list/selected_personalities = list()
	var/num = rand(lower_end, upper_end)
	var/i = 1
	while(i <= num)
		if(!length(personality_pool))
			break
		var/picked_type = pick(personality_pool)
		if(is_incompatible(selected_personalities, picked_type))
			continue
		selected_personalities += picked_type
		personality_pool -= picked_type
		i += 1
	return selected_personalities

/**
 * ## Personality Singleton
 *
 * Contains information about a personaility.
 *
 * A personality is designed to be a small modifier to the way a mob reacts to moodlets or world events.
 *
 * For example, a mob with the Callous personality would not receive a positive moodlet for saving someone's life.
 *
 * They're not meant to be full blown quirks that hold state and such.
 * If you NEED state, consider making a quirk, or moving your behavior into a component the personality applies.
 */
/datum/personality
	/// Required: Name of the personality
	var/name
	/// Required: Description of the personality.
	/// Phrased to be "In character" - i.e. "I like to help people!"
	/// Rather than OOC- i.e. "When helping people, I get a positive moodlet."
	var/desc
	/// Optional: What positive effects this personality has on gameplay.
	var/pos_gameplay_desc
	/// Optional: What negative effects this personality has on gameplay.
	var/neg_gameplay_desc
	/// Optional: What neutral effects this personality has on gameplay.
	var/neut_gameplay_desc
	/// Easy way to apply a trait as a part of a personality.
	var/personality_trait
	/// Required: The key to use when saving this personality to a savefile.
	/// Don't change it once it's set unless you want to write migration code
	var/savefile_key
	/// Does this process?
	var/processes = FALSE

/datum/personality/Destroy(force)
	if(force)
		return ..()
	stack_trace("qdel called on a personality singleton!")
	return QDEL_HINT_LETMELIVE

/// Trait source for personality traits
#define PERSONALITY_TRAIT "personality_trait"

/**
 * Called when applying this personality to a mob.
 *
 * * who - The mob to apply this personality to.
 * This mob is asserted to have `mob_mood`.
 */
/datum/personality/proc/apply_to_mob(mob/living/who)
	SHOULD_CALL_PARENT(TRUE)
	if(personality_trait)
		ADD_TRAIT(who, personality_trait, PERSONALITY_TRAIT)
	LAZYSET(who.personalities, type, TRUE)
	if(processes)
		SSpersonalities.processing_personalities[type] += who

/**
 * Called when removing this personality from a mob.
 *
 * This is not called as a part of the mob being deleted.
 *
 * * who - The mob to remove this personality from.
 * This mob is asserted to have `mob_mood`.
 */
/datum/personality/proc/remove_from_mob(mob/living/who)
	SHOULD_CALL_PARENT(TRUE)
	if(personality_trait)
		REMOVE_TRAIT(who, personality_trait, PERSONALITY_TRAIT)
	LAZYREMOVE(who.personalities, type)
	if(processes)
		SSpersonalities.processing_personalities[type] -= who

#undef PERSONALITY_TRAIT

/// Called every SSpersonality tick if `processes` is TRUE
/datum/personality/proc/on_tick(mob/living/subject, seconds_per_tick)
	CRASH("Personality [type] processed but did not override on_tick().")

/datum/personality/callous
	savefile_key = "callous"
	name = "Callous"
	desc = "I don't care much about what happens to other people."
	pos_gameplay_desc = "Does not mind seeing death"
	neg_gameplay_desc = "Prefers not to help people"

/datum/personality/compassionate
	savefile_key = "compassionate"
	name = "Compassionate"
	desc = "I like giving a hand to those in need."
	pos_gameplay_desc = "Likes helping people"
	neg_gameplay_desc = "Seeing death affects your mood more"

/datum/personality/empathetic
	savefile_key = "empathetic"
	name = "Empathetic" // according to google "empathic" means you understand other people, while "empathetic" means you feel what they feel
	desc = "Other people's feelings are important to me."
	pos_gameplay_desc = "Likes seeing other people happy"
	neg_gameplay_desc = "Dislikes seeing other people sad"

/datum/personality/misanthropic
	savefile_key = "misanthropic"
	name = "Misanthropic"
	desc = "We should have never entered the stars."
	pos_gameplay_desc = "Likes seeing other people sad"
	neg_gameplay_desc = "Dislikes seeing other people happy"

/datum/personality/department
	/// List of areas this personality applies to
	var/list/applicable_areas

/datum/personality/department/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignal(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE), PROC_REF(update_effect))
	// Unfortunate side effect here in that IC job changes, IE HoP are missed
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area, applicable_areas & who.mind?.get_work_areas())

/datum/personality/department/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE))
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area)

/// Signal handler to update our status effect when our job changes
/datum/personality/department/proc/update_effect(mob/living/source, ...)
	SIGNAL_HANDLER

	source.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area)
	source.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area, applicable_areas & source.mind.get_work_areas())

/datum/personality/department/analytical
	savefile_key = "analytical"
	name = "Analytical"
	desc = "When it comes to making decisions, I tend to be more impersonal."
	neut_gameplay_desc = "Prefers working in systemic environments like engineering, research, or medical"
	applicable_areas = list(
		/datum/job_department/engineering::primary_work_area,
		/datum/job_department/science::primary_work_area,
		/datum/job_department/medical::primary_work_area,
	)

/datum/personality/department/impulsive
	savefile_key = "impulsive"
	name = "Impulsive"
	desc = "I'm better making stuff up as I go along."
	neut_gameplay_desc = "Prefers working in social environments like cargo, command, security, or service"
	applicable_areas = list(
		/datum/job_department/cargo::primary_work_area,
		/datum/job_department/command::primary_work_area,
		/datum/job_department/security::primary_work_area,
		/datum/job_department/service::primary_work_area,
	)

// /datum/personality/morbid
// 	name = "Morbid"
// 	desc = "I am interested in more macabre things."
// 	pos_gameplay_desc = "You receive positive moodlets from abnormal and macabre things, such as death and blood."
// 	personality_trait = TRAIT_MORBID

// /datum/personality/evil
// 	name = "Evil"
// 	desc = "I'm a bad person."
// 	pos_gameplay_desc = "You receive positive moodlets from hurting people, and negative moodlets from helping them."

/datum/personality/snob
	savefile_key = "snob"
	name = "Snobbish"
	desc = "I expect only the best out of this station - anything less is unacceptable!"
	neut_gameplay_desc = "Room quality affects your mood"
	personality_trait = TRAIT_SNOB

/datum/personality/apathetic
	savefile_key = "apathetic"
	name = "Apathetic"
	desc = "I don't care about much. Not the good, nor the bad, and certainly not the ugly."
	neut_gameplay_desc = "All moodlets affect you less"

/datum/personality/apathetic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood.mood_modifier -= 0.2

/datum/personality/apathetic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood.mood_modifier += 0.2

/datum/personality/sensitive
	savefile_key = "sensitive"
	name = "Sensitive"
	desc = "I am easily affected by the world around me."
	neut_gameplay_desc = "All moodlets affect you more"

/datum/personality/sensitive/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood.mood_modifier += 0.2

/datum/personality/sensitive/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood.mood_modifier -= 0.2

/datum/personality/introvert
	savefile_key = "introvert"
	name = "Introverted"
	desc = "I prefer to be alone, reading or painting in the library."
	pos_gameplay_desc = "Likes being in the library"
	// neg_gameplay_desc = "Dislikes large groups"
	personality_trait = TRAIT_INTROVERT

/datum/personality/extrovert
	savefile_key = "extrovert"
	name = "Extroverted"
	desc = "I prefer to be surrounded by people, having a drink at the Bar."
	pos_gameplay_desc = "Likes being in the bar"
	// neg_gameplay_desc = "Dislikes being alone"
	personality_trait = TRAIT_EXTROVERT

/datum/personality/resilient
	savefile_key = "resilient"
	name = "Resilient"
	desc = "It's whatever. I can take it."
	pos_gameplay_desc = "Negative moodlets expire faster"

/datum/personality/resilient/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood.negative_moodlet_length_modifier -= 0.2

/datum/personality/resilient/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding
	savefile_key = "brooding"
	name = "Brooding"
	desc = "Everything gets to me and I can't help but think about it."
	neg_gameplay_desc = "Negative moodlets last longer"

/datum/personality/brooding/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood.negative_moodlet_length_modifier -= 0.2

/datum/personality/brave
	savefile_key = "brave"
	name = "Brave"
	desc = "It'll take a lot more than a little blood to scare me."
	pos_gameplay_desc = "Accumulate fear slower, and moodlets related to fear are weaker"

/datum/personality/cowardly
	savefile_key = "cowardly"
	name = "Cowardly"
	desc = "Everything is a danger around here! Even the air!"
	neg_gameplay_desc = "Accumulate fear faster, and moodlets related to fear are stronger"

/datum/personality/slacking
	/// Areas which are considered "slacking off"
	var/list/slacker_areas = list(
		/area/station/commons/fitness,
		/area/station/commons/lounge,
		/area/station/service/bar,
		/area/station/service/cafeteria,
		/area/station/service/library,
		/area/station/service/minibar,
		/area/station/service/theater,
	)
	/// Mood event applied when in a slacking area
	var/mood_event_type

/datum/personality/slacking/apply_to_mob(mob/living/who)
	. = ..()
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, mood_event_type, slacker_areas, CALLBACK(src, PROC_REF(is_slacking)))

/datum/personality/slacking/remove_from_mob(mob/living/who)
	. = ..()
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, mood_event_type)

/// Callback for the moodlet_in_area status effect to determine if we're slacking off
/datum/personality/slacking/proc/is_slacking(mob/living/who, area/new_area)
	if(!istype(new_area, /area/station/service))
		return TRUE
	// Service workers don't slack in service
	if(who.mind?.assigned_role.departments_bitflags & DEPARTMENT_SERVICE)
		return FALSE

	return TRUE

/datum/personality/slacking/lazy
	savefile_key = "lazy"
	name = "Lazy"
	desc = "I don't really feel like working today."
	pos_gameplay_desc = "Happy in the bar or recreation areas"
	mood_event_type = /datum/mood_event/slacking_off_lazy

/datum/personality/slacking/diligent
	savefile_key = "diligent"
	name = "Diligent"
	desc = "Things need to get done around here!"
	pos_gameplay_desc = "Happy when in their department"
	neg_gameplay_desc = "Unhappy when slacking off in the bar or recreation areas"
	mood_event_type = /datum/mood_event/slacking_off_diligent

/datum/personality/slacking/diligent/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignals(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE), PROC_REF(update_effect))
	// Unfortunate side effect here in that IC job changes, IE HoP are missed
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent, who.mind?.get_work_areas())

/datum/personality/slacking/diligent/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE))
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent)

/// Signal handler to update our status effect when our job changes
/datum/personality/slacking/diligent/proc/update_effect(mob/living/source, ...)
	SIGNAL_HANDLER

	source.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent)
	source.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent, source.mind.get_work_areas())

/datum/personality/industrious
	savefile_key = "industrious"
	name = "Industrious"
	desc = "Everyone needs to be working - otherwise we're all wasting our time."
	neg_gameplay_desc = "Dislikes playing games"

/datum/personality/athletic
	savefile_key = "athletic"
	name = "Athletic"
	desc = "Can't just sit around all day! Have to keep moving."
	pos_gameplay_desc = "Likes exercising"
	neg_gameplay_desc = "Dislikes being lazy"

// /datum/personality/greedy
// 	savefile_key = "greedy"
// 	name = "Greedy"
// 	desc = "Everything is mine, all mine!"
// 	neg_gameplay_desc = "Dislikes spending or giving away money"

/datum/personality/whimsical
	savefile_key = "whimsical"
	name = "Whimsical"
	desc = "This station is too serious sometimes, lighten up!"
	pos_gameplay_desc = "Likes ostensibly pointless but silly things, and does not mind clownish pranks"

/datum/personality/spiritual
	savefile_key = "spiritual"
	name = "Spiritual"
	desc = "I believe in a higher power."
	pos_gameplay_desc = "Likes the Chapel and the Chaplain"
	neg_gameplay_desc = "Dislikes heretical things"
	personality_trait = TRAIT_SPIRITUAL

/datum/personality/creative
	savefile_key = "creative"
	name = "Creative"
	desc = "I like expressing myself, especially in a chaotic place like this."
	pos_gameplay_desc = "Likes making art"

/datum/personality/unimaginative
	savefile_key = "unimaginative"
	name = "Unimaginative"
	desc = "I'm not good at thinking outside the box. The box is there for a reason."
	neg_gameplay_desc = "Dislikes making, seeing or hearing art"

/datum/personality/aloof
	savefile_key = "aloof"
	name = "Aloof"
	desc = "Why is everyone so touchy? I'd rather be left alone."
	neg_gameplay_desc = "Dislikes being grabbed, touched, or hugged"
	personality_trait = TRAIT_BADTOUCH

/datum/personality/aloof/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignals(who, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT), PROC_REF(uncomfortable_touch))

/datum/personality/aloof/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT))

/// Causes a negative moodlet to our quirk holder on signal
/datum/personality/aloof/proc/uncomfortable_touch(mob/living/source)
	SIGNAL_HANDLER

	if(source.stat == DEAD)
		return

	new /obj/effect/temp_visual/annoyed(source.loc)
	if(source.mob_mood.sanity <= SANITY_NEUTRAL)
		source.add_mood_event("bad_touch", /datum/mood_event/very_bad_touch)
	else
		source.add_mood_event("bad_touch", /datum/mood_event/bad_touch)

/datum/personality/hopeful
	savefile_key = "hopeful"
	name = "Hopeful"
	desc = "I believe things will always get better."
	pos_gameplay_desc = "Positive moodlets last longer"

/datum/personality/hopeful/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood.positive_moodlet_length_modifier += 0.2

/datum/personality/hopeful/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic
	savefile_key = "pessimistic"
	name = "Pessimistic"
	desc = "I believe our best days are behind us."
	neg_gameplay_desc = "Positive moodlets last shorter"

/datum/personality/pessimistic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood.positive_moodlet_length_modifier += 0.2

/datum/personality/prideful
	savefile_key = "prideful"
	name = "Prideful"
	desc = "I am proud of who I am."
	pos_gameplay_desc = "Likes success"
	neg_gameplay_desc = "Dislikes failure"

/datum/personality/humble
	savefile_key = "humble"
	name = "Humble"
	desc = "I'm just doing my job."
	neut_gameplay_desc = "Success or failure affects your mood less"

/datum/personality/aromantic
	savefile_key = "aromantic"
	name = "Aromantic"
	desc = "Romance has no place on the station."
	neg_gameplay_desc = "Dislikes kisses and hugs"
	personality_trait = TRAIT_BADTOUCH

/datum/personality/ascetic
	savefile_key = "ascetic"
	name = "Ascetic"
	desc = "I don't care much for luxurious foods. It's all fuel for the body."
	pos_gameplay_desc = "Sorrow from eating disliked food is reduced"
	neg_gameplay_desc = "Enjoyment from eating liked food is limited"

/datum/personality/gourmand
	savefile_key = "gourmand"
	name = "Gourmand"
	desc = "Food means everything to me."
	pos_gameplay_desc = "Enjoyment from eating liked food is strengthened"
	neg_gameplay_desc = "Sorrow from eating food you dislike is increased, and mediocre food is less enjoyable"

// /datum/personality/authoritarian
// 	savefile_key = "authoritarian"
// 	name = "Authoritarian"
// 	desc = "Order and discipline are the only things keeping this station running."
// 	pos_gameplay_desc = "Likes being around heads of staff"
// 	neut_gameplay_desc = "Prefers to work in positions of authority, such as a head of staff or security"

// /datum/personality/egalitarian
// 	savefile_key = "egalitarian"
// 	name = "Egalitarian"
// 	desc = "Everyone should have equal say. We are all in this together."
// 	neg_gameplay_desc = "Dislikes being around heads of staff"

/datum/personality/nt
	processes = TRUE
	/// What mood event to apply when seeing NT propaganda
	var/mood_event_type

/datum/personality/nt/proc/can_see_nt_propaganda(mob/living/subject)
	for(var/obj/structure/sign/nearby in view(subject, 5))
		if(istype(nearby, /obj/structure/sign/nanotrasen))
			return TRUE
		if(istype(nearby, /obj/structure/sign/poster/official/nanotrasen_logo))
			return TRUE

	return FALSE

/datum/personality/nt/on_tick(mob/living/subject, seconds_per_tick)
	if(can_see_nt_propaganda(subject))
		subject.add_mood_event("nt_personality", mood_event_type)
	else
		subject.clear_mood_event("nt_personality")

/datum/personality/nt/remove_from_mob(mob/living/who)
	. = ..()
	who.clear_mood_event("nt_personality")

/datum/personality/nt/loyalist
	savefile_key = "loyalist"
	name = "Loyal"
	desc = "I believe in the station and in Central Command, till the very end!"
	pos_gameplay_desc = "Likes company posters and signs"
	mood_event_type = /datum/mood_event/nt_loyalist

/datum/personality/nt/disillusioned
	savefile_key = "disillusioned"
	name = "Disillusioned"
	desc = "Nanotrasen isn't what it used to be. This isn't what I signed up for."
	neg_gameplay_desc = "Dislikes company posters and signs"
	mood_event_type = /datum/mood_event/nt_disillusioned

/datum/personality/paranoid
	savefile_key = "paranoid"
	name = "Paranoid"
	desc = "Everyone and everything is out to get me! This place is a deathtrap!"
	pos_gameplay_desc = "Likes being alone or in moderately-sized groups"
	neg_gameplay_desc = "Stressed when with one other person, or in large groups"
	processes = TRUE

/datum/personality/paranoid/remove_from_mob(mob/living/who)
	. = ..()
	who.clear_mood_event("paranoia_personality")

/datum/personality/paranoid/on_tick(mob/living/subject, seconds_per_tick)
	var/list/nearby_people = list()
	for(var/mob/living/carbon/human/nearby in view(subject, 5))
		if(nearby == subject || !is_dangerous_mob(subject, nearby))
			continue
		nearby_people += nearby

	switch(length(nearby_people))
		if(0)
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/alone)
		if(1)
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/one_on_one)
		if(2 to 6) // 6 people is roughly the size of the larger jobs like meddoc or secoff
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/small_group)
		else
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/large_group)

/datum/personality/paranoid/proc/is_dangerous_mob(mob/living/subject, mob/living/carbon/human/target)
	if(target.stat >= UNCONSCIOUS)
		return FALSE
	if(target.invisibility > subject.see_invisible || target.alpha < 20)
		return FALSE
	// things that are threatening: other players
	// things that are also threatening: monkeys
	return TRUE

/datum/personality/teetotal
	savefile_key = "teetotal"
	name = "Teetotaler"
	desc = "Alcohol isn't for me."
	neg_gameplay_desc = "Dislikes drinking alcohol"

/datum/personality/bibulous
	savefile_key = "bibulous"
	name = "Bibulous"
	desc = "I'll always go for another round of drinks!"
	pos_gameplay_desc = "Fulfillment from drinking lasts longer, even after you are no longer drunk"

// /datum/personality/reckless
// 	savefile_key = "reckless"
// 	name = "Reckless"
// 	desc = "What is life without a little danger?"
// 	pos_gameplay_desc = "Likes doing risky things"

// /datum/personality/cautious
// 	savefile_key = "cautious"
// 	name = "Cautious"
// 	desc = "Risks are foolish on a station as deadly as this."
// 	neg_gameplay_desc = "Dislikes doing risky things"

/datum/personality/gambler
	savefile_key = "gambler"
	name = "Gambler"
	desc = "Throwing the dice is always worth it!"
	pos_gameplay_desc = "Likes gambling and card games, and content with losing when gambling"

/datum/personality/erudite
	savefile_key = "erudite"
	name = "Erudite"
	desc = "Knowledge is power. Especially this deep in space."
	pos_gameplay_desc = "Likes reading books"

/datum/personality/uneducated
	savefile_key = "uneducated"
	name = "Uneducated"
	desc = "I don't care much for books. Already know everything I need to know."
	neg_gameplay_desc = "Dislikes reading books"

/datum/personality/animal_friend
	savefile_key = "animal_friend"
	name = "Animal Friend"
	desc = "I love animals!"
	pos_gameplay_desc = "Likes being around pets"

/datum/personality/cat_lover
	savefile_key = "cat_lover"
	name = "Cat Lover"
	desc = "Cats are so cute!"
	pos_gameplay_desc = "Likes being around cats"
	neg_gameplay_desc = "Dislikes being around dogs"

/datum/personality/dog_lover
	savefile_key = "dog_lover"
	name = "Dog Lover"
	desc = "Dogs are the best!"
	pos_gameplay_desc = "Likes being around dogs"
	neg_gameplay_desc = "Dislikes being around cats"

/datum/personality/animal_disliker
	savefile_key = "animal_disliker"
	name = "Animal Averse"
	desc = "We can barely survive on this station, and you want to keep a pet?"
	neg_gameplay_desc = "Dislikes being around pets"
