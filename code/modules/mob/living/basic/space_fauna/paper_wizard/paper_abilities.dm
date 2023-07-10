/datum/action/cooldown/spell/conjure/wizard_summon_minions
	name = "Summon Minions"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "art_summon"
	invocation = "Rise, my creations! Jump off your pages and into this realm!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cooldown_time = 15 SECONDS
	summon_type = list(
		/mob/living/basic/stickman,
		/mob/living/basic/stickman/ranged,
		/mob/living/basic/stickman/dog,
	)
	summon_radius = 1
	summon_amount = 2
	///How many minions we summoned
	var/summoned_minions = 0
	///How many minions we can have at once
	var/max_minions = 6


/datum/action/cooldown/spell/conjure/wizard_summon_minions/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(summoned_minions >= max_minions)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/conjure/wizard_summon_minions/post_summon(atom/summoned_object, atom/cast_on)
	var/mob/living/chosen_minion = summoned_object
	RegisterSignals(chosen_minion, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(lost_minion))
	summoned_minions++

/datum/action/cooldown/spell/conjure/wizard_summon_minions/proc/lost_minion(mob/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	summoned_minions--

/datum/action/cooldown/spell/pointed/wizard_mimic
	name = "Craft Mimicry"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	invocation = "My craft defines me, you could even say it IS me!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cooldown_time = 25 SECONDS
	///when the clones will die
	var/clone_lifespan = 15 SECONDS
	///list of clones
	var/list/copies = list()

/datum/action/cooldown/spell/pointed/wizard_mimic/Grant(mob/grant_to)
	. = ..()
	if(!owner)
		return
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(delete_clones))

/datum/action/cooldown/spell/pointed/wizard_mimic/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/wizard_mimic/cast(mob/living/cast_on)
	. = ..()
	var/list/directions = GLOB.cardinals.Copy()
	for(var/i in 1 to 3)
		var/mob/living/basic/paper_wizard/copy/copy = new (get_step(cast_on, pick_n_take(directions)))
		invocation(copy)
		RegisterSignals(copy, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(lost_minion))
		copies += copy
		QDEL_IN(copy, clone_lifespan)
	owner.forceMove(get_step(cast_on, pick_n_take(directions)))

/datum/action/cooldown/spell/pointed/wizard_mimic/proc/lost_minion(mob/living/basic/paper_wizard/copy/source)
	SIGNAL_HANDLER

	copies -= source
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(lost_minion))

/datum/action/cooldown/spell/pointed/wizard_mimic/proc/delete_clones(mob/source)
	SIGNAL_HANDLER

	QDEL_LIST(copies)

/datum/action/cooldown/spell/pointed/wizard_mimic/Destroy()
	QDEL_LIST(copies)
	return ..()

