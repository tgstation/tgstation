#define VASSAL_SCAN_MIN_DISTANCE 5
#define VASSAL_SCAN_MAX_DISTANCE 500
/// 2s update time.
#define VASSAL_SCAN_PING_TIME (2 SECONDS)

/datum/antagonist/vassal
	name = "\improper Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	show_in_roundend = FALSE

	/// The Master Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/master
	var/datum/game_mode/blooodsucker
	/// List of all Purchased Powers, like Bloodsuckers.
	var/list/datum/action/powers = list()
	/// The favorite vassal gets unique features, and Ventrue can upgrade theirs
	var/favorite_vassal = FALSE
	/// Bloodsucker levels, but for Vassals.
	var/vassal_level

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()

/datum/antagonist/vassal/on_gain()
	/// Enslave them to their Master
	if(master)
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = master.owner.has_antag_datum(/datum/antagonist/bloodsucker)
		if(bloodsuckerdatum)
			bloodsuckerdatum.vassals |= src
		owner.enslave_mind_to_creator(master.owner.current)
	owner.current.log_message("has been vassalized by [master.owner.current]!", LOG_ATTACK, color="#960000")
	/// Give Vassal Pinpointer
	owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)
	/// Give Recuperate Power
	BuyPower(new /datum/action/bloodsucker/recuperate)
	/// Give Objectives
	var/datum/objective/bloodsucker/vassal/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective
	/// Give Vampire Language & Hud
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	update_vassal_icons_added(owner.current)
	. = ..()

/datum/antagonist/vassal/on_removal()
	/// Free them from their Master
	if(master && master.owner)
		master.vassals -= src
		owner.enslaved_to = null
	/// Remove Pinpointer
	owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)
	/// Remove ALL Traits, as long as its from BLOODSUCKER_TRAIT's source.
	for(var/all_status_traits in owner.current.status_traits)
		REMOVE_TRAIT(owner.current, all_status_traits, BLOODSUCKER_TRAIT)
	/// Remove Recuperate Power
	while(powers.len)
		var/datum/action/bloodsucker/power = pick(powers)
		powers -= power
		power.Remove(owner.current)
	/// Remove Language & Hud
	owner.current.remove_language(/datum/language/vampiric)
	update_vassal_icons_removed(owner.current)
	return ..()

/datum/antagonist/vassal/proc/add_objective(datum/objective/added_objective)
	objectives += added_objective

/datum/antagonist/vassal/proc/remove_objectives(datum/objective/removed_objective)
	objectives -= removed_objective

/datum/antagonist/vassal/greet()
	. = ..()
	to_chat(owner, span_userdanger("You are now the mortal servant of [master.owner.current], a Bloodsucker!"))
	to_chat(owner, span_boldannounce("The power of [master.owner.current.p_their()] immortal blood compels you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.\n\
		You are not required to obey any other Bloodsucker, for only [master.owner.current] is your master. The laws of Nanotrasen do not apply to you now; only your vampiric master's word must be obeyed."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You have been vassalized, becoming the mortal servant of <b>[master.owner.current]</b>, a bloodsucking vampire!<br>"
	/// Message told to your Master.
	to_chat(master.owner, span_userdanger("[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] [owner.current.p_are()] now your undying servant!"))
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	owner.current.visible_message(
		span_deconversion_message("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seem[owner.current.p_s()] calm, \
		like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self."),
	)
	to_chat(owner, span_deconversion_message("With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	/// Message told to your (former) Master.
	if(master && master.owner)
		to_chat(master.owner, span_cultbold("You feel the bond with your vassal [owner.current] has somehow been broken!"))

/// Called when we are made into the Favorite Vassal
/datum/antagonist/vassal/proc/make_favorite(mob/living/master)
	// Default stuff for all
	favorite_vassal = TRUE
	set_antag_hud(owner.current, "vassal6")
	to_chat(master, span_danger("You have turned [owner.current] into your Favorite Vassal! They will no longer be deconverted upon Mindshielding!"))
	to_chat(owner, span_notice("As Blood drips over your body, you feel closer to your Master... You are now the Favorite Vassal!"))
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = master.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.my_clan == CLAN_GANGREL)
		var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/batform = new
		owner.current.AddSpell(batform)
/// If we weren't created by a bloodsucker, then we cannot be a vassal (assigned from antag panel)
/datum/antagonist/vassal/can_be_owned(datum/mind/new_owner)
	if(!master)
		return FALSE
	return ..()

/// Used for Admin removing Vassals.
/datum/mind/proc/remove_vassal()
	var/datum/antagonist/vassal/selected_vassal = has_antag_datum(/datum/antagonist/vassal)
	if(selected_vassal)
		remove_antag_datum(/datum/antagonist/vassal)

/// When a Bloodsucker gets FinalDeath, all Vassals are freed - This is a Bloodsucker proc, not a Vassal one.
/datum/antagonist/bloodsucker/proc/FreeAllVassals()
	for(var/datum/antagonist/vassal/all_vassals in vassals)
		// Skip over any Bloodsucker Vassals, they're too far gone to have all their stuff taken away from them
		if(all_vassals.owner.has_antag_datum(/datum/antagonist/bloodsucker))
			continue
		remove_vassal(all_vassals.owner)

/// Called by FreeAllVassals()
/datum/antagonist/bloodsucker/proc/remove_vassal(datum/mind/vassal)
	vassal.remove_antag_datum(/datum/antagonist/vassal)

/// Used when your Master teaches you a new Power.
/datum/antagonist/vassal/proc/BuyPower(datum/action/bloodsucker/power)
	powers += power
	power.Grant(owner.current)

/datum/antagonist/vassal/proc/LevelUpPowers()
	for(var/datum/action/bloodsucker/power in powers)
		power.level_current++

/**
 *	# Vassal Pinpointer
 *
 *	Pinpointer that points to their Master's location at all times.
 *	Unlike the Monster hunter one, this one is permanently active, and has no power needed to activate it.
 */

/atom/movable/screen/alert/status_effect/agent_pinpointer/vassal_edition
	name = "Blood Bond"
	desc = "You always know where your master is."

/datum/status_effect/agent_pinpointer/vassal_edition
	id = "agent_pinpointer"
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/vassal_edition
	minimum_range = VASSAL_SCAN_MIN_DISTANCE
	tick_interval = VASSAL_SCAN_PING_TIME
	duration = -1
	range_fuzz_factor = 0

/datum/status_effect/agent_pinpointer/vassal_edition/on_creation(mob/living/new_owner, ...)
	..()
	var/datum/antagonist/vassal/antag_datum = new_owner.mind.has_antag_datum(/datum/antagonist/vassal)
	scan_target = antag_datum?.master?.owner?.current

/datum/status_effect/agent_pinpointer/vassal_edition/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/vassal_edition/Destroy()
	if(scan_target)
		to_chat(owner, span_notice("You've lost your master's trail."))
	return ..()

/**
 * # HUD
 */
/datum/antagonist/vassal/proc/update_vassal_icons_added(mob/living/vassal, icontype = "vassal")
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]
	hud.join_hud(vassal)
	/// Located in icons/mob/hud.dmi
	set_antag_hud(vassal, icontype)
	/// FULP ADDITION! Check prepare_huds in mob.dm to see why.

/datum/antagonist/vassal/proc/update_vassal_icons_removed(mob/living/vassal)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]
	hud.leave_hud(vassal)
	set_antag_hud(vassal, null)
