#define VASSAL_SCAN_MIN_DISTANCE 5
#define VASSAL_SCAN_MAX_DISTANCE 500
/// 2s update time.
#define VASSAL_SCAN_PING_TIME 20

/datum/antagonist/vassal
	name = "\improper Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "vassal"
	show_in_roundend = FALSE
	hud_icon = 'monkestation/icons/bloodsuckers/bloodsucker_icons.dmi'

	/// The Master Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/master
	/// List of all Purchased Powers, like Bloodsuckers.
	var/list/datum/action/powers = list()
	///Whether this vassal is already a special type of Vassal.
	var/special_type = FALSE
	///Description of what this Vassal does.
	var/vassal_description

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.apply_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)
	current_mob.clear_mood_event("vampcandle")
	add_team_hud(current_mob)

/datum/antagonist/vassal/add_team_hud(mob/target)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/hud = team_hud_ref.resolve()

	var/list/mob/living/mob_list = list()
	mob_list += master.owner.current
	for(var/datum/antagonist/vassal/vassal as anything in master.vassals)
		mob_list += vassal.owner.current

	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if(!(antag_hud.target in mob_list))
			continue
		antag_hud.show_to(target)
		hud.show_to(antag_hud.target)

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)

/datum/antagonist/vassal/pre_mindshield(mob/implanter, mob/living/mob_override)
	return COMPONENT_MINDSHIELD_PASSED

/// This is called when the antagonist is successfully mindshielded.
/datum/antagonist/vassal/on_mindshield(mob/implanter, mob/living/mob_override)
	owner.remove_antag_datum(/datum/antagonist/vassal)
	owner.current.log_message("has been deconverted from Vassalization by [implanter]!", LOG_ATTACK, color="#960000")
	return COMPONENT_MINDSHIELD_DECONVERTED

/datum/antagonist/vassal/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER
	var/vassal_examine = return_vassal_examine(examiner)
	if(vassal_examine)
		examine_text += vassal_examine

/datum/antagonist/vassal/on_gain()
	RegisterSignal(owner.current, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))
	/// Enslave them to their Master
	if(!master || !istype(master, master))
		return
	if(special_type)
		if(!master.special_vassals[special_type])
			master.special_vassals[special_type] = list()
		master.special_vassals[special_type] |= src
	master.vassals |= src
	owner.enslave_mind_to_creator(master.owner.current)
	owner.current.log_message("has been vassalized by [master.owner.current]!", LOG_ATTACK, color="#960000")
	/// Give Recuperate Power
	BuyPower(new /datum/action/cooldown/bloodsucker/recuperate)
	/// Give Objectives
	var/datum/objective/bloodsucker/vassal/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective
	/// Give Vampire Language & Hud
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_removal()
	UnregisterSignal(owner.current, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN)
	//Free them from their Master
	if(!QDELETED(master?.owner))
		if(special_type && master.special_vassals[special_type])
			master.special_vassals[special_type] -= src
		master.vassals -= src
		owner.enslaved_to = null
	//Remove ALL Traits, as long as its from BLOODSUCKER_TRAIT's source.
	for(var/allstatus_traits in owner.current._status_traits)
		REMOVE_TRAIT(owner.current, allstatus_traits, BLOODSUCKER_TRAIT)
	//Remove Recuperate Power
	while(length(powers))
		var/datum/action/cooldown/bloodsucker/power = pick(powers)
		powers -= power
		power.Remove(owner.current)
	//Remove Language & Hud
	owner.current.remove_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

/datum/antagonist/vassal/greet()
	. = ..()
	if(silent)
		return

	to_chat(owner, span_userdanger("You are now the mortal servant of [master.owner.current], a Bloodsucker!"))
	to_chat(owner, span_boldannounce("The power of [master.owner.current.p_their()] immortal blood compels you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.\n\
		You are not required to obey any other Bloodsucker, for only [master.owner.current] is your master. The laws of Nanotrasen do not apply to you now; only your vampiric master's word must be obeyed.")) // if only there was a /p_theirs() proc...
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You, becoming the mortal servant of <b>[master.owner.current]</b>, a bloodsucking vampire!<br>"
	/// Message told to your Master.
	to_chat(master.owner, span_userdanger("[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] [owner.current.p_are()] now your undying servant!"))
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	if(silent)
		return

	owner.current.visible_message(
		span_deconversion_message("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seem[owner.current.p_s()] calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self."), \
		span_deconversion_message("With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	/// Message told to your (former) Master.
	if(master && master.owner)
		to_chat(master.owner, span_cultbold("You feel the bond with your vassal [owner.current] has somehow been broken!"))

/datum/antagonist/vassal/admin_add(datum/mind/new_owner, mob/admin)
	var/list/datum/mind/possible_vampires = list()
	for(var/datum/antagonist/bloodsucker/bloodsuckerdatums in GLOB.antagonists)
		var/datum/mind/vamp = bloodsuckerdatums.owner
		if(!vamp)
			continue
		if(!vamp.current)
			continue
		if(vamp.current.stat == DEAD)
			continue
		possible_vampires += vamp
	if(!length(possible_vampires))
		message_admins("[key_name_admin(usr)] tried vassalizing [key_name_admin(new_owner)], but there were no bloodsuckers!")
		return
	var/datum/mind/choice = input("Which bloodsucker should this vassal belong to?", "Bloodsucker") in possible_vampires
	if(!choice)
		return
	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a vassal of [key_name_admin(choice)]!")
	var/datum/antagonist/bloodsucker/vampire = choice.has_antag_datum(/datum/antagonist/bloodsucker)
	master = vampire
	new_owner.add_antag_datum(src)
	to_chat(choice, span_notice("Through divine intervention, you've gained a new vassal!"))
