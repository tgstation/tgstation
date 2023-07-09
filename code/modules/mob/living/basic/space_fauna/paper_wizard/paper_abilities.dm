/datum/action/cooldown/spell/wizard_summon_minions
	name = "Summon Minions"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "art_summon"
	invocation = "Rise, my creations! Jump off your pages and into this realm!"
	spell_requirements = NONE
	cooldown_time = 15 SECONDS
	///How many minions we summoned
	var/summoned_minions = 0
	///How many minions we can have at once
	var/max_minions = 6
	///How many minions we should spawn
	var/minions_to_summon = 3


/datum/action/cooldown/spell/wizard_summon_minions/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(summoned_minions >= max_minions)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/wizard_summon_minions/cast(mob/living/cast_on)
	. = ..()
	var/list/minions = list(
		/mob/living/basic/stickman,
		/mob/living/basic/stickman/ranged,
		/mob/living/basic/stickman/dog,
	)
	var/list/directions = GLOB.cardinals.Copy()
	var/summon_amount = min(minions_to_summon, max_minions - summoned_minions)
	for(var/i in 1 to summon_amount)
		var/atom/chosen_minion = pick_n_take(minions)
		chosen_minion = new chosen_minion(get_step(owner, pick_n_take(directions)))
		RegisterSignals(chosen_minion, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(lost_minion))
		summoned_minions++

/datum/action/cooldown/spell/wizard_summon_minions/proc/lost_minion(mob/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	summoned_minions--

/datum/action/cooldown/spell/pointed/wizard_mimic
	name = "Craft Mimicry"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	invocation = "My craft defines me, you could even say it IS me!"
	spell_requirements = NONE
	cooldown_time = 25 SECONDS
	var/clone_lifespan = 15 SECONDS

/datum/action/cooldown/spell/pointed/wizard_mimic/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/wizard_mimic/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/basic/paper_wizard/wizard = owner
	var/directions = GLOB.cardinals.Copy()
	for(var/i in 1 to 3)
		var/mob/living/basic/paper_wizard/copy/copies = new (get_step(cast_on, pick_n_take(directions)))
		wizard.copies += copies
		copies.original = owner
		copies.say(invocation)
		QDEL_IN(copies, clone_lifespan)
	owner.forceMove(get_step(cast_on, pick_n_take(directions)))

