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

	antag_hud_name = "vassal"

	/// The Master Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/master
	var/datum/game_mode/blooodsucker
	/// List of all Purchased Powers, like Bloodsuckers.
	var/list/datum/action/powers = list()
	/// The favorite vassal gets unique features, and Ventrue can upgrade theirs
	var/favorite_vassal = FALSE
	/// Bloodsucker levels, but for Vassals.
	var/vassal_level
	/// Tremere Vassals only - Have I been mutated?
	var/mutilated = FALSE

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	add_team_hud(current_mob)

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

/datum/antagonist/vassal/add_team_hud(mob/target)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		image(hud_icon, target, antag_hud_name),
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
/datum/antagonist/vassal/proc/make_favorite(mob/living/master, silent = FALSE)
	// Default stuff for all
	favorite_vassal = TRUE
	antag_hud_name = "vassal6"
	if(!silent)
		to_chat(master, span_danger("You have turned [owner.current] into your Favorite Vassal! They will no longer be deconverted upon Mindshielding!"))
		to_chat(owner, span_notice("As Blood drips over your body, you feel closer to your Master... You are now the Favorite Vassal!"))
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = master.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.my_clan == CLAN_BRUJAH)
		BuyPower(new /datum/action/bloodsucker/targeted/brawn/vassal)
	if(bloodsuckerdatum.my_clan == CLAN_NOSFERATU)
		ADD_TRAIT(owner.current, TRAIT_VENTCRAWLER_NUDE, BLOODSUCKER_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_DISFIGURED, BLOODSUCKER_TRAIT)
		to_chat(owner, span_notice("Additionally, you can now ventcrawl while naked, and are permanently disfigured."))
	if(bloodsuckerdatum.my_clan == CLAN_TREMERE)
		var/datum/action/cooldown/spell/shapeshift/bat/batform = new
		batform.Grant(owner.current)
	if(bloodsuckerdatum.my_clan == CLAN_VENTRUE)
		to_chat(master, span_announce("* Bloodsucker Tip: You can now upgrade your Favorite Vassal by buckling them onto a Candelabrum!"))
		BuyPower(new /datum/action/bloodsucker/distress)
	if(bloodsuckerdatum.my_clan == CLAN_MALKAVIAN)
		var/mob/living/carbon/carbonowner = owner.current
		carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
		to_chat(owner, span_notice("Additionally, you now suffer the same fate as your Master."))

/datum/antagonist/vassal/pre_mindshield(mob/implanter, mob/living/mob_override)
	if(favorite_vassal || master.my_clan == CLAN_TREMERE)
		return COMPONENT_MINDSHIELD_RESISTED
	return COMPONENT_MINDSHIELD_PASSED

/// This is called when the antagonist is successfully mindshielded.
/datum/antagonist/vassal/on_mindshield(mob/implanter, mob/living/mob_override)
	owner.remove_antag_datum(/datum/antagonist/vassal)
	owner.current.log_message("has been deconverted from Vassalization by [implanter]!", LOG_ATTACK, color="#960000")
	return COMPONENT_MINDSHIELD_DECONVERTED

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

/datum/antagonist/vassal/proc/HandleFeeding(mob/living/carbon/target, mult=1)
	var/blood_taken = min(15, target.blood_volume) * mult
	target.blood_volume -= blood_taken
	// Simple Animals lose a LOT of blood, and take damage. This is to keep cats, cows, and so forth from giving you insane amounts of blood.
	if(!ishuman(target))
		target.blood_volume -= (blood_taken / max(target.mob_size, 0.1)) * 3.5 // max() to prevent divide-by-zero
		target.apply_damage_type(blood_taken / 3.5) // Don't do too much damage, or else they die and provide no blood nourishment.
		if(target.blood_volume <= 0)
			target.blood_volume = 0
			target.death(0)
	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	owner.current.bodytemperature = ((owner.current.blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (owner.current.blood_volume + blood_taken)
	// our volume * temp, + their volume * temp, / total volume
	///////////
	// Reduce Value Quantity
	if(target.stat == DEAD) // Penalty for Dead Blood
		blood_taken /= 3
	if(!ishuman(target)) // Penalty for Non-Human Blood
		blood_taken /= 2
	//if (!iscarbon(target)) // Penalty for Animals (they're junk food)
	// Apply to Volume
	AddBloodVolume(blood_taken)
	// Reagents (NOT Blood!)
	if(target.reagents && target.reagents.total_volume)
		target.reagents.trans_to(owner.current, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.

/datum/antagonist/vassal/proc/AddBloodVolume(value)
	owner.current.blood_volume = clamp(owner.current.blood_volume + value, 0, 560)
