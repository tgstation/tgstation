// Defines for priority levels of various conditional death moodlets.
// These are defines so it's easier to get an overview of all priority levels in one place and tweak them all in some synchronous manner

#define DESENSITIZED_PRIORITY 10
#define PET_PRIORITY 30
#define XENO_PRIORITY 35
#define DONTCARE_PRIORITY 40
#define ASHWALKER_PRIORITY 50
#define GAMER_PRIORITY 80
#define REVOLUTIONARY_PRIORITY 85
#define CULT_PRIORITY 90
#define NAIVE_PRIORITY 100

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
	update_effect(dead_mob, dusted, gibbed)

	if(HAS_TRAIT(dead_mob, TRAIT_SPAWNED_MOB))
		mood_change *= 0.25
		timeout *= 0.2

	if(mood_change < 0)
		mood_change = ceil(mood_change * max(DESENSITIZED_MINIMUM, owner.mind?.desensitized_level || 1.0))

		if(HAS_PERSONALITY(owner, /datum/personality/compassionate))
			mood_change *= 1.5
			timeout *= 1.5

	if(gibbed || dusted)
		mood_change *= 1.2
		timeout *= 1.5

	if(!description)
		if(gibbed)
			description = "%DEAD_MOB% просто взорвался напротив меня!!"
		else if(dusted)
			description = "%DEAD_MOB% просто испарился у меня на глазах!!"
		else
			description = "Я видел, как %DEAD_MOB% умер. Как ужасно..."

	description = capitalize(replacetext(description, "%DEAD_MOB%", get_descriptor(dead_mob)))

/// Blank proc which allows conditional effects to modify mood, timeout, or description before the main effect is applied
/datum/mood_event/conditional/see_death/proc/update_effect(mob/dead_mob, dusted, gibbed)
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
	if(IS_DESENSITIZED(owner) && mood_change < 0)
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
		return "[LOWER_TEXT(dead_mob.mind?.assigned_role.title)]"
	return "кто-то"

/// Highest priority: Clown naivety about death
/datum/mood_event/conditional/see_death/naive
	priority = NAIVE_PRIORITY
	mood_change = 0

/datum/mood_event/conditional/see_death/naive/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return HAS_MIND_TRAIT(who, TRAIT_NAIVE) && !dusted && !gibbed

/datum/mood_event/conditional/see_death/naive/update_effect(mob/dead_mob, dusted, gibbed)
	description = "Хорошо поспать, [get_descriptor(dead_mob)]."

/// Cultists are super brainwashed so they get buffs instead
/datum/mood_event/conditional/see_death/cult
	priority = CULT_PRIORITY
	description = "Больше душ для Геометра!"
	mood_change = parent_type::mood_change * -0.5

/datum/mood_event/conditional/see_death/cult/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	if(!HAS_TRAIT(who, TRAIT_CULT_HALO))
		return FALSE
	if(HAS_TRAIT(dead_mob, TRAIT_CULT_HALO))
		return FALSE
	return TRUE

/// Revs are also brainwashed but less so
/datum/mood_event/conditional/see_death/revolutionary
	priority = REVOLUTIONARY_PRIORITY
	mood_change = parent_type::mood_change * -0.5

/datum/mood_event/conditional/see_death/revolutionary/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return IS_REVOLUTIONARY(who) && (dead_mob.mind?.assigned_role.job_flags & JOB_HEAD_OF_STAFF)

/datum/mood_event/conditional/see_death/revolutionary/update_effect(mob/dead_mob, dusted, gibbed)
	var/datum/job/possible_head_job = dead_mob.mind?.assigned_role
	description = "[possible_head_job.title ? "[LOWER_TEXT(possible_head_job.title)]" : "Ещё один глава отдела"] мёртв! Да здравствует революция!"

/// Then gamers
/datum/mood_event/conditional/see_death/gamer
	priority = GAMER_PRIORITY
	description = "Ещё один глотает пыль!"
	mood_change = parent_type::mood_change * -0.5

/datum/mood_event/conditional/see_death/gamer/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return istype(who.mind?.assigned_role, /datum/job/bitrunning_glitch) || istype(who.mind?.assigned_role, /datum/job/bit_avatar)

/// People who just don't gaf
/datum/mood_event/conditional/see_death/dontcare
	priority = DONTCARE_PRIORITY
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
		description = "Оу, %DEAD_MOB% взорвался. Что ж, пора за шваброй."
	else if(dusted)
		description = "Оу, %DEAD_MOB% испарился. Придётся искать совок."
	else
		description = "Оу, %DEAD_MOB% умер. Досадно, наверное."

/// Ashwalkers get a small boost from sacrificing people to the necropolis spire, and don't care otherwise
/datum/mood_event/conditional/see_death/ashwalker
	priority = ASHWALKER_PRIORITY
	mood_change = 0

/datum/mood_event/conditional/see_death/ashwalker/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return HAS_TRAIT(who, TRAIT_NECROPOLIS_WORSHIP) && !HAS_TRAIT(dead_mob, TRAIT_NECROPOLIS_WORSHIP)

/datum/mood_event/conditional/see_death/ashwalker/update_effect(mob/dead_mob, dusted, gibbed)
	if(gibbed)
		description = "%DEAD_MOB% hasss been torn asssunder, glory to the Necropolisss!"
		mood_change = /datum/mood_event/conditional/see_death::mood_change * -0.5
	else if(dusted)
		description = "Oh, %DEAD_MOB% wasss vaporized."
	else
		description = "Oh, %DEAD_MOB% died. Ssshame, I guesss."

/// Pets take priority over normal death moodlets
/datum/mood_event/conditional/see_death/pet
	priority = PET_PRIORITY

/datum/mood_event/conditional/see_death/pet/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return is_pet(dead_mob)

/datum/mood_event/conditional/see_death/pet/update_effect(mob/dead_mob, dusted, gibbed)
	if(gibbed)
		description = "%DEAD_MOB% просто взорвался!!"
	else if(dusted)
		description = "%DEAD_MOB% просто испарился!!"
	else
		description = "%DEAD_MOB% просто умер!!"

	// future todo : make the hop care about ian, cmo runtime, etc.
	if(HAS_PERSONALITY(owner, /datum/personality/animal_friend))
		mood_change *= 1.5
		timeout *= 1.25
	else if(!HAS_PERSONALITY(owner, /datum/personality/compassionate))
		mood_change *= 0.25
		timeout *= 0.5

/// Small boost if you see a xenomorph die
/datum/mood_event/conditional/see_death/xeno
	priority = XENO_PRIORITY

/// Check if the passed mob is any kind of xenomorph (covering for both carbon and basic types)
/datum/mood_event/conditional/see_death/xeno/proc/is_any_xenomorph(mob/target)
	return isalien(target) || isalienadult(target) // latter proc should have coverage for basic mbos

/datum/mood_event/conditional/see_death/xeno/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	if(is_any_xenomorph(who))
		return FALSE

	if(HAS_TRAIT(who, TRAIT_XENO_HOST))
		return TRUE

	return is_any_xenomorph(dead_mob)

// Give buffs based on the type of xenomorph dying
/datum/mood_event/conditional/see_death/xeno/update_effect(mob/dead_mob, dusted, gibbed)
	// following values are in absolute value form, we make it have a positive effect later
	var/change_modifier = 0
	var/timeout_modifier = 0

	if(HAS_TRAIT(owner, TRAIT_XENO_HOST))
		handle_embryo_carrier(dead_mob)
		return

	if(islarva(dead_mob))
		change_modifier = 0.1
		timeout_modifier = 0.1
		description = "Прекрасный день, когда давят этих червей."

	if(isalienadult(dead_mob))
		change_modifier = 0.25
		timeout_modifier = 0.25
		description = "Этот ксеноморф глотает пыль. Ооо, да!!"
		if(gibbed || dusted)
			change_modifier += 0.1
			timeout_modifier += 0.1
			description = "Это согревает моё сердце, когда ксеноморфов разносят на кусочки!"

	if(isalienroyal(dead_mob) || istype(dead_mob, /mob/living/basic/alien/queen))
		change_modifier = 0.5
		timeout_modifier = 0.5
		description = "Королева пала! Галактика начнёт новую жизнь! Я надеюсь, что все эти ублюдки сгниют в аду!"
		if(gibbed || dusted)
			change_modifier += 0.25
			timeout_modifier += 0.25
			description = "Вид королевы ксеноморфов, разорванной на куски, наполняет меня огромной радостью!"


	mood_change = initial(mood_change) * -change_modifier
	timeout = initial(timeout) * timeout_modifier

/// Separate proc that handles cases where the viewer is carrying a xenomorph embryo
/datum/mood_event/conditional/see_death/xeno/proc/handle_embryo_carrier(mob/dead_mob)
	if(!HAS_TRAIT(owner, TRAIT_XENO_HOST))
		return

	var/obj/item/organ/body_egg/alien_embryo/embryo = owner.get_organ_by_type(/obj/item/organ/body_egg/alien_embryo)
	if(isnull(embryo))
		stack_trace("Xeno Host [owner] missing embryo organ despite having XENO_HOST trait. What the fuck?")
		return

	if(owner.stat != CONSCIOUS) // if the carrier is sleeping then presumably the embryo's hivemind isn't affected
		return

	// You feel a lot worse if you're conscious and see a xenomorph die while implanted because the hivemind feels the loss of their sister
	var/embryo_stage_multiplier = 1 + (embryo.stage / 10)
	mood_change *= embryo_stage_multiplier
	timeout *= embryo_stage_multiplier
	description = "Что-то внутри меня всколыхнулось после того, как я увидел смерть того ксеноморфа."
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_XENO_HOST), PROC_REF(on_embryo_removal))

/// Handles cleanup once the embryo carrier dies
/datum/mood_event/conditional/see_death/xeno/proc/on_embryo_removal(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// Desensitized brings up the rear
/datum/mood_event/conditional/see_death/desensitized
	priority = DESENSITIZED_PRIORITY
	timeout = parent_type::timeout * 0.5

/datum/mood_event/conditional/see_death/desensitized/condition_fulfilled(mob/living/who, mob/dead_mob, dusted, gibbed)
	return IS_DESENSITIZED(who)

/datum/mood_event/conditional/see_death/desensitized/update_effect(mob/dead_mob, dusted, gibbed)
	if(gibbed)
		description = "Я увидел, как %DEAD_MOB% взорвался."
	else if(dusted)
		description = "Я увидел, как %DEAD_MOB% испарился."
	else
		description = "Я увидел, как %DEAD_MOB% умер."


#undef DESENSITIZED_PRIORITY
#undef PET_PRIORITY
#undef XENO_PRIORITY
#undef DONTCARE_PRIORITY
#undef ASHWALKER_PRIORITY
#undef GAMER_PRIORITY
#undef REVOLUTIONARY_PRIORITY
#undef CULT_PRIORITY
#undef NAIVE_PRIORITY
