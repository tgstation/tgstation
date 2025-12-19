/datum/mood_event/conditional/see_death
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/conditional/see_death/can_effect_mob(datum/mood/home, mob/living/who, mob/dead_mob, dusted, gibbed)
	if(isnull(dead_mob))
		stack_trace("Death mood event being applied with null dead_mob")
		return FALSE

	return ..()

/datum/mood_event/conditional/see_death/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return TRUE

/datum/mood_event/conditional/see_death/add_effects(mob/dead_mob, dusted, gibbed)
	update_effect(dead_mob)

	if(HAS_TRAIT(dead_mob, TRAIT_SPAWNED_MOB))
		mood_change *= 0.25
		timeout *= 0.2

	if(HAS_PERSONALITY(owner, /datum/personality/compassionate) && mood_change < 0)
		mood_change *= 1.5
		timeout *= 1.5

	if(gibbed || dusted)
		mood_change *= 1.2
		timeout *= 1.5

	if(!description)
		if(gibbed)
			description = "%DEAD_MOB% just exploded in front of me!!"
		else if(dusted)
			description = "%DEAD_MOB% was just vaporized in front of me!!"
		else
			description = "I just saw %DEAD_MOB% die. How horrible..."

	description = capitalize(replacetext(description, "%DEAD_MOB%", get_descriptor(dead_mob)))

/// Blank proc which allows conditional effects to modify mood, timeout, or description before the main effect is applied
/datum/mood_event/conditional/see_death/proc/update_effect(mob/dead_mob)
	return

/// Checks if the dead mob is a pet
/datum/mood_event/conditional/see_death/proc/is_pet(mob/dead_mob)
	return istype(dead_mob, /mob/living/basic/pet) || ismonkey(dead_mob)

/datum/mood_event/conditional/see_death/be_refreshed(datum/mood/home, mob/dead_mob, dusted, gibbed)
	if(can_stack_effect(dead_mob))
		mood_change *= 1.5
	return ..()

/datum/mood_event/conditional/see_death/be_replaced(datum/mood/home, datum/mood_event/new_event, mob/dead_mob, dusted, gibbed)
	. = ..()
	// when blocking a new mood event (because it's lower priority), refresh ourselves instead
	if(. == BLOCK_NEW_MOOD)
		return be_refreshed(home, dead_mob, dusted, gibbed)

/// Checks if our mood can get worse by seeing another death (or better if we're weird like that)
/datum/mood_event/conditional/see_death/proc/can_stack_effect(mob/dead_mob)
	// if we're desensitized, don't stack unless it's a buff
	if(HAS_TRAIT(owner, TRAIT_DESENSITIZED) && mood_change > 0)
		return FALSE
	// if we're seeing a spawned mob die, don't stack
	if(HAS_TRAIT(dead_mob, TRAIT_SPAWNED_MOB))
		return FALSE
	return TRUE

/// Changes "I saw Joe x" to "I saw the engineer x"
/datum/mood_event/conditional/see_death/proc/get_descriptor(mob/dead_mob)
	if(is_pet(dead_mob))
		return "[dead_mob]"
	if(dead_mob.name != "Unknown" && dead_mob.mind?.assigned_role?.job_flags & JOB_CREW_MEMBER)
		return "the [LOWER_TEXT(dead_mob.mind?.assigned_role.title)]"
	return "someone"

/// Highest priority: Clown naivety about death
/datum/mood_event/conditional/see_death/naive
	priority = 100
	mood_change = 0

/datum/mood_event/conditional/see_death/naive/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return HAS_TRAIT(who, TRAIT_NAIVE) && !dusted && !gibbed

/datum/mood_event/conditional/see_death/naive/update_effect(mob/dead_mob)
	description = "Have a good nap, [get_descriptor(dead_mob)]."

/// Cultists are super brainwashed so they get buffs instead
/datum/mood_event/conditional/see_death/cult
	priority = 90
	description = "More souls for the Geometer!"
	mood_change = parent_type::mood_change * -0.5

/datum/mood_event/conditional/see_death/cult/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	if(!HAS_TRAIT(who, TRAIT_CULT_HALO))
		return FALSE
	if(HAS_TRAIT(dead_mob, TRAIT_CULT_HALO))
		return FALSE
	return TRUE

/// Revs are also brainwashed but less so
/datum/mood_event/conditional/see_death/revolutionary
	priority = 85
	mood_change = parent_type::mood_change * -0.5

/datum/mood_event/conditional/see_death/revolutionary/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return IS_REVOLUTIONARY(who) && (dead_mob.mind?.assigned_role.job_flags & JOB_HEAD_OF_STAFF)

/datum/mood_event/conditional/see_death/revolutionary/update_effect(mob/dead_mob)
	var/datum/job/possible_head_job = dead_mob.mind?.assigned_role
	description = "[possible_head_job.title ? "The [LOWER_TEXT(possible_head_job.title)]" : "Another head of staff"] is dead! Long live the revolution!"

/// Then gamers
/datum/mood_event/conditional/see_death/gamer
	priority = 80
	description = "Another one bites the dust!"
	mood_change = parent_type::mood_change * -0.5

/datum/mood_event/conditional/see_death/gamer/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return istype(who.mind?.assigned_role, /datum/job/bitrunning_glitch) || istype(who.mind?.assigned_role, /datum/job/bit_avatar)

/// People who just don't gaf
/datum/mood_event/conditional/see_death/dontcare
	priority = 40
	mood_change = 0
	timeout = parent_type::timeout * 0.5

/datum/mood_event/conditional/see_death/dontcare/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	if(HAS_PERSONALITY(who, /datum/personality/callous))
		return TRUE
	if(HAS_PERSONALITY(who, /datum/personality/animal_disliker) && is_pet(dead_mob))
		return TRUE
	return FALSE

/datum/mood_event/conditional/see_death/dontcare/update_effect(mob/dead_mob, dusted, gibbed)
	if(gibbed)
		description = "Oh, %DEAD_MOB% exploded. Now I have to get the mop."
	else if(dusted)
		description = "Oh, %DEAD_MOB% was vaporized. Now I have to get the dustpan."
	else
		description = "Oh, %DEAD_MOB% died. Shame, I guess."

/// Pets take priority over normal death moodlets
/datum/mood_event/conditional/see_death/pet
	priority = 30

/datum/mood_event/conditional/see_death/pet/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return is_pet(dead_mob)

/datum/mood_event/conditional/see_death/pet/update_effect(mob/dead_mob, dusted, gibbed)
	if(gibbed)
		description = "%DEAD_MOB% just exploded!!"
	else if(dusted)
		description = "%DEAD_MOB% just vaporized!!"
	else
		description = "%DEAD_MOB% just died!!"

	// future todo : make the hop care about ian, cmo runtime, etc.
	if(HAS_PERSONALITY(owner, /datum/personality/animal_friend))
		mood_change *= 1.5
		timeout *= 1.25
	else if(!HAS_PERSONALITY(owner, /datum/personality/compassionate))
		mood_change *= 0.25
		timeout *= 0.5

/// Desensitized brings up the rear
/datum/mood_event/conditional/see_death/desensitized
	priority = 10
	mood_change = parent_type::mood_change * 0.5
	timeout = parent_type::timeout * 0.5

/datum/mood_event/conditional/see_death/desensitized/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return HAS_TRAIT(who, TRAIT_DESENSITIZED)

/datum/mood_event/conditional/see_death/desensitized/update_effect(mob/dead_mob, dusted, gibbed)
	if(gibbed)
		description = "I saw %DEAD_MOB% explode."
	else if(dusted)
		description = "I saw %DEAD_MOB% get vaporized."
	else
		description = "I saw %DEAD_MOB% die."
